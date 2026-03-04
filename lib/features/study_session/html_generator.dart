import 'dart:convert';
import 'package:flashcards_app/data/models/flashcard.dart';

class HtmlGenerator {
  static String generateContent(Flashcard card, {bool writeMode = false}) {
    Map<String, dynamic> extraData = {};
    final rawExtra = card.extraDataJson;
    if (rawExtra != null && rawExtra.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawExtra);
        if (decoded is Map<String, dynamic>) {
          extraData = decoded;
        } else if (decoded is Map) {
          extraData = decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {}
    }

    final String readingWord = (extraData['reading'] ?? '').toString().trim();
    final bool hasRealReading = readingWord.isNotEmpty && readingWord != card.question.trim();
    final bool isRecog = card.cardType.endsWith('recog');
    final bool isComplexRecog = isRecog && hasRealReading;

    final String css = _getBaseCss();
    String bodyContent = "";

    // Autoplay SOLO en recog simple
    String jsInit = (isRecog && !isComplexRecog) ? "playSequence('q-view');" : "";
    if (writeMode && !isRecog) {
      jsInit += " initWriteMode();";
    }

    if (isComplexRecog) {
      bodyContent = _generateComplexRecogBody(card, extraData);
    } else if (isRecog) {
      bodyContent = _generateSimpleRecogBody(card, extraData);
    } else {
      bodyContent = _generateProdBody(card, extraData, writeMode);
    }

    return """
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>$css</style>
</head>
<body onload="$jsInit">
  <div class="card-container">
    $bodyContent
  </div>

  <script>
    function playOne(id) {
      stopAll();
      var audio = document.getElementById(id);
      if (audio) audio.play().catch(e => console.log(e));
    }

    function stopAll() {
      document.querySelectorAll('audio').forEach(a => { a.pause(); a.currentTime = 0; });
    }

    function playSequence(containerId) {
      stopAll();
      var container = document.getElementById(containerId);
      if (!container) return;

      var aw = container.querySelector('.audio-w');
      var as = container.querySelector('.audio-s');

      if (aw) {
        aw.play().catch(e => console.log(e));
        aw.onended = function() {
          if (as) as.play().catch(e => console.log(e));
        };
      } else if (as) {
        as.play().catch(e => console.log(e));
      }
    }

    // LECTURA SIN AUDIO
    function showReading() {
      document.querySelectorAll('.reading-text').forEach(e => { e.style.visibility='visible'; e.style.opacity='1'; });
      document.querySelectorAll('.delayed-btn').forEach(e => { e.style.visibility='visible'; e.style.opacity='1'; });
    }

    function toggleTranslation() {
      var t = document.getElementById('hidden-trans');
      if (t) t.style.display = (t.style.display === 'none') ? 'block' : 'none';
    }

    function toggleUserRaw() {
      var t = document.getElementById('user-raw-container');
      if (t) t.style.display = (t.style.display === 'none') ? 'block' : 'none';
    }

    // --- ESCRITURA ---
    var targetSegments = [];

    function initWriteMode() {
      var rawEl = document.getElementById('target-hidden-raw');
      var container = document.getElementById('dynamic-write-area');
      if(!rawEl || !container) return;

      var rawHtml = rawEl.innerHTML;
      var splitRegex = /<strong>\\s*\\d+\\.\\s*<\\/strong>/gi;
      var parts = rawHtml.split(splitRegex);

      targetSegments = parts.map(p => cleanHtmlPart(p)).filter(p => p.length > 0);
      if (targetSegments.length === 0) targetSegments = [ cleanHtmlPart(rawHtml) ];

      var html = "";
      for (var i = 0; i < targetSegments.length; i++) {
        var label = targetSegments.length > 1 ? (i + 1) + ". " : "";
        html += '<div class="write-group">';
        if(label) html += '<span class="write-index">' + label + '</span>';
        html += '<textarea id="input-' + i + '" class="write-input" rows="2" placeholder="Escribe aquí..."></textarea>';
        html += '</div>';
      }
      container.innerHTML = html;
    }

    function cleanHtmlPart(text) {
      var noBr = text.replace(/<br\\s*\\/?>(\\s*)?/gi, ' ');
      var tmp = document.createElement("DIV");
      tmp.innerHTML = noBr;
      var plain = tmp.textContent || tmp.innerText || "";
      return plain.replace(/\\s+/g, ' ').trim();
    }

    // RESPUESTA CON AUTOPLAY
    function showAnswer() {
      var qView = document.getElementById('q-view');
      var aView = document.getElementById('a-view');

      // evaluar escritura si aplica
      var container = document.getElementById('dynamic-write-area');
      if (container && targetSegments.length > 0) {
        var totalPercent = 0;
        var resultHtml = "";
        var fullUserText = "";

        for (var i = 0; i < targetSegments.length; i++) {
          var inputEl = document.getElementById('input-' + i);
          var userText = inputEl ? inputEl.value : "";
          var targetText = targetSegments[i];

          if (targetSegments.length > 1) fullUserText += (i+1) + ". " + userText + "<br>";
          else fullUserText += userText;

          var diff = compareByWords(userText, targetText);
          totalPercent += diff.percent;

          var label = targetSegments.length > 1 ? "<strong>" + (i + 1) + ". </strong>" : "";
          resultHtml += '<div class="diff-row">' + label + diff.html + '</div>';
        }

        var finalAverage = Math.round(totalPercent / targetSegments.length);

        var resBox = document.getElementById('diff-results-box');
        if(resBox) resBox.innerHTML = resultHtml;

        var rawBox = document.getElementById('user-raw-text');
        if(rawBox) rawBox.innerHTML = fullUserText;

        if(window.flutter_inappwebview) {
          window.flutter_inappwebview.callHandler('submitScore', finalAverage);
        }
      }

      // cambiar vista
      if(qView && aView) {
        qView.style.display = 'none';
        aView.style.display = 'block';

        // ✅ clave: pequeño delay para asegurar DOM listo antes de play()
        var hasAudio = aView.querySelector('audio');
        if (hasAudio) {
          setTimeout(function() {
            playSequence('a-view');
          }, 60);
        }
      }
    }

    function compareByWords(user, target) {
      var cleanUser = (user || "").replace(/\\s+/g, ' ').trim();
      var cleanTarget = (target || "").replace(/\\s+/g, ' ').trim();

      var uWords = cleanUser.length ? cleanUser.split(' ') : [];
      var tWords = cleanTarget.length ? cleanTarget.split(' ') : [];

      var html = "";
      var totalCorrectChars = 0;

      var totalTargetChars = cleanTarget.replace(/ /g, '').length;
      if (totalTargetChars === 0) totalTargetChars = 1;

      for (var i = 0; i < tWords.length; i++) {
        var tWord = tWords[i];
        var uWord = uWords[i] || "";

        var wordHtml = "";
        var wMax = Math.max(tWord.length, uWord.length);

        for (var k = 0; k < wMax; k++) {
          var tChar = tWord[k] || "";
          var uChar = uWord[k] || "";

          if (tChar.toLowerCase() === uChar.toLowerCase()) {
            wordHtml += "<span class='diff-good'>" + tChar + "</span>";
            if (tChar !== "") totalCorrectChars++;
          } else {
            if (tChar !== "") wordHtml += "<span class='diff-bad'>" + tChar + "</span>";
          }
        }

        html += wordHtml + " ";
      }

      var percent = Math.round((totalCorrectChars / totalTargetChars) * 100);
      if (percent > 100) percent = 100;

      return { html: html, percent: percent };
    }
  </script>
</body>
</html>
""";
  }

