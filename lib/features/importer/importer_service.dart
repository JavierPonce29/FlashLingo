import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:uuid/uuid.dart';

import '../../data/models/deck_settings.dart';
import '../../data/models/flashcard.dart';

enum ImportDeckConflictAction {
  createNewDeck,
  updateExistingDeck,
}

class ImportExecutionOptions {
  final ImportDeckConflictAction action;

  /// Solo se usa cuando [action] es [ImportDeckConflictAction.createNewDeck].
  /// Permite renombrar el mazo importado para evitar conflicto.
  final String? customPackName;

  /// Si se está actualizando un mazo existente:
  /// - false (recomendado): conserva la configuración del usuario
  /// - true: reemplaza la configuración del mazo con la del manifest importado
  final bool updateDeckSettingsFromManifest;

  const ImportExecutionOptions({
    required this.action,
    this.customPackName,
    this.updateDeckSettingsFromManifest = false,
  });

  const ImportExecutionOptions.createNew({
    this.customPackName,
  })  : action = ImportDeckConflictAction.createNewDeck,
        updateDeckSettingsFromManifest = false;

  const ImportExecutionOptions.updateExisting({
    this.updateDeckSettingsFromManifest = false,
  })  : action = ImportDeckConflictAction.updateExistingDeck,
        customPackName = null;
}

class ImportPreviewResult {
  final String zipFilePath;
  final String zipFileName;

  final String importedPackName;
  final String isoCode;
  final String dbFilename;

  final bool deckNameExists;
  final int sqliteRows;
  final int estimatedCardsToImport;

  final int zipEntriesTotal;
  final int zipRealFileEntries;

  const ImportPreviewResult({
    required this.zipFilePath,
    required this.zipFileName,
    required this.importedPackName,
    required this.isoCode,
    required this.dbFilename,
    required this.deckNameExists,
    required this.sqliteRows,
    required this.estimatedCardsToImport,
    required this.zipEntriesTotal,
    required this.zipRealFileEntries,
  });

  @override
  String toString() {
    return 'ImportPreviewResult(pack="$importedPackName", exists=$deckNameExists, '
        'rows=$sqliteRows, cards=$estimatedCardsToImport)';
  }
}

class ImportSummary {
  final String zipFilePath;
  final String zipFileName;
  final String importedPackName;
  final String finalPackName;
  final String isoCode;
  final ImportDeckConflictAction action;

  final bool targetDeckExistedBeforeImport;

  final int sqliteRowsRead;
  final int cardsProcessed;
  final int cardsCreated;
  final int cardsUpdated;
  final int cardsUnchanged;
  final int duplicateLogicalCardsInImport;
  final int existingCardsNotPresentInImport;

  final bool deckSettingsCreated;
  final bool deckSettingsUpdated;
  final bool deckSettingsPreserved;

  final int missingWordAudio;
  final int missingSentenceAudio;
  final int missingImages;

  final int zipEntriesTotal;
  final int zipRealFileEntries;
  final int extractedFilesWritten;
  final int extractedDirsCreated;
  final int extractedCollisions;
  final int extractedSkipped;
  final int extractedErrors;

  final int mediaFilesCopied;
  final int mediaFilesSkipped;
  final int mediaDuplicateKeys;

  const ImportSummary({
    required this.zipFilePath,
    required this.zipFileName,
    required this.importedPackName,
    required this.finalPackName,
    required this.isoCode,
    required this.action,
    required this.targetDeckExistedBeforeImport,
    required this.sqliteRowsRead,
    required this.cardsProcessed,
    required this.cardsCreated,
    required this.cardsUpdated,
    required this.cardsUnchanged,
    required this.duplicateLogicalCardsInImport,
    required this.existingCardsNotPresentInImport,
    required this.deckSettingsCreated,
    required this.deckSettingsUpdated,
    required this.deckSettingsPreserved,
    required this.missingWordAudio,
    required this.missingSentenceAudio,
    required this.missingImages,
    required this.zipEntriesTotal,
    required this.zipRealFileEntries,
    required this.extractedFilesWritten,
    required this.extractedDirsCreated,
    required this.extractedCollisions,
    required this.extractedSkipped,
    required this.extractedErrors,
    required this.mediaFilesCopied,
    required this.mediaFilesSkipped,
    required this.mediaDuplicateKeys,
  });
}

