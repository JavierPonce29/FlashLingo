import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class TourHighlight extends StatelessWidget {
  final bool highlighted;
  final Widget child;

  const TourHighlight({
    super.key,
    required this.highlighted,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: highlighted
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: primary, width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            )
          : null,
      child: child,
    );
  }
}

class TourMessageCard extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const TourMessageCard({
    super.key,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
  });

  static final RegExp _urlRegex = RegExp(r'https?:\/\/[^\s]+');

  List<_MessagePart> _splitMessage(String input) {
    final parts = <_MessagePart>[];
    int cursor = 0;
    for (final match in _urlRegex.allMatches(input)) {
      if (match.start > cursor) {
        parts.add(_MessagePart(input.substring(cursor, match.start), false));
      }
      parts.add(_MessagePart(match.group(0)!, true));
      cursor = match.end;
    }
    if (cursor < input.length) {
      parts.add(_MessagePart(input.substring(cursor), false));
    }
    return parts;
  }

  @override
  Widget build(BuildContext context) {
    final parts = _splitMessage(message);
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final linkStyle = textStyle?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final part in parts)
                  if (part.isLink)
                    Link(
                      uri: Uri.parse(part.text),
                      target: LinkTarget.blank,
                      builder: (context, openLink) => InkWell(
                        onTap: openLink,
                        child: Text(part.text, style: linkStyle),
                      ),
                    )
                  else
                    Text(part.text, style: textStyle),
              ],
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: onActionPressed,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MessagePart {
  final String text;
  final bool isLink;

  const _MessagePart(this.text, this.isLink);
}
