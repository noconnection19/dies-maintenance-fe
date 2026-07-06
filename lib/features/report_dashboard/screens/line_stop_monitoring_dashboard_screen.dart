import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_shell.dart';

class LineStopMonitoringDashboardScreen extends StatelessWidget {
  const LineStopMonitoringDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          _buildHeader(),
          const SizedBox(height: 12),

          // Stat Cards
          _buildStatCards(),
          const SizedBox(height: 12),

          // Main Content Area (Chart + Cards)
          Expanded(
            flex: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Column (2/3 width)
                Expanded(
                  flex: 2,
                  child: _buildChartCard(),
                ),
                const SizedBox(width: 24),
                // Right Column (1/3 width)
                Expanded(
                  flex: 1,
                  child: _buildRightPanel(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Bottom Area (3 equal cards)
          Expanded(
            flex: 1,
            child: _buildBottomCards(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Dashboard Line Stop Monitoring',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Row(
          children: [
            _buildFilterButton('Date', Icons.calendar_today),
            const SizedBox(width: 12),
            _buildFilterButton('Line', Icons.precision_manufacturing),
            const SizedBox(width: 12),
            _buildFilterButton('Shift', Icons.access_time),
          ],
        )
      ],
    );
  }

  Widget _buildFilterButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildSingleStatCard('PPM vs Target - Current Month', '2000/2700', 'PPM', '2% vs Last Month')),
          const SizedBox(width: 16),
          Expanded(child: _buildSingleStatCard('AVG PPM', '2350', 'PPM', '1.5% vs Last Month')),
          const SizedBox(width: 16),
          Expanded(child: _buildSingleStatCard('Incident Line Stop - Current Month', '15', 'Incidents', '3% vs Last Month')),
          const SizedBox(width: 16),
          Expanded(child: _buildSingleStatCard('Worst Line - Current month', 'Line A', '', '1 Rank vs Last Month')),
        ],
      ),
    );
  }

  Widget _buildSingleStatCard(String title, String value, String unit, String comparison) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (unit.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          unit,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]
                    ],
                  ),
                  if (comparison.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_upward, color: Colors.redAccent, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          comparison,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PPM Monthly Monitoring',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 30,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const style = TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    );
                                    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                    int index = value.toInt() - 1;
                                    if (index >= 0 && index < 12) {
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        space: 8,
                                        child: Text('${months[index]}\n26', textAlign: TextAlign.center, style: style),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                  reservedSize: 40,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 35,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 5,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: const Color(0xFFE2E8F0),
                                strokeWidth: 1,
                                dashArray: [4, 4],
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              _buildBarGroup(1, 4, 2, 2, 1, 1),
                              _buildBarGroup(2, 5, 3, 2, 1, 1),
                              _buildBarGroup(3, 3, 2, 1, 1, 1),
                              _buildBarGroup(4, 6, 4, 2, 2, 1),
                              _buildBarGroup(5, 4, 3, 2, 1, 1),
                              _buildBarGroup(6, 6, 3, 2, 2, 1),
                              _buildBarGroup(7, 3, 2, 2, 1, 1),
                              _buildBarGroup(8, 6, 4, 3, 2, 1),
                              _buildBarGroup(9, 5, 3, 2, 2, 1),
                              _buildBarGroup(10, 4, 2, 2, 1, 1),
                              _buildBarGroup(11, 6, 5, 3, 2, 1),
                              _buildBarGroup(12, 5, 4, 2, 2, 1),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLegend(),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.green.withOpacity(0.1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Best Month',
                                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                      text: const TextSpan(
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter'), // Assuming standard font
                                        children: [
                                          TextSpan(text: 'Jan 26 | 1500', style: TextStyle(color: AppColors.green)),
                                          TextSpan(
                                            text: ' PPM',
                                            style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Worst Month',
                                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                      text: const TextSpan(
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                        children: [
                                          TextSpan(text: 'Jul 26 | 3200', style: TextStyle(color: Colors.red)),
                                          TextSpan(
                                            text: ' PPM',
                                            style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double v1, double v2, double v3, double v4, double v5) {
    double total = v1 + v2 + v3 + v4 + v5;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: total,
          width: 48,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          rodStackItems: [
            BarChartRodStackItem(0, v1, Colors.green.shade700),
            BarChartRodStackItem(v1, v1 + v2, Colors.lightGreen.shade700),
            BarChartRodStackItem(v1 + v2, v1 + v2 + v3, Colors.orange.shade600),
            BarChartRodStackItem(v1 + v2 + v3, v1 + v2 + v3 + v4, Colors.purple.shade600),
            BarChartRodStackItem(v1 + v2 + v3 + v4, total, Colors.blue.shade700),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem('Target', Colors.deepOrange),
        _buildLegendItem('Tandem', Colors.green.shade700),
        _buildLegendItem('Blanking', Colors.lightGreen.shade700),
        _buildLegendItem('Transfer 1', Colors.orange.shade600),
        _buildLegendItem('Transfer 2', Colors.purple.shade600),
        _buildLegendItem('Transfer 3', Colors.blue.shade700),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top row inside the 1/3 panel
        Expanded(
          flex: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildSmallDetailCard('PPM Tandem', '1450 | 8 Jam', '2% vs Last Month')),
              const SizedBox(width: 16),
              Expanded(child: _buildSmallDetailCard('PPM Blanking', '900 | 8 Jam', '1.5% vs Last Month')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Bottom large card inside the 1/3 panel
        Expanded(
          flex: 1,
          child: _buildTransverCard(),
        ),
      ],
    );
  }

  Widget _buildSmallDetailCard(String title, String value, String comparison) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.red, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        comparison,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeDetailCard(String title, {Widget? child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: child ?? const Center(
              child: Text(
                'No additional details available',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransverCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: const Text(
              'PPM Transver 1 - 3',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '778 | 8 Jam',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.arrow_upward, color: Colors.red, size: 14),
                      SizedBox(width: 4),
                      Text(
                        '2% vs Last Month',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCards() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildLargeDetailCard('Breakdown Problem per Categories', child: _buildBreakdownProblemContent())),
        const SizedBox(width: 24),
        Expanded(child: _buildLargeDetailCard('Trend Occurence per LINE', child: _buildTrendOccurenceContent())),
        const SizedBox(width: 24),
        Expanded(child: _buildLargeDetailCard('Improvement PPM per Dies - Top 5', child: _buildImprovementContent())),
      ],
    );
  }

  Widget _buildBreakdownProblemContent() {
    final data = [
      {'problem': 'Dies Scratch', 'occ': 45, 'percent': 85},
      {'problem': 'Dies Crack', 'occ': 30, 'percent': 60},
      {'problem': 'Sensor Error', 'occ': 25, 'percent': 50},
      {'problem': 'Misfeed', 'occ': 20, 'percent': 40},
      {'problem': 'Ejector Stuck', 'occ': 15, 'percent': 30},
      {'problem': 'Slug Mark', 'occ': 10, 'percent': 20},
      {'problem': 'Spring Broken', 'occ': 5, 'percent': 10},
    ];

    return Column(
      children: [
        Row(
          children: const [
            Expanded(flex: 3, child: Text('Problem', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
            Expanded(flex: 1, child: Text('Occ', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
            Expanded(flex: 1, child: Text('%', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: data.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = data[index];
              final percent = item['percent'] as int;
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['problem'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            backgroundColor: Colors.grey.shade200,
                            color: AppColors.green,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('${item['occ']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('$percent%', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w600)),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendOccurenceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(enabled: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: const Color(0xFFE2E8F0),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      );
                      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                      int index = value.toInt() - 1;
                      if (index >= 0 && index < 12) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8,
                          child: Text('${months[index]}\n26', textAlign: TextAlign.center, style: style),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 40,
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 1,
              maxX: 12,
              minY: 0,
              maxY: 30,
              lineBarsData: [
                _buildLineChartBarData([8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8], Colors.deepOrange),
                _buildLineChartBarData([4, 5, 3, 6, 4, 6, 3, 6, 5, 4, 6, 5], Colors.green.shade700),
                _buildLineChartBarData([2, 3, 2, 4, 3, 3, 2, 4, 3, 2, 5, 4], Colors.lightGreen.shade700),
                _buildLineChartBarData([2, 2, 1, 2, 2, 2, 2, 3, 2, 2, 3, 2], Colors.orange.shade600),
                _buildLineChartBarData([1, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2], Colors.purple.shade600),
                _buildLineChartBarData([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], Colors.blue.shade700),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  LineChartBarData _buildLineChartBarData(List<double> values, Color color) {
    return LineChartBarData(
      spots: List.generate(values.length, (index) => FlSpot(index + 1.0, values[index])),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildImprovementContent() {
    final improves = [
      {'name': 'BARI', 'old': 309, 'new': 129},
      {'name': 'KALI', 'old': 250, 'new': 100},
      {'name': 'TARI', 'old': 400, 'new': 200},
      {'name': 'SARI', 'old': 150, 'new': 80},
      {'name': 'LARI', 'old': 100, 'new': 40},
    ];

    final worsens = [
      {'name': 'DORI', 'old': 100, 'new': 300},
      {'name': 'MORI', 'old': 50, 'new': 200},
      {'name': 'PORI', 'old': 120, 'new': 250},
      {'name': 'TORI', 'old': 80, 'new': 180},
      {'name': 'LORI', 'old': 90, 'new': 150},
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PPM Improves', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.green)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: improves.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _buildImprovementItem(improves[index], true),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PPM Worsens', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: worsens.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _buildImprovementItem(worsens[index], false),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImprovementItem(Map<String, dynamic> data, bool isImprove) {
    final oldVal = data['old'] as int;
    final newVal = data['new'] as int;
    final diff = oldVal - newVal;
    final diffText = isImprove ? '-${diff.abs()}' : '+${diff.abs()}';
    final diffColor = isImprove ? AppColors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('$oldVal ➔ $newVal', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          Text(
            diffText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: diffColor,
            ),
          ),
        ],
      ),
    );
  }
}
