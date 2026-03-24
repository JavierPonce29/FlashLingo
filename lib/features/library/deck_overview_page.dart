import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/study_session.dart';
import 'package:flashcards_app/data/utils/study_day.dart';
import 'package:flashcards_app/features/onboarding/guided_tour_controller.dart';
import 'package:flashcards_app/features/onboarding/tour_widgets.dart';
import 'package:flashcards_app/features/study_session/study_page.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';
import 'package:flashcards_app/theme/app_ui_colors.dart';

class DeckOverviewPage extends ConsumerWidget {
  final String packName;
  static const Uuid _uuid = Uuid();

  const DeckOverviewPage({super.key, required this.packName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final muted = AppUiColors.mutedText(context);
    final guidedTourState = ref.watch(guidedTourProvider);
    final isTourStep = guidedTourState.step == GuidedTourStep.deckOverviewStart;

    final page = Scaffold(
      appBar: AppBar(title: Text(packName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              packName,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.tr('deck_overview_ready'),
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 40),
            TourHighlight(
              highlighted: isTourStep,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                ),
                onPressed: () async {
                  if (guidedTourState.isTourActive && !isTourStep) return;
                  if (isTourStep) {
                    ref.read(guidedTourProvider.notifier).onDeckStudyStarted();
                  }
                  await _startSession(context, ref);
                },
                child: Text(
                  l10n.tr('deck_overview_start'),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!isTourStep) return page;

    return Stack(
      children: [
        page,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(color: Colors.black.withValues(alpha: 0.24)),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: TourMessageCard(
            message: l10n.tr('onboarding_tour_deck_overview_start'),
          ),
        ),
      ],
    );
  }

  Future<void> _startSession(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final isar = await ref.read(isarDbProvider.future);
    final now = DateTime.now();

    DeckSettings? settings = await isar.deckSettings
        .filter()
        .packNameEqualTo(packName)
        .findFirst();
    if (settings == null) {
      settings = DeckSettings()..packName = packName;
      await isar.writeTxn(() async {
        await isar.deckSettings.put(settings!);
      });
    }

    final currentLabel = StudyDay.label(now, settings);
    final last = settings.lastNewCardStudyDate;
    final lastLabel = last == null ? null : StudyDay.label(last, settings);
    final isSameStudyDay =
        lastLabel != null &&
        lastLabel.year == currentLabel.year &&
        lastLabel.month == currentLabel.month &&
        lastLabel.day == currentLabel.day;

    if (!isSameStudyDay) {
      settings.newCardsSeenToday = 0;
      settings.lastNewCardStudyDate = now;
      await isar.writeTxn(() async {
        await isar.deckSettings.put(settings!);
      });
    }

    final existingSession = await isar.studySessions
        .filter()
        .packNameEqualTo(packName)
        .findFirst();

    if (existingSession != null) {
      if (existingSession.sessionId.isEmpty ||
          existingSession.startedAt.millisecondsSinceEpoch == 0) {
        existingSession.sessionId = existingSession.sessionId.isEmpty
            ? _uuid.v4()
            : existingSession.sessionId;
        existingSession.startedAt =
            existingSession.startedAt.millisecondsSinceEpoch == 0
            ? now
            : existingSession.startedAt;
        await isar.writeTxn(() async {
          await isar.studySessions.put(existingSession);
        });
      }
      if (_isSameDay(existingSession.sessionDay, currentLabel)) {
        final resumedCards = await _loadCardsFromSession(
          isar,
          existingSession.queueCardIds,
        );
        if (resumedCards.isNotEmpty) {
          final savedIndex = existingSession.currentIndex;
          final canResume = savedIndex >= 0 && savedIndex < resumedCards.length;
          if (canResume) {
            if (!context.mounted) return;
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudyPage(
                  packName: packName,
                  cards: resumedCards,
                  initialIndex: savedIndex,
                  sessionId: existingSession.sessionId,
                  sessionStartedAt: existingSession.startedAt,
                ),
              ),
            );
            if (!context.mounted) return;
            if (ref.read(guidedTourProvider).step ==
                GuidedTourStep.homeOpenStats) {
              Navigator.pop(context);
            }
            return;
          }
        }
        await isar.writeTxn(() async {
          await isar.studySessions.delete(existingSession.id);
        });
      } else {
        await isar.writeTxn(() async {
          await isar.studySessions.delete(existingSession.id);
        });
      }
    }

    final remainingQuota = max(
      0,
      settings.newCardsPerDay - settings.newCardsSeenToday,
    );

    final reviews = await isar.flashcards
        .filter()
        .packNameEqualTo(packName)
        .not()
        .stateEqualTo(CardState.newCard)
        .and()
        .nextReviewLessThan(now.add(const Duration(seconds: 1)))
        .limit(settings.maxReviewsPerDay)
        .findAll();
    reviews.shuffle();

    List<Flashcard> newCardsOrdered = [];
    if (remainingQuota > 0) {
      final newCardsRaw = await isar.flashcards
          .filter()
          .packNameEqualTo(packName)
          .stateEqualTo(CardState.newCard)
          .sortByOriginalId()
          .limit(remainingQuota)
          .findAll();

      final newRecog = newCardsRaw
          .where((c) => c.cardType.endsWith('recog'))
          .toList();
      final newProd = newCardsRaw
          .where((c) => c.cardType.endsWith('prod'))
          .toList();
      newCardsOrdered = [...newRecog, ...newProd];
    }

    final sessionCards = _buildSessionCards(
      settings: settings,
      reviews: reviews,
      newCards: newCardsOrdered,
    );
    if (!context.mounted) return;
    if (sessionCards.isEmpty) {
      String message = l10n.tr('deck_overview_all_done');
      if (remainingQuota == 0 && settings.newCardsPerDay > 0) {
        message = l10n.tr('deck_overview_new_limit');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppUiColors.success(context),
        ),
      );
      return;
    }

