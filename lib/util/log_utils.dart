import 'dart:convert' as convert;
import 'package:common_utils/common_utils.dart';
import 'package:flutter_deer/res/constant.dart';

/// Output Log tool class
class Log {
  static const String tag = 'DEER-LOG';

  static void init() {
    LogUtil.init(isDebug: !Constant.inProduction, maxLen: 512);
  }

  static void d(String msg, {String tag = tag}) {
    if (!Constant.inProduction) {
      LogUtil.v(msg, tag: tag);
    }
  }

  static void e(String msg, {String tag = tag}) {
    if (!Constant.inProduction) {
      LogUtil.e(msg, tag: tag);
    }
  }

  static void json(String msg, {String tag = tag}) {
    if (!Constant.inProduction) {
      try {
        final dynamic data = convert.json.decode(msg);
        if (data is Map) {
          _printMap(data);
        } else if (data is List) {
          _printList(data);
        } else {
          LogUtil.v(msg, tag: tag);
        }
      } catch (e) {
        LogUtil.e(msg, tag: tag);
      }
    }
  }

  // https://github.com/Milad-Akarie/pretty_dio_logger
  static void _printMap(Map<dynamic, dynamic> data,
      {String tag = tag,
      int tabs = 1,
      bool isListItem = false,
      bool isLast = false}) {
    final bool isRoot = tabs == 1;
    final String initialIndent = _indent(tabs);
    tabs++;

    if (isRoot || isListItem) {
      LogUtil.v('$initialIndent{', tag: tag);
    }

    data.keys.toList().asMap().forEach((index, dynamic key) {
      final bool isLast = index == data.length - 1;
      dynamic value = data[key];
      if (value is String) {
        value = '"$value"';
      }
      if (value is Map) {
        if (value.isEmpty) {
          LogUtil.v('${_indent(tabs)} $key: $value${!isLast ? ',' : ''}',
              tag: tag);
        } else {
          LogUtil.v('${_indent(tabs)} $key: {', tag: tag);
          _printMap(value, tabs: tabs);
        }
      } else if (value is List) {
        if (value.isEmpty || value.length > 50) {
          LogUtil.v('${_indent(tabs)} $key: $value', tag: tag);
        } else {
          LogUtil.v('${_indent(tabs)} $key: [', tag: tag);
          _printList(value, tabs: tabs);
          LogUtil.v('${_indent(tabs)} ]${isLast ? '' : ','}', tag: tag);
        }
      } else {
        final msg = value.toString().replaceAll('\n', '');
        LogUtil.v('${_indent(tabs)} $key: $msg${!isLast ? ',' : ''}', tag: tag);
      }
    });

    LogUtil.v('$initialIndent}${isListItem && !isLast ? ',' : ''}', tag: tag);
  }

  static void _printList(List<dynamic> list, {String tag = tag, int tabs = 1}) {
    list.asMap().forEach((i, dynamic e) {
      final bool isLast = i == list.length - 1;
      if (e is Map) {
        if (_canFlattenMap(e, list)) {
          LogUtil.v('${_indent(tabs)}  $e${!isLast ? ',' : ''}', tag: tag);
        } else {
          _printMap(e, tabs: tabs + 1, isListItem: true, isLast: isLast);
        }
      } else {
        LogUtil.v('${_indent(tabs + 2)} $e${isLast ? '' : ','}', tag: tag);
      }
    });
  }

  /// Avoid the display of logs that output too many lines in one second
  /// Single process limit 250/s drop 66 lines.
  static bool _canFlattenMap(Map<dynamic, dynamic> map, List<dynamic> list) {
    return list.length * map.length > 100;
  }

  static String _indent([int tabCount = 1]) => '  ' * tabCount;
}
