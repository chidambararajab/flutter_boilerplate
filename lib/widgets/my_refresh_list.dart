import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_deer/res/resources.dart';
import 'package:flutter_deer/util/theme_utils.dart';
import 'package:flutter_deer/widgets/state_layout.dart';

/// Encapsulate pull-down refresh and load more
class DeerListView extends StatefulWidget {
  const DeerListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onRefresh,
    this.loadMore,
    this.hasMore = false,
    this.stateType = StateType.empty,
    this.pageSize = 10,
    this.padding,
    this.itemExtent,
  });

  final RefreshCallback onRefresh;
  final LoadMoreCallback? loadMore;
  final int itemCount;
  final bool hasMore;
  final IndexedWidgetBuilder itemBuilder;
  final StateType stateType;

  /// The number of pages, the default is 10
  final int pageSize;

  /// When using the padding attribute, be careful that it will destroy the original SafeArea, and you need to calculate the bottom size by yourself
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;

  @override
  _DeerListViewState createState() => _DeerListViewState();
}

typedef RefreshCallback = Future<void> Function();
typedef LoadMoreCallback = Future<void> Function();

class _DeerListViewState extends State<DeerListView> {
  /// Is the data being loaded
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Widget child = RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: widget.itemCount == 0
          ? StateLayout(type: widget.stateType)
          : ListView.builder(
              itemCount: widget.loadMore == null
                  ? widget.itemCount
                  : widget.itemCount + 1,
              padding: widget.padding,
              itemExtent: widget.itemExtent,
              itemBuilder: (BuildContext context, int index) {
                /// If you don't need to load more, you don't need to add FootView
                if (widget.loadMore == null) {
                  return widget.itemBuilder(context, index);
                } else {
                  return index < widget.itemCount
                      ? widget.itemBuilder(context, index)
                      : MoreWidget(
                          widget.itemCount, widget.hasMore, widget.pageSize);
                }
              },
            ),
    );
    return SafeArea(
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification note) {
          /// Make sure to scroll vertically and slide to the bottom
          if (note.metrics.pixels == note.metrics.maxScrollExtent &&
              note.metrics.axis == Axis.vertical) {
            _loadMore();
          }
          return true;
        },
        child: child,
      ),
    );
  }

  Future<void> _loadMore() async {
    if (widget.loadMore == null) {
      return;
    }
    if (_isLoading) {
      return;
    }
    if (!widget.hasMore) {
      return;
    }
    _isLoading = true;
    await widget.loadMore?.call();
    _isLoading = false;
  }
}

class MoreWidget extends StatelessWidget {
  const MoreWidget(this.itemCount, this.hasMore, this.pageSize, {super.key});

  final int itemCount;
  final bool hasMore;
  final int pageSize;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = context.isDark
        ? TextStyles.textGray14
        : const TextStyle(color: Color(0x8A000000));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (hasMore) const CupertinoActivityIndicator(),
          if (hasMore) Gaps.hGap5,

          /// When there is only one page, the FooterView is not displayed
          Text(hasMore ? 'Loading...' : (itemCount < pageSize ? '' : 'no more'),
              style: style),
        ],
      ),
    );
  }
}
