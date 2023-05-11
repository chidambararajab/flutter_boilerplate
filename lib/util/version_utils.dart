import 'package:flutter/services.dart';

class VersionUtils {
  static const MethodChannel _kChannel = MethodChannel('version');

  /// app install
  static void install(String path) {
    _kChannel.invokeMethod<void>('install', {'path': path});
  }

  /// AppStore Jump
  static void jumpAppStore() {
    _kChannel.invokeMethod<void>('jumpAppStore');
  }
}
