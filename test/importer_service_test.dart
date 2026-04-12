import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/features/importer/importer_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PathProviderPlatform originalPathProvider;
  late Directory tempRoot;
  late Isar isar;
  late ImporterService importer;

  setUpAll(() async {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
    await Isar.initializeIsarCore(
      libraries: {Abi.current(): _resolveIsarLibraryPath()},
    );
    originalPathProvider = PathProviderPlatform.instance;
  });

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp(
      'flashlingo_importer_test_',
    );
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempRoot.path);
    final isarDir = await Directory(
      p.join(tempRoot.path, 'isar'),
    ).create(recursive: true);
    isar = await Isar.open(
      [DeckSettingsSchema, FlashcardSchema],
      directory: isarDir.path,
      name: 'importer_test_${DateTime.now().microsecondsSinceEpoch}',
      inspector: false,
    );
    importer = ImporterService(isar);
  });

  tearDown(() async {
    PathProviderPlatform.instance = originalPathProvider;
    if (isar.isOpen) {
      await isar.close(deleteFromDisk: true);
    }
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  test(
    'imports a flat package and applies normalized boolean settings',
    () async {
      final packageFile = await _createPackageZip(
        tempRoot,
        packName: 'Basics',
        isoCode: 'ja',
        rows: [
          _PackageRow(
            id: 'w1',
            word: '猫',
            meaning: 'cat',
            wordAudio: 'audio/cat.mp3',
            sentenceAudio: 'audio/cat_sentence.mp3',
            image: 'images/cat.png',
            sentence: '猫です。',
            translation: 'It is a cat.',
          ),
          _PackageRow(
            id: 'w2',
            word: '犬',
            meaning: 'dog',
            sentence: '犬です。',
            translation: 'It is a dog.',
          ),
        ],
        settings: {
          'enable_write_mode': 'sí',
          'use_fixed_interval_on_lapse': 'no',
        },
        mediaFiles: {
          'audio/cat.mp3': utf8.encode('cat-audio'),
          'audio/cat_sentence.mp3': utf8.encode('cat-sentence-audio'),
          'images/cat.png': <int>[1, 2, 3, 4],
        },
      );

      final preview = await importer.previewFlashcardPackage(packageFile.path);
      final summary = await importer.importFlashcardPackageAdvanced(
        packageFile.path,
        options: const ImportExecutionOptions.createNew(),
      );

      final settings = await isar.deckSettings
          .filter()
          .packNameEqualTo('Basics')
          .findFirst();

      expect(preview.sqliteRows, 2);
      expect(preview.estimatedCardsToImport, 4);
      expect(summary.sqliteRows, 2);
      expect(summary.cardsCreated, 4);
      expect(summary.mediaFilesCopied, 3);
      expect(settings, isNotNull);
      expect(settings!.enableWriteMode, isTrue);
      expect(settings.useFixedIntervalOnLapse, isFalse);
    },
  );

  test('imports packages wrapped in a single root folder', () async {
    final packageFile = await _createPackageZip(
      tempRoot,
      packName: 'Wrapped',
      isoCode: 'en',
      wrapperDir: 'root_bundle',
      rows: [
        _PackageRow(
          id: 'root-1',
          word: 'house',
          meaning: 'casa',
          sentence: 'The house is blue.',
          translation: 'La casa es azul.',
        ),
      ],
    );

    final preview = await importer.previewFlashcardPackage(packageFile.path);
    final summary = await importer.importFlashcardPackageAdvanced(
      packageFile.path,
      options: const ImportExecutionOptions.createNew(),
    );

    expect(preview.importedPackName, 'Wrapped');
    expect(preview.sqliteRows, 1);
    expect(summary.cardsCreated, 2);
    expect(await isar.flashcards.count(), 2);
  });

  test(
    'updateExisting preserves progress and only refreshes imported content',
    () async {
      final initialPackage = await _createPackageZip(
        tempRoot,
        packName: 'Progress',
        isoCode: 'ja',
        rows: [
          _PackageRow(
            id: 'keep-1',
            word: '山',
            meaning: 'mountain',
            sentence: '山が高い。',
            translation: 'The mountain is tall.',
          ),
        ],
        settings: {'new_cards_per_day': 10, 'enable_write_mode': true},
      );

      await importer.importFlashcardPackageAdvanced(
        initialPackage.path,
        options: const ImportExecutionOptions.createNew(),
      );

      final existingCards = await isar.flashcards
          .filter()
          .packNameEqualTo('Progress')
          .findAll();
      final existingSettings = await isar.deckSettings
          .filter()
          .packNameEqualTo('Progress')
          .findFirst();

      expect(existingCards.length, 2);
      expect(existingSettings, isNotNull);

      await isar.writeTxn(() async {
        existingSettings!
          ..newCardsPerDay = 99
          ..enableWriteMode = false;
        await isar.deckSettings.put(existingSettings);
        for (final card in existingCards) {
          card
            ..state = CardState.review
            ..nextReview = DateTime(2026, 5, 1)
            ..lastReview = DateTime(2026, 4, 1)
            ..repetitionCount = 11
            ..lifetimeReviewCount = 15
            ..lifetimeCorrectCount = 12
            ..lifetimeWrongCount = 3
            ..totalStudyTimeMs = 6400;
        }
        await isar.flashcards.putAll(existingCards);
      });

      final updatedPackage = await _createPackageZip(
        tempRoot,
        packName: 'Progress',
        isoCode: 'ja',
        rows: [
          _PackageRow(
            id: 'keep-1',
            word: '丘',
            meaning: 'hill',
            sentence: '丘が近い。',
            translation: 'The hill is nearby.',
            wordAudio: 'audio/hill.mp3',
          ),
        ],
        settings: {'new_cards_per_day': 5, 'enable_write_mode': true},
        mediaFiles: {'audio/hill.mp3': utf8.encode('hill-audio')},
        fileName: 'progress_update.flashjp',
      );

      final summary = await importer.importFlashcardPackageAdvanced(
        updatedPackage.path,
        options: const ImportExecutionOptions.updateExisting(),
      );

      final updatedCards = await isar.flashcards
          .filter()
          .packNameEqualTo('Progress')
          .findAll();
      final updatedSettings = await isar.deckSettings
          .filter()
          .packNameEqualTo('Progress')
          .findFirst();

      expect(summary.cardsCreated, 0);
      expect(summary.cardsUpdated, 2);
      expect(summary.deckSettingsPreserved, isTrue);
      expect(updatedSettings, isNotNull);
      expect(updatedSettings!.newCardsPerDay, 99);
      expect(updatedSettings.enableWriteMode, isFalse);

      for (final card in updatedCards) {
        expect(card.state, CardState.review);
        expect(card.nextReview, DateTime(2026, 5, 1));
        expect(card.lastReview, DateTime(2026, 4, 1));
        expect(card.repetitionCount, 11);
        expect(card.lifetimeReviewCount, 15);
        expect(card.lifetimeCorrectCount, 12);
        expect(card.lifetimeWrongCount, 3);
        expect(card.totalStudyTimeMs, 6400);
        expect(card.audioPath, isNotNull);
        if (card.cardType == 'ja_recog') {
          expect(card.question, '丘');
          expect(card.answer, 'hill');
          expect(card.sentence, '丘が近い。');
          expect(card.translation, 'The hill is nearby.');
        } else {
          expect(card.question, 'hill');
          expect(card.answer, '丘');
          expect(card.translation, '丘が近い。');
          expect(card.sentence, 'The hill is nearby.');
        }
      }
    },
  );

  test('cleans orphaned media after updating an existing deck', () async {
    final initialPackage = await _createPackageZip(
      tempRoot,
      packName: 'MediaDeck',
      isoCode: 'ja',
      rows: [
        _PackageRow(
          id: 'm1',
          word: '海',
          meaning: 'sea',
          wordAudio: 'audio/old.mp3',
        ),
      ],
      mediaFiles: {'audio/old.mp3': utf8.encode('old-audio')},
    );

    await importer.importFlashcardPackageAdvanced(
      initialPackage.path,
      options: const ImportExecutionOptions.createNew(),
    );

    final oldCard = await isar.flashcards
        .filter()
        .packNameEqualTo('MediaDeck')
        .cardTypeEqualTo('ja_recog')
        .findFirst();
    final oldMediaFile = File.fromUri(Uri.parse(oldCard!.audioPath!));

    final updatedPackage = await _createPackageZip(
      tempRoot,
      packName: 'MediaDeck',
      isoCode: 'ja',
      rows: [
        _PackageRow(
          id: 'm1',
          word: '海',
          meaning: 'sea',
          wordAudio: 'audio/new.mp3',
        ),
      ],
      mediaFiles: {'audio/new.mp3': utf8.encode('new-audio')},
      fileName: 'media_update.flashjp',
    );

    await importer.importFlashcardPackageAdvanced(
      updatedPackage.path,
      options: const ImportExecutionOptions.updateExisting(),
    );

    final updatedCard = await isar.flashcards
        .filter()
        .packNameEqualTo('MediaDeck')
        .cardTypeEqualTo('ja_recog')
        .findFirst();
    final newMediaFile = File.fromUri(Uri.parse(updatedCard!.audioPath!));

    expect(await oldMediaFile.exists(), isFalse);
    expect(await newMediaFile.exists(), isTrue);
  });

  test('counts missing media references from sqlite rows', () async {
    final packageFile = await _createPackageZip(
      tempRoot,
      packName: 'MissingMedia',
      isoCode: 'ja',
      rows: [
        _PackageRow(
          id: 'missing-1',
          word: '空',
          meaning: 'sky',
          wordAudio: 'audio/missing_word.mp3',
          sentenceAudio: 'audio/missing_sentence.mp3',
          image: 'images/missing.png',
        ),
      ],
    );

    final summary = await importer.importFlashcardPackageAdvanced(
      packageFile.path,
      options: const ImportExecutionOptions.createNew(),
    );

    expect(summary.missingWordAudio, 1);
    expect(summary.missingSentenceAudio, 1);
    expect(summary.missingImages, 1);
  });

  test('skips duplicate logical cards inside a single import', () async {
    final packageFile = await _createPackageZip(
      tempRoot,
      packName: 'Duplicates',
      isoCode: 'en',
      rows: [
        _PackageRow(id: 'dup-1', word: 'apple', meaning: 'manzana'),
        _PackageRow(id: 'dup-1', word: 'apple-2', meaning: 'manzana-2'),
      ],
    );

    final summary = await importer.importFlashcardPackageAdvanced(
      packageFile.path,
      options: const ImportExecutionOptions.createNew(),
    );

    expect(summary.sqliteRows, 2);
    expect(summary.cardsCreated, 2);
    expect(summary.duplicateLogicalCardsInImport, 2);
    expect(await isar.flashcards.count(), 2);
  });

  test('imports more than one sqlite batch without losing cards', () async {
    final rows = List<_PackageRow>.generate(
      260,
      (index) => _PackageRow(
        id: 'row-$index',
        word: 'word-$index',
        meaning: 'meaning-$index',
      ),
    );
    final packageFile = await _createPackageZip(
      tempRoot,
      packName: 'Batched',
      isoCode: 'en',
      rows: rows,
    );

    final summary = await importer.importFlashcardPackageAdvanced(
      packageFile.path,
      options: const ImportExecutionOptions.createNew(),
    );

    expect(summary.sqliteRows, 260);
    expect(summary.cardsCreated, 520);
    expect(await isar.flashcards.count(), 520);
  });
}

class _PackageRow {
  const _PackageRow({
    required this.id,
    required this.word,
    required this.meaning,
    this.wordAudio,
    this.sentenceAudio,
    this.image,
    this.sentence,
    this.translation,
  });

  final String id;
  final String word;
  final String meaning;
  final String? wordAudio;
  final String? sentenceAudio;
  final String? image;
  final String? sentence;
  final String? translation;

  Map<String, Object?> toSqlMap() {
    return <String, Object?>{
      'ID': id,
      'PALABRA': word,
      'SIGNIFICADO': meaning,
      'AUDIO_PALABRA': wordAudio,
      'AUDIO_ORACION': sentenceAudio,
      'IMAGEN': image,
      'ORACION': sentence,
      'TRADUCCION': translation,
      'LECTURA_PALABRA': null,
      'LECTURA_ORACION': null,
      'FORMAS': null,
    };
  }
}

class _FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProviderPlatform(this.rootPath);

  final String rootPath;

  Future<String> _ensurePath(String folderName) async {
    final dir = Directory(p.join(rootPath, folderName));
    await dir.create(recursive: true);
    return dir.path;
  }

  @override
  Future<String?> getApplicationCachePath() => _ensurePath('cache');

  @override
  Future<String?> getApplicationDocumentsPath() => _ensurePath('docs');

  @override
  Future<String?> getApplicationSupportPath() => _ensurePath('support');

  @override
  Future<String?> getDownloadsPath() => _ensurePath('downloads');

  @override
  Future<String?> getExternalStoragePath() => _ensurePath('external_storage');

  @override
  Future<List<String>?> getExternalCachePaths() async => <String>[
    await _ensurePath('external_cache'),
  ];

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => <String>[await _ensurePath('external_storage_multi')];

  @override
  Future<String?> getLibraryPath() => _ensurePath('library');

  @override
  Future<String> getTemporaryPath() => _ensurePath('temp');
}

