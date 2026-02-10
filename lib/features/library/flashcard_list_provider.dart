import 'package:isar/isar.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/flashcard.dart';

part 'flashcard_list_provider.g.dart';

@riverpod
Stream<List<Flashcard>> flashcardsStream(FlashcardsStreamRef ref) async* {
  // Esperamos a que la DB esté lista
  final isar = await ref.watch(isarDbProvider.future);

  // Observamos la colección completa.
  // fireImmediately: true hace que emita el valor actual inmediatamente.
  yield* isar.flashcards.where().anyId().watch(fireImmediately: true);
}
