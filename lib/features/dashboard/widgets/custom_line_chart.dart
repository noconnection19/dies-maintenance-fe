import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const CustomLineChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    const double chartHeight = 160.0;

    return Column(
      children: [
        SizedBox(
          height: chartHeight,
          child: CustomPaint(
            size: Size.infinite,
            painter: _LineChartPainter(data: data),
          ),
        ),
        const SizedBox(height: 8),

        // X Axis Labels (Months)
        Padding(
          padding: const EdgeInsets.only(left: 36.0, right: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.map((item) {
              final parts = (item['month'] as String).split(' ');
              final label = parts.length == 2 ? '${parts[0]} \'${parts[1].substring(2)}' : item['month'];
              return Text(
                label,
                style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  _LineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    const double leftMargin = 30.0;
    const double rightMargin = 10.0;
    const double topMargin = 10.0;
    const double bottomMargin = 10.0;

    final double width = size.width - leftMargin - rightMargin;
    final double height = size.height - topMargin - bottomMargin;

    // Nilai Occurrences maks pada Y axis
    const double maxY = 100.0;

    final paintGrid = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // ── 1. Draw Grid & Y Labels ──────────────────────────────────────
    const int gridLines = 5;
    for (int i = 0; i < gridLines; i++) {
      final double y = topMargin + (height / (gridLines - 1)) * i;
      canvas.drawLine(Offset(leftMargin, y), Offset(size.width - rightMargin, y), paintGrid);

      // Y axis label
      final int labelVal = ((gridLines - 1 - i) * (maxY / (gridLines - 1))).round();
      textPainter.text = TextSpan(
        text: '$labelVal',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 8),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }

    if (data.isEmpty) return;

    // ── 2. Draw Lines for each Category ──────────────────────────────
    final categories = {
      'blanking': Colors.orange,
      'tandem': const Color(0xFF10B981), // Emerald Green
      'transver1': Colors.deepPurple,
      'transver2': Colors.pinkAccent,
      'transver3': Colors.blue,
    };

    final int pointsCount = data.length;
    final double stepX = width / (pointsCount - 1 == 0 ? 1 : pointsCount - 1);

    categories.forEach((key, color) {
      final path = Path();
      final points = <Offset>[];

      for (int i = 0; i < pointsCount; i++) {
        final val = (data[i][key] as num?)?.toDouble() ?? 0.0;
        final double x = leftMargin + i * stepX;
        final double y = topMargin + height - (val / maxY) * height;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
        points.add(Offset(x, y));
      }

      // Draw the line path
      final paintLine = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..isAntiAlias = true;

      canvas.drawPath(path, paintLine);

      // Draw the dots
      final paintDot = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      final paintDotBorder = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      for (var pt in points) {
        canvas.drawCircle(pt, 4.0, paintDotBorder);
        canvas.drawCircle(pt, 2.5, paintDot);
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
