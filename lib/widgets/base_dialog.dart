import 'package:flutter/material.dart';
import 'package:flutter_deer/res/resources.dart';
import 'package:flutter_deer/routers/fluro_navigator.dart';
import 'package:flutter_deer/util/device_utils.dart';
import 'package:flutter_deer/widgets/my_button.dart';

/// Custom dialog template
class BaseDialog extends StatelessWidget {
  const BaseDialog(
      {super.key,
      this.title,
      this.onPressed,
      this.hiddenTitle = false,
      required this.child});

  final String? title;
  final VoidCallback? onPressed;
  final Widget child;
  final bool hiddenTitle;

  @override
  Widget build(BuildContext context) {
    final Widget dialogTitle = Visibility(
      visible: !hiddenTitle,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          hiddenTitle ? '' : title ?? '',
          style: TextStyles.textBold18,
        ),
      ),
    );

    final Widget bottomButton = Row(
      children: <Widget>[
        _DialogButton(
          text: 'Cancel',
          textColor: Colours.text_gray,
          onPressed: () => NavigatorUtils.goBack(context),
        ),
        const SizedBox(
          height: 48.0,
          width: 0.6,
          child: VerticalDivider(),
        ),
        _DialogButton(
          text: 'Sure',
          textColor: Theme.of(context).primaryColor,
          onPressed: onPressed,
        ),
      ],
    );

    final Widget content = Material(
      borderRadius: BorderRadius.circular(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Gaps.vGap24,
          dialogTitle,
          Flexible(child: child),
          Gaps.vGap8,
          Gaps.line,
          bottomButton,
        ],
      ),
    );

    final Widget body = MediaQuery.removeViewInsets(
      removeLeft: true,
      removeTop: true,
      removeRight: true,
      removeBottom: true,
      context: context,
      child: Center(
        child: SizedBox(
          width: 270.0,
          child: content,
        ),
      ),
    );

    /// Android 11 has added a keyboard pop-up animation, which conflicts with the transition animation I added (the original iOS and Android did not have related transition animations, related issue tracking：https://github.com/flutter/flutter/issues/19279）。
    /// Because on Android 11, the value of viewInsets changes during the keyboard popup process (previously only the beginning and end values)。
    /// So the solution is to use Padding instead of AnimatedPadding in Android 11 and above.

    if (Device.getAndroidSdkInt() >= 30) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: body,
      );
    } else {
      return AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInCubic, // easeOutQuad
        child: body,
      );
    }
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.text,
    this.textColor,
    this.onPressed,
  });

  final String text;
  final Color? textColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MyButton(
        text: text,
        textColor: textColor,
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
