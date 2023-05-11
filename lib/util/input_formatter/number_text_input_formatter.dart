import 'package:flutter/services.dart';

/// Number, decimal formatting (default two decimal places)
class UsNumberTextInputFormatter extends TextInputFormatter {
  UsNumberTextInputFormatter({this.digit = 2, this.max = 1000000});

  /// The number of decimal places allowed to be entered, -1 means unlimited digits
  final int digit;

  /// Maximum value allowed
  final double max;

  static const double _kDefaultDouble = 0.001;

  double _strToFloat(String str, [double defaultValue = _kDefaultDouble]) {
    try {
      return double.parse(str);
    } catch (e) {
      return defaultValue;
    }
  }

  ///Get the current number of decimal places
  int _getValueDigit(String value) {
    if (value.contains('.')) {
      return value.split('.')[1].length;
    } else {
      return -1;
    }
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String value = newValue.text;
    int selectionIndex = newValue.selection.end;
    if (value == '.') {
      value = '0.';
      selectionIndex++;
    } else if (value != '' &&
            value != _kDefaultDouble.toString() &&
            _strToFloat(value) == _kDefaultDouble ||
        _getValueDigit(value) > digit ||
        _strToFloat(value) > max) {
      value = oldValue.text;
      selectionIndex = oldValue.selection.end;
    }
    return TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
