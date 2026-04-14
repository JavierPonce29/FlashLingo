import 'dart:ffi';
import 'dart:io';

import 'package:flashcards_app/features/onboarding/starter_deck_service.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _isarCoreInitialized = false;

Future<void> ensureDesktopTestBindings() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(const <String, Object>{});
  if (_isarCoreInitialized) {
    return;
  }
  await Isar.initializeIsarCore(
    libraries: <Abi, String>{Abi.current(): _resolveIsarLibraryPath()},
  );
  _isarCoreInitialized = true;
}

Future<TestIsarHarness> openTestIsarHarness(
  List<CollectionSchema<dynamic>> schemas,
) async {
  await ensureDesktopTestBindings();
  final root = await Directory.systemTemp.createTemp('flashlingo_widget_test_');
  final previousPathProvider = PathProviderPlatform.instance;
  PathProviderPlatform.instance = FakePathProviderPlatform(root.path);
  final docsDir = await Directory(
    p.join(root.path, 'docs'),
  ).create(recursive: true);
  final starterDir = await Directory(
    p.join(docsDir.path, StarterDeckService.starterDeckFolderName),
  ).create(recursive: true);
  final starterFile = File(
    p.join(starterDir.path, StarterDeckService.starterDeckFileName),
  );
  if (!starterFile.existsSync()) {
    await starterFile.writeAsBytes(const <int>[], flush: true);
  }
  final isarDir = await Directory(
    p.join(root.path, 'isar'),
  ).create(recursive: true);
  final isar = await Isar.open(
    schemas,
    directory: isarDir.path,
    name: 'widget_test_${DateTime.now().microsecondsSinceEpoch}',
    inspector: false,
  );
  return TestIsarHarness(
    root: root,
    isar: isar,
    previousPathProvider: previousPathProvider,
  );
}

Widget buildTestApp({
  required Widget home,
  List<Override> overrides = const <Override>[],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    ),
  );
}

Future<void> pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw TestFailure('Finder did not appear within $timeout: $finder');
}

Finder findTextFormFieldByLabel(String label) {
  return find.bySemanticsLabel(label);
}

class TestIsarHarness {
  TestIsarHarness({
    required this.root,
    required this.isar,
    required this.previousPathProvider,
  });

  final Directory root;
  final Isar isar;
  final PathProviderPlatform previousPathProvider;

  Future<void> dispose() async {
    PathProviderPlatform.instance = previousPathProvider;
    if (isar.isOpen) {
      await isar.close(deleteFromDisk: true);
    }
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  }
}

class FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  FakePathProviderPlatform(this.rootPath);

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
