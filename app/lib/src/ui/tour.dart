// The first-run tour of the controls (UIC-NAV-05): a spotlight on each control in
// turn with one sentence about it — modelled on Amethyst's walkthrough
// (`amethyst/lib/widgets/walkthrough_spotlight.dart`), kept small.
// It runs on first launch and again from Help. Back ends it.
//
// Owner rulings (2026-10-26, Pixel field test):
// * Skip ends the tour for now — it comes back on the next launch; Skip all ends
//   it for good (Help still runs it). Finishing it counts as Skip all.
// * Previous and Next; the spotlight glides from one control to the next
//   (none under the system's reduce-motion setting).
// * Outside the spotlight is darker, inside it lighter, and the frame's four
//   sides always lie within the visible screen.
import 'dart:math' as math;

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

/// How the reader left the tour.
enum TourExit { skip, skipAll }

/// Space between a control and the spotlight frame around it.
const double tourSpotlightPad = 8;

/// Corner radius of the spotlight frame.
const double tourSpotlightRadius = 12;

/// Width of the frame's stroke; half of it lies outside the cut-out.
const double tourFrameWidth = 3;

/// How long the spotlight takes to glide from one control to the next.
const Duration tourMorphDuration = Duration(milliseconds: 280);

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
  final exit = await Navigator.of(context).push(
    PageRouteBuilder<TourExit>(
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (_, _, _) => _TourOverlay(steps: steps),
    ),
  );
  // Back and Skip leave the first-run tour to show again next launch.
  if (exit == TourExit.skipAll) await settings.setTourSeen();
}

/// The spotlight frame for [target], padded and then pulled inside [viewport] so
/// all four sides of the frame (stroke included) stay visible on screen.
Rect tourSpotlightFrame(Rect target, Rect viewport) {
  final safe = viewport.deflate(tourFrameWidth);
  final r = target.inflate(tourSpotlightPad);
  return Rect.fromLTRB(
    math.max(r.left, safe.left),
    math.max(r.top, safe.top),
    math.min(r.right, safe.right),
    math.min(r.bottom, safe.bottom),
  );
}

class _TourOverlay extends StatefulWidget {
  const _TourOverlay({required this.steps});
  final List<_Step> steps;

  @override
  State<_TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<_TourOverlay>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  _Step? _current;

  late final AnimationController _morph = AnimationController(
    vsync: this,
    duration: tourMorphDuration,
    value: 1,
  );
  late final Animation<double> _morphT = CurvedAnimation(
    parent: _morph,
    curve: Curves.easeInOut,
  );
  Rect? _from;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remeasure();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _morph.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() => _remeasure();

  /// Rebuild once the current frame is laid out, so the rects are fresh.
  void _remeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  /// The target's rect in this overlay's coordinates, or null when it is not on
  /// screen (the step then shows as a card without a spotlight).
  Rect? _rect(GlobalKey? key) {
    if (key == null) return null;
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final me = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return null;
    if (me == null || !me.attached || !me.hasSize) return null;
    return box.localToGlobal(Offset.zero) - me.localToGlobal(Offset.zero) &
        box.size;
  }

  /// Only steps whose control is on screen now: the layout can change mid-tour
  /// (rotation swaps the top menu for the rail, which adds the title button).
  List<_Step> get _visible => [
    for (final s in widget.steps)
      if (s.target == null || s.target!.currentContext != null) s,
  ];

  void _go(_Step to, Rect? fromRect) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    setState(() {
      _from = fromRect;
      _current = to;
    });
    if (reduce) {
      _morph.value = 1;
    } else {
      _morph.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final steps = _visible;
    final step = steps.contains(_current) ? _current! : steps.first;
    final i = steps.indexOf(step);
    final first = i == 0;
    final last = i == steps.length - 1;
    final mq = MediaQuery.of(context);

    return LayoutBuilder(
      builder: (context, box) {
        final viewport = Rect.fromLTRB(
          mq.padding.left,
          mq.padding.top,
          box.maxWidth - mq.padding.right,
          box.maxHeight - mq.padding.bottom,
        );
        final target = _rect(step.target);
        final to = target == null ? null : tourSpotlightFrame(target, viewport);

        Widget card(Rect? spot) {
          final anchor = _cardAnchor(viewport, spot);
          return Positioned(
            left: viewport.left,
            right: box.maxWidth - viewport.right,
            top: anchor.below ? anchor.offset : null,
            bottom: anchor.below ? null : box.maxHeight - anchor.offset,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: scheme.primary, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(step.text, style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        Text(
                          '${i + 1} / ${steps.length}',
                          textAlign: TextAlign.end,
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (!last)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context)
                                            .pop(TourExit.skip),
                                    child: Text(l.skip),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context)
                                            .pop(TourExit.skipAll),
                                    child: Text(l.skipAll),
                                  ),
                                ],
                              ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!first)
                                  OutlinedButton(
                                    onPressed: () => _go(steps[i - 1], spot),
                                    child: Text(l.previous),
                                  ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  autofocus: true,
                                  onPressed: () => last
                                      ? Navigator.of(context)
                                            .pop(TourExit.skipAll)
                                      : _go(steps[i + 1], spot),
                                  child: Text(last ? l.done : l.next),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Material(
          type: MaterialType.transparency,
          child: AnimatedBuilder(
            animation: _morphT,
            builder: (context, _) {
              // From a card-only step, or to one, there is nothing to glide.
              final spot = (_from == null || to == null)
                  ? to
                  : Rect.lerp(_from, to, _morphT.value);
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: TourSpotlightPainter(
                        hole: spot,
                        scrim: Colors.black.withValues(alpha: 0.78),
                        wash: Colors.white.withValues(
                          alpha: dark ? 0.16 : 0.35,
                        ),
                        frame: dark ? Colors.white : scheme.primary,
                      ),
                    ),
                  ),
                  card(spot),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// Where the card goes, in overlay coordinates: its top when [below], else its
/// bottom — on whichever side of the spotlight has more room, or near the top of
/// the screen when there is no spotlight.
({bool below, double offset}) _cardAnchor(Rect viewport, Rect? spot) {
  const gap = 12.0;
  if (spot == null) return (below: true, offset: viewport.top + 72);
  final spaceBelow = viewport.bottom - spot.bottom;
  final spaceAbove = spot.top - viewport.top;
  if (spaceBelow >= spaceAbove) return (below: true, offset: spot.bottom + gap);
  return (below: false, offset: spot.top - gap);
}

class TourSpotlightPainter extends CustomPainter {
  TourSpotlightPainter({
    required this.hole,
    required this.scrim,
    required this.wash,
    required this.frame,
  });

  /// The frame (already padded and clamped), or null for a card-only step.
  final Rect? hole;
  final Color scrim;

  /// Laid over the cut-out, so the focused control reads lighter than its
  /// surroundings even on a dark page.
  final Color wash;
  final Color frame;

  @override
  void paint(Canvas canvas, Size size) {
    final screen = Offset.zero & size;
    final h = hole;
    if (h == null) {
      canvas.drawRect(screen, Paint()..color = scrim);
      return;
    }
    final r = RRect.fromRectAndRadius(
      h,
      const Radius.circular(tourSpotlightRadius),
    );
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(screen)
        ..addRRect(r),
      Paint()..color = scrim,
    );
    canvas.drawRRect(r, Paint()..color = wash);
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = tourFrameWidth
        ..color = frame,
    );
  }

  @override
  bool shouldRepaint(TourSpotlightPainter old) =>
      old.hole != hole ||
      old.scrim != scrim ||
      old.wash != wash ||
      old.frame != frame;
}
