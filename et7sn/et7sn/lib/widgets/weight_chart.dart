import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Minimal line chart for weekly weights (oldest on the left).
class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.values, this.height = 170});

  final List<double> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _WeightChartPainter(
          values: values,
          lineColor: scheme.primary,
          gridColor: scheme.outlineVariant,
          textColor: scheme.onSurfaceVariant,
          dotFill: scheme.surface,
        ),
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  _WeightChartPainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
    required this.dotFill,
  });

  final List<double> values;
  final Color lineColor;
  final Color gridColor;
  final Color textColor;
  final Color dotFill;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const left = 36.0;
    const right = 12.0;
    const top = 12.0;
    const bottom = 12.0;
    final width = size.width - left - right;
    final height = size.height - top - bottom;

    var minValue = values.reduce(math.min);
    var maxValue = values.reduce(math.max);
    if (maxValue - minValue < 1) {
      final middle = (maxValue + minValue) / 2;
      minValue = middle - 1;
      maxValue = middle + 1;
    }
    final padding = (maxValue - minValue) * 0.15;
    minValue -= padding;
    maxValue += padding;

    Offset pointAt(int index) {
      final x = values.length == 1
          ? left + width / 2
          : left + width * index / (values.length - 1);
      final y = top + height * (1 - (values[index] - minValue) / (maxValue - minValue));
      return Offset(x, y);
    }

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final fraction = i / 2;
      final y = top + height * fraction;
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), gridPaint);
      final label = maxValue - (maxValue - minValue) * fraction;
      final painter = TextPainter(
        text: TextSpan(
          text: label.toStringAsFixed(0),
          style: TextStyle(color: textColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(0, y - painter.height / 2));
    }

    final linePath = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < values.length; i++) {
      final point = pointAt(i);
      linePath.lineTo(point.dx, point.dy);
    }

    if (values.length > 1) {
      final fillPath = Path.from(linePath)
        ..lineTo(pointAt(values.length - 1).dx, top + height)
        ..lineTo(pointAt(0).dx, top + height)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..color = lineColor.withValues(alpha: 0.12)
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < values.length; i++) {
      final point = pointAt(i);
      canvas.drawCircle(point, 5, Paint()..color = dotFill);
      canvas.drawCircle(
        point,
        5,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) {
    return !listEquals(oldDelegate.values, values) ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.dotFill != dotFill;
  }
}
