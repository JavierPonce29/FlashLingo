import 'package:flutter/material.dart';

import 'package:flashcards_app/data/models/review_log.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';
import 'package:flashcards_app/theme/app_ui_colors.dart';

Future<void> showReviewHistorySheet(
  BuildContext context,
  List<ReviewLog> reviewLogs,
) {
  final l10n = context.l10n;

  String formatDuration(int totalMs) {
    if (totalMs <= 0) return '0s';
    final totalSeconds = Duration(milliseconds: totalMs).inSeconds;
    if (totalSeconds < 60) return '${totalSeconds}s';
    final totalMinutes = Duration(milliseconds: totalMs).inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours <= 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.tr(
                    'browser_history_title',
                    params: <String, Object?>{'count': reviewLogs.length},
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: reviewLogs.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(l10n.tr('browser_history_empty')),
                        ),
                      )
                    : ListView.builder(
                        itemCount: reviewLogs.length,
                        itemBuilder: (context, index) {
                          final log = reviewLogs[index];
                          final isCorrect = log.isCorrect || log.rating >= 3;
                          final transition =
                              (log.previousState == 'unknown' ||
                                  log.newState == 'unknown')
                              ? ''
                              : '  ${log.previousState} -> ${log.newState}';
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect
                                  ? AppUiColors.success(context)
                                  : AppUiColors.danger(context),
                            ),
                            title: Text(log.timestamp.toString()),
                            subtitle: Text(
                              '${isCorrect ? l10n.tr('study_good') : l10n.tr('study_bad')}'
                              '  ${l10n.tr('browser_history_duration', params: <String, Object?>{'value': formatDuration(log.studyDurationMs)})}'
                              '${log.daysLate > 0 ? '  ${l10n.tr('browser_history_late', params: <String, Object?>{'count': log.daysLate})}' : ''}'
                              '$transition',
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
