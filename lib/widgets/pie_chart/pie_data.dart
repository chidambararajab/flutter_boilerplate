import 'package:flutter/material.dart';

class PieData {
  /// color
  late Color color;

  /// percentage
  late num percentage;

  /// quantity
  late int number;

  /// name
  late String name;

  @override
  String toString() => 'name: $name, color: $color, '
      'number: $number, percentage: $percentage';
}
