// Which kind of device the app runs on (UIC-PLT-01).
//
// TV: Android reports a television UI mode or the leanback feature (the same check
// as Day OK). Otherwise the shortest side decides: tablet from 600 dp, else phone.
// When the platform cannot answer, the device is "other" and is treated like a TV —
// everything reachable without touch — plus a keyboard button next to text fields.
import 'package:flutter/services.dart';

enum DeviceKind { phone, tablet, tv, other }

extension DeviceKindX on DeviceKind {
  /// TV treatment: in-app keyboard, 10-foot type, overscan-safe margins.
  bool get tvLike => this == DeviceKind.tv || this == DeviceKind.other;
}

const _channel = MethodChannel('capdebour/device');

const double tabletMinSide = 600;

Future<DeviceKind> detectDevice(Size logicalSize) async {
  try {
    final isTv = await _channel.invokeMethod<bool>('isTv');
    if (isTv == null) return DeviceKind.other;
    if (isTv) return DeviceKind.tv;
  } on MissingPluginException {
    return DeviceKind.other;
  } on PlatformException {
    return DeviceKind.other;
  }
  return logicalSize.shortestSide >= tabletMinSide
      ? DeviceKind.tablet
      : DeviceKind.phone;
}
