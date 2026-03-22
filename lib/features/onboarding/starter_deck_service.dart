import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StarterDeckService {
  const StarterDeckService._();

  static const String starterDeckFileName = 'FlashLingo.flashjp';
  static const String starterDeckFolderName = 'starter_decks';
  static const String guidedDeckName = 'FlashLingo';

  static const String _starterDeckAssetPath =
      'lib/assets/starter/FlashLingo.flashjp';

  static Future<File> ensureStarterPackageExists() async {
    final docs = await getApplicationDocumentsDirectory();
    final targetDir = Directory(p.join(docs.path, starterDeckFolderName));
    await targetDir.create(recursive: true);

    final packageFile = File(p.join(targetDir.path, starterDeckFileName));
    if (await packageFile.exists()) {
      return packageFile;
    }

    final packageBytes = await _loadAssetBytes(_starterDeckAssetPath);
    await packageFile.writeAsBytes(packageBytes, flush: true);
    return packageFile;
  }

  static Future<String> ensureStarterPackagePath() async {
    final file = await ensureStarterPackageExists();
    return file.path;
  }

  static Future<List<int>> _loadAssetBytes(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
