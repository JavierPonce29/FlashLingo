import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/review_log.dart';
import 'package:flashcards_app/data/models/study_session.dart';

part 'isar_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Isar> isarDb(IsarDbRef ref) async {
  // ✅ Evita abrir Isar más de una vez (muy común en hot restart / rebuilds).
  final existing = Isar.getInstance();
  if (existing != null) return existing;

  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open(
    [FlashcardSchema, DeckSettingsSchema, ReviewLogSchema, StudySessionSchema],
    directory: dir.path,
    inspector: kDebugMode, // ✅ Solo en debug
  );

  // Si el provider se llega a disponer (p. ej. en tests), cerrar la DB.
  ref.onDispose(() {
    if (isar.isOpen) {
      isar.close();
    }
  });

  return isar;
}
