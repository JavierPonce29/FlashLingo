import 'dart:convert';
import 'dart:ui';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';

class HtmlGenerator {
  static const Set<String> _allowedHtmlTags = {
    'a', 'b', 'big', 'blockquote', 'br', 'code',
    'div', 'em', 'font', 'hr', 'i', 'img', 'kbd', 'li', 'mark', 'ol', 'p', 'pre', 'rp', 'rt', 'ruby', 's',
    'small', 'span', 'strike', 'strong', 'sub', 'sup', 'table', 'tbody', 'td', 'th', 'thead', 'tr', 'u', 'ul',
  };

  static String _safeHtml(String? input) {
    if (input == null || input.isEmpty) return '';
    var html = input.replaceAll('\u0000', '');
    html = html.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');
    html = html.replaceAll(
      RegExp(
        r'<\s*(script|style|iframe|object|embed|link|meta|base)\b[^>]*>[\s\S]*?<\s*/\s*\1\s*>',
        caseSensitive: false,
      ),
      '',
    );
    html = html.replaceAll(
      RegExp(
        r'<\s*(script|style|iframe|object|embed|link|meta|base)\b[^>]*\/?\s*>',
        caseSensitive: false,
      ),
      '',
    );
    html = html.replaceAllMapped(
      RegExp(r'<[^>]+>'),
      (m) => _sanitizeTag(m.group(0)!),
    );
    return html;
  }

