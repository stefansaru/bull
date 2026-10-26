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
  const _Step(this.target, this.text);

  /// The control to spotlight, measured afresh on every frame: the shell may still
  /// be settling (route transition, rotation, rail vs top menu) when the tour opens.
  final GlobalKey? target;
  final String text;
}

Future<void> startTour(BuildContext context, TourKeys keys) async {
  final l = AppLocalizations.of(context);
  final settings = AppScope.of(context).settings;
  final steps = [
    _Step(null, l.tourWelcome),
    _Step(keys.back, l.tourBack),
    _Step(keys.sections, l.tourSections),
    _Step(keys.star, l.tourStar),
    _Step(keys.search, l.tourSearch),
    _Step(keys.title, l.tourTitle), // rail only; skipped when not on screen
    _Step(keys.more, l.tourMore),
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

class _TourOverlayState extends State<_TourOverlay>
    with WidgetsBindingObserver {
  _Step? _current;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Re-measure once the route transition and the shell's layout have settled.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  /// The target's rect in this overlay's coordinates, or null when it is not on
  /// screen (the step then shows as a centred card without a spotlight).
  Rect? _rect(GlobalKey? key) {
    if (key == null) return null;
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final me = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return null;
    if (me == null || !me.attached || !me.hasSize) return null;
    return box.localToGlobal(Offset.zero) - me.localToGlobal(Offset.zero) &
        box.size;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Only steps whose control is on screen now: the layout can change mid-tour
    // (rotation swaps the top menu for the rail, which adds the title button).
    final steps = [
      for (final s in widget.steps)
        if (s.target == null || s.target!.currentContext != null) s,
    ];
    final step = steps.contains(_current) ? _current! : steps.first;
    final i = steps.indexOf(step);
    final rect = _rect(step.target);
    final last = i == steps.length - 1;
    final size = MediaQuery.sizeOf(context);
    final below = rect == null || rect.center.dy < size.height / 2;
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
                Text('${i + 1}/${steps.length}'),
                const SizedBox(width: 12),
                FilledButton(
                  autofocus: true,
                  onPressed: () => last
                      ? Navigator.of(context).pop()
                      : setState(() => _current = steps[i + 1]),
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
          Positioned.fill(child: CustomPaint(painter: _Spotlight(rect))),
          Positioned(
            left: 0,
            right: 0,
            top: below ? (rect?.bottom ?? size.height / 3) + 8 : null,
            bottom: below ? null : size.height - rect.top + 8,
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
