import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:uuid/uuid.dart';

import '../../data/models/deck_settings.dart';
import '../../data/models/flashcard.dart';

class ImporterService {
  final Isar isar;
  final Uuid _uuid = const Uuid();

  ImporterService(this.isar);

  Future<void> importFlashcardPackage(String zipFilePath) async {
    print("\n📦 --- INICIANDO IMPORTACIÓN DE MAZO ---");
    print("📂 Archivo: ${p.basename(zipFilePath)}");

    final tempDir = await getTemporaryDirectory();
    final uniqueSessionId = _uuid.v4();
    final extractPath = p.join(tempDir.path, 'import_$uniqueSessionId');
    final extractDir = Directory(extractPath);

    try {
      // 1) ANALIZAR ZIP
      final bytes = await File(zipFilePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final zipFileEntries = archive.files
          .where((f) => f.isFile && !f.name.contains('__MACOSX'))
          .length;

      print("📊 Entradas detectadas en ZIP: ${archive.length} (archivos reales: $zipFileEntries)");

      // 2) EXTRAER (ROBUSTO: sin overwrite silencioso)
      print("⏳ Descomprimiendo...");
      final report = await _extractArchiveSafely(archive, extractPath);

      print(
        "✅ Extracción: ${report.filesWritten} archivos, "
            "${report.dirsCreated} carpetas, "
            "${report.collisions} colisiones renombradas, "
            "${report.skipped} omitidos, "
            "${report.errors} errores.",
      );

      if (report.filesWritten < zipFileEntries) {
        print(
          "⚠️ AVISO: El ZIP contiene $zipFileEntries archivos, pero solo se escribieron ${report.filesWritten}. "
              "Si el mazo fue generado con nombres repetidos, esta versión los renombra para evitar pérdidas. "
              "Si aún faltan, puede ser que el ZIP esté corrupto o contenga entradas inválidas.",
        );
      }

      // 3) INDEXAR EXTRAÍDOS
      print("🔍 Indexando archivos extraídos...");
      if (!await extractDir.exists()) {
        throw Exception("Error crítico: No se creó la carpeta temporal.");
      }

      List<FileSystemEntity> allEntities = [];
      try {
        allEntities = await extractDir.list(recursive: true).toList();
      } catch (e) {
        print("⚠️ Error en listado recursivo nativo: $e. Intentando método manual...");
        allEntities = await _manualRecursiveList(extractDir);
      }

      print("📄 Total elementos en disco (archivos+carpetas): ${allEntities.length}");

      // 4) ENCONTRAR MANIFEST
      File? manifestFile;
      Directory? packageRoot;

      for (final entity in allEntities) {
        if (entity is File && !entity.path.contains('__MACOSX')) {
          if (p.basename(entity.path).toLowerCase() == 'manifest.json') {
            manifestFile = entity;
            packageRoot = entity.parent;
            print("✅ Manifest encontrado en: ${entity.path}");
            break;
          }
        }
      }

      if (manifestFile == null) {
        print("❌ CRÍTICO: No se encontró 'manifest.json'.");
        throw Exception("El archivo 'manifest.json' no existe en el paquete importado.");
      }

      // 5) LEER MANIFEST
      final manifestContent = await manifestFile.readAsString();
      final Map<String, dynamic> manifestData = jsonDecode(manifestContent);

      final String isoCode = (manifestData['language_id'] ?? 'unknown').toString();
      final String packName = (manifestData['pack_name'] ?? 'Importado').toString();
      final String dbFilename = (manifestData['db_filename'] ?? 'data.db').toString();

      // 6) COPIAR MULTIMEDIA + CREAR ÍNDICE (CON RUTAS RELATIVAS Y file://)
      final MediaIndex mediaIndex = await _processAllMedia(
        allEntities,
        packageRoot: packageRoot!,
        extractRoot: extractDir,
      );

      // 7) ENCONTRAR DB SQLITE
      File? dbFile;
      try {
        final dbEntity = allEntities.firstWhere((e) =>
        e is File &&
            p.basename(e.path).toLowerCase() == dbFilename.toLowerCase() &&
            !e.path.contains('__MACOSX'));
        dbFile = dbEntity as File;
        print("✅ Base de datos encontrada: ${dbFile.path}");
      } catch (_) {
        throw Exception("Base de datos '$dbFilename' no encontrada en el paquete.");
      }

      final sqliteDb = await sql.openDatabase(dbFile.path, readOnly: true);

      // 8) MIGRAR SQLITE -> ISAR
      await _migrateDataToIsar(sqliteDb, isoCode, packName, mediaIndex, manifestData);

      await sqliteDb.close();
      print("🎉 Importación completada con éxito.");
    } catch (e, stackTrace) {
      print("🔴 ERROR FATAL EN IMPORTACIÓN: $e");
      print(stackTrace);
      rethrow;
    } finally {
      // Limpieza
      if (await extractDir.exists()) {
        try {
          await extractDir.delete(recursive: true);
        } catch (e) {
          print("Aviso: No se pudo borrar carpeta temporal: $e");
        }
      }
      print("🏁 --- PROCESO TERMINADO ---");
    }
  }

  // ============================================================
  //  EXTRACTION ROBUSTA (sin overwrite silencioso)
  // ============================================================

  Future<_ExtractReport> _extractArchiveSafely(Archive archive, String destPath) async {
    final destDir = Directory(destPath);
    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }

    int filesWritten = 0;
    int dirsCreated = 0;
    int collisions = 0;
    int skipped = 0;
    int errors = 0;

    for (final entry in archive.files) {
      final rawName = entry.name;

      // Ignorar basura de macOS
      if (rawName.contains('__MACOSX')) {
        skipped++;
        continue;
      }

      final normalized = _normalizeZipEntryName(rawName);
      if (normalized.isEmpty) {
        skipped++;
        continue;
      }

      final outPath = p.join(destPath, normalized);

      try {
        if (!entry.isFile) {
          // directorio
          final dir = Directory(outPath);
          if (!await dir.exists()) {
            await dir.create(recursive: true);
            dirsCreated++;
          }
          continue;
        }

        // asegurar carpeta padre
        final parentDir = Directory(p.dirname(outPath));
        if (!await parentDir.exists()) {
          await parentDir.create(recursive: true);
          dirsCreated++;
        }

        // evitar overwrite: si existe, renombrar
        String finalPath = outPath;
        if (File(finalPath).existsSync()) {
          finalPath = _makeNonCollidingPath(finalPath);
          collisions++;
        }

        final content = entry.content;
        if (content is List<int>) {
          await File(finalPath).writeAsBytes(content, flush: true);
          filesWritten++;
        } else {
          // Fallback raro
          final bytes = entry.content as List<int>;
          await File(finalPath).writeAsBytes(bytes, flush: true);
          filesWritten++;
        }
      } catch (e) {
        errors++;
        // No abortamos: seguimos para rescatar lo posible
        print("⚠️ Error extrayendo '$rawName' -> '$outPath': $e");
      }
    }

    return _ExtractReport(
      filesWritten: filesWritten,
      dirsCreated: dirsCreated,
      collisions: collisions,
      skipped: skipped,
      errors: errors,
    );
  }

