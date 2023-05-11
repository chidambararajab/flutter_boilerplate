import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// General layout for this project（SingleChildScrollView）
/// 1.button at the bottom
/// 2.no buttons at the bottom
class MyScrollView extends StatelessWidget {
  /// Note: When there are bottom buttons and keyboardConfig configurations at the same time, it is necessary to ensure that the pop-up height of the soft keyboard is normal. Need to use `resizeToAvoidBottomInset: defaultTargetPlatform != TargetPlatform.iOS,` in `Scaffold`
  /// Unless both Android and iOS platforms use keyboard_actions
  const MyScrollView({
    super.key,
    required this.children,
    this.padding,
    this.physics = const BouncingScrollPhysics(),
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.bottomButton,
    this.keyboardConfig,
    this.tapOutsideToDismiss = false,
    this.overScroll = 16.0,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics physics;
  final CrossAxisAlignment crossAxisAlignment;
  final Widget? bottomButton;
  final KeyboardActionsConfig? keyboardConfig;

  /// Press outside the keyboard to turn it off
  final bool tapOutsideToDismiss;

  /// The default pop-up position is below the text of the TextField, you can add this property to continue sliding up for a certain distance. Used to expose the complete TextField.
  final double overScroll;

  @override
  Widget build(BuildContext context) {
    Widget contents = Column(
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );

    if (defaultTargetPlatform == TargetPlatform.iOS && keyboardConfig != null) {
      /// iOS keyboard handling

      if (padding != null) {
        contents = Padding(padding: padding!, child: contents);
      }

      contents = KeyboardActions(
          isDialog: bottomButton != null,
          overscroll: overScroll,
          config: keyboardConfig!,
          tapOutsideBehavior: tapOutsideToDismiss
              ? TapOutsideBehavior.opaqueDismiss
              : TapOutsideBehavior.none,
          child: contents);
    } else {
      contents = SingleChildScrollView(
        padding: padding,
        physics: physics,
        child: contents,
      );
    }

    if (bottomButton != null) {
      contents = Column(
        children: <Widget>[
          Expanded(child: contents),
          SafeArea(child: bottomButton!)
        ],
      );
    }

    return contents;
  }
}
