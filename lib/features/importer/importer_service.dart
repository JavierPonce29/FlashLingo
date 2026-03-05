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
  final String? customPackName;
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
}

class ImportConflictException implements Exception {
  final ImportPreviewResult preview;
  const ImportConflictException(this.preview);

  @override
  String toString() =>
      'Conflicto: el mazo "${preview.importedPackName}" ya existe.';
}

class ImportSummary {
  final String zipFilePath;
  final String zipFileName;
  final String importedPackName;
  final String targetPackName;
  final String isoCode;
  final bool deckSettingsCreated;
  final bool deckSettingsUpdated;
  final bool deckSettingsPreserved;
  final int sqliteRows;
  final int cardsCreated;
  final int cardsUpdated;
  final int cardsUnchanged;
  final int duplicateLogicalCardsInImport;
  final int missingWordAudio;
  final int missingSentenceAudio;
  final int missingImages;
  final int archiveEntriesTotal;
  final int archiveRealFileEntries;
  final int mediaFilesCopied;
  final int mediaFilesSkipped;
  final int mediaKeyCollisions;
  const ImportSummary({
    required this.zipFilePath,
    required this.zipFileName,
    required this.importedPackName,
    required this.targetPackName,
    required this.isoCode,
    required this.deckSettingsCreated,
    required this.deckSettingsUpdated,
    required this.deckSettingsPreserved,
    required this.sqliteRows,
    required this.cardsCreated,
    required this.cardsUpdated,
    required this.cardsUnchanged,
    required this.duplicateLogicalCardsInImport,
    required this.missingWordAudio,
    required this.missingSentenceAudio,
    required this.missingImages,
    required this.archiveEntriesTotal,
    required this.archiveRealFileEntries,
    required this.mediaFilesCopied,
    required this.mediaFilesSkipped,
    required this.mediaKeyCollisions,
  });
}

class _PreparedPackage {
  final Directory extractDir;
  final Directory packageRoot;
  final File dbFile;
  final String packName;
  final String isoCode;
  final String dbFilename;
  final Map<String, dynamic> manifestData;
  final int archiveEntriesTotal;
  final int archiveRealFileEntries;
  final MediaIndex? mediaIndex;
  const _PreparedPackage({
    required this.extractDir,
    required this.packageRoot,
    required this.dbFile,
    required this.packName,
    required this.isoCode,
    required this.dbFilename,
    required this.manifestData,
    required this.archiveEntriesTotal,
    required this.archiveRealFileEntries,
    required this.mediaIndex,
  });
}

class _MergeImportSummary {
  final bool deckSettingsCreated;
  final bool deckSettingsUpdated;
  final bool deckSettingsPreserved;
  final int sqliteRows;
  final int cardsCreated;
  final int cardsUpdated;
  final int cardsUnchanged;
  final int duplicateLogicalCardsInImport;
  final int missingWordAudio;
  final int missingSentenceAudio;
  final int missingImages;
  const _MergeImportSummary({
    required this.deckSettingsCreated,
    required this.deckSettingsUpdated,
    required this.deckSettingsPreserved,
    required this.sqliteRows,
    required this.cardsCreated,
    required this.cardsUpdated,
    required this.cardsUnchanged,
    required this.duplicateLogicalCardsInImport,
    required this.missingWordAudio,
    required this.missingSentenceAudio,
    required this.missingImages,
  });
}

