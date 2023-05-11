import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deer/res/resources.dart';
import 'package:flutter_deer/util/device_utils.dart';
import 'package:rxdart/rxdart.dart';

class ThemeUtils {
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color? getDarkColor(BuildContext context, Color darkColor) {
    return isDark(context) ? darkColor : null;
  }

  static Color? getIconColor(BuildContext context) {
    return isDark(context) ? Colours.dark_text : null;
  }

  static Color getStickyHeaderColor(BuildContext context) {
    return isDark(context) ? Colours.dark_bg_gray_ : Colours.bg_gray_;
  }

  static Color getDialogTextFieldColor(BuildContext context) {
    return isDark(context) ? Colours.dark_bg_gray_ : Colours.bg_gray;
  }

  static Color? getKeyboardActionsColor(BuildContext context) {
    return isDark(context) ? Colours.dark_bg_color : Colors.grey[200];
  }

  static StreamSubscription<dynamic>? _subscription;

  /// Set the NavigationBar style so that the color of the navigation bar matches the setting of the dark mode.
  static void setSystemNavigationBar(ThemeMode mode) {
    /// The theme switching animation (AnimatedTheme) time is 200 milliseconds, and the color of the navigation bar is set with a delay, so that the transition is relatively natural.
    _subscription?.cancel();
    _subscription =
        Stream.value(1).delay(const Duration(milliseconds: 200)).listen((_) {
      bool isDark = false;
      if (mode == ThemeMode.dark ||
          (mode == ThemeMode.system &&
              window.platformBrightness == Brightness.dark)) {
        isDark = true;
      }
      setSystemBarStyle(isDark: isDark);
    });
  }

  /// Set the StatusBar and NavigationBar styles. (Android only)
  /// This item has been set in android MainActivity, no need to override the settings.
  static void setSystemBarStyle({bool? isDark}) {
    if (Device.isAndroid) {
      final bool isDarkMode =
          isDark ?? window.platformBrightness == Brightness.dark;
      debugPrint('isDark: $isDarkMode');
      final SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        /// transparent status bar
        statusBarColor: Colors.transparent,
        systemNavigationBarColor:
            isDarkMode ? Colours.dark_bg_color : Colors.white,
        systemNavigationBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      );
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
  }
}

extension ThemeExtension on BuildContext {
  bool get isDark => ThemeUtils.isDark(this);
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get dialogBackgroundColor => Theme.of(this).canvasColor;
}