  static String _sanitizeTag(String tag) {
    final match = RegExp(r'^<\s*/?\s*([a-zA-Z0-9]+)').firstMatch(tag);
    if (match == null) return '';
    final tagName = match.group(1)!.toLowerCase();
    if (!_allowedHtmlTags.contains(tagName)) return '';

    var sanitized = tag;
    sanitized = sanitized.replaceAll(
      RegExp(
        r'\son[a-zA-Z0-9_-]+\s*=\s*(".*?"|\x27.*?\x27|[^\s>]+)',
        caseSensitive: false,
      ),
      '',
    );
    sanitized = sanitized.replaceAll(
      RegExp(
        r'\s(src|href)\s*=\s*("|\x27)\s*(javascript:|data:text/html)[^"\x27]*\2',
        caseSensitive: false,
      ),
      '',
    );
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\sstyle\s*=\s*(".*?"|\x27.*?\x27)', caseSensitive: false),
      (m) {
        final raw = m.group(1)!;
        if (raw.length < 2) return '';
        final quote = raw.substring(0, 1);
        final value = raw.substring(1, raw.length - 1);
        final clean = _sanitizeInlineStyle(value);
        if (clean.isEmpty) return '';
        return ' style=$quote$clean$quote';
      },
    );
    return sanitized;
  }

  static String _sanitizeInlineStyle(String value) {
    var clean = value;
    clean = clean.replaceAll(
      RegExp(r'expression\s*\([^)]*\)', caseSensitive: false),
      '',
    );
    clean = clean.replaceAll(
      RegExp(r'url\s*\(\s*["\x27]?\s*javascript:[^)]*\)', caseSensitive: false),
      '',
    );
    clean = clean.replaceAll(
      RegExp(r'-moz-binding\s*:[^;]+;?', caseSensitive: false),
      '',
    );
    clean = clean.replaceAll(RegExp(r'@import', caseSensitive: false), '');
    return clean.trim();
  }

  static String _safeAttr(String? input) {
    if (input == null || input.isEmpty) return '';
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }

  static String _safeJsString(String? input) {
    if (input == null || input.isEmpty) return '';
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll("'", r"\'")
        .replaceAll('\n', r'\n')
        .replaceAll('\r', '');
  }

  static String _imageHtml(String? src) {
    if (src == null || src.trim().isEmpty) return '';
    final normalized = src.trim();
    final lower = normalized.toLowerCase();
    if (lower.startsWith('javascript:') || lower.startsWith('data:text/html')) {
      return '';
    }
    return '<img src="${_safeAttr(normalized)}" class="card-img" />';
  }

  static String generateContent(
    Flashcard card, {
    required AppLocalizations l10n,
    bool writeMode = false,
    Brightness brightness = Brightness.light,
  }) {
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
    final bool hasRealReading =
        readingWord.isNotEmpty && readingWord != card.question.trim();
    final bool isRecog = card.cardType.endsWith('recog');
    final bool isComplexRecog = isRecog && hasRealReading;

    final String css = _getBaseCss(brightness);
    String bodyContent = "";

    // Autoplay SOLO en recog simple
    String jsInit = (isRecog && !isComplexRecog)
        ? "playSequence('q-view');"
        : "";
    if (writeMode && !isRecog) {
      jsInit += " initWriteMode();";
    }

    if (isComplexRecog) {
      bodyContent = _generateComplexRecogBody(card, extraData, l10n);
    } else if (isRecog) {
      bodyContent = _generateSimpleRecogBody(card, extraData, l10n);
    } else {
      bodyContent = _generateProdBody(card, extraData, writeMode, l10n);
    }

    final writePlaceholder = _safeJsString(l10n.tr('html_write_placeholder'));

    return """
<!DOCTYPE html>
<html lang="${l10n.languageCode}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>$css</style>
</head>
<body onload="$jsInit">
  <div class="card-container">
    <div class="flashcard card">
      $bodyContent
    </div>
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

    function revealReadingElements(root) {
      var scope = root || document;
      scope.querySelectorAll('.reading-text').forEach(e => { e.style.visibility='visible'; e.style.opacity='1'; });
      scope.querySelectorAll('.delayed-btn').forEach(e => { e.style.visibility='visible'; e.style.opacity='1'; });
    }

    function showReading() {
      var qView = document.getElementById('q-view');
      revealReadingElements(qView || document);
      playSequence('q-view');
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
        html += '<textarea id="input-' + i + '" class="write-input" rows="2" placeholder="$writePlaceholder"></textarea>';
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
        revealReadingElements(aView);
        qView.style.display = 'none';
        aView.style.display = 'block';

        // pequeno delay para asegurar DOM listo antes de play()
        setTimeout(function() {
          playSequence('a-view');
        }, 60);
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

  static String _generateSimpleRecogBody(
    Flashcard card,
    Map<String, dynamic> extra,
    AppLocalizations l10n,
  ) {
    final String questionHtml = _safeHtml(card.question);
    final String answerHtml = _safeHtml(card.answer);
    final String sentenceHtml = _safeHtml(card.sentence);
    final String translationHtml = _safeHtml(card.translation);
    final String formas = _safeHtml((extra['forms'] ?? '').toString());
    final String awSrc = card.audioPath ?? '';
    final String asSrc = card.sentenceAudioPath ?? '';
    final String imgHtml = _imageHtml(card.imagePath);

    final String questionView =
        """
<section id="q-view" class="card-face front">
  <div class="row-main">
    <div class="word-text">$questionHtml</div>
    ${_playBtn('audio-word-q', awSrc.isNotEmpty)}
  </div>
  <div class="separator"></div>
  <div class="sentence-wrapper">
    <div class="row-sent">
      <div class="sentence-text">$sentenceHtml</div>
      ${_playBtn('audio-sent-q', asSrc.isNotEmpty)}
    </div>
  </div>
  $imgHtml
  ${_audioHtml('audio-word-q', awSrc, 'audio-w')}
  ${_audioHtml('audio-sent-q', asSrc, 'audio-s')}
</section>
""";

    final String answerView =
        """
<section id="a-view" class="card-face back" style="display:none;">
  <div class="row-main">
    <div class="word-text">$questionHtml</div>
    ${_playBtn('audio-word-a', awSrc.isNotEmpty)}
  </div>
  <div class="separator"></div>
  <div class="meaning-text">$answerHtml</div>
  ${formas.isNotEmpty ? '<div class="forms-text"><span class="prompt">${_safeHtml(l10n.tr('html_forms'))}:</span> $formas</div>' : ''}
  <div class="sentence-wrapper">
    <div class="row-sent">
      <div class="sentence-text">$sentenceHtml</div>
      ${_playBtn('audio-sent-a', asSrc.isNotEmpty)}
    </div>
  </div>
  <div class="trans-toggle hint" onclick="toggleTranslation()">${_safeHtml(l10n.tr('html_view_translation'))} v</div>
  <div id="hidden-trans" class="translation-text sentence-translation" style="display:none;">
    $translationHtml
  </div>
  $imgHtml
  ${_audioHtml('audio-word-a', awSrc, 'audio-w')}
  ${_audioHtml('audio-sent-a', asSrc, 'audio-s')}
</section>
""";

    return questionView + answerView;
  }

  static String _generateProdBody(
    Flashcard card,
    Map<String, dynamic> extra,
    bool writeMode,
    AppLocalizations l10n,
  ) {
    final String questionHtml = _safeHtml(card.question);
    final String answerHtml = _safeHtml(card.answer);
    final String sentenceHtml = _safeHtml(card.sentence);
    final String translationHtml = _safeHtml(card.translation);
    final String formas = _safeHtml((extra['forms'] ?? '').toString());
    final String reading = _safeHtml(
      (extra['target_reading'] ?? '').toString(),
    );
    final String awSrc = card.audioPath ?? '';
    final String asSrc = card.sentenceAudioPath ?? '';
    final String imgHtml = _imageHtml(card.imagePath);

    String inputHtml = "";
    String sentenceArea =
        """
<div class="sentence-text">$translationHtml</div>
""";

    if (writeMode) {
      inputHtml =
          """
<div class="write-section">
  <div class="write-label">${_safeHtml(l10n.tr('html_write_sentences'))}</div>
  <div id="dynamic-write-area"></div>
  <div id="target-hidden-raw" style="display:none;">$translationHtml</div>
</div>
""";

      sentenceArea =
          """
<div id="diff-results-box" class="diff-container"></div>
<div class="small-note">${_safeHtml(l10n.tr('html_note_good_bad'))}</div>

<div class="toggle-link" onclick="toggleUserRaw()">${_safeHtml(l10n.tr('html_view_my_answer'))}</div>
<div id="user-raw-container" style="display:none; margin-bottom:10px;">
  <div id="user-raw-text" class="user-raw-box"></div>
</div>

<div class="sentence-text answer-reference">
  ${_safeHtml(l10n.tr('html_correct'))}:<br/>$translationHtml
</div>
""";
    }

    final String questionView =
        """
<section id="q-view" class="card-face front">
  <div class="meaning-prod">$questionHtml</div>
  <div class="sentence-trans-prod">$sentenceHtml</div>
  $inputHtml
</section>
""";

    final String answerView =
        """
<section id="a-view" class="card-face back" style="display:none;">
  <div class="row-main">
    <div class="ruby-block">
      <div class="word-text">$answerHtml</div>
      ${reading.isNotEmpty ? '<div class="reading-sub">$reading</div>' : ''}
    </div>
    ${_playBtn('audio-word-a', awSrc.isNotEmpty)}
  </div>

  <div class="separator"></div>

  <div class="meaning-text meaning-muted">$questionHtml</div>
  ${formas.isNotEmpty ? '<div class="forms-text"><span class="prompt">${_safeHtml(l10n.tr('html_forms'))}:</span> $formas</div>' : ''}

  <div class="sentence-wrapper sentence-wrapper-block">
    $sentenceArea
    <div style="margin-top:10px; text-align:center;">
      ${_playBtn('audio-sent-a', asSrc.isNotEmpty)}
    </div>
  </div>

  $imgHtml

  <div class="trans-toggle hint" onclick="toggleTranslation()">${_safeHtml(l10n.tr('html_view_translation'))} v</div>
  <div id="hidden-trans" class="translation-text sentence-translation" style="display:none;">
    $sentenceHtml
  </div>

  ${_audioHtml('audio-word-a', awSrc, 'audio-w')}
  ${_audioHtml('audio-sent-a', asSrc, 'audio-s')}
</section>
""";

    return questionView + answerView;
  }

  static String _generateComplexRecogBody(
    Flashcard card,
    Map<String, dynamic> extra,
    AppLocalizations l10n,
  ) {
    final String questionHtml = _safeHtml(card.question);
    final String answerHtml = _safeHtml(card.answer);
    final String sentenceHtml = _safeHtml(card.sentence);
    final String translationHtml = _safeHtml(card.translation);
    final String formas = _safeHtml((extra['forms'] ?? '').toString());
    final String awSrc = card.audioPath ?? '';
    final String asSrc = card.sentenceAudioPath ?? '';
    final String imgHtml = _imageHtml(card.imagePath);

    final String readingWord = _safeHtml((extra['reading'] ?? '').toString());
    final String readingSent = _safeHtml(
      (extra['sentence_reading'] ?? '').toString(),
    );

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

    final String questionView =
        """
<section id="q-view" class="card-face front">
  <div class="row-main">
    <div class="ruby-block">
      <div class="word-text">$questionHtml</div>
      <div class="reading-text" style="visibility:hidden; opacity:0;">$readingWord</div>
    </div>
    $btnWordWrapperQ
  </div>

  <div class="separator"></div>

  <div class="sentence-wrapper">
    <div class="row-sent">
      <div class="ruby-block">
        <div class="sentence-text">$sentenceHtml</div>
        <div class="reading-text sentence-reading" style="visibility:hidden; opacity:0;">$readingSent</div>
      </div>
      $btnSentWrapperQ
    </div>
  </div>

  $imgHtml
  ${_audioHtml('audio-word-q', awSrc, 'audio-w')}
  ${_audioHtml('audio-sent-q', asSrc, 'audio-s')}
</section>
""";

    final String answerView =
        """
<section id="a-view" class="card-face back" style="display:none;">
  <div class="row-main">
    <div class="ruby-block">
      <div class="word-text">$questionHtml</div>
      <div class="reading-text" style="visibility:hidden; opacity:0;">$readingWord</div>
    </div>
    $btnWordWrapperA
  </div>

  <div class="separator"></div>

  <div class="meaning-text">$answerHtml</div>
  ${formas.isNotEmpty ? '<div class="forms-text"><span class="prompt">${_safeHtml(l10n.tr('html_forms'))}:</span> $formas</div>' : ''}

  <div class="sentence-wrapper">
    <div class="row-sent">
      <div class="ruby-block">
        <div class="sentence-text">$sentenceHtml</div>
        <div class="reading-text sentence-reading" style="visibility:hidden; opacity:0;">$readingSent</div>
      </div>
      $btnSentWrapperA
    </div>
  </div>

  <div class="trans-toggle hint" onclick="toggleTranslation()">${_safeHtml(l10n.tr('html_view_translation'))} v</div>
  <div id="hidden-trans" class="translation-text sentence-translation" style="display:none;">
    $translationHtml
  </div>

  $imgHtml
  ${_audioHtml('audio-word-a', awSrc, 'audio-w')}
  ${_audioHtml('audio-sent-a', asSrc, 'audio-s')}
</section>
""";

    return questionView + answerView;
  }

  static String _audioHtml(String id, String src, String classType) {
    final normalized = src.trim();
    if (normalized.isEmpty) return '';
    final lower = normalized.toLowerCase();
    if (lower.startsWith('javascript:') || lower.startsWith('data:text/html')) {
      return '';
    }
    return '<audio id="$id" class="$classType" src="${_safeAttr(normalized)}" preload="auto"></audio>';
  }

  static String _playBtn(String id, bool exists) {
    if (!exists) return '';
    return """<button class="audio-btn" onclick="playOne('$id')"><svg viewBox="0 0 40 40" aria-hidden="true"><circle cx="20" cy="20" r="19"></circle><path d="M16 12.5v15l12-7.5z"></path></svg></button>""";
  }

  static String _getBaseCss(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final pageBg = isDark ? 'rgb(11, 7, 22)' : 'rgb(251, 250, 254)';
    final cardBg = isDark ? 'rgb(19, 12, 34)' : 'rgb(255, 255, 255)';
    final text = isDark ? 'rgba(255, 255, 255, 0.85)' : 'rgb(48, 32, 111)';
    final soft = isDark
        ? 'rgba(255, 255, 255, 0.72)'
        : 'rgba(48, 32, 111, 0.72)';
    final accent = isDark ? 'rgb(153, 128, 255)' : 'rgb(101, 68, 233)';
    final accentDark = isDark ? 'rgb(133, 102, 255)' : 'rgb(75, 50, 174)';
    final line = isDark ? 'rgb(48, 32, 111)' : 'rgb(216, 208, 249)';
    final panel = isDark ? 'rgb(26, 18, 61)' : 'rgb(246, 245, 253)';
    final audioFill = isDark ? 'rgb(26, 18, 61)' : 'rgb(246, 245, 253)';
    final audioBorder = isDark ? 'rgb(48, 32, 111)' : 'rgb(216, 208, 249)';
    final diffGood = isDark ? 'rgb(140, 224, 175)' : 'rgb(29, 122, 69)';
    final diffBad = isDark ? 'rgb(255, 154, 154)' : 'rgb(179, 43, 43)';
    final cardShadow = isDark
        ? 'rgba(0, 0, 0, 0.75)'
        : 'rgba(133, 102, 255, 0.4)';
    final focusRing = isDark
        ? 'rgba(153, 128, 255, 0.28)'
        : 'rgba(101, 68, 233, 0.16)';

    return """
html, body { margin: 0; padding: 0; }
body {
  margin: 20px;
  overflow-wrap: break-word;
  overscroll-behavior: none;
  background-color: $pageBg;
  color: $text;
  font-family: 'Open Sans', 'Segoe UI', sans-serif;
  font-size: 16px;
  line-height: 1.187;
  text-align: left;
  color-scheme: ${isDark ? 'dark' : 'light'};
}

a {
  color: $accent;
  text-decoration: none;
}

strong {
  font-weight: 700;
  color: $accentDark;
}

ul, ol {
  margin-left: 20px;
  margin-bottom: 10px;
  padding-left: 0;
}

li {
  margin-bottom: 5px;
  font-size: 18px;
  line-height: 1.4;
  color: $text;
}

blockquote {
  margin: 0;
  padding-left: 16px;
  border-left: 3px solid $line;
  color: $soft;
}

.card-container {
  width: 100%;
  max-width: 500px;
  margin: 0 auto;
}

.card {
  font-family: 'Open Sans', 'Segoe UI', sans-serif;
  font-size: 16px;
  text-align: left;
  color: $text;
}

.flashcard {
  display: block;
  padding: 0 24px 20px 24px;
  min-height: 200px;
  border-radius: 10px;
  background-color: $cardBg;
  box-shadow: 0 5px 10px -5px $cardShadow;
}

.card-face {
  display: block;
  animation: cardFade 0.2s ease;
}

.front {
  padding-top: 10px;
  margin-bottom: -10px;
  font-family: 'Montserrat', 'Open Sans', 'Segoe UI', sans-serif;
}

.back {
  font-family: 'Open Sans', 'Segoe UI', sans-serif;
  font-size: 20px;
}

.row-main,
.row-sent {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
}

.row-main {
  position: relative;
  justify-content: center;
  align-items: center;
  min-height: 44px;
}

.row-sent {
  align-items: center;
}

.ruby-block {
  flex: 1;
  min-width: 0;
}

.row-main > .word-text,
.row-main > .ruby-block {
  width: 100%;
  text-align: center;
}

.row-main > .audio-btn,
.row-main > .delayed-btn {
  position: absolute;
  right: 0;
  top: 50%;
  transform: translateY(-50%);
}

.word-text,
.reading-sub {
  color: $accent;
  font-size: 32px;
  line-height: 1.18;
}

.word-text {
  font-weight: 700;
}

.meaning-text {
  font-size: 24px;
  margin-bottom: 0;
  color: $text;
  font-weight: 600;
  line-height: 1.35;
}

.meaning-muted {
  color: $accentDark;
}

.sentence-wrapper {
  display: block;
  margin-top: 34px;
}

.sentence-wrapper-block {
  display: block;
}

.sentence-text,
.example-sentence,
.sentence-trans-prod {
  font-size: 20px;
  line-height: 1.5;
  color: $text;
  margin: 0;
}

.translation-text,
.sentence-translation {
  margin-top: 8px;
  font-style: italic;
  font-size: 16px;
  color: $soft;
}

.meaning-prod {
  font-size: 24px;
  margin-bottom: 14px;
  color: $text;
  font-weight: 700;
  line-height: 1.35;
}

.forms-text,
.irregular-forms {
  color: $accentDark;
  margin-top: 12px;
  font-size: 16px;
  line-height: 1.45;
}

.prompt {
  font-weight: 700;
}

.hint,
.trans-toggle,
.toggle-link {
  color: $accent;
}

.trans-toggle,
.toggle-link {
  display: inline-block;
  margin-top: 18px;
  cursor: pointer;
  user-select: none;
  font-size: 16px;
  font-weight: 600;
}

.separator {
  border: 0;
  border-bottom: 1px solid $line;
  margin: 28px 0 32px;
}

.reading-text,
.reading-sub {
  color: $accent;
  font-size: 20px;
  line-height: 1.3;
  margin-top: 4px;
  transition: opacity 0.25s ease;
}

.sentence-reading {
  font-size: 16px;
  margin-top: 8px;
}

.audio-btn {
  -webkit-appearance: none;
  appearance: none;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  vertical-align: middle;
  margin: 0;
  padding: 0;
  border: 0;
  background: transparent;
  cursor: pointer;
  flex-shrink: 0;
}

.audio-btn svg {
  width: 40px;
  height: 40px;
}

.audio-btn svg circle {
  fill: $audioFill;
  stroke: $audioBorder;
  stroke-width: 1;
}

.audio-btn svg path {
  fill: $accentDark;
}

.audio-btn:active {
  transform: translateY(1px);
}

.card-img {
  width: 100%;
  max-height: 220px;
  object-fit: contain;
  margin-top: 22px;
  border-radius: 12px;
  border: 1px solid $line;
  background: $panel;
}

.write-section {
  display: block;
  margin-top: 26px;
}

.write-label {
  font-size: 16px;
  font-weight: 700;
  color: $text;
  margin-bottom: 10px;
}

.write-group {
  margin-bottom: 12px;
}

.write-index {
  font-size: 14px;
  color: $accentDark;
  font-weight: 700;
}

.write-input {
  width: 100%;
  min-height: 88px;
  box-sizing: border-box;
  padding: 14px 16px;
  border-radius: 10px;
  border: 1px solid $line;
  outline: none;
  background: $panel;
  color: $text;
  font-family: 'Open Sans', 'Segoe UI', sans-serif;
  font-size: 18px;
  line-height: 1.45;
}

.write-input:focus {
  border-color: $accent;
  box-shadow: 0 0 0 3px $focusRing;
}

.diff-container {
  text-align: left;
  background: $panel;
  border: 1px solid $line;
  border-radius: 10px;
  padding: 14px 16px;
  margin-top: 10px;
}

.diff-row {
  font-size: 18px;
  line-height: 1.5;
  margin-bottom: 8px;
  word-wrap: break-word;
}

.diff-good {
  color: $diffGood;
  font-weight: 700;
}

.diff-bad {
  color: $diffBad;
  font-weight: 700;
  text-decoration: underline;
  text-decoration-thickness: 2px;
}

.small-note {
  font-size: 14px;
  color: $soft;
  margin-top: 10px;
}

.user-raw-box {
  font-size: 16px;
  color: $text;
  padding: 12px 14px;
  border: 1px dashed $line;
  border-radius: 10px;
  background: $panel;
}

.answer-reference {
  font-size: 18px;
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid $line;
}

.delayed-btn {
  visibility: hidden;
  opacity: 0;
  transition: opacity 0.25s ease;
}

@keyframes cardFade {
  from {
    opacity: 0;
    transform: translateY(6px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (max-width: 420px) {
  body {margin: 14px;}

  .flashcard {padding: 0 18px 18px 18px;}

  .row-main,
  .row-sent {gap: 12px;}

  .word-text {font-size: 28px;}

  .reading-text,
  .reading-sub {font-size: 18px;}

  .meaning-text,
  .meaning-prod {font-size: 22px;}

  .sentence-text,
  .example-sentence,
  .sentence-trans-prod {font-size: 18px;}
}
""";
  }
}