class ImporterService {
  final Isar isar;
  final Uuid _uuid = const Uuid();
  ImporterService(this.isar);
  Future<ImportPreviewResult> previewFlashcardPackage(String zipFilePath) async {
    final prepared = await _preparePackage(zipFilePath, copyMedia: false);
    try {
      final sqliteDb = await sql.openDatabase(prepared.dbFile.path, readOnly: true);
      try {
        final rows = await sqliteDb.rawQuery('SELECT COUNT(*) AS c FROM flashcards');
        final sqliteRows =
            rows.isNotEmpty ? _asInt(rows.first['c'], fallback: 0) : 0;
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
        throw StateError(
          "No existe el mazo '$targetPackName' para actualizar. "
              "Selecciona crear nuevo mazo.",
        );
      }

      sqliteDb = await sql.openDatabase(prepared.dbFile.path, readOnly: true);
      final mediaIndex = prepared.mediaIndex!;
      final merge = await _migrateDataToIsar(
        sqliteDb,
        prepared.isoCode,
        importedPackName,
        targetPackName,
        mediaIndex,
        prepared.manifestData,
        options: options,
        targetDeckExistedBeforeImport: targetExists,
      );

      return ImportSummary(
        zipFilePath: zipFilePath,
        zipFileName: p.basename(zipFilePath),
        importedPackName: importedPackName,
        targetPackName: targetPackName,
        isoCode: prepared.isoCode,
        deckSettingsCreated: merge.deckSettingsCreated,
        deckSettingsUpdated: merge.deckSettingsUpdated,
        deckSettingsPreserved: merge.deckSettingsPreserved,
        sqliteRows: merge.sqliteRows,
        cardsCreated: merge.cardsCreated,
        cardsUpdated: merge.cardsUpdated,
        cardsUnchanged: merge.cardsUnchanged,
        duplicateLogicalCardsInImport: merge.duplicateLogicalCardsInImport,
        missingWordAudio: merge.missingWordAudio,
        missingSentenceAudio: merge.missingSentenceAudio,
        missingImages: merge.missingImages,
        archiveEntriesTotal: prepared.archiveEntriesTotal,
        archiveRealFileEntries: prepared.archiveRealFileEntries,
        mediaFilesCopied: mediaIndex.filesCopied,
        mediaFilesSkipped: mediaIndex.filesSkipped,
        mediaKeyCollisions: mediaIndex.keyCollisions,
      );
    } finally {
      try {
        await sqliteDb?.close();
      } catch (_) {}
      await _cleanupExtractDir(prepared.extractDir);
    }
  }

  String _resolveTargetPackName(String importedPackName, ImportExecutionOptions options) {
    if (options.action == ImportDeckConflictAction.createNewDeck) {
      final custom = options.customPackName?.trim();
      if (custom != null && custom.isNotEmpty) return custom;
      return importedPackName;
    }
    return importedPackName;
  }

  Future<bool> _deckExistsByName(String packName) async {
    final settings =
    await isar.deckSettings.filter().packNameEqualTo(packName).findFirst();
    if (settings != null) return true;
    final anyCards = await isar.flashcards
        .filter()
        .packNameEqualTo(packName)
        .limit(1)
        .count();
    return anyCards > 0;
  }

