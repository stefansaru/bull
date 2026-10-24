// Full-screen zoomable image (APP-RDR-002): pinch on touch screens; on a TV remote,
// select toggles zoom, the arrows pan, and back closes.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';

class ImageViewer extends StatefulWidget {
  const ImageViewer({super.key, required this.asset, required this.caption});

  final String asset;
  final String caption;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final _transform = TransformationController();
  static const _zoom = 2.5;
  static const _pan = 120.0;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  bool get _zoomed => _transform.value.getMaxScaleOnAxis() > 1.01;

  void _toggleZoom(Size size) {
    setState(() {
      if (_zoomed) {
        _transform.value = Matrix4.identity();
      } else {
        final c = size.center(Offset.zero);
        _transform.value = Matrix4.identity()
          ..translateByDouble(-c.dx * (_zoom - 1), -c.dy * (_zoom - 1), 0, 1)
          ..scaleByDouble(_zoom, _zoom, 1, 1);
      }
    });
  }

  KeyEventResult _onKey(KeyEvent event, Size size) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      _toggleZoom(size);
      return KeyEventResult.handled;
    }
    if (!_zoomed) return KeyEventResult.ignored;
    final delta = switch (key) {
      LogicalKeyboardKey.arrowLeft => const Offset(_pan, 0),
      LogicalKeyboardKey.arrowRight => const Offset(-_pan, 0),
      LogicalKeyboardKey.arrowUp => const Offset(0, _pan),
      LogicalKeyboardKey.arrowDown => const Offset(0, -_pan),
      _ => null,
    };
    if (delta == null) return KeyEventResult.ignored;
    setState(() {
      _transform.value = Matrix4.identity()
        ..translateByDouble(delta.dx, delta.dy, 0, 1)
        ..multiply(_transform.value);
    });
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, box) => Focus(
          autofocus: true,
          onKeyEvent: (_, e) => _onKey(e, box.biggest),
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _transform,
                  maxScale: 6,
                  child: Center(
                    child: Image.asset(widget.asset, fit: BoxFit.contain),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Text(
                  l.zoomHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