  String _normalizeZipEntryName(String name) {
    // normaliza separadores
    var n = name.replaceAll('\\', '/').trim();

    // quitar / iniciales
    while (n.startsWith('/')) {
      n = n.substring(1);
    }

    if (n.isEmpty) return '';

    // proteger zip-slip
    final parts = n.split('/').where((s) => s.isNotEmpty && s != '.').toList();
    if (parts.any((s) => s == '..')) return '';

    return parts.join('/');
  }

  String _makeNonCollidingPath(String path) {
    final dir = p.dirname(path);
    final base = p.basenameWithoutExtension(path);
    final ext = p.extension(path);

    int i = 1;
    while (true) {
      final candidate = p.join(dir, "${base}_$i$ext");
      if (!File(candidate).existsSync()) return candidate;
      i++;
    }
  }

  // ============================================================
  //  MULTIMEDIA: Copia a media_assets + crea índice robusto
  // ============================================================

  Future<MediaIndex> _processAllMedia(
      List<FileSystemEntity> allEntities, {
        required Directory packageRoot,
        required Directory extractRoot,
      }) async {
    final Map<String, String> exactMap = {};
    final Map<String, String> lowerCaseMap = {};
    final Map<String, String> stemMap = {};

    final appDocDir = await getApplicationDocumentsDirectory();
    final destDir = Directory(p.join(appDocDir.path, 'media_assets'));
    if (!await destDir.exists()) await destDir.create(recursive: true);

    const allowedExt = {
      '.mp3', '.wav', '.m4a', '.aac', '.ogg', '.opus', '.flac',
      '.png', '.jpg', '.jpeg', '.webp', '.gif',
    };

    print("📂 Copiando multimedia a: ${destDir.path}");

    int count = 0;
    int skipped = 0;
    int dupKeys = 0;

    for (final entity in allEntities) {
      if (entity is! File) continue;

      final filePath = entity.path;
      if (filePath.contains('__MACOSX')) {
        skipped++;
        continue;
      }

      final fileName = p.basename(filePath);
      if (fileName.startsWith('.')) {
        skipped++;
        continue;
      }

      final lowerName = fileName.toLowerCase();
      if (lowerName == 'manifest.json' || lowerName.endsWith('.db')) {
        skipped++;
        continue;
      }

      final ext = p.extension(fileName).toLowerCase();
      if (!allowedExt.contains(ext)) {
        skipped++;
        continue;
      }

      // copiar con nombre único
      final uniqueName = "${_uuid.v4()}$ext";
      final destFile = File(p.join(destDir.path, uniqueName));
      await entity.copy(destFile.path);

      final destUri = destFile.uri.toString(); // file:///...

      count++;

      // Keys para match (basename + relativo a packageRoot + relativo a extractRoot)
      final relFromPackage = _safeRelative(entity.path, packageRoot.path);
      final relFromExtract = _safeRelative(entity.path, extractRoot.path);

      final keys = <String>{
        fileName,
        fileName.toLowerCase(),
        Uri.decodeFull(fileName).toLowerCase(),
        relFromPackage,
        relFromPackage.toLowerCase(),
        Uri.decodeFull(relFromPackage).toLowerCase(),
        relFromExtract,
        relFromExtract.toLowerCase(),
        Uri.decodeFull(relFromExtract).toLowerCase(),
      };

      // Stem keys (para wav vs mp3, etc)
      final stem1 = p.basenameWithoutExtension(fileName).toLowerCase();
      final stem2 = p.basenameWithoutExtension(relFromPackage).toLowerCase();
      final stem3 = p.basenameWithoutExtension(relFromExtract).toLowerCase();

      // Registrar en mapas (sin pisar si ya existe => más estable)
      for (final k in keys) {
        if (k.trim().isEmpty) continue;
        if (exactMap.containsKey(k)) {
          dupKeys++;
          continue;
        }
        exactMap[k] = destUri;
      }

      // lowerCaseMap mantiene compatibilidad con tu MediaIndex.find()
      for (final k in keys) {
        final lk = k.toLowerCase().trim();
        if (lk.isEmpty) continue;
        if (lowerCaseMap.containsKey(lk)) {
          dupKeys++;
          continue;
        }
        lowerCaseMap[lk] = destUri;
      }

      for (final s in {stem1, stem2, stem3}) {
        if (s.trim().isEmpty) continue;
        if (!stemMap.containsKey(s)) {
          stemMap[s] = destUri;
        } else {
          dupKeys++;
        }
      }
    }

    print("✅ Multimedia procesada: $count archivos copiados. (omitidos: $skipped, claves duplicadas: $dupKeys)");
    return MediaIndex(exactMap, lowerCaseMap, stemMap);
  }

