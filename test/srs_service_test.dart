import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/features/study_session/srs_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SrsService', () {
    test(
      'moves a new card into review after completing the last learning step',
      () {
        final settings = DeckSettings()
          ..packName = 'Demo'
          ..newCardMinCorrectReps = 1
          ..learningSteps = <double>[1.0]
          ..dayCutoffHour = 4
          ..dayCutoffMinute = 0;
        final card = Flashcard()
          ..originalId = '1'
          ..isoCode = 'ja'
          ..packName = 'Demo'
          ..cardType = 'ja_recog'
          ..question = '猫'
          ..answer = 'cat'
          ..state = CardState.newCard;
        final service = SrsService();

        final firstRepeatToday = service.reviewCard(card, true, settings);
        final firstNextReview = card.nextReview;
        final secondRepeatToday = service.reviewCard(card, true, settings);

        expect(firstRepeatToday, isFalse);
        expect(
          firstNextReview.isAfter(
            DateTime.now().subtract(const Duration(hours: 23)),
          ),
          isTrue,
        );
        expect(secondRepeatToday, isFalse);
        expect(card.state, CardState.review);
        expect(card.learningStep, 0);
      },
    );

    test(
      'sends a review card to relearning when lapse tolerance is reached',
      () {
        final settings = DeckSettings()
          ..packName = 'Demo'
          ..learningSteps = <double>[1.0, 4.0]
          ..lapseTolerance = 2
          ..dayCutoffHour = 4
          ..dayCutoffMinute = 0;
        final card = Flashcard()
          ..originalId = '2'
          ..isoCode = 'ja'
          ..packName = 'Demo'
          ..cardType = 'ja_recog'
          ..question = '山'
          ..answer = 'mountain'
          ..state = CardState.review
          ..consecutiveLapses = 1;
        final service = SrsService();
        final before = DateTime.now();

        final repeatToday = service.reviewCard(card, false, settings);

        expect(repeatToday, isTrue);
        expect(card.state, CardState.relearning);
        expect(card.learningStep, -1);
        expect(card.fixedPhaseQueue, settings.learningSteps);
        expect(card.nextReview.isAfter(before), isTrue);
        expect(
          card.nextReview.difference(before).inMinutes,
          inInclusiveRange(9, 11),
        );
      },
    );

    test('increments repetition count for production cards on success', () {
      final settings = DeckSettings()
        ..packName = 'Demo'
        ..newCardMinCorrectReps = 1
        ..learningSteps = <double>[1.0];
      final service = SrsService();
      final learningCard = Flashcard()
        ..originalId = '3'
        ..isoCode = 'ja'
        ..packName = 'Demo'
        ..cardType = 'ja_prod'
        ..question = 'cat'
        ..answer = '猫'
        ..state = CardState.newCard;
      final reviewCard = Flashcard()
        ..originalId = '4'
        ..isoCode = 'ja'
        ..packName = 'Demo'
        ..cardType = 'ja_prod'
        ..question = 'dog'
        ..answer = '犬'
        ..state = CardState.review
        ..repetitionCount = 3;

      service.reviewCard(learningCard, true, settings);
      service.reviewCard(reviewCard, true, settings);

      expect(learningCard.repetitionCount, 1);
      expect(reviewCard.repetitionCount, 4);
    });

    test('repeats a review card the same day for sub-day lapse intervals', () {
      final settings = DeckSettings()
        ..packName = 'Demo'
        ..useFixedIntervalOnLapse = true
        ..lapseFixedInterval = 0.5;
      final card = Flashcard()
        ..originalId = '5'
        ..isoCode = 'en'
        ..packName = 'Demo'
        ..cardType = 'en_recog'
        ..question = 'house'
        ..answer = 'casa'
        ..state = CardState.review;
      final service = SrsService();
      final before = DateTime.now();

      final repeatToday = service.reviewCard(card, false, settings);

      expect(repeatToday, isTrue);
      expect(card.state, CardState.review);
      expect(
        card.nextReview.isAfter(before.add(const Duration(hours: 11))),
        isTrue,
      );
      expect(
        card.nextReview.isBefore(before.add(const Duration(hours: 13))),
        isTrue,
      );
    });
  });
}
