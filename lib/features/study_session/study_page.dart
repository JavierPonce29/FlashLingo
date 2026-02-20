import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:isar/isar.dart';

import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/review_log.dart';
import 'package:flashcards_app/data/models/study_session.dart';
import 'package:flashcards_app/features/study_session/html_generator.dart';
import 'package:flashcards_app/features/study_session/srs_service.dart';

class StudyPage extends StatefulWidget {
  final String packName;
  final List<Flashcard> cards;
  final int initialIndex;

  const StudyPage({
    super.key,
    required this.packName,
    required this.cards,
    this.initialIndex = 0,
  });

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  InAppWebViewController? webViewController;

  late List<Flashcard> studyQueue;
  int currentIndex = 0;

  // Estados UI
  bool isAnswerShown = false;
  bool isReadingShown = false;
  bool isComplexCard = false;

  // Estados Escritura
  bool isWriteModeActive = false;
  int currentWriteScore = 0;
  int minScoreRequired = 0;

  final SrsService _srsService = SrsService();
  DeckSettings? _currentDeckSettings;

  bool _sessionCleared = false;

  @override
  void initState() {
    super.initState();

    studyQueue = List.from(widget.cards);

    // Clamp inicial por seguridad (sesión recuperada / colas cambiadas).
    currentIndex = widget.initialIndex
        .clamp(0, studyQueue.isEmpty ? 0 : studyQueue.length - 1)
        .toInt();

    _loadDeckSettings();

    // Persistir el estado inicial de la sesión (por si el usuario sale sin responder nada).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _persistStudySession();
      _checkCardComplexity();
    });
  }

  Future<void> _loadDeckSettings() async {
    final isar = Isar.getInstance();
    if (isar == null) return;

    final settings = await isar.deckSettings
        .filter()
        .packNameEqualTo(widget.packName)
        .findFirst();

    if (!mounted) return;

    setState(() {
      _currentDeckSettings = settings;
      _checkCardComplexity();
    });
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
    final bool hasReading =
        readingStr.isNotEmpty && readingStr != card.question.trim();

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

  bool get _isFinished => currentIndex >= studyQueue.length;

  // Barra superior de color según tipo de tarjeta.
  // - Nueva: azul
  // - Primer paso (learningStep==0): naranja
  // - Todo lo demás (learningStep>0, review, relearning): verde
  Color _cardTypeColor(Flashcard card) {
    if (card.state == CardState.newCard) return Colors.blue;
    if (card.state == CardState.learning && card.learningStep == 0) {
      return Colors.orange;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isFinished) {
          await _clearStudySession();
        } else {
          await _persistStudySession();
        }
        return true;
      },
      child: _isFinished ? _buildFinished() : _buildStudy(),
    );
  }

  Widget _buildFinished() {
    // Asegurar limpieza (una sola vez).
    if (!_sessionCleared) {
      _sessionCleared = true;
      _clearStudySession();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Sesión Finalizada")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green,
            ),
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

  Widget _buildStudy() {
    final card = studyQueue[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Estudiando (${currentIndex + 1}/${studyQueue.length})"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 4,
            color: _cardTypeColor(card),
          ),
        ),
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
                      print(
                        "📝 Score escritura: $score% (Min: $minScoreRequired%)",
                      );
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
                _persistStudySession(); // guardar progreso aunque no haya calificación
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
              _persistStudySession(); // guardar progreso aunque no haya calificación
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
              _persistStudySession(); // guardar progreso aunque no haya calificación
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
    final bool writePassed =
        !isWriteModeActive || (currentWriteScore >= minScoreRequired);

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

  Widget _buildRatingButton(
      String text,
      Color color,
      VoidCallback onPressed,
      bool enabled,
      ) {
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

    final now = DateTime.now();

    // ✅ Contar "nueva vista" solo UNA vez: en el primer momento en que el usuario califica esta carta.
    final bool isFirstRating = card.lastReview.millisecondsSinceEpoch == 0;
    if (card.state == CardState.newCard && isFirstRating) {
      await _incrementNewCardCounter();
    }

    // Guardar lastReview para evitar dobles conteos y para tener trazabilidad.
    card.lastReview = now;

    final bool repeatToday =
    _srsService.reviewCard(card, isCorrect, _currentDeckSettings!);

    int daysInterval = card.nextReview.difference(now).inDays;
    if (daysInterval < 0) daysInterval = 0;

    final reviewLog = ReviewLog()
      ..packName = card.packName
      ..timestamp = now
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

    // Guardar sesión después de avanzar (para que currentIndex quede correcto).
    await _persistStudySession();
  }

  Future<void> _incrementNewCardCounter() async {
    final isar = Isar.getInstance();
    if (isar != null && _currentDeckSettings != null) {
      await isar.writeTxn(() async {
        final latestSettings =
        await isar.deckSettings.get(_currentDeckSettings!.id);
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

  Future<void> _persistStudySession() async {
    final isar = Isar.getInstance();
    if (isar == null) return;

    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);

    await isar.writeTxn(() async {
      var session = await isar.studySessions
          .filter()
          .packNameEqualTo(widget.packName)
          .findFirst();

      session ??= StudySession()..packName = widget.packName;

      session
        ..packName = widget.packName
        ..queueCardIds = studyQueue.map((c) => c.id).toList()
        ..currentIndex = currentIndex
        ..sessionDay = day
        ..lastUpdated = now;

      await isar.studySessions.put(session);
    });
  }

  Future<void> _clearStudySession() async {
    final isar = Isar.getInstance();
    if (isar == null) return;

    await isar.writeTxn(() async {
      await isar.studySessions
          .filter()
          .packNameEqualTo(widget.packName)
          .deleteAll();
    });
  }
}