  String _safeRelative(String fullPath, String from) {
    try {
      final rel = p.relative(fullPath, from: from);
      return rel.replaceAll('\\', '/');
    } catch (_) {
      // Fallback: basename
      return p.basename(fullPath);
    }
  }

  // ============================================================
  //  MIGRACIÓN SQLITE -> ISAR
  // ============================================================

  Future<void> _migrateDataToIsar(
      sql.Database db,
      String isoCode,
      String packName,
      MediaIndex mediaIndex,
      Map<String, dynamic> manifestData,
      ) async {
    // 1) SETTINGS
    final settings = DeckSettings()
      ..packName = packName
      ..newCardsPerDay = 20
      ..maxReviewsPerDay = 200
      ..lapseTolerance = 0
      ..useFixedIntervalOnLapse = true
      ..lapseFixedInterval = 1.0
      ..pMin = 0.90
      ..alpha = 0.10
      ..beta = 0.50
      ..offset = 0.0
      ..initialNt = 0.015
      ..learningSteps = [1.0, 4.0]
      ..enableWriteMode = false
      ..writeModeThreshold = 80
      ..writeModeMaxReps = 0;

    // Sobreescribir con manifest.settings si existe
    if (manifestData.containsKey('settings')) {
      final Map<String, dynamic> custom = Map<String, dynamic>.from(manifestData['settings']);

      print("⚙️ Aplicando configuraciones personalizadas del mazo...");

      if (custom['new_cards_per_day'] != null) settings.newCardsPerDay = custom['new_cards_per_day'];
      if (custom['max_reviews_per_day'] != null) settings.maxReviewsPerDay = custom['max_reviews_per_day'];

      if (custom['lapse_tolerance'] != null) settings.lapseTolerance = custom['lapse_tolerance'];
      if (custom['use_fixed_interval_on_lapse'] != null) settings.useFixedIntervalOnLapse = custom['use_fixed_interval_on_lapse'];
      if (custom['lapse_fixed_interval'] != null) settings.lapseFixedInterval = (custom['lapse_fixed_interval'] as num).toDouble();

      if (custom['p_min'] != null) settings.pMin = (custom['p_min'] as num).toDouble();
      if (custom['alpha'] != null) settings.alpha = (custom['alpha'] as num).toDouble();
      if (custom['beta'] != null) settings.beta = (custom['beta'] as num).toDouble();
      if (custom['offset'] != null) settings.offset = (custom['offset'] as num).toDouble();
      if (custom['initial_nt'] != null) settings.initialNt = (custom['initial_nt'] as num).toDouble();

      if (custom['learning_steps'] != null) {
        settings.learningSteps = (custom['learning_steps'] as List).map((e) => (e as num).toDouble()).toList();
      }

      if (custom['enable_write_mode'] != null) settings.enableWriteMode = custom['enable_write_mode'];
      if (custom['write_mode_threshold'] != null) settings.writeModeThreshold = custom['write_mode_threshold'];
      if (custom['write_mode_max_reps'] != null) settings.writeModeMaxReps = custom['write_mode_max_reps'];
    }

    await isar.writeTxn(() async {
      await isar.deckSettings.putByIndex('packName', settings);
    });

    // 2) TARJETAS
    final rows = await db.query('flashcards');
    print("🗄️ Importando ${rows.length} registros de la base de datos...");

    final double initialNtValue = settings.initialNt;
    final List<double> initialQueueValue = settings.learningSteps;

    final List<Flashcard> batchToSave = [];

    int missingWordAudio = 0;
    int missingSentenceAudio = 0;
    int missingImages = 0;

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];

