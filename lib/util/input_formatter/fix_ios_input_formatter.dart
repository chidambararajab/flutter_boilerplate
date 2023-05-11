import 'dart:io';

import 'package:flutter/services.dart';

/// https://github.com/flutter/flutter/issues/25511
/// It is mainly aimed at the problem of setting maxLength for TextInput and crashing when using the native input method to input Chinese on the iOS platform.
/// Instructions:
/// TextField(
///   inputFormatters: [FixIOSTextInputFormatter()],
/// )
/// The problem after use is that the input pinyin is not displayed.
///
/// 1.22 Fixed：https://github.com/flutter/flutter/pull/63754
@Deprecated('1.22fixed')
class FixIOSTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (Platform.isIOS) {
      // ios Composing changes also execute format, because LengthLimitingTextInputFormatter is not executed in the Pinyin stage, and it needs to be re-executed from Pinyin to Chinese characters
      if (newValue.composing.isValid) {
        // The ios pinyin stage does not implement the format of the length limit
        return TextEditingValue.empty;
      }
    }
    return TextEditingValue(
      text: newValue.text,
      selection: TextSelection.collapsed(offset: newValue.selection.end),
    );
  }
}