Future<File> _createPackageZip(
  Directory root, {
  required String packName,
  required String isoCode,
  required List<_PackageRow> rows,
  Map<String, dynamic>? settings,
  Map<String, List<int>> mediaFiles = const {},
  String? wrapperDir,
  String? fileName,
}) async {
  final workspace = await Directory(
    p.join(root.path, 'package_${DateTime.now().microsecondsSinceEpoch}'),
  ).create(recursive: true);
  final dbFilename = 'flashcards.db';
  final dbFile = File(p.join(workspace.path, dbFilename));
  final database = await sqflite.openDatabase(
    dbFile.path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE flashcards (
          ID TEXT,
          PALABRA TEXT,
          SIGNIFICADO TEXT,
          AUDIO_PALABRA TEXT,
          AUDIO_ORACION TEXT,
          IMAGEN TEXT,
          ORACION TEXT,
          TRADUCCION TEXT,
          LECTURA_PALABRA TEXT,
          LECTURA_ORACION TEXT,
          FORMAS TEXT
        )
      ''');
    },
  );

  final batch = database.batch();
  for (final row in rows) {
    batch.insert('flashcards', row.toSqlMap());
  }
  await batch.commit(noResult: true);
  await database.close();

  final manifest = <String, dynamic>{
    'language_id': isoCode,
    'pack_name': packName,
    'db_filename': dbFilename,
    ...?(settings == null ? null : <String, dynamic>{'settings': settings}),
  };

  final archive = Archive();
  final prefix = wrapperDir == null
      ? ''
      : '${wrapperDir.replaceAll('\\', '/')}/';
  _addArchiveFile(
    archive,
    '${prefix}manifest.json',
    utf8.encode(jsonEncode(manifest)),
  );
  _addArchiveFile(archive, '$prefix$dbFilename', await dbFile.readAsBytes());
  for (final entry in mediaFiles.entries) {
    _addArchiveFile(archive, '$prefix${entry.key}', entry.value);
  }

  final outputFile = File(
    p.join(root.path, fileName ?? '${packName.toLowerCase()}.flashjp'),
  );
  final bytes = ZipEncoder().encode(archive);
  await outputFile.writeAsBytes(bytes, flush: true);
  return outputFile;
}

void _addArchiveFile(Archive archive, String name, List<int> bytes) {
  archive.addFile(ArchiveFile(name, bytes.length, bytes));
}

String _resolveIsarLibraryPath() {
  final localAppData = Platform.environment['LOCALAPPDATA'];
  if (localAppData == null || localAppData.isEmpty) {
    throw StateError('LOCALAPPDATA no esta disponible para localizar isar.dll');
  }

  final hostedDir = Directory(
    p.join(localAppData, 'Pub', 'Cache', 'hosted', 'pub.dev'),
  );
  final matches =
      hostedDir
          .listSync(followLinks: false)
          .whereType<Directory>()
          .where((dir) => p.basename(dir.path).startsWith('isar_flutter_libs-'))
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path));
  if (matches.isEmpty) {
    throw StateError('No se encontro isar_flutter_libs en el cache de Pub');
  }

  final dllPath = p.join(matches.first.path, 'windows', 'isar.dll');
  if (!File(dllPath).existsSync()) {
    throw StateError('No se encontro isar.dll en $dllPath');
  }
  return dllPath;
}