      final String? audioPath = mediaIndex.find(row['AUDIO_PALABRA']?.toString());
      final String? sentenceAudioPath = mediaIndex.find(row['AUDIO_ORACION']?.toString());
      final String? imagePath = mediaIndex.find(row['IMAGEN']?.toString());

      if (row['AUDIO_PALABRA'] != null && audioPath == null) {
        missingWordAudio++;
        print("⚠️ Audio palabra faltante fila ${i + 1}: '${row['AUDIO_PALABRA']}'");
      }
      if (row['AUDIO_ORACION'] != null && sentenceAudioPath == null) {
        missingSentenceAudio++;
        // no spamear demasiado
        if (missingSentenceAudio <= 20) {
          print("⚠️ Audio oración faltante fila ${i + 1}: '${row['AUDIO_ORACION']}'");
        }
      }
      if (row['IMAGEN'] != null && imagePath == null) {
        missingImages++;
      }

      final originalId = row['ID']?.toString() ?? _uuid.v4();

      final cardRecog = Flashcard()
        ..originalId = originalId
        ..isoCode = isoCode
        ..packName = packName
        ..cardType = "${isoCode}_recog"
        ..question = (row['PALABRA'] ?? '').toString()
        ..answer = (row['SIGNIFICADO'] ?? '').toString()
        ..audioPath = audioPath
        ..imagePath = imagePath
        ..sentenceAudioPath = sentenceAudioPath
        ..sentence = row['ORACION']?.toString()
        ..translation = row['TRADUCCION']?.toString()
        ..state = CardState.newCard
        ..extraDataJson = jsonEncode({
          "reading": row['LECTURA_PALABRA'],
          "sentence_reading": row['LECTURA_ORACION'],
          "forms": row['FORMAS'],
          "type": "recognition"
        })
        ..decayRate = initialNtValue
        ..fixedPhaseQueue = List.from(initialQueueValue)
        ..learningStep = 0
        ..consecutiveLapses = 0
        ..lastReview = DateTime.now();

