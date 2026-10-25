// The reader's navigation stack (UIC-PRN-01).
//
// One entry per artefact visited: where the reader is (artefact, scroll offset, the
// unit to bring into view). Overlays — previews, the Sections window, search, menus,
// the image viewer — are ordinary routes above the shell, so Back closes the
// innermost overlay first and only then walks this stack. The stack is restorable,
// so a process death in the background returns the reader to the same place
// (H-APP-LIFE-004), and it survives rotation (H-APP-LIFE-005).
import 'package:flutter/widgets.dart';

class NavEntry {
  const NavEntry(this.artefactId, {this.offset = 0, this.anchor = ''});

  factory NavEntry.fromJson(Map<Object?, Object?> j) => NavEntry(
    j['a']! as String,
    offset: (j['o'] as num?)?.toDouble() ?? 0,
    anchor: j['u'] as String? ?? '',
  );

  final String artefactId;
  final double offset;

  /// A unit to bring into view on arrival (a bookmarked passage, a table).
  final String anchor;

  NavEntry copyWith({double? offset, String? anchor}) => NavEntry(
    artefactId,
    offset: offset ?? this.offset,
    anchor: anchor ?? this.anchor,
  );

  Map<String, Object> toJson() => {
    'a': artefactId,
    'o': offset,
    if (anchor.isNotEmpty) 'u': anchor,
  };
}

class RestorableNavStack extends RestorableValue<List<NavEntry>> {
  RestorableNavStack(this._initial);

  final String _initial;

  @override
  List<NavEntry> createDefaultValue() => [NavEntry(_initial)];

  @override
  void didUpdateValue(List<NavEntry>? oldValue) => notifyListeners();

  @override
  List<NavEntry> fromPrimitives(Object? data) {
    final list = data as List<Object?>?;
    if (list == null || list.isEmpty) return createDefaultValue();
    return [
      for (final e in list) NavEntry.fromJson(e! as Map<Object?, Object?>),
    ];
  }

  @override
  Object toPrimitives() => [for (final e in value) e.toJson()];

  NavEntry get top => value.last;
  bool get canPop => value.length > 1;

  void push(NavEntry e) => value = [...value, e];

  /// Page turning (previous/next) replaces the current entry: the back stack
  /// records where the reader came from, not every page they turned.
  void replaceTop(NavEntry e) =>
      value = [...value.sublist(0, value.length - 1), e];

  void pop() {
    if (canPop) value = value.sublist(0, value.length - 1);
  }

  /// Remember the scroll position of the current entry (no rebuild needed).
  void recordOffset(double offset) {
    final updated = top.copyWith(offset: offset);
    value = [...value.sublist(0, value.length - 1), updated];
  }
}
