import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_deer/res/resources.dart';
import 'package:flutter_deer/util/theme_utils.dart';
import 'package:flutter_deer/widgets/pie_chart/pie_data.dart';

///Donut Chart Reference：https://github.com/apgapg/pie_chart
class PieChart extends StatefulWidget {
  const PieChart({super.key, required this.data, required this.name});

  final List<PieData> data;
  final String name;
  static const List<Color> colorList = <Color>[
    Color(0xFFFFD147),
    Color(0xFFA9DAF2),
    Color(0xFFFAAF64),
    Color(0xFF7087FA),
    Color(0xFFA0E65C),
    Color(0xFF5CE6A1),
    Color(0xFFA364FA),
    Color(0xFFDA61F2),
    Color(0xFFFA64AE),
    Color(0xFFFA6464),
  ];

  @override
  _PieChartState createState() => _PieChartState();
}

class _PieChartState extends State<PieChart>
    with SingleTickerProviderStateMixin {
  late int count;
  late Animation<double> animation;
  late AnimationController controller;
  late List<PieData> oldData;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    final Animation<double> curve =
        CurvedAnimation(parent: controller, curve: Curves.decelerate);
    animation = Tween<double>(begin: 0, end: 1).animate(curve);
    controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(PieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate when data changes
    if (oldData != widget.data) {
      controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    oldData = widget.data;
    count = 0;
    for (int i = 0; i < widget.data.length; i++) {
      count += widget.data[i].number;
    }
    final Color bgColor = context.backgroundColor;
    final Color shadowColor =
        context.isDark ? Colours.dark_bg_gray : const Color(0x80C8DAFA);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: shadowColor,
              offset: const Offset(0.0, 4.0),
              blurRadius: 8.0),
        ],
      ),
      child: RepaintBoundary(
        child: AnimatedBuilder(
            animation: animation,
            builder: (_, Widget? child) {
              return CustomPaint(
                painter: PieChartPainter(
                    widget.data, animation.value, bgColor, widget.name, count),
                child: child,
              );
            },
            child: Center(
              child: ExcludeSemantics(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(widget.name, style: TextStyles.textBold16),
                    Gaps.vGap4,
                    Text('$count件')
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  PieChartPainter(
      this.data, double angleFactor, this.bgColor, this.name, this.count) {
    if (data.isEmpty) {
      return;
    }
    int count = 0;
    for (int i = 0; i < data.length; i++) {
      count += data[i].number;
    }
    PieData? pieData;
    if (data.length == 11) {
      // Get "other" data
      pieData = data[10];
      pieData.percentage = pieData.number / count;
      pieData.color = Colours.text_gray_c;
      // Sort by Quantity after removing "Other"
      data.removeAt(10);
    }

    data.sort(
        (PieData left, PieData right) => right.number.compareTo(left.number));
    // Give colors from largest to smallest
    for (int i = 0; i < data.length; i++) {
      data[i].color = PieChart.colorList[i];
      data[i].percentage = data[i].number / count;
      // sorted data output
//      print(data[i].toString());
    }
    if (pieData != null) {
      data.add(pieData);
    }
    _mPaint = Paint();
    totalAngle = angleFactor * math.pi * 2;
  }

  late Rect mCircle;
  late Paint _mPaint;
  // radius
  late double mRadius;
  late List<PieData> data;
  late double totalAngle;

  // starting angle
  late double prevAngle;
  late Color bgColor;

  // The total amount
  late int count;
  // chart name
  late String name;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) {
      return;
    }
    prevAngle = -math.pi;
    mRadius = math.min(size.width, size.height) / 2 - 4;
    // center of circle
    final Offset offset = Offset(size.width / 2, size.height / 2);
    mCircle = Rect.fromCircle(center: offset, radius: mRadius);

    for (int i = 0; i < data.length; i++) {
      _mPaint
        ..color = data[i].color
        ..style = PaintingStyle.fill;
      canvas.drawArc(
          mCircle, prevAngle, totalAngle * data[i].percentage, true, _mPaint);
      prevAngle = prevAngle + totalAngle * data[i].percentage;
    }
    // In order for the text not to be covered, draw the text after drawing the fan
    prevAngle = -math.pi;
    for (int i = 0; i < data.length; i++) {
      //Calculate the coordinates of the fan center point
      final double x = (size.height * 0.74 / 2) *
          math.cos(prevAngle + (totalAngle * data[i].percentage / 2));
      final double y = (size.height * 0.74 / 2) *
          math.sin(prevAngle + (totalAngle * data[i].percentage / 2));
      // one decimal place
      final String percentage =
          '${(data[i].percentage * 100).toStringAsFixed(1)}%';
      drawPercentage(canvas, percentage, x, y, size);
      prevAngle = prevAngle + totalAngle * data[i].percentage;
    }

    canvas.save();
    _mPaint
      ..color = bgColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(offset, mRadius * 0.52, _mPaint);

    _mPaint
      ..color = const Color(0x80FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;
    canvas.drawCircle(offset, mRadius * 0.52, _mPaint);

    canvas.restore();
  }

  void drawPercentage(
      Canvas context, String percentage, double x, double y, Size size) {
    final TextSpan span = TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: Dimens.font_sp12),
        text: percentage);
    final TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.rtl);
    tp.layout();
    tp.paint(
        context,
        Offset(size.width / 2 + x - (tp.width / 2),
            size.height / 2 + y - (tp.height / 2)));
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) {
    // Returns true because the animation needs to be redrawn. Avoid redrawing and let RepaintBoundary handle it. You can also judge whether the animation is executed to redraw when processing
    return true;
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder => _buildSemantics;

  /// Add semantic nodes to each fan-shaped area on the pie chart (for ease of reading, change the node area to a rectangle)
  List<CustomPainterSemantics> _buildSemantics(Size size) {
    final List<CustomPainterSemantics> nodes = <CustomPainterSemantics>[];
    final double height = size.height / data.length;
    for (int i = 0; i < data.length; i++) {
      final String percentage =
          '${(data[i].percentage * 100).toStringAsFixed(1)}%';
      final CustomPainterSemantics node = CustomPainterSemantics(
        rect: Rect.fromLTRB(
          0,
          height * i,
          size.width,
          height * i + height,
        ),
        properties: SemanticsProperties(
          sortKey: OrdinalSortKey(i.toDouble()),
          label: '$name${'$count件'}${data[i].name}占比$percentage',
          readOnly: true,
          textDirection: TextDirection.ltr,
        ),
        tags: const <SemanticsTag>{
          SemanticsTag('pieChart-label'),
        },
      );
      nodes.add(node);
    }
    return nodes;
  }
}
