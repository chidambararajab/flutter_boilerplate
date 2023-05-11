import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_deer/res/constant.dart';

/// Capture global exceptions for unified processing.
void handleError(void Function() body) {
  /// Rewrite Flutter exception callback FlutterError.onError
  FlutterError.onError = (FlutterErrorDetails details) {
    if (!Constant.inProduction) {
      // When debugging, directly print the exception information.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // During release, the exception is handled by the zone.
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    }
  };

  /// Catching Flutter uncaught exceptions with runZonedGuarded
  runZonedGuarded(body, (Object error, StackTrace stackTrace) async {
    await _reportError(error, stackTrace);
  });
}

Future<void> _reportError(Object error, StackTrace stackTrace) async {
  if (!Constant.inProduction) {
    debugPrintStack(
      stackTrace: stackTrace,
      label: error.toString(),
      maxFrames: 100,
    );
  } else {
    /// Collect and upload exception information to the server. You can directly use plugins like `flutter_bugly` to handle exception reporting.
  }
}