      final cardProd = Flashcard()
        ..originalId = originalId
        ..isoCode = isoCode
        ..packName = packName
        ..cardType = "${isoCode}_prod"
        ..question = (row['SIGNIFICADO'] ?? '').toString()
        ..answer = (row['PALABRA'] ?? '').toString()
        ..audioPath = audioPath
        ..imagePath = imagePath
        ..sentenceAudioPath = sentenceAudioPath
        ..sentence = row['TRADUCCION']?.toString()
        ..translation = row['ORACION']?.toString()
        ..state = CardState.newCard
        ..extraDataJson = jsonEncode({
          "target_reading": row['LECTURA_PALABRA'],
          "forms": row['FORMAS'],
          "type": "production"
        })
        ..decayRate = initialNtValue
        ..fixedPhaseQueue = List.from(initialQueueValue)
        ..learningStep = 0
        ..consecutiveLapses = 0
        ..lastReview = DateTime.now();

      batchToSave.add(cardRecog);
      batchToSave.add(cardProd);
    }

    await isar.writeTxn(() async {
      await isar.flashcards.putAll(batchToSave);
    });

    print("🎉 Importación de ${batchToSave.length} tarjetas completada con éxito.");
    print(
      "🔎 Diagnóstico media: "
          "audio palabra faltante=$missingWordAudio, "
          "audio oración faltante=$missingSentenceAudio, "
          "imágenes faltantes=$missingImages",
    );
  }

  // ============================================================
  //  Helper listado manual
  // ============================================================

  Future<List<FileSystemEntity>> _manualRecursiveList(Directory dir) async {
    final List<FileSystemEntity> files = [];
    await for (final entity in dir.list(recursive: false)) {
      files.add(entity);
      if (entity is Directory) {
        files.addAll(await _manualRecursiveList(entity));
      }
    }
    return files;
  }
}

class _ExtractReport {
  final int filesWritten;
  final int dirsCreated;
  final int collisions;
  final int skipped;
  final int errors;

  const _ExtractReport({
    required this.filesWritten,
    required this.dirsCreated,
    required this.collisions,
    required this.skipped,
    required this.errors,
  });
}

// ============================================================
//  Clase índice media (más tolerante)
// ============================================================

class MediaIndex {
  final Map<String, String> exactMap;
  final Map<String, String> lowerCaseMap;
  final Map<String, String> stemMap;

  MediaIndex(this.exactMap, this.lowerCaseMap, this.stemMap);

  String? find(String? filename) {
    if (filename == null || filename.trim().isEmpty) return null;
    var clean = filename.trim();

    // Si viene como file://..., intentar extraer nombre/ruta
    if (clean.startsWith('file://')) {
      try {
        final uri = Uri.parse(clean);
        clean = uri.path.replaceAll('\\', '/');
      } catch (_) {}
    }

    // 1) exacto
    if (exactMap.containsKey(clean)) return exactMap[clean];

    // 2) decodificado
    try {
      final decoded = Uri.decodeFull(clean);
      if (exactMap.containsKey(decoded)) return exactMap[decoded];
    } catch (_) {}

    // 3) minúsculas
    final lower = clean.toLowerCase();
    if (lowerCaseMap.containsKey(lower)) return lowerCaseMap[lower];

    // 4) minúsculas decodificado
    try {
      final decodedLower = Uri.decodeFull(clean).toLowerCase();
      if (lowerCaseMap.containsKey(decodedLower)) return lowerCaseMap[decodedLower];
    } catch (_) {}

    // 5) stem (ignora extensión)
    final stem = p.basenameWithoutExtension(clean).toLowerCase();
    if (stemMap.containsKey(stem)) return stemMap[stem];

    // 6) stem por basename si venía con ruta
    final baseStem = p.basenameWithoutExtension(p.basename(clean)).toLowerCase();
    if (stemMap.containsKey(baseStem)) return stemMap[baseStem];

    return null;
  }
}