  Future<_PreparedPackage> _preparePackage(
      String zipFilePath, {
        required bool copyMedia,
      }) async {
    final extractDir = await _createTempExtractDir(zipFilePath);
    final fileBytes = await File(zipFilePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(fileBytes);
    int totalEntries = archive.length;
    int realFileEntries = 0;

    for (final entry in archive) {
      if (!entry.isFile) continue;
      final name = entry.name.replaceAll('\\', '/');
      if (name.startsWith('__MACOSX/')) continue;
      realFileEntries++;
      final safeOutPath =
          _resolveSafeExtractPath(extractRoot: extractDir.path, entryName: name);
      if (safeOutPath == null) {
        print("WARNING suspicious zip entry ignored: $name");
        continue;
      }
      final outFile = File(safeOutPath);
      await outFile.parent.create(recursive: true);
      // Evitar overwrite silencioso: renombrar si ya existe.
      var finalPath = safeOutPath;
      int counter = 1;
      while (await File(finalPath).exists()) {
        final dir = p.dirname(safeOutPath);
        final base = p.basenameWithoutExtension(safeOutPath);
        final ext = p.extension(safeOutPath);
        finalPath = p.join(dir, "${base}_$counter$ext");
        counter++;
      }

      await File(finalPath).writeAsBytes(entry.content as List<int>);
    }

    // Encontrar manifest.json
    final manifestFile = File(p.join(extractDir.path, 'manifest.json'));
    if (!manifestFile.existsSync()) {
      throw StateError("No se encontro manifest.json en el paquete.");
    }
    final manifestData =
    jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
    final isoCode = (manifestData['language_id'] ?? '').toString().trim();
    final packName = (manifestData['pack_name'] ?? '').toString().trim();
    final dbFilename = (manifestData['db_filename'] ?? '').toString().trim();
    if (isoCode.isEmpty || packName.isEmpty || dbFilename.isEmpty) {
      throw StateError("manifest.json invalido: faltan campos requeridos.");
    }
    final packageRoot = Directory(extractDir.path);
    final dbFile = File(p.join(extractDir.path, dbFilename));
    if (!dbFile.existsSync()) {
      throw StateError("No se encontro la base de datos '$dbFilename' en el paquete.");
    }

    MediaIndex? mediaIndex;
    if (copyMedia) {
      mediaIndex = await _processAllMedia(packageRoot, extractDir);
    }
    return _PreparedPackage(
      extractDir: extractDir,
      packageRoot: packageRoot,
      dbFile: dbFile,
      packName: packName,
      isoCode: isoCode,
      dbFilename: dbFilename,
      manifestData: manifestData,
      archiveEntriesTotal: totalEntries,
      archiveRealFileEntries: realFileEntries,
      mediaIndex: mediaIndex,
    );
  }

  Future<Directory> _createTempExtractDir(String zipFilePath) async {
    final docs = await getApplicationDocumentsDirectory();
    final tempRoot = Directory(p.join(docs.path, 'import_tmp'));
    await tempRoot.create(recursive: true);
    final name = p.basenameWithoutExtension(zipFilePath);
    final dir = Directory(p.join(tempRoot.path, "${name}_${DateTime.now().millisecondsSinceEpoch}"));
    await dir.create(recursive: true);
    return dir;
  }

  Future<void> _cleanupExtractDir(Directory extractDir) async {
    try {
      if (extractDir.existsSync()) {
        await extractDir.delete(recursive: true);
      }
    } catch (_) {}
  }

  String? _resolveSafeExtractPath({
    required String extractRoot,
    required String entryName,
  }) {
    final normalized = p.normalize(entryName.replaceAll('\\', '/'));
    if (normalized.isEmpty || normalized == '.' || normalized == p.separator) {
      return null;
    }
    if (p.isAbsolute(normalized)) {
      return null;
    }
    final segments = p.split(normalized);
    if (segments.any((s) => s.contains(':') || s == '..' || s == '.')) {
      return null;
    }

    final candidate = p.normalize(p.join(extractRoot, normalized));
    return _isInsideRoot(extractRoot, candidate) ? candidate : null;
  }

  bool _isInsideRoot(String root, String path) {
    final rootNorm = p.normalize(root);
    final pathNorm = p.normalize(path);
    final rootLc = rootNorm.toLowerCase();
    final pathLc = pathNorm.toLowerCase();
    if (pathLc == rootLc) return true;
    final prefix = '$rootLc${p.separator}';
    return pathLc.startsWith(prefix);
  }

  // ============================================================
  //  Multimedia processing -> media_assets
  // ============================================================

  Future<MediaIndex> _processAllMedia(Directory packageRoot, Directory extractDir) async {
    final docs = await getApplicationDocumentsDirectory();
    final destDir = Directory(p.join(docs.path, 'media_assets'));
    await destDir.create(recursive: true);
    final exactMap = <String, String>{};
    final lowerCaseMap = <String, String>{};
    final stemMap = <String, String>{};
    int count = 0;
    int skipped = 0;
    int dupKeys = 0;
    final entities = <File>[];
    await for (final entity in extractDir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final basename = p.basename(entity.path).toLowerCase();
      if (basename.endsWith('.db') || basename == 'manifest.json') continue;
      entities.add(entity);
    }
    for (final entity in entities) {
      final ext = p.extension(entity.path);
      if (ext.isEmpty) {
        skipped++;
        continue;
      }
      final uniqueName = "${_uuid.v4()}$ext";
      final destFile = File(p.join(destDir.path, uniqueName));
      await entity.copy(destFile.path);
      final destUri = destFile.uri.toString();
      count++;
      final relFromPackage = _safeRelative(entity.path, packageRoot.path);
      final relFromExtract = _safeRelative(entity.path, extractDir.path);
      final keys = <String>{
        p.basename(entity.path),
        relFromPackage,
        relFromExtract,
      };
      try {
        keys.add(Uri.decodeFull(p.basename(entity.path)));
      } catch (_) {}
      final stem1 = p.basenameWithoutExtension(p.basename(entity.path)).toLowerCase();
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
    print("Multimedia procesada: $count archivos copiados. (omitidos: $skipped, colisiones de keys: $dupKeys)");

    return MediaIndex(
      exactMap,
      lowerCaseMap,
      stemMap,
      filesCopied: count,
      filesSkipped: skipped,
      keyCollisions: dupKeys,
    );
  }

  String _safeRelative(String filePath, String rootPath) {
    try {
      final rel = p.relative(filePath, from: rootPath);
      return rel.replaceAll('\\', '/');
    } catch (_) {
      return p.basename(filePath);
    }
  }

  String? _normalizeDbRef(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    return s;
  }

  int _asInt(dynamic value, {required int fallback}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim()) ?? fallback;
  }

  double _asDouble(dynamic value, {required double fallback}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    final raw = value.toString().trim().replaceAll(',', '.');
    return double.tryParse(raw) ?? fallback;
  }

  bool _asBool(dynamic value, {required bool fallback}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final s = value.toString().trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes' || s == 'si' || s == 'sí') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
    return fallback;
  }

  List<double> _asDoubleList(dynamic value, {required List<double> fallback}) {
    if (value is! List) return fallback;
    final out = <double>[];
    for (final e in value) {
      final parsed = _asDouble(e, fallback: double.nan);
      if (!parsed.isNaN && parsed > 0) out.add(parsed);
    }
    return out.isEmpty ? fallback : out;
  }

  String? _extractDeckIconRef(Map<String, dynamic> manifestData) {
    final candidates = <dynamic>[
      manifestData['deck_icon'],
      manifestData['deckIcon'],
      manifestData['deck_icon_path'],
      manifestData['deckIconPath'],
      manifestData['icon'],
      manifestData['icon_path'],
      manifestData['iconPath'],
    ];
    for (final c in candidates) {
      final s = _normalizeDbRef(c);
      if (s != null) return s;
    }
    final settings = manifestData['settings'];
    if (settings is Map) {
      final m = Map<String, dynamic>.from(settings);
      final inner = _normalizeDbRef(
        m['deck_icon'] ?? m['deck_icon_path'] ?? m['icon'] ?? m['icon_path'],
      );
      if (inner != null) return inner;
    }
    return null;
  }

  // ============================================================
  //  MIGRACION SQLITE -> ISAR (nuevo / actualizacion)
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
    // 1) SETTINGS (preparar, pero persistir junto con tarjetas en una sola txn)
    final importedSettings = _buildDeckSettingsFromManifest(
      packName: targetPackName,
      manifestData: manifestData,
    );
    // Icono del mazo (si existe en manifest)
    final iconRef = _extractDeckIconRef(manifestData);
    final iconUri = mediaIndex.find(iconRef);
    bool deckSettingsCreated = false;
    bool deckSettingsUpdated = false;
    bool deckSettingsPreserved = false;
    final existingSettings =
        await isar.deckSettings.filter().packNameEqualTo(targetPackName).findFirst();

    final bool preserveUserSettings =
        existingSettings != null &&
            ((options.action == ImportDeckConflictAction.updateExistingDeck &&
                    !options.updateDeckSettingsFromManifest) ||
                (options.action == ImportDeckConflictAction.createNewDeck &&
                    targetDeckExistedBeforeImport));

    DeckSettings? settingsToPersist;
    if (existingSettings == null) {
      importedSettings.deckIconUri = iconUri;
      settingsToPersist = importedSettings;
      deckSettingsCreated = true;
    } else if (preserveUserSettings) {
      deckSettingsPreserved = true;
      if (iconUri != null && iconUri != existingSettings.deckIconUri) {
        existingSettings.deckIconUri = iconUri;
        settingsToPersist = existingSettings;
      }
    } else {
      importedSettings.id = existingSettings.id;
      importedSettings.newCardsSeenToday = existingSettings.newCardsSeenToday;
      importedSettings.lastNewCardStudyDate = existingSettings.lastNewCardStudyDate;
      importedSettings.deckIconUri = iconUri ?? existingSettings.deckIconUri;
      settingsToPersist = importedSettings;
      deckSettingsUpdated = true;
    }

    // 2) Leer filas SQLite
    final rows = await db.query('flashcards');
    print("Importando ${rows.length} registros de la base de datos...");
    final double initialNtValue = preserveUserSettings && existingSettings != null
        ? existingSettings.initialNt
        : importedSettings.initialNt;

    // 3) Si es actualizacion, cargar tarjetas existentes del mazo una vez
    final Map<String, Flashcard> existingByLogicalKey = {};
    if (options.action == ImportDeckConflictAction.updateExistingDeck) {
      final existingCards =
      await isar.flashcards.filter().packNameEqualTo(targetPackName).findAll();
      for (final c in existingCards) {
        existingByLogicalKey[_logicalKey(c.originalId, c.cardType)] = c;
      }
      print("Mazo existente '$targetPackName': ${existingCards.length} tarjetas actuales.");
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
          print("Audio palabra faltante fila ${i + 1}: '$wordAudioRef'");
        }
      }
      if (sentenceAudioRef != null && sentenceAudioPath == null) {
        missingSentenceAudio++;
        if (missingSentenceAudio <= 20) {
          print("Audio oracion faltante fila ${i + 1}: '$sentenceAudioRef'");
        }
      }
      if (imageRef != null && imagePath == null) {
        missingImages++;
        if (missingImages <= 20) {
          print("Imagen faltante fila ${i + 1}: '$imageRef'");
        }
      }
      final originalId = (row['ID'] ?? '').toString().trim();
      if (originalId.isEmpty) continue;
      final cards = _buildCardsFromRow(
        row: row,
        originalId: originalId,
        isoCode: isoCode,
        packName: targetPackName,
        audioPath: audioPath,
        sentenceAudioPath: sentenceAudioPath,
        imagePath: imagePath,
        initialNtValue: initialNtValue,
      );