    final session = StudySession()
      ..packName = packName
      ..sessionId = _uuid.v4()
      ..queueCardIds = sessionCards.map((c) => c.id).toList()
      ..currentIndex = 0
      ..sessionDay = currentLabel
      ..startedAt = now
      ..lastUpdated = now;
    await isar.writeTxn(() async {
      await isar.studySessions.put(session);
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudyPage(
          packName: packName,
          cards: sessionCards,
          initialIndex: 0,
          sessionId: session.sessionId,
          sessionStartedAt: session.startedAt,
        ),
      ),
    );
    if (!context.mounted) return;
    if (ref.read(guidedTourProvider).step == GuidedTourStep.homeOpenStats) {
      Navigator.pop(context);
    }
  }

  List<Flashcard> _buildSessionCards({
    required DeckSettings settings,
    required List<Flashcard> reviews,
    required List<Flashcard> newCards,
  }) {
    final mode = DeckStudyMixMode.values.contains(settings.studyMixMode)
        ? settings.studyMixMode
        : DeckStudyMixMode.reviewsFirst;

    switch (mode) {
      case DeckStudyMixMode.newFirst:
        return [...newCards, ...reviews];
      case DeckStudyMixMode.reviewsFirst:
        return [...reviews, ...newCards];
      case DeckStudyMixMode.interleaveReviewsThenNew:
        return _interleaveChunks(
          first: reviews,
          firstChunkSize: settings.interleaveReviewsCount,
          second: newCards,
          secondChunkSize: settings.interleaveNewCardsCount,
        );
      case DeckStudyMixMode.interleaveNewThenReviews:
        return _interleaveChunks(
          first: newCards,
          firstChunkSize: settings.interleaveNewCardsCount,
          second: reviews,
          secondChunkSize: settings.interleaveReviewsCount,
        );
      default:
        return [...reviews, ...newCards];
    }
  }

  List<Flashcard> _interleaveChunks({
    required List<Flashcard> first,
    required int firstChunkSize,
    required List<Flashcard> second,
    required int secondChunkSize,
  }) {
    final aChunk = max(1, firstChunkSize);
    final bChunk = max(1, secondChunkSize);
    final result = <Flashcard>[];
    int i = 0;
    int j = 0;
    while (i < first.length || j < second.length) {
      if (i < first.length) {
        final endA = min(i + aChunk, first.length);
        result.addAll(first.sublist(i, endA));
        i = endA;
      }
      if (j < second.length) {
        final endB = min(j + bChunk, second.length);
        result.addAll(second.sublist(j, endB));
        j = endB;
      }
    }
    return result;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<List<Flashcard>> _loadCardsFromSession(
    Isar isar,
    List<int> queueIds,
  ) async {
    if (queueIds.isEmpty) return [];
    final uniqueIds = <int>{...queueIds}.toList();
    final cards = await isar.flashcards.getAll(uniqueIds);
    final map = <int, Flashcard>{};
    for (final card in cards) {
      if (card != null) map[card.id] = card;
    }

    final ordered = <Flashcard>[];
    for (final id in queueIds) {
      final card = map[id];
      if (card != null) ordered.add(card);
    }
    return ordered;
  }
}
