import 'dart:math' as math;

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

enum TourCardFallbackPlacement { top, bottom }

class TourOverlayCard extends StatefulWidget {
  final GlobalKey? targetKey;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final TourCardFallbackPlacement fallbackPlacement;
  final EdgeInsets margin;
  final double gap;
  final double? fallbackTop;
  final double? fallbackBottom;

  const TourOverlayCard({
    super.key,
    required this.message,
    this.targetKey,
    this.actionLabel,
    this.onActionPressed,
    this.fallbackPlacement = TourCardFallbackPlacement.bottom,
    this.margin = const EdgeInsets.fromLTRB(16, 16, 16, 24),
    this.gap = 12,
    this.fallbackTop,
    this.fallbackBottom,
  });

  @override
  State<TourOverlayCard> createState() => _TourOverlayCardState();
}

class _TourOverlayCardState extends State<TourOverlayCard> {
  Rect? _targetRect;
  bool _measurementQueued = false;

  @override
  void initState() {
    super.initState();
    _scheduleMeasurement();
  }

  @override
  void didUpdateWidget(covariant TourOverlayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetKey != widget.targetKey ||
        oldWidget.message != widget.message ||
        oldWidget.actionLabel != widget.actionLabel) {
      _scheduleMeasurement();
    }
  }

  void _scheduleMeasurement() {
    if (_measurementQueued) return;
    _measurementQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measurementQueued = false;
      if (!mounted) return;
      final nextRect = _measureGlobalRect(widget.targetKey);
      if (nextRect != _targetRect) {
        setState(() => _targetRect = nextRect);
      }
      _scheduleMeasurement();
    });
  }

  Rect? _measureGlobalRect(GlobalKey? key) {
    final context = key?.currentContext;
    final renderObject = context?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    final origin = renderObject.localToGlobal(Offset.zero);
    return origin & renderObject.size;
  }

  @override
  Widget build(BuildContext context) {
    _scheduleMeasurement();

    return Positioned.fill(
      child: CustomSingleChildLayout(
        delegate: _TourOverlayCardDelegate(
          targetRect: _targetRect,
          margin: widget.margin,
          gap: widget.gap,
          fallbackPlacement: widget.fallbackPlacement,
          fallbackTop: widget.fallbackTop,
          fallbackBottom: widget.fallbackBottom,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: TourMessageCard(
            message: widget.message,
            actionLabel: widget.actionLabel,
            onActionPressed: widget.onActionPressed,
          ),
        ),
      ),
    );
  }
}

class _TourOverlayCardDelegate extends SingleChildLayoutDelegate {
  final Rect? targetRect;
  final EdgeInsets margin;
  final double gap;
  final TourCardFallbackPlacement fallbackPlacement;
  final double? fallbackTop;
  final double? fallbackBottom;

  const _TourOverlayCardDelegate({
    required this.targetRect,
    required this.margin,
    required this.gap,
    required this.fallbackPlacement,
    required this.fallbackTop,
    required this.fallbackBottom,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxWidth = math.max(
      0.0,
      constraints.biggest.width - margin.horizontal,
    );
    return BoxConstraints(
      minWidth: 0,
      maxWidth: maxWidth,
      minHeight: 0,
      maxHeight: constraints.biggest.height,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final minX = margin.left;
    final maxX = math.max(minX, size.width - margin.right - childSize.width);
    final defaultX = (size.width - childSize.width) / 2;

    if (targetRect == null) {
      final y = switch (fallbackPlacement) {
        TourCardFallbackPlacement.top => fallbackTop ?? margin.top,
        TourCardFallbackPlacement.bottom =>
          size.height - (fallbackBottom ?? margin.bottom) - childSize.height,
      };
      return Offset(defaultX.clamp(minX, maxX), y);
    }

    final target = targetRect!;
    final centeredX =
        (target.left + (target.width / 2)) - (childSize.width / 2);
    final x = centeredX.clamp(minX, maxX);

    final availableAbove = target.top - margin.top - gap;
    final availableBelow = size.height - target.bottom - margin.bottom - gap;
    final canFitAbove = availableAbove >= childSize.height;
    final canFitBelow = availableBelow >= childSize.height;

    double y;
    if (canFitBelow || (!canFitAbove && availableBelow >= availableAbove)) {
      y = target.bottom + gap;
      final maxY = size.height - margin.bottom - childSize.height;
      y = y.clamp(margin.top, maxY);
      if (y < target.bottom && y + childSize.height > target.top) {
        y = (target.top - gap - childSize.height).clamp(margin.top, maxY);
      }
    } else {
      y = target.top - gap - childSize.height;
      final maxY = size.height - margin.bottom - childSize.height;
      y = y.clamp(margin.top, maxY);
      if (y + childSize.height > target.top && y < target.bottom) {
        y = (target.bottom + gap).clamp(margin.top, maxY);
      }
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(covariant _TourOverlayCardDelegate oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.margin != margin ||
        oldDelegate.gap != gap ||
        oldDelegate.fallbackPlacement != fallbackPlacement ||
        oldDelegate.fallbackTop != fallbackTop ||
        oldDelegate.fallbackBottom != fallbackBottom;
  }
}

Future<void> ensureTourTargetVisible(
  GlobalKey? key, {
  double alignment = 0.18,
  Duration duration = const Duration(milliseconds: 280),
  Curve curve = Curves.easeOutCubic,
}) async {
  final context = key?.currentContext;
  if (context == null) return;

  await Scrollable.ensureVisible(
    context,
    duration: duration,
    curve: curve,
    alignment: alignment,
    alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
  );
}
