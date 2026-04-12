import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';

Future<Directory> mediaAssetsDirectory() async {
  final docs = await getApplicationDocumentsDirectory();
  return Directory(p.join(docs.path, 'media_assets'));
}

Future<void> purgeOrphanedMediaAssets(Isar isar) async {
  final mediaDir = await mediaAssetsDirectory();
  if (!await mediaDir.exists()) {
    return;
  }

  final referencedUris = <String>{};
  final cards = await isar.flashcards.where().findAll();
  for (final card in cards) {
    _addUri(referencedUris, card.audioPath);
    _addUri(referencedUris, card.sentenceAudioPath);
    _addUri(referencedUris, card.imagePath);
  }

  final settings = await isar.deckSettings.where().findAll();
  for (final deckSettings in settings) {
    _addUri(referencedUris, deckSettings.deckIconUri);
  }

  await for (final entity in mediaDir.list(followLinks: false)) {
    if (entity is! File) {
      continue;
    }
    if (referencedUris.contains(entity.uri.toString())) {
      continue;
    }
    try {
      await entity.delete();
    } catch (_) {}
  }
}

void _addUri(Set<String> referencedUris, String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return;
  }
  referencedUris.add(normalized);
}