  static String _generateSimpleRecogBody(Flashcard card, Map<String, dynamic> extra) {
    final String formas = (extra['forms'] ?? '').toString();
    final String awSrc = card.audioPath ?? '';
    final String asSrc = card.sentenceAudioPath ?? '';
    final String imgHtml = card.imagePath != null ? '<img src="${card.imagePath}" class="card-img" />' : '';

    final String questionView = """
<div id="q-view">
  <div class="row-main">
    <div class="word-text">${card.question}</div>
    ${_playBtn('audio-word-q', awSrc.isNotEmpty)}
  </div>
  <div class="separator"></div>
  <div class="row-sent">
    <div class="sentence-text">${card.sentence ?? ''}</div>
    ${_playBtn('audio-sent-q', asSrc.isNotEmpty)}
  </div>
  $imgHtml
  ${_audioHtml('audio-word-q', awSrc, 'audio-w')}
  ${_audioHtml('audio-sent-q', asSrc, 'audio-s')}
</div>
""";

    final String answerView = """
<div id="a-view" style="display:none;">
  <div class="row-main">
    <div class="word-text">${card.question}</div>
    ${_playBtn('audio-word-a', awSrc.isNotEmpty)}
  </div>
  <div class="separator"></div>
  <div class="meaning-text">${card.answer}</div>
  ${formas.isNotEmpty ? '<div class="forms-text">Formas: $formas</div>' : ''}
  <div class="row-sent" style="margin-top: 15px;">
    <div class="sentence-text">${card.sentence ?? ''}</div>
    ${_playBtn('audio-sent-a', asSrc.isNotEmpty)}
  </div>
  <div class="trans-toggle" onclick="toggleTranslation()">Ver Traducción ▼</div>
  <div id="hidden-trans" class="translation-text" style="display:none;">
    ${card.translation ?? ''}
  </div>
  $imgHtml
  ${_audioHtml('audio-word-a', awSrc, 'audio-w')}
  ${_audioHtml('audio-sent-a', asSrc, 'audio-s')}
</div>
""";

    return questionView + answerView;
  }

