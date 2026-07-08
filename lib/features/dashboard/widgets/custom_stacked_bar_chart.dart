import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomStackedBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final double targetValue;

  const CustomStackedBarChart({
    super.key,
    required this.data,
    this.targetValue = 2700.0,
  });

  @override
  Widget build(BuildContext context) {
    const double chartHeight = 200.0;

    // Cari max total PPM untuk menentukan maxY dinamis agar tidak terjadi overflow
    double maxTotalVal = 3500.0;
    for (var item in data) {
      final total = ((item['tandem'] ?? 0) as num).toDouble() +
                    ((item['transver'] ?? 0) as num).toDouble();
      if (total > maxTotalVal) {
        maxTotalVal = total;
      }
    }
    final double maxY = (maxTotalVal * 1.15).roundToDouble(); // margin 15% untuk visualisasi di atas target line

    return LayoutBuilder(
      builder: (context, constraints) {
        final double chartWidth = constraints.maxWidth - 50; // Sisa untuk Y axis label
        final double barWidth = (chartWidth / (data.isEmpty ? 1 : data.length)) * 0.5;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Y Axis Labels ──────────────────────────────────────────────
            SizedBox(
              height: chartHeight,
              width: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(8, (index) {
                  final val = ((7 - index) * (maxY / 7)).round();
                  return Text(
                    val >= 1000 ? '${(val / 1000).toStringAsFixed(1).replaceAll('.0', '')}K' : '$val',
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  );
                }),
              ),
            ),
            const SizedBox(width: 8),

            // ── Chart Area ──────────────────────────────────────────────────
            Expanded(
              child: Column(
                children: [
                  Stack(
                    children: [
                      // Grid lines & Target line
                      SizedBox(
                        height: chartHeight,
                        child: Stack(
                          children: [
                            // Horizontal Grid Lines
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(8, (index) => Container(
                                height: 1,
                                color: Colors.grey[200],
                              )),
                            ),
                            // Target horizontal line (Red line at 2700 PPM)
                            Positioned(
                              bottom: (targetValue / maxY) * chartHeight,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bars Stack
                      SizedBox(
                        height: chartHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: data.map((item) {
                            final tandemVal = (item['tandem'] as num).toDouble();
                            final transverVal = (item['transver'] as num).toDouble();

                            // Hitung tinggi proporsional masing-masing segmen (PPM)
                            final hTandem = (tandemVal / maxY) * chartHeight;
                            final hTransver = (transverVal / maxY) * chartHeight;

                            return Tooltip(
                              message: '${item['month']}\n'
                                  'Tandem: ${tandemVal.toStringAsFixed(0)} PPM\n'
                                  'Transver: ${transverVal.toStringAsFixed(0)} PPM\n'
                                  'Overall: ${(item['overall_ppm'] as num).toStringAsFixed(0)} PPM',
                              child: SizedBox(
                                width: barWidth.clamp(12.0, 30.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (hTransver > 0) Container(height: hTransver, color: Colors.orangeAccent),
                                    if (hTandem > 0) Container(height: hTandem, color: const Color(0xFF10B981)), // Emerald Green
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── X Axis Labels (Months) ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: data.map((item) {
                      // Ambil 3 huruf bulan + tahun terakhir (e.g. "Jul 25")
                      final parts = (item['month'] as String).split(' ');
                      final label = parts.length == 2 ? '${parts[0]} \'${parts[1].substring(2)}' : item['month'];
                      return SizedBox(
                        width: barWidth.clamp(16.0, 48.0),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
