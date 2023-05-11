import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deer/res/resources.dart';
import 'package:flutter_deer/util/theme_utils.dart';
import 'package:flutter_deer/widgets/load_image.dart';

/// design/9 No status page yet/index.html#artboard3
class StateLayout extends StatelessWidget {
  const StateLayout({super.key, required this.type, this.hintText});

  final StateType type;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (type == StateType.loading)
          const CupertinoActivityIndicator(radius: 16.0)
        else if (type != StateType.empty)
          Opacity(
            opacity: context.isDark ? 0.5 : 1,
            child: LoadAssetImage(
              'state/${type.img}',
              width: 120,
            ),
          ),
        const SizedBox(
          width: double.infinity,
          height: Dimens.gap_dp16,
        ),
        Text(
          hintText ?? type.hintText,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontSize: Dimens.font_sp14),
        ),
        Gaps.vGap50,
      ],
    );
  }
}

enum StateType {
  /// Order
  order,

  /// commodity
  goods,

  /// No network
  network,

  /// information
  message,

  /// No cash withdrawal account
  account,

  /// Loading
  loading,

  /// null
  empty
}

extension StateTypeExtension on StateType {
  String get img =>
      <String>['zwdd', 'zwsp', 'zwwl', 'zwxx', 'zwzh', '', ''][index];

  String get hintText => <String>[
        'No order yet',
        'No products',
        'no internet connection',
        'no news',
        'Add a withdrawal account now',
        '',
        ''
      ][index];
}