  static String _generateProdBody(Flashcard card, Map<String, dynamic> extra, bool writeMode) {
    final String formas = (extra['forms'] ?? '').toString();
    final String reading = (extra['target_reading'] ?? '').toString();
    final String awSrc = card.audioPath ?? '';
    final String asSrc = card.sentenceAudioPath ?? '';
    final String imgHtml = card.imagePath != null ? '<img src="${card.imagePath}" class="card-img" />' : '';

    String inputHtml = "";
    String sentenceArea = """
<div class="sentence-text">${card.translation ?? ''}</div>
""";

    if (writeMode) {
      inputHtml = """
<div class="write-section">
  <div class="write-label">Escribe la(s) oración(es):</div>
  <div id="dynamic-write-area"></div>
  <div id="target-hidden-raw" style="display:none;">${card.translation ?? ''}</div>
</div>
""";

      sentenceArea = """
<div id="diff-results-box" class="diff-container"></div>
<div class="small-note">(Verde: Bien / Rojo: Mal)</div>

<div class="toggle-link" onclick="toggleUserRaw()">Ver mi respuesta</div>
<div id="user-raw-container" style="display:none; margin-bottom:10px;">
  <div id="user-raw-text" class="user-raw-box"></div>
</div>

<div class="sentence-text" style="font-size:0.9em; color:#888; margin-top:5px; border-top:1px dashed #ccc; padding-top:5px;">
  Correcto:<br/>${card.translation ?? ''}
</div>
""";
    }

    final String questionView = """
<div id="q-view">
  <div class="meaning-prod">${card.question}</div>
  <div class="sentence-trans-prod">${card.sentence ?? ''}</div>
  $inputHtml
</div>
""";

    final String answerView = """
<div id="a-view" style="display:none;">
  <div class="row-main">
    <div class="ruby-block">
      <div class="word-text">${card.answer}</div>
      ${reading.isNotEmpty ? '<div class="reading-sub">$reading</div>' : ''}
    </div>
    ${_playBtn('audio-word-a', awSrc.isNotEmpty)}
  </div>

  <div class="separator"></div>

  <div class="meaning-text" style="color: #555;">${card.question}</div>
  ${formas.isNotEmpty ? '<div class="forms-text">Formas: $formas</div>' : ''}

  <div class="row-sent" style="margin-top: 15px; display:block;">
    $sentenceArea
    <div style="margin-top:10px; text-align:center;">
      ${_playBtn('audio-sent-a', asSrc.isNotEmpty)}
    </div>
  </div>

  $imgHtml

  <div class="trans-toggle" onclick="toggleTranslation()">Ver Traducción ▼</div>
  <div id="hidden-trans" class="translation-text" style="display:none;">
    ${card.sentence ?? ''}
  </div>

  ${_audioHtml('audio-word-a', awSrc, 'audio-w')}
  ${_audioHtml('audio-sent-a', asSrc, 'audio-s')}
</div>
""";

    return questionView + answerView;
  }