class ImportConflictException implements Exception {
  final ImportPreviewResult preview;

  ImportConflictException(this.preview);

  @override
  String toString() {
    return 'Ya existe un mazo con el nombre "${preview.importedPackName}". '
        'Debes elegir actualizar el mazo existente o crear uno nuevo con otro nombre.';
  }
}

class ImporterService {
  final Isar isar;
  final Uuid _uuid = const Uuid();

  ImporterService(this.isar);

  // ---------------------------------------------------------------------------
  // API pública
  // ---------------------------------------------------------------------------

  /// Mantiene compatibilidad con la UI actual:
  /// - Si no hay conflicto de nombre: importa como mazo nuevo
  /// - Si hay conflicto: lanza [ImportConflictException] (la UI futura decidirá)
  Future<void> importFlashcardPackage(String zipFilePath) async {
    final preview = await previewFlashcardPackage(zipFilePath);
    if (preview.deckNameExists) {
      throw ImportConflictException(preview);
    }

    await importFlashcardPackageAdvanced(
      zipFilePath,
      options: const ImportExecutionOptions.createNew(),
    );
  }

  /// Lee el paquete y devuelve metadatos para que la UI pueda decidir:
  /// actualizar mazo existente o crear uno nuevo con otro nombre.
  Future<ImportPreviewResult> previewFlashcardPackage(String zipFilePath) async {
    final prepared = await _preparePackage(zipFilePath, copyMedia: false);

    try {
      final sqliteDb = await sql.openDatabase(prepared.dbFile.path, readOnly: true);
      try {
        final rows = await sqliteDb.rawQuery('SELECT COUNT(*) AS c FROM flashcards');
        final sqliteRows = (rows.isNotEmpty ? (rows.first['c'] as int?) : null) ?? 0;
        final exists = await _deckExistsByName(prepared.packName);

        return ImportPreviewResult(
          zipFilePath: zipFilePath,
          zipFileName: p.basename(zipFilePath),
          importedPackName: prepared.packName,
          isoCode: prepared.isoCode,
          dbFilename: prepared.dbFilename,
          deckNameExists: exists,
          sqliteRows: sqliteRows,
          estimatedCardsToImport: sqliteRows * 2,
          zipEntriesTotal: prepared.archiveEntriesTotal,
          zipRealFileEntries: prepared.archiveRealFileEntries,
        );
      } finally {
        await sqliteDb.close();
      }
    } finally {
      await _cleanupExtractDir(prepared.extractDir);
    }
  }

