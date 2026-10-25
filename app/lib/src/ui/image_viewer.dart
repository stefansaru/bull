// The image viewer (UIC-IMG): every image of the book in its numbered order.
//
// Touch: pinch to zoom, drag to pan; while the image fits the screen, swipe left or
// right for the next or previous image. Top bar: Back · zoom in · zoom out · fit ·
// previous · next · bookmark.
// Remote (two modes, so panning and paging never compete for the same key):
//   fitted — Left/Right step through the images, Select zooms in;
//   zoomed — the arrows pan, Select returns to fitted; Back leaves zoom before it
//            closes the viewer.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../content/book.dart';
import '../content/inline.dart';
import '../settings.dart';
import 'scope.dart';

const double minZoom = 1, maxZoom = 6, zoomStep = 1.5;

Future<void> openImageViewer(
  BuildContext context,
  BookImage? image,
  String asset,
  String caption,
) {
  final book = AppScope.of(context).book;
  final start = image == null ? -1 : book.images.indexOf(image);
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => start < 0
          ? ImageViewer.single(asset: asset, caption: caption)
          : ImageViewer(images: book.images, initial: start),
    ),
  );
}

class ImageViewer extends StatefulWidget {
  const ImageViewer({super.key, required this.images, required this.initial})
    : asset = null,
      caption = null;

  /// An image outside the numbered index (shown alone).
  const ImageViewer.single({
    super.key,
    required String this.asset,
    required String this.caption,
  }) : images = const [],
       initial = 0;

  final List<BookImage> images;
  final int initial;
  final String? asset;
  final String? caption;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late final _pages = PageController(initialPage: widget.initial);
  late int _index = widget.initial;
  final _transform = TransformationController();
  static const _pan = 0.15; // of the viewport, per key press

  @override
  void initState() {
    super.initState();
    _transform.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pages.dispose();
    _transform.dispose();
    super.dispose();
  }

  int get _count => widget.images.isEmpty ? 1 : widget.images.length;
  double get _scale => _transform.value.getMaxScaleOnAxis();
  bool get _zoomed => _scale > 1.01;

  void _zoomTo(double scale, Size size) {
    final s = scale.clamp(minZoom, maxZoom);
    final c = size.center(Offset.zero);
    _transform.value = Matrix4.identity()
      ..translateByDouble(-c.dx * (s - 1), -c.dy * (s - 1), 0, 1)
      ..scaleByDouble(s, s, 1, 1);
  }

  void _fit() => _transform.value = Matrix4.identity();

  void _go(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= _count) return;
    _fit();
    _pages.animateToPage(
      next,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  KeyEventResult _onKey(KeyEvent event, Size size) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      _zoomed ? _fit() : _zoomTo(2.5, size);
      return KeyEventResult.handled;
    }
    if (!_zoomed) {
      if (key == LogicalKeyboardKey.arrowLeft) {
        _go(-1);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowRight) {
        _go(1);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    final dx = size.width * _pan, dy = size.height * _pan;
    final delta = switch (key) {
      LogicalKeyboardKey.arrowLeft => Offset(dx, 0),
      LogicalKeyboardKey.arrowRight => Offset(-dx, 0),
      LogicalKeyboardKey.arrowUp => Offset(0, dy),
      LogicalKeyboardKey.arrowDown => Offset(0, -dy),
      _ => null,
    };
    if (delta == null) return KeyEventResult.ignored;
    _transform.value = Matrix4.identity()
      ..translateByDouble(delta.dx, delta.dy, 0, 1)
      ..multiply(_transform.value);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scope = AppScope.of(context);
    final current = widget.images.isEmpty ? null : widget.images[_index];
    final caption = current == null
        ? widget.caption!
        : plainLinks(pick(current.caption, scope.lang));
    final bookmarked =
        current != null &&
        scope.settings.bookmarks.any(
          (b) => b.kind == BookmarkKind.image && b.anchor == current.imageId,
        );
    const fg = Colors.white;
    return PopScope(
      canPop: !_zoomed,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _fit();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: fg,
          title: Text(
            current == null ? '' : l.imageNumber(current.number, _count),
          ),
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                tooltip: l.zoomIn,
                onPressed: _scale >= maxZoom
                    ? null
                    : () => _zoomTo(_scale * zoomStep, MediaQuery.sizeOf(ctx)),
                icon: const Icon(Icons.zoom_in),
              ),
            ),
            Builder(
              builder: (ctx) => IconButton(
                tooltip: l.zoomOut,
                onPressed: _zoomed
                    ? () => _zoomTo(_scale / zoomStep, MediaQuery.sizeOf(ctx))
                    : null,
                icon: const Icon(Icons.zoom_out),
              ),
            ),
            IconButton(
              tooltip: l.fit,
              onPressed: _zoomed ? _fit : null,
              icon: const Icon(Icons.fit_screen),
            ),
            IconButton(
              tooltip: l.previousImage,
              onPressed: _index > 0 ? () => _go(-1) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: l.nextImage,
              onPressed: _index < _count - 1 ? () => _go(1) : null,
              icon: const Icon(Icons.chevron_right),
            ),
            if (current != null)
              IconButton(
                tooltip: bookmarked ? l.removeBookmark : l.bookmarkImage,
                isSelected: bookmarked,
                onPressed: () {
                  final b = Bookmark(
                    artefactId: current.section,
                    kind: BookmarkKind.image,
                    anchor: current.imageId,
                    label: l.imageNumber(current.number, _count),
                    created: DateTime.now().millisecondsSinceEpoch,
                  );
                  bookmarked
                      ? scope.settings.removeBookmark(b)
                      : scope.settings.addBookmark(b);
                },
                icon: const Icon(Icons.bookmark_border),
                selectedIcon: const Icon(Icons.bookmark),
              ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, box) => Focus(
            autofocus: true,
            onKeyEvent: (_, e) => _onKey(e, box.biggest),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: _count,
                    // Swiping pages only while the image fits; zoomed, a drag pans.
                    physics: _zoomed
                        ? const NeverScrollableScrollPhysics()
                        : const PageScrollPhysics(),
                    onPageChanged: (i) => setState(() {
                      _index = i;
                      _fit();
                    }),
                    itemBuilder: (context, i) {
                      final asset = widget.images.isEmpty
                          ? widget.asset!
                          : widget.images[i].asset;
                      final image = Center(
                        child: Image.asset(
                          asset,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const SizedBox(),
                        ),
                      );
                      if (i != _index) return image;
                      return InteractiveViewer(
                        transformationController: _transform,
                        minScale: minZoom,
                        maxScale: maxZoom,
                        child: image,
                      );
                    },
                  ),
                ),
                if (caption.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      caption,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: fg.withValues(alpha: 0.85)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