  static String _generateComplexRecogBody(Flashcard card, Map<String, dynamic> extra) {
    final String formas = (extra['forms'] ?? '').toString();
    final String awSrc = card.audioPath ?? '';
    final String asSrc = card.sentenceAudioPath ?? '';
    final String imgHtml = card.imagePath != null ? '<img src="${card.imagePath}" class="card-img" />' : '';

    final String readingWord = (extra['reading'] ?? '').toString();
    final String readingSent = (extra['sentence_reading'] ?? '').toString();

    final String btnWordWrapperQ = awSrc.isNotEmpty
        ? '<div class="delayed-btn" style="visibility:hidden; opacity:0; transition: opacity 0.3s;">${_playBtn('audio-word-q', true)}</div>'
        : '';
    final String btnSentWrapperQ = asSrc.isNotEmpty
        ? '<div class="delayed-btn" style="visibility:hidden; opacity:0; transition: opacity 0.3s;">${_playBtn('audio-sent-q', true)}</div>'
        : '';

    final String btnWordWrapperA = awSrc.isNotEmpty
        ? '<div class="delayed-btn" style="visibility:hidden; opacity:0; transition: opacity 0.3s;">${_playBtn('audio-word-a', true)}</div>'
        : '';
    final String btnSentWrapperA = asSrc.isNotEmpty
        ? '<div class="delayed-btn" style="visibility:hidden; opacity:0; transition: opacity 0.3s;">${_playBtn('audio-sent-a', true)}</div>'
        : '';

    final String questionView = """
<div id="q-view">
  <div class="row-main">
    <div class="ruby-block">
      <div class="word-text">${card.question}</div>
      <div class="reading-text" style="visibility:hidden; opacity:0;">$readingWord</div>
    </div>
    $btnWordWrapperQ
  </div>

  <div class="separator"></div>

  <div class="row-sent">
    <div class="ruby-block">
      <div class="sentence-text">${card.sentence ?? ''}</div>
      <div class="reading-text sentence-reading" style="visibility:hidden; opacity:0;">$readingSent</div>
    </div>
    $btnSentWrapperQ
  </div>

  $imgHtml
  ${_audioHtml('audio-word-q', awSrc, 'audio-w')}
  ${_audioHtml('audio-sent-q', asSrc, 'audio-s')}
</div>
""";

    final String answerView = """
<div id="a-view" style="display:none;">
  <div class="row-main">
    <div class="ruby-block">
      <div class="word-text">${card.question}</div>
      <div class="reading-text" style="visibility:hidden; opacity:0;">$readingWord</div>
    </div>
    $btnWordWrapperA
  </div>

  <div class="separator"></div>

  <div class="meaning-text">${card.answer}</div>
  ${formas.isNotEmpty ? '<div class="forms-text">Formas: $formas</div>' : ''}

  <div class="row-sent" style="margin-top: 15px;">
    <div class="ruby-block">
      <div class="sentence-text">${card.sentence ?? ''}</div>
      <div class="reading-text sentence-reading" style="visibility:hidden; opacity:0;">$readingSent</div>
    </div>
    $btnSentWrapperA
  </div>

  <div class="trans-toggle" onclick="toggleTranslation()">Ver Traducción ▼</div>
  <div id="hidden-trans" class="translation-text" style="display:none;">
    ${card.translation ?? ''}
  </div>

  $imgHtml
  ${_audioHtml('audio-word-a', awSrc, 'audio-w')}
  ${_audioHtml('audio-sent-a', asSrc, 'audio-s')}
</div>
""";

    return questionView + answerView;
  }