  /// Importación avanzada con resolución explícita de conflicto.
  /// Devuelve un resumen para mostrar en pantalla al finalizar.
  Future<ImportSummary> importFlashcardPackageAdvanced(
      String zipFilePath, {
        required ImportExecutionOptions options,
      }) async {
    final prepared = await _preparePackage(zipFilePath, copyMedia: true);

    sql.Database? sqliteDb;
    try {
      final importedPackName = prepared.packName;
      final targetPackName = _resolveTargetPackName(importedPackName, options);

      final targetExists = await _deckExistsByName(targetPackName);

      if (options.action == ImportDeckConflictAction.createNewDeck && targetExists) {
        // Si el usuario intentó crear nuevo con nombre ya existente, detenemos.
        final preview = ImportPreviewResult(
          zipFilePath: zipFilePath,
          zipFileName: p.basename(zipFilePath),
          importedPackName: importedPackName,
          isoCode: prepared.isoCode,
          dbFilename: prepared.dbFilename,
          deckNameExists: true,
          sqliteRows: 0,
          estimatedCardsToImport: 0,
          zipEntriesTotal: prepared.archiveEntriesTotal,
          zipRealFileEntries: prepared.archiveRealFileEntries,
        );
        throw ImportConflictException(preview);
      }

      if (options.action == ImportDeckConflictAction.updateExistingDeck && !targetExists) {
        throw Exception(
          'No existe un mazo llamado "$targetPackName" para actualizar. '
              'Importa como mazo nuevo o revisa el nombre.',
        );
      }

      sqliteDb = await sql.openDatabase(prepared.dbFile.path, readOnly: true);

      final mergeSummary = await _migrateDataToIsar(
        sqliteDb,
        prepared.isoCode,
        importedPackName,
        targetPackName,
        prepared.mediaResult?.index ?? MediaIndex({}, {}, {}),
        prepared.manifestData,
        options: options,
        targetDeckExistedBeforeImport: targetExists,
      );

      final summary = ImportSummary(
        zipFilePath: zipFilePath,
        zipFileName: p.basename(zipFilePath),
        importedPackName: importedPackName,
        finalPackName: targetPackName,
        isoCode: prepared.isoCode,
        action: options.action,
        targetDeckExistedBeforeImport: targetExists,
        sqliteRowsRead: mergeSummary.sqliteRowsRead,
        cardsProcessed: mergeSummary.cardsProcessed,
        cardsCreated: mergeSummary.cardsCreated,
        cardsUpdated: mergeSummary.cardsUpdated,
        cardsUnchanged: mergeSummary.cardsUnchanged,
        duplicateLogicalCardsInImport: mergeSummary.duplicateLogicalCardsInImport,
        existingCardsNotPresentInImport: mergeSummary.existingCardsNotPresentInImport,
        deckSettingsCreated: mergeSummary.deckSettingsCreated,
        deckSettingsUpdated: mergeSummary.deckSettingsUpdated,
        deckSettingsPreserved: mergeSummary.deckSettingsPreserved,
        missingWordAudio: mergeSummary.missingWordAudio,
        missingSentenceAudio: mergeSummary.missingSentenceAudio,
        missingImages: mergeSummary.missingImages,
        zipEntriesTotal: prepared.archiveEntriesTotal,
        zipRealFileEntries: prepared.archiveRealFileEntries,
        extractedFilesWritten: prepared.extractReport.filesWritten,
        extractedDirsCreated: prepared.extractReport.dirsCreated,
        extractedCollisions: prepared.extractReport.collisions,
        extractedSkipped: prepared.extractReport.skipped,
        extractedErrors: prepared.extractReport.errors,
        mediaFilesCopied: prepared.mediaResult?.copied ?? 0,
        mediaFilesSkipped: prepared.mediaResult?.skipped ?? 0,
        mediaDuplicateKeys: prepared.mediaResult?.duplicateKeys ?? 0,
      );

      print("🎉 Importación completada con éxito.");
      print("📌 Resumen: creadas=${summary.cardsCreated}, actualizadas=${summary.cardsUpdated}, "
          "sin cambios=${summary.cardsUnchanged}");

      return summary;
    } catch (e, st) {
      print("🔴 ERROR FATAL EN IMPORTACIÓN: $e");
      print(st);
      rethrow;
    } finally {
      if (sqliteDb != null) {
        await sqliteDb.close();
      }
      await _cleanupExtractDir(prepared.extractDir);
      print("🏁 --- PROCESO TERMINADO ---");
    }
  }

  // ---------------------------------------------------------------------------
  // Preparación del paquete (ZIP -> extracción -> manifest -> DB -> media opcional)
  // ---------------------------------------------------------------------------

