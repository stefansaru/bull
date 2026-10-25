// The first-run tour of the controls (UIC-NAV-05): a spotlight on each control in
// turn with one sentence about it — modelled on Amethyst's walkthrough, kept small.
// It runs once on first launch and again from Help. Back ends it.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'scope.dart';

class TourKeys {
  final back = GlobalKey(debugLabel: 'tour-back');
  final sections = GlobalKey(debugLabel: 'tour-sections');
  final star = GlobalKey(debugLabel: 'tour-star');
  final search = GlobalKey(debugLabel: 'tour-search');
  final more = GlobalKey(debugLabel: 'tour-more');
  final title = GlobalKey(debugLabel: 'tour-title');
}

class _Step {
  const _Step(this.rect, this.text);
  final Rect? rect;
  final String text;
}

Rect? _rectOf(GlobalKey key) {
  final box = key.currentContext?.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize || !box.attached) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

Future<void> startTour(
  BuildContext context,
  TourKeys keys,
  LayoutMode mode,
) async {
  final l = AppLocalizations.of(context);
  final settings = AppScope.of(context).settings;
  final steps = [
    _Step(null, l.tourWelcome),
    _Step(_rectOf(keys.back), l.tourBack),
    _Step(_rectOf(keys.sections), l.tourSections),
    _Step(_rectOf(keys.star), l.tourStar),
    _Step(_rectOf(keys.search), l.tourSearch),
    if (mode != LayoutMode.portrait) _Step(_rectOf(keys.title), l.tourTitle),
    _Step(_rectOf(keys.more), l.tourMore),
    _Step(null, l.tourLinks),
  ];
  await Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (_, _, _) => _TourOverlay(steps: steps),
    ),
  );
  await settings.setTourSeen();
}

class _TourOverlay extends StatefulWidget {
  const _TourOverlay({required this.steps});
  final List<_Step> steps;

  @override
  State<_TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<_TourOverlay> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final step = widget.steps[_i];
    final last = _i == widget.steps.length - 1;
    final size = MediaQuery.sizeOf(context);
    final below = step.rect == null || step.rect!.center.dy < size.height / 2;
    final card = Card(
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(step.text, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!last)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l.skip),
                  ),
                const Spacer(),
                Text('${_i + 1}/${widget.steps.length}'),
                const SizedBox(width: 12),
                FilledButton(
                  autofocus: true,
                  onPressed: () =>
                      last ? Navigator.of(context).pop() : setState(() => _i++),
                  child: Text(last ? l.done : l.next),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _Spotlight(step.rect))),
          Positioned(
            left: 0,
            right: 0,
            top: below ? (step.rect?.bottom ?? size.height / 3) + 8 : null,
            bottom: below ? null : size.height - step.rect!.top + 8,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: card,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Spotlight extends CustomPainter {
  _Spotlight(this.hole);
  final Rect? hole;

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Path()..addRect(Offset.zero & size);
    if (hole != null) {
      final r = RRect.fromRectAndRadius(
        hole!.inflate(6),
        const Radius.circular(12),
      );
      final cut = Path()..addRRect(r);
      canvas.drawPath(
        Path.combine(PathOperation.difference, scrim, cut),
        Paint()..color = const Color(0xB3000000),
      );
      canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFFFFFFF),
      );
    } else {
      canvas.drawPath(scrim, Paint()..color = const Color(0xB3000000));
    }
  }

  @override
  bool shouldRepaint(_Spotlight old) => old.hole != hole;
}
