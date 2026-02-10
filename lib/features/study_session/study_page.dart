import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:isar/isar.dart';

import 'package:flashcards_app/data/models/flashcard.dart';
import '../../data/models/deck_settings.dart';
import '../../data/models/review_log.dart';
import 'html_generator.dart';
import 'srs_service.dart';

class StudyPage extends StatefulWidget {
  final List<Flashcard> cards;

  const StudyPage({super.key, required this.cards});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  InAppWebViewController? webViewController;
  int currentIndex = 0;

  // Estados UI
  bool isAnswerShown = false;
  bool isReadingShown = false;
  bool isComplexCard = false;

  // Estados Escritura
  bool isWriteModeActive = false;
  int currentWriteScore = 0;
  int minScoreRequired = 0;

  late List<Flashcard> studyQueue;
  final SrsService _srsService = SrsService();
  DeckSettings? _currentDeckSettings;

  @override
  void initState() {
    super.initState();
    studyQueue = List.from(widget.cards);
    _loadDeckSettings();
    _checkCardComplexity();
  }

  Future<void> _loadDeckSettings() async {
    final isar = Isar.getInstance();
    if (isar != null && studyQueue.isNotEmpty) {
      final settings = await isar.deckSettings
          .filter()
          .packNameEqualTo(studyQueue.first.packName)
          .findFirst();

      setState(() {
        _currentDeckSettings = settings;
        _checkCardComplexity();
      });
    }
  }

  void _checkCardComplexity() {
    if (currentIndex >= studyQueue.length) return;

    final card = studyQueue[currentIndex];
    Map<String, dynamic> extra = {};
    if (card.extraDataJson != null) {
      try {
        extra = jsonDecode(card.extraDataJson!);
      } catch (_) {}
    }

    // Complejidad por Lectura (idiomas con reading)
    final readingVal = extra['reading'];
    final readingStr = (readingVal is String) ? readingVal.trim() : '';
    final bool isRecog = card.cardType.endsWith('recog');
    final bool hasReading = readingStr.isNotEmpty && readingStr != card.question.trim();

    // Escritura
    final bool writeEnabled = _currentDeckSettings?.enableWriteMode ?? false;
    final bool isProd = card.cardType.endsWith('prod');

    setState(() {
      isComplexCard = (isRecog && hasReading);

      isWriteModeActive = writeEnabled && isProd;
      if (isWriteModeActive) {
        minScoreRequired = _currentDeckSettings?.writeModeThreshold ?? 80;
        currentWriteScore = 0;
      } else {
        minScoreRequired = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= studyQueue.length) {
      return Scaffold(
        appBar: AppBar(title: const Text("Sesión Finalizada")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text("¡Has terminado por ahora!", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Volver"),
              )
            ],
          ),
        ),
      );
    }

    final card = studyQueue[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Estudiando (${currentIndex + 1}/${studyQueue.length})"),
      ),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              // ✅ CLAVE: permitir reproducción automática (autoplay)
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
              ),
              initialData: InAppWebViewInitialData(
                data: HtmlGenerator.generateContent(
                  card,
                  writeMode: isWriteModeActive,
                ),
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;

                controller.addJavaScriptHandler(
                  handlerName: 'submitScore',
                  callback: (args) {
                    if (args.isNotEmpty) {
                      final score = args[0] as int;
                      setState(() {
                        currentWriteScore = score;
                      });
                      // ignore: avoid_print
                      print("📝 Score escritura: $score% (Min: $minScoreRequired%)");
                    }
                  },
                );
              },
            ),
          ),
          _buildControls(card),
        ],
      ),
    );
  }

  Widget _buildControls(Flashcard card) {
    // PASO 1: Antes de mostrar la respuesta
    if (!isAnswerShown) {
      // Complejas: primero lectura (SIN audio)
      if (isComplexCard && !isReadingShown) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                setState(() {
                  isReadingShown = true;
                });
                webViewController?.evaluateJavascript(source: "showReading()");
              },
              child: const Text(
                "Mostrar Lectura / Notas",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        );
      }

      // Simples (o complejas ya con lectura): ahora respuesta (CON audio)
      return Container(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              setState(() {
                isAnswerShown = true;
              });
              webViewController?.evaluateJavascript(source: "showAnswer()");
            },
            child: const Text(
              "Mostrar Respuesta",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      );
    }

    // PASO 2: Seguridad (si algo mostró respuesta sin lectura)
    if (isComplexCard && !isReadingShown) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              setState(() {
                isReadingShown = true;
              });
              webViewController?.evaluateJavascript(source: "showReading()");
            },
            child: const Text(
              "Mostrar Lectura / Notas",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      );
    }

    // PASO 3: Botones Mal/Bien (bloqueo por escritura)
    final bool writePassed = !isWriteModeActive || (currentWriteScore >= minScoreRequired);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildRatingButton("Mal", Colors.red, () => _submitAnswer(card, false), true),
          _buildRatingButton("Bien", Colors.green, () => _submitAnswer(card, true), writePassed),
        ],
      ),
    );
  }

  Widget _buildRatingButton(String text, Color color, VoidCallback onPressed, bool enabled) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: enabled ? color : Colors.grey.shade300,
              foregroundColor: enabled ? Colors.white : Colors.grey,
            ),
            onPressed: enabled ? onPressed : null,
            child: Text(text, style: const TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }

  Future<void> _submitAnswer(Flashcard card, bool isCorrect) async {
    if (_currentDeckSettings == null) return;

    if (card.state == CardState.newCard && card.learningStep == 0) {
      await _incrementNewCardCounter();
    }

    final bool repeatToday = _srsService.reviewCard(card, isCorrect, _currentDeckSettings!);

    int daysInterval = card.nextReview.difference(DateTime.now()).inDays;
    if (daysInterval < 0) daysInterval = 0;

    final reviewLog = ReviewLog()
      ..packName = card.packName
      ..timestamp = DateTime.now()
      ..cardOriginalId = card.originalId
      ..rating = isCorrect ? 3 : 1
      ..scheduledDays = daysInterval;

    final isar = Isar.getInstance();
    if (isar != null) {
      await isar.writeTxn(() async {
        await isar.flashcards.put(card);
        await isar.reviewLogs.put(reviewLog);
      });
    }

    if (repeatToday) {
      setState(() {
        studyQueue.add(card);
      });
    }

    _nextCard();
  }

  Future<void> _incrementNewCardCounter() async {
    final isar = Isar.getInstance();
    if (isar != null && _currentDeckSettings != null) {
      await isar.writeTxn(() async {
        final latestSettings = await isar.deckSettings.get(_currentDeckSettings!.id);
        if (latestSettings != null) {
          latestSettings.newCardsSeenToday += 1;
          latestSettings.lastNewCardStudyDate = DateTime.now();
          await isar.deckSettings.put(latestSettings);
          _currentDeckSettings = latestSettings;
        }
      });
    }
  }

  void _nextCard() {
    if (currentIndex < studyQueue.length - 1) {
      setState(() {
        currentIndex++;
        isAnswerShown = false;
        isReadingShown = false;
        currentWriteScore = 0;
      });

      _checkCardComplexity();

      webViewController?.loadData(
        data: HtmlGenerator.generateContent(
          studyQueue[currentIndex],
          writeMode: isWriteModeActive,
        ),
      );
    } else {
      setState(() {
        currentIndex++;
      });
    }
  }
}