  static String _audioHtml(String id, String src, String classType) {
    if (src.isEmpty) return '';
    return '<audio id="$id" class="$classType" src="$src" preload="auto"></audio>';
  }

  static String _playBtn(String id, bool exists) {
    if (!exists) return '';
    return """<button class="audio-btn" onclick="playOne('$id')"><svg viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg></button>""";
  }

  static String _getBaseCss() {
    return """
body { font-family: 'Segoe UI', Roboto, sans-serif; text-align: center; background-color: #ffffff; color: #333; margin: 0; padding: 20px; display: flex; flex-direction: column; justify-content: center; min-height: 95vh; }
.card-container { width: 100%; max-width: 500px; margin: 0 auto; }
.row-main, .row-sent { display: flex; flex-direction: row; align-items: center; justify-content: center; gap: 15px; }
.ruby-block { display: flex; flex-direction: column; align-items: center; }
.word-text { font-size: 32px; font-weight: 600; margin: 5px 0; }
.meaning-text { font-size: 26px; font-weight: 600; margin: 10px 0; }
.sentence-text { font-size: 18px; color: #555; margin: 10px 0; text-align: center; }
.translation-text { font-size: 16px; color: #666; margin-top: 8px; padding: 10px; background: #f7f7f7; border-radius: 10px; }
.separator { height: 1px; background: #e0e0e0; margin: 15px 0; }
.audio-btn { background: #f0f0f0; border: none; border-radius: 999px; width: 44px; height: 44px; display: inline-flex; align-items: center; justify-content: center; cursor: pointer; box-shadow: 0 1px 3px rgba(0,0,0,0.15); }
.audio-btn svg { width: 22px; height: 22px; fill: #333; }
.trans-toggle { margin-top: 12px; font-size: 14px; color: #0077cc; cursor: pointer; user-select: none; }
.forms-text { margin-top: 10px; font-size: 14px; color: #777; }

.reading-text { font-size: 18px; color: #777; margin-top: 3px; transition: opacity 0.3s; }
.sentence-reading { font-size: 16px; }
.reading-sub { font-size: 18px; color: #777; margin-top: 3px; }

.meaning-prod { font-size: 22px; font-weight: 600; color: #444; margin-bottom: 10px; }
.sentence-trans-prod { font-size: 16px; color: #777; margin-bottom: 15px; }

.write-section { margin-top: 10px; text-align: left; }
.write-label { font-size: 14px; color: #666; margin-bottom: 8px; }
.write-group { margin-bottom: 10px; }
.write-index { font-size: 14px; color: #555; margin-right: 6px; }
.write-input { width: 100%; box-sizing: border-box; font-size: 16px; padding: 10px; border-radius: 10px; border: 1px solid #ddd; outline: none; }
.write-input:focus { border-color: #66aaff; box-shadow: 0 0 0 3px rgba(102,170,255,0.2); }

.diff-container { text-align: left; background: #fafafa; border: 1px solid #eee; border-radius: 10px; padding: 10px; margin-top: 10px; }
.diff-row { font-size: 16px; line-height: 1.5; margin-bottom: 6px; word-wrap: break-word; }
.diff-good { color: #1a7f37; font-weight: 600; }
.diff-bad { color: #c62828; font-weight: 700; text-decoration: underline; }

.small-note { font-size: 12px; color: #777; margin-top: 6px; }
.toggle-link { font-size: 13px; color: #0077cc; cursor: pointer; user-select: none; margin-top: 10px; display: inline-block; }
.user-raw-box { font-size: 14px; color: #444; padding: 8px; border: 1px dashed #ccc; border-radius: 10px; background: #fff; }
.card-img { width: 100%; max-height: 220px; object-fit: contain; margin-top: 15px; border-radius: 12px; border: 1px solid #eee; }

@media (max-width: 420px) {
  .word-text { font-size: 28px; }
  .meaning-text { font-size: 22px; }
  .sentence-text { font-size: 16px; }
}
""";
  }
}
