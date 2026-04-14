import 'package:flashcards_app/l10n/app_localizations.dart';

List<double>? parseLearningSteps(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final parts = trimmed.split(',');
  final values = <double>[];
  for (final part in parts) {
    final normalized = part.trim();
    if (normalized.isEmpty) {
      return null;
    }
    final value = double.tryParse(normalized.replaceAll(',', '.'));
    if (value == null) {
      return null;
    }
    values.add(value);
  }

  return values.isEmpty ? null : values;
}

String? validateLearningStepsInput(AppLocalizations l10n, String? value) {
  final raw = (value ?? '').trim();
  if (raw.isEmpty) {
    return l10n.tr('validation_steps_required');
  }
  final list = parseLearningSteps(raw);
  if (list == null) {
    return l10n.tr('validation_steps_invalid');
  }
  if (list.any((step) => step <= 0)) {
    return l10n.tr('validation_steps_positive');
  }
  return null;
}
