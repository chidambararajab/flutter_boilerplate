import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deer/util/toast_utils.dart';

/// Double click to return and exit
class DoubleTapBackExitApp extends StatefulWidget {
  const DoubleTapBackExitApp({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2500),
  });

  final Widget child;

  /// The time interval between two clicks of the back button
  final Duration duration;

  @override
  _DoubleTapBackExitAppState createState() => _DoubleTapBackExitAppState();
}

class _DoubleTapBackExitAppState extends State<DoubleTapBackExitApp> {
  DateTime? _lastTime;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _isExit,
      child: widget.child,
    );
  }

  Future<bool> _isExit() async {
    if (_lastTime == null ||
        DateTime.now().difference(_lastTime!) > widget.duration) {
      _lastTime = DateTime.now();
      Toast.show('Click again to exit the app');
      return Future.value(false);
    }
    Toast.cancelToast();

    /// exit(0) from `dart:io` is deprecated
    await SystemNavigator.pop();
    return Future.value(true);
  }
}