  Future<_PreparedImportPackage> _preparePackage(
      String zipFilePath, {
        required bool copyMedia,
      }) async {
    print("\n📦 --- INICIANDO IMPORTACIÓN DE MAZO ---");
    print("📂 Archivo: ${p.basename(zipFilePath)}");

    final tempDir = await getTemporaryDirectory();
    final uniqueSessionId = _uuid.v4();
    final extractPath = p.join(tempDir.path, 'import_$uniqueSessionId');
    final extractDir = Directory(extractPath);

    // 1) Analizar ZIP
    final bytes = await File(zipFilePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final zipFileEntries = archive.files
        .where((f) => f.isFile && !f.name.contains('__MACOSX'))
        .length;

    print("📊 Entradas detectadas en ZIP: ${archive.length} (archivos reales: $zipFileEntries)");

    // 2) Extraer (robusto)
    print("⏳ Descomprimiendo...");
    final extractReport = await _extractArchiveSafely(archive, extractPath);

    print(
      "✅ Extracción: ${extractReport.filesWritten} archivos, "
          "${extractReport.dirsCreated} carpetas, "
          "${extractReport.collisions} colisiones renombradas, "
          "${extractReport.skipped} omitidos, "
          "${extractReport.errors} errores.",
    );

    if (extractReport.filesWritten < zipFileEntries) {
      print(
        "⚠️ AVISO: El ZIP contiene $zipFileEntries archivos, pero solo se escribieron "
            "${extractReport.filesWritten}. Si el mazo tenía nombres repetidos, se renombraron "
            "para evitar pérdidas. Si aún faltan, el ZIP puede estar corrupto.",
      );
    }

    // 3) Indexar extraídos
    print("🔍 Indexando archivos extraídos...");
    if (!await extractDir.exists()) {
      throw Exception("Error crítico: No se creó la carpeta temporal.");
    }

    List<FileSystemEntity> allEntities;
    try {
      allEntities = await extractDir.list(recursive: true).toList();
    } catch (e) {
      print("⚠️ Error en listado recursivo nativo: $e. Intentando método manual...");
      allEntities = await _manualRecursiveList(extractDir);
    }
    print("📄 Total elementos en disco (archivos+carpetas): ${allEntities.length}");

    // 4) Manifest
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

    if (manifestFile == null || packageRoot == null) {
      print("❌ CRÍTICO: No se encontró 'manifest.json'.");
      throw Exception("El archivo 'manifest.json' no existe en el paquete importado.");
    }

    final manifestContent = await manifestFile.readAsString();
    final Map<String, dynamic> manifestData = jsonDecode(manifestContent);

    final String isoCode = (manifestData['language_id'] ?? 'unknown').toString();
    final String packName = (manifestData['pack_name'] ?? 'Importado').toString();
    final String dbFilename = (manifestData['db_filename'] ?? 'data.db').toString();

    // 5) Media opcional
    _MediaProcessResult? mediaResult;
    if (copyMedia) {
      mediaResult = await _processAllMedia(
        allEntities,
        packageRoot: packageRoot,
        extractRoot: extractDir,
      );
    }

    // 6) DB SQLite
    File? dbFile;
    try {
      final dbEntity = allEntities.firstWhere(
            (e) =>
        e is File &&
            p.basename(e.path).toLowerCase() == dbFilename.toLowerCase() &&
            !e.path.contains('__MACOSX'),
      );
      dbFile = dbEntity as File;
      print("✅ Base de datos encontrada: ${dbFile.path}");
    } catch (_) {
      throw Exception("Base de datos '$dbFilename' no encontrada en el paquete.");
    }

    return _PreparedImportPackage(
      zipFilePath: zipFilePath,
      extractDir: extractDir,
      archiveEntriesTotal: archive.length,
      archiveRealFileEntries: zipFileEntries,
      extractReport: extractReport,
      allEntities: allEntities,
      packageRoot: packageRoot,
      manifestData: manifestData,
      isoCode: isoCode,
      packName: packName,
      dbFilename: dbFilename,
      dbFile: dbFile,
      mediaResult: mediaResult,
    );
  }

  String _resolveTargetPackName(String importedPackName, ImportExecutionOptions options) {
    final custom = options.customPackName?.trim();

    if (options.action == ImportDeckConflictAction.createNewDeck) {
      if (custom != null && custom.isNotEmpty) {
        return custom;
      }
      return importedPackName;
    }

    // updateExisting siempre actualiza el mazo con el nombre importado
    return importedPackName;
  }

  Future<void> _cleanupExtractDir(Directory extractDir) async {
    if (await extractDir.exists()) {
      try {
        await extractDir.delete(recursive: true);
      } catch (e) {
        print("Aviso: No se pudo borrar carpeta temporal: $e");
      }
    }
  }

  Future<bool> _deckExistsByName(String packName) async {
    final deckSettingsCount =
    await isar.deckSettings.filter().packNameEqualTo(packName).count();
    if (deckSettingsCount > 0) return true;

    final flashcardCount =
    await isar.flashcards.filter().packNameEqualTo(packName).count();
    return flashcardCount > 0;
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
          final dir = Directory(outPath);
          if (!await dir.exists()) {
            await dir.create(recursive: true);
            dirsCreated++;
          }
          continue;
        }

        final parentDir = Directory(p.dirname(outPath));
        if (!await parentDir.exists()) {
          await parentDir.create(recursive: true);
          dirsCreated++;
        }

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
          final bytes = entry.content as List<int>;
          await File(finalPath).writeAsBytes(bytes, flush: true);
          filesWritten++;
        }
      } catch (e) {
        errors++;
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
    var n = name.replaceAll('\\', '/').trim();

    while (n.startsWith('/')) {
      n = n.substring(1);
    }

    if (n.isEmpty) return '';

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

  Future<_MediaProcessResult> _processAllMedia(
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
      '.mp3',
      '.wav',
      '.m4a',
      '.aac',
      '.ogg',
      '.opus',
      '.flac',
      '.png',
      '.jpg',
      '.jpeg',
      '.webp',
      '.gif',
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

      final uniqueName = "${_uuid.v4()}$ext";
      final destFile = File(p.join(destDir.path, uniqueName));
      await entity.copy(destFile.path);

      final destUri = destFile.uri.toString(); // file:///...
      count++;

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

      final stem1 = p.basenameWithoutExtension(fileName).toLowerCase();
      final stem2 = p.basenameWithoutExtension(relFromPackage).toLowerCase();
      final stem3 = p.basenameWithoutExtension(relFromExtract).toLowerCase();

      for (final k in keys) {
        if (k.trim().isEmpty) continue;
        if (exactMap.containsKey(k)) {
          dupKeys++;
          continue;
        }
        exactMap[k] = destUri;
      }

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

    print(
      "✅ Multimedia procesada: $count archivos copiados. "
          "(omitidos: $skipped, claves duplicadas: $dupKeys)",
    );

    return _MediaProcessResult(
      index: MediaIndex(exactMap, lowerCaseMap, stemMap),
      copied: count,
      skipped: skipped,
      duplicateKeys: dupKeys,
    );
  }

  String _safeRelative(String fullPath, String from) {
    try {
      final rel = p.relative(fullPath, from: from);
      return rel.replaceAll('\\', '/');
    } catch (_) {
      return p.basename(fullPath);
    }
  }

  String? _normalizeDbRef(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    return s;
  }

  // ============================================================
  //  MIGRACIÓN SQLITE -> ISAR (nuevo / actualización)
  // ============================================================

  Future<_MergeImportSummary> _migrateDataToIsar(
      sql.Database db,
      String isoCode,
      String importedPackName,
      String targetPackName,
      MediaIndex mediaIndex,
      Map<String, dynamic> manifestData, {
        required ImportExecutionOptions options,
        required bool targetDeckExistedBeforeImport,
      }) async {
    // 1) SETTINGS
    final importedSettings = _buildDeckSettingsFromManifest(
      packName: targetPackName,
      manifestData: manifestData,
    );

    bool deckSettingsCreated = false;
    bool deckSettingsUpdated = false;
    bool deckSettingsPreserved = false;

    final existingSettings =
    await isar.deckSettings.filter().packNameEqualTo(targetPackName).findFirst();

    await isar.writeTxn(() async {
      if (existingSettings == null) {
        await isar.deckSettings.putByIndex('packName', importedSettings);
        deckSettingsCreated = true;
      } else {
        if (options.action == ImportDeckConflictAction.updateExistingDeck &&
            !options.updateDeckSettingsFromManifest) {
          deckSettingsPreserved = true;
        } else if (options.action == ImportDeckConflictAction.createNewDeck &&
            targetDeckExistedBeforeImport) {
          // En createNewDeck no deberíamos llegar aquí con conflicto, pero por seguridad:
          deckSettingsPreserved = true;
        } else {
          // Reemplazar settings por las importadas, pero conservar tracking diario
          importedSettings.id = existingSettings.id;
          importedSettings.newCardsSeenToday = existingSettings.newCardsSeenToday;
          importedSettings.lastNewCardStudyDate = existingSettings.lastNewCardStudyDate;
          await isar.deckSettings.putByIndex('packName', importedSettings);
          deckSettingsUpdated = true;
        }
      }
    });

    // 2) Leer filas SQLite
    final rows = await db.query('flashcards');
    print("🗄️ Importando ${rows.length} registros de la base de datos...");

    final double initialNtValue = importedSettings.initialNt;

    // 3) Si es actualización, cargar tarjetas existentes del mazo una vez
    final Map<String, Flashcard> existingByLogicalKey = {};
    if (options.action == ImportDeckConflictAction.updateExistingDeck) {
      final existingCards =
      await isar.flashcards.filter().packNameEqualTo(targetPackName).findAll();
      for (final c in existingCards) {
        existingByLogicalKey[_logicalKey(c.originalId, c.cardType)] = c;
      }
      print("🔎 Mazo existente '$targetPackName': ${existingCards.length} tarjetas actuales.");
    }

    final List<Flashcard> toInsert = [];
    final List<Flashcard> toUpdate = [];

    final seenImportKeys = <String>{};
    int duplicateLogicalCardsInImport = 0;
    int cardsCreated = 0;
    int cardsUpdated = 0;
    int cardsUnchanged = 0;
    int missingWordAudio = 0;
    int missingSentenceAudio = 0;
    int missingImages = 0;

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];

      final wordAudioRef = _normalizeDbRef(row['AUDIO_PALABRA']);
      final sentenceAudioRef = _normalizeDbRef(row['AUDIO_ORACION']);
      final imageRef = _normalizeDbRef(row['IMAGEN']);

      final String? audioPath = mediaIndex.find(wordAudioRef);
      final String? sentenceAudioPath = mediaIndex.find(sentenceAudioRef);
      final String? imagePath = mediaIndex.find(imageRef);

      if (wordAudioRef != null && audioPath == null) {
        missingWordAudio++;
        if (missingWordAudio <= 20) {
          print("⚠️ Audio palabra faltante fila ${i + 1}: '$wordAudioRef'");
        }
      }
      if (sentenceAudioRef != null && sentenceAudioPath == null) {
        missingSentenceAudio++;
        if (missingSentenceAudio <= 20) {
          print("⚠️ Audio oración faltante fila ${i + 1}: '$sentenceAudioRef'");
        }
      }
      if (imageRef != null && imagePath == null) {
        missingImages++;
      }

      final originalId = row['ID']?.toString() ?? _uuid.v4();

      final importedCards = _buildCardsFromRow(
        row: row,
        originalId: originalId,
        isoCode: isoCode,
        packName: targetPackName,
        audioPath: audioPath,
        sentenceAudioPath: sentenceAudioPath,
        imagePath: imagePath,
        initialNtValue: initialNtValue,
      );

      for (final imported in importedCards) {
        final key = _logicalKey(imported.originalId, imported.cardType);

        if (!seenImportKeys.add(key)) {
          duplicateLogicalCardsInImport++;
          // Nos quedamos con la última versión del ZIP si hay duplicados
        }

        if (options.action == ImportDeckConflictAction.updateExistingDeck) {
          final existing = existingByLogicalKey[key];
          if (existing == null) {
            toInsert.add(imported);
            cardsCreated++;
          } else {
            if (_importedContentDiffers(existing, imported)) {
              _applyImportedContent(existing, imported);
              toUpdate.add(existing);
              cardsUpdated++;
            } else {
              cardsUnchanged++;
            }
          }
        } else {
          toInsert.add(imported);
          cardsCreated++;
        }
      }
    }

    if (toInsert.isNotEmpty || toUpdate.isNotEmpty) {
      await isar.writeTxn(() async {
        if (toInsert.isNotEmpty) {
          await isar.flashcards.putAll(toInsert);
        }
        if (toUpdate.isNotEmpty) {
          await isar.flashcards.putAll(toUpdate);
        }
      });
    }

    final existingCardsNotPresentInImport =
    options.action == ImportDeckConflictAction.updateExistingDeck
        ? ((existingByLogicalKey.length - seenImportKeys.length).clamp(0, 1 << 30) as int)
        : 0;

    final cardsProcessed = cardsCreated + cardsUpdated + cardsUnchanged;

    print("🎉 Importación de $cardsProcessed tarjetas procesadas.");
    print(
      "🔎 Diagnóstico media: "
          "audio palabra faltante=$missingWordAudio, "
          "audio oración faltante=$missingSentenceAudio, "
          "imágenes faltantes=$missingImages",
    );

    return _MergeImportSummary(
      sqliteRowsRead: rows.length,
      cardsProcessed: cardsProcessed,
      cardsCreated: cardsCreated,
      cardsUpdated: cardsUpdated,
      cardsUnchanged: cardsUnchanged,
      duplicateLogicalCardsInImport: duplicateLogicalCardsInImport,
      existingCardsNotPresentInImport: existingCardsNotPresentInImport,
      deckSettingsCreated: deckSettingsCreated,
      deckSettingsUpdated: deckSettingsUpdated,
      deckSettingsPreserved: deckSettingsPreserved,
      missingWordAudio: missingWordAudio,
      missingSentenceAudio: missingSentenceAudio,
      missingImages: missingImages,
    );
  }

  DeckSettings _buildDeckSettingsFromManifest({
    required String packName,
    required Map<String, dynamic> manifestData,
  }) {
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
      ..newCardMinCorrectReps =
          int.tryParse((manifestData['new_card_min_correct_reps'] ?? '2').toString()) ?? 2
      ..newCardIntraDayMinutes =
          int.tryParse((manifestData['new_card_intra_day_minutes'] ?? '10').toString()) ?? 10
      ..enableWriteMode = false
      ..writeModeThreshold = 80
      ..writeModeMaxReps = 0;

    if (manifestData.containsKey('settings') && manifestData['settings'] is Map) {
      final Map<String, dynamic> custom =
      Map<String, dynamic>.from(manifestData['settings'] as Map);

      print("⚙️ Aplicando configuraciones personalizadas del mazo...");

      if (custom['new_cards_per_day'] != null) {
        settings.newCardsPerDay = (custom['new_cards_per_day'] as num).toInt();
      }
      if (custom['max_reviews_per_day'] != null) {
        settings.maxReviewsPerDay = (custom['max_reviews_per_day'] as num).toInt();
      }

      if (custom['lapse_tolerance'] != null) {
        settings.lapseTolerance = (custom['lapse_tolerance'] as num).toInt();
      }
      if (custom['use_fixed_interval_on_lapse'] != null) {
        settings.useFixedIntervalOnLapse =
        custom['use_fixed_interval_on_lapse'] as bool;
      }
      if (custom['lapse_fixed_interval'] != null) {
        settings.lapseFixedInterval =
            (custom['lapse_fixed_interval'] as num).toDouble();
      }

      if (custom['p_min'] != null) settings.pMin = (custom['p_min'] as num).toDouble();
      if (custom['alpha'] != null) settings.alpha = (custom['alpha'] as num).toDouble();
      if (custom['beta'] != null) settings.beta = (custom['beta'] as num).toDouble();
      if (custom['offset'] != null) settings.offset = (custom['offset'] as num).toDouble();
      if (custom['initial_nt'] != null) {
        settings.initialNt = (custom['initial_nt'] as num).toDouble();
      }

      if (custom['learning_steps'] != null && custom['learning_steps'] is List) {
        settings.learningSteps = (custom['learning_steps'] as List)
            .map((e) => (e as num).toDouble())
            .toList();
      }

      if (custom['enable_write_mode'] != null) {
        settings.enableWriteMode = custom['enable_write_mode'] as bool;
      }
      if (custom['write_mode_threshold'] != null) {
        settings.writeModeThreshold =
            (custom['write_mode_threshold'] as num).toInt();
      }
      if (custom['write_mode_max_reps'] != null) {
        settings.writeModeMaxReps = (custom['write_mode_max_reps'] as num).toInt();
      }
    }

    return settings;
  }

  List<Flashcard> _buildCardsFromRow({
    required Map<String, Object?> row,
    required String originalId,
    required String isoCode,
    required String packName,
    required String? audioPath,
    required String? sentenceAudioPath,
    required String? imagePath,
    required double initialNtValue,
  }) {
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
        "type": "recognition",
      })
      ..decayRate = initialNtValue
      ..fixedPhaseQueue = <double>[]
      ..learningStep = 0
      ..consecutiveLapses = 0;

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
        "type": "production",
      })
      ..decayRate = initialNtValue
      ..fixedPhaseQueue = <double>[]
      ..learningStep = 0
      ..consecutiveLapses = 0;

    return [cardRecog, cardProd];
  }

  String _logicalKey(String originalId, String cardType) => '$originalId||$cardType';

  bool _importedContentDiffers(Flashcard existing, Flashcard imported) {
    return existing.isoCode != imported.isoCode ||
        existing.packName != imported.packName ||
        existing.cardType != imported.cardType ||
        existing.question != imported.question ||
        existing.answer != imported.answer ||
        existing.audioPath != imported.audioPath ||
        existing.sentenceAudioPath != imported.sentenceAudioPath ||
        existing.imagePath != imported.imagePath ||
        existing.sentence != imported.sentence ||
        existing.translation != imported.translation ||
        existing.extraDataJson != imported.extraDataJson;
  }

  void _applyImportedContent(Flashcard target, Flashcard imported) {
    // Preservamos todo el progreso SRS/estado del usuario.
    target
      ..isoCode = imported.isoCode
      ..packName = imported.packName
      ..cardType = imported.cardType
      ..question = imported.question
      ..answer = imported.answer
      ..audioPath = imported.audioPath
      ..sentenceAudioPath = imported.sentenceAudioPath
      ..imagePath = imported.imagePath
      ..sentence = imported.sentence
      ..translation = imported.translation
      ..extraDataJson = imported.extraDataJson;
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

class _PreparedImportPackage {
  final String zipFilePath;
  final Directory extractDir;

  final int archiveEntriesTotal;
  final int archiveRealFileEntries;
  final _ExtractReport extractReport;

  final List<FileSystemEntity> allEntities;
  final Directory packageRoot;
  final Map<String, dynamic> manifestData;
  final String isoCode;
  final String packName;
  final String dbFilename;
  final File dbFile;
  final _MediaProcessResult? mediaResult;

  const _PreparedImportPackage({
    required this.zipFilePath,
    required this.extractDir,
    required this.archiveEntriesTotal,
    required this.archiveRealFileEntries,
    required this.extractReport,
    required this.allEntities,
    required this.packageRoot,
    required this.manifestData,
    required this.isoCode,
    required this.packName,
    required this.dbFilename,
    required this.dbFile,
    required this.mediaResult,
  });
}

class _MergeImportSummary {
  final int sqliteRowsRead;
  final int cardsProcessed;
  final int cardsCreated;
  final int cardsUpdated;
  final int cardsUnchanged;
  final int duplicateLogicalCardsInImport;
  final int existingCardsNotPresentInImport;

  final bool deckSettingsCreated;
  final bool deckSettingsUpdated;
  final bool deckSettingsPreserved;

  final int missingWordAudio;
  final int missingSentenceAudio;
  final int missingImages;

  const _MergeImportSummary({
    required this.sqliteRowsRead,
    required this.cardsProcessed,
    required this.cardsCreated,
    required this.cardsUpdated,
    required this.cardsUnchanged,
    required this.duplicateLogicalCardsInImport,
    required this.existingCardsNotPresentInImport,
    required this.deckSettingsCreated,
    required this.deckSettingsUpdated,
    required this.deckSettingsPreserved,
    required this.missingWordAudio,
    required this.missingSentenceAudio,
    required this.missingImages,
  });
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

class _MediaProcessResult {
  final MediaIndex index;
  final int copied;
  final int skipped;
  final int duplicateKeys;

  const _MediaProcessResult({
    required this.index,
    required this.copied,
    required this.skipped,
    required this.duplicateKeys,
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