      for (final card in cards) {
        final key = _logicalKey(card.originalId, card.cardType);
        if (seenImportKeys.contains(key)) {
          duplicateLogicalCardsInImport++;
          continue;
        }
        seenImportKeys.add(key);
        if (options.action == ImportDeckConflictAction.updateExistingDeck) {
          final existing = existingByLogicalKey[key];
          if (existing == null) {
            toInsert.add(card);
            cardsCreated++;
          } else {
            final changed = _applyImportedContent(existing, card);
            if (changed) {
              toUpdate.add(existing);
              cardsUpdated++;
            } else {
              cardsUnchanged++;
            }
          }
        } else {
          toInsert.add(card);
          cardsCreated++;
        }
      }
    }

    // Persistir cambios (settings + tarjetas en una sola transacción)
    await isar.writeTxn(() async {
      if (settingsToPersist != null) {
        await isar.deckSettings.putByIndex('packName', settingsToPersist!);
      }
      if (toInsert.isNotEmpty) {
        await isar.flashcards.putAll(toInsert);
      }
      if (toUpdate.isNotEmpty) {
        await isar.flashcards.putAll(toUpdate);
      }
    });

    return _MergeImportSummary(
      deckSettingsCreated: deckSettingsCreated,
      deckSettingsUpdated: deckSettingsUpdated,
      deckSettingsPreserved: deckSettingsPreserved,
      sqliteRows: rows.length,
      cardsCreated: cardsCreated,
      cardsUpdated: cardsUpdated,
      cardsUnchanged: cardsUnchanged,
      duplicateLogicalCardsInImport: duplicateLogicalCardsInImport,
      missingWordAudio: missingWordAudio,
      missingSentenceAudio: missingSentenceAudio,
      missingImages: missingImages,
    );
  }

  String _logicalKey(String originalId, String cardType) => '$originalId::$cardType';
  bool _applyImportedContent(Flashcard existing, Flashcard incoming) {
    bool changed = false;
    if (existing.question != incoming.question) {
      existing.question = incoming.question;
      changed = true;
    }
    if (existing.answer != incoming.answer) {
      existing.answer = incoming.answer;
      changed = true;
    }
    if (existing.sentence != incoming.sentence) {
      existing.sentence = incoming.sentence;
      changed = true;
    }
    if (existing.translation != incoming.translation) {
      existing.translation = incoming.translation;
      changed = true;
    }
    if (existing.audioPath != incoming.audioPath) {
      existing.audioPath = incoming.audioPath;
      changed = true;
    }
    if (existing.sentenceAudioPath != incoming.sentenceAudioPath) {
      existing.sentenceAudioPath = incoming.sentenceAudioPath;
      changed = true;
    }
    if (existing.imagePath != incoming.imagePath) {
      existing.imagePath = incoming.imagePath;
      changed = true;
    }
    if (existing.extraDataJson != incoming.extraDataJson) {
      existing.extraDataJson = incoming.extraDataJson;
      changed = true;
    }
    return changed;
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
          _asInt(manifestData['new_card_min_correct_reps'], fallback: 2)
      ..newCardIntraDayMinutes =
          _asInt(manifestData['new_card_intra_day_minutes'], fallback: 10)
      ..enableWriteMode = false
      ..writeModeThreshold = 80
      ..writeModeMaxReps = 0;

    if (manifestData.containsKey('settings') && manifestData['settings'] is Map) {
      final Map<String, dynamic> custom =
          Map<String, dynamic>.from(manifestData['settings'] as Map);
      print("Aplicando configuraciones personalizadas del mazo...");

      settings.newCardsPerDay =
          _asInt(custom['new_cards_per_day'], fallback: settings.newCardsPerDay);
      settings.maxReviewsPerDay =
          _asInt(custom['max_reviews_per_day'], fallback: settings.maxReviewsPerDay);
      settings.lapseTolerance =
          _asInt(custom['lapse_tolerance'], fallback: settings.lapseTolerance);
      settings.useFixedIntervalOnLapse = _asBool(
        custom['use_fixed_interval_on_lapse'],
        fallback: settings.useFixedIntervalOnLapse,
      );
      settings.lapseFixedInterval =
          _asDouble(custom['lapse_fixed_interval'], fallback: settings.lapseFixedInterval);
      settings.pMin = _asDouble(custom['p_min'], fallback: settings.pMin);
      settings.alpha = _asDouble(custom['alpha'], fallback: settings.alpha);
      settings.beta = _asDouble(custom['beta'], fallback: settings.beta);
      settings.offset = _asDouble(custom['offset'], fallback: settings.offset);
      settings.initialNt = _asDouble(custom['initial_nt'], fallback: settings.initialNt);
      settings.learningSteps =
          _asDoubleList(custom['learning_steps'], fallback: settings.learningSteps);
      settings.enableWriteMode =
          _asBool(custom['enable_write_mode'], fallback: settings.enableWriteMode);
      settings.writeModeThreshold =
          _asInt(custom['write_mode_threshold'], fallback: settings.writeModeThreshold);
      settings.writeModeMaxReps =
          _asInt(custom['write_mode_max_reps'], fallback: settings.writeModeMaxReps);
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
      ..translation = row['ORACION']?.toString()
      ..sentence = row['TRADUCCION']?.toString()
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
}
class MediaIndex {
  final Map<String, String> exactMap;
  final Map<String, String> lowerCaseMap;
  final Map<String, String> stemMap;
  final int filesCopied;
  final int filesSkipped;
  final int keyCollisions;
  MediaIndex(
      this.exactMap,
      this.lowerCaseMap,
      this.stemMap, {
        required this.filesCopied,
        required this.filesSkipped,
        required this.keyCollisions,
      });
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
    // 3) minusculas
    final lower = clean.toLowerCase();
    if (lowerCaseMap.containsKey(lower)) return lowerCaseMap[lower];
    // 4) minusculas decodificado
    try {
      final decodedLower = Uri.decodeFull(clean).toLowerCase();
      if (lowerCaseMap.containsKey(decodedLower)) return lowerCaseMap[decodedLower];
    } catch (_) {}
    // 5) stem (ignora extension)
    final stem = p.basenameWithoutExtension(clean).toLowerCase();
    if (stemMap.containsKey(stem)) return stemMap[stem];
    // 6) stem por basename si venia con ruta
    final baseStem = p.basenameWithoutExtension(p.basename(clean)).toLowerCase();
    if (stemMap.containsKey(baseStem)) return stemMap[baseStem];
    return null;
  }
}