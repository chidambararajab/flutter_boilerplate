import 'package:oktoast/oktoast.dart';

/// Toast tool class
class Toast {
  static void show(String? msg, {int duration = 2000}) {
    if (msg == null) {
      return;
    }
    showToast(msg,
        duration: Duration(milliseconds: duration), dismissOtherToast: true);
  }

  static void cancelToast() {
    dismissAllToast();
  }
}
