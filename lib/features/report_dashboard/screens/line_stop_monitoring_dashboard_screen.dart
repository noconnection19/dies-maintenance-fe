import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

class LineStopMonitoringDashboardScreen extends StatefulWidget {
  const LineStopMonitoringDashboardScreen({super.key});

  @override
  State<LineStopMonitoringDashboardScreen> createState() => _LineStopMonitoringDashboardScreenState();
}

class _LineStopMonitoringDashboardScreenState extends State<LineStopMonitoringDashboardScreen> {
  late DateTime _fromDate;
  late DateTime _toDate;
  
  bool _isLoading = false;
  double _ppmCurrent = 0;
  double _avgPpm = 0;
  int _incidentOcc = 0;
  String _worstLineName = '-';
  double _worstLinePpm = 0;
  double _worstLineTarget = 0;
  Map<String, dynamic> _lineDetails = {
    'tandem': {'ppm': 0, 'hours': 0},
    'blanking': {'ppm': 0, 'hours': 0},
    'transver': {'ppm': 0, 'hours': 0},
  };
  String _bestMonthName = '-';
  double _bestMonthValue = 0;
  String _worstMonthName = '-';
  double _worstMonthValue = 0;
  List<Map<String, dynamic>> _breakdownCategories = [];
  List<Map<String, dynamic>> _improves = [];
  List<Map<String, dynamic>> _worsens = [];
  List<Map<String, dynamic>> _trendOccurrence = [];
  List<Map<String, dynamic>> _monthlyMonitoring = [];


  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _toDate = DateTime(now.year, now.month);
    _fromDate = DateTime(now.year, now.month - 5);
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final startDateStr = DateFormat('yyyy-MM-dd').format(DateTime(_fromDate.year, _fromDate.month, 1));
      final lastDayOfMonth = DateTime(_toDate.year, _toDate.month + 1, 0);
      final endDateStr = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);
      
      final response = await ApiClient.get(
        ApiConstants.dashboardMonitoring,
        queryParams: {
          'start_date': startDateStr,
          'end_date': endDateStr,
        },
      );
      
      if (response != null && response['data'] != null) {
        final kpi = response['data']['kpi'];
        final lineDetails = response['data']['line_details'];
        setState(() {
          if (kpi != null) {
            _ppmCurrent = (kpi['ppm_current'] as num).toDouble();
            _avgPpm = (kpi['avg_ppm'] as num).toDouble();
            _incidentOcc = (kpi['incident_occ'] as num).toInt();
            _worstLineName = kpi['worst_line_name'] as String? ?? '-';
            _worstLinePpm = (kpi['worst_line_ppm'] as num).toDouble();
            _worstLineTarget = (kpi['worst_line_target'] as num).toDouble();
          }
          _bestMonthName = response['data']['best_month_name'] as String? ?? '-';
          _bestMonthValue = (response['data']['best_month_value'] as num? ?? 0).toDouble();
          _worstMonthName = response['data']['worst_month_name'] as String? ?? '-';
          _worstMonthValue = (response['data']['worst_month_value'] as num? ?? 0).toDouble();
          if (lineDetails != null) {
            _lineDetails = Map<String, dynamic>.from(lineDetails);
          }
          if (response['data']['breakdown_categories'] != null) {
            _breakdownCategories = List<Map<String, dynamic>>.from(response['data']['breakdown_categories']);
          } else {
            _breakdownCategories = [];
          }
          final improvements = response['data']['improvements'];
          if (improvements != null) {
            _improves = List<Map<String, dynamic>>.from(improvements['improves'] ?? []);
            _worsens = List<Map<String, dynamic>>.from(improvements['worsens'] ?? []);
          } else {
            _improves = [];
            _worsens = [];
          }
          if (response['data']['trend_occurrence'] != null) {
            _trendOccurrence = List<Map<String, dynamic>>.from(response['data']['trend_occurrence']);
          } else {
            _trendOccurrence = [];
          }
          if (response['data']['monthly_monitoring'] != null) {
            _monthlyMonitoring = List<Map<String, dynamic>>.from(response['data']['monthly_monitoring']);
          } else {
            _monthlyMonitoring = [];
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showMonthYearRangePicker() async {
    final result = await showDialog<Map<String, DateTime>>(
      context: context,
      builder: (context) => _MonthYearRangePickerDialog(
        initialFromDate: _fromDate,
        initialToDate: _toDate,
      ),
    );

    if (result != null) {
      setState(() {
        _fromDate = result['from']!;
        _toDate = result['to']!;
      });
      _fetchDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      contentPadding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenW = constraints.maxWidth;
          final screenH = constraints.maxHeight;

          // Responsive padding
          final hPad = (screenW * 0.025).clamp(16.0, 40.0);
          final vPad = (screenH * 0.02).clamp(12.0, 24.0);
          final gap = (screenH * 0.015).clamp(8.0, 16.0);

          // Proportional section heights with minimums
          final statH = (screenH * 0.12).clamp(80.0, 120.0);
          final mainH = (screenH * 0.42).clamp(280.0, double.infinity);
          final bottomH = (screenH * 0.38).clamp(260.0, double.infinity);

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Row
                  _buildHeader(),
                  SizedBox(height: gap),

                  // Stat Cards
                  SizedBox(
                    height: statH,
                    child: _buildStatCardsContent(),
                  ),
                  SizedBox(height: gap),

                  // Main Content Area (Chart + Cards)
                  SizedBox(
                    height: mainH,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildChartCard(),
                        ),
                        SizedBox(width: gap * 1.5),
                        Expanded(
                          flex: 1,
                          child: _buildRightPanel(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: gap),

                  // Bottom Area (3 equal cards)
                  SizedBox(
                    height: bottomH,
                    child: _buildBottomCards(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final dateLabel = '${DateFormat('MMM yy').format(_fromDate)} - ${DateFormat('MMM yy').format(_toDate)}';
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
            _buildFilterButton(dateLabel, Icons.calendar_today, onTap: _showMonthYearRangePicker),
            const SizedBox(width: 12),
            _buildFilterButton('Line', Icons.precision_manufacturing),
            const SizedBox(width: 12),
            _buildFilterButton('Shift', Icons.access_time),
          ],
        )
      ],
    );
  }

  Widget _buildFilterButton(String label, IconData icon, {VoidCallback? onTap}) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
        ),
      ),
    );
  }

  /// Stat cards content — parent provides height via SizedBox.
  Widget _buildStatCardsContent() {
    int monthsDiff = (_toDate.year - _fromDate.year) * 12 + _toDate.month - _fromDate.month + 1;
    int targetPpm = 1721 * monthsDiff;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildSingleStatCard('PPM vs Target - by Range Date', _isLoading ? '...' : '${_ppmCurrent.toInt()} / $targetPpm', 'PPM', '')),
        const SizedBox(width: 16),
        Expanded(child: _buildSingleStatCard('AVG PPM - by Range Date', _isLoading ? '...' : '${_avgPpm.toInt()}', 'PPM', '')),
        const SizedBox(width: 16),
        Expanded(child: _buildSingleStatCard('Incident Line Stop - by Range Date', _isLoading ? '...' : '$_incidentOcc', 'Incidents', '')),
        const SizedBox(width: 16),
        Expanded(child: _buildSingleStatCard('Worst Line - by Range Date', _isLoading ? '...' : '$_worstLineName / ${_worstLineTarget.toInt()}', 'PPM', '')),
      ],
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
          const SizedBox(height: 16),
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
                        child: LayoutBuilder(
                          builder: (context, chartConstraints) {
                            double maxTotalPpm = 30.0;
                            for (final data in _monthlyMonitoring) {
                              final tandem = (data['tandem'] as num? ?? 0.0).toDouble();
                              final blanking = (data['blanking'] as num? ?? 0.0).toDouble();
                              final transver = (data['transver'] as num? ?? 0.0).toDouble();
                              final total = tandem + blanking + transver;
                              if (total > maxTotalPpm) {
                                maxTotalPpm = total;
                              }
                            }
                            double chartMaxY = (maxTotalPpm * 1.15).ceilToDouble();
                            if (chartMaxY < 2000.0) chartMaxY = 2000.0;

                            double gridInterval = 1000.0;
                            if (chartMaxY <= 1000) {
                              gridInterval = 200.0;
                            }

                            // Dynamic bar width based on chart area & number of bars
                            final barCount = _monthlyMonitoring.length;
                            final availableW = chartConstraints.maxWidth - 35; // minus left titles
                            final dynamicRodWidth = barCount > 0
                                ? (availableW / barCount * 0.35).clamp(12.0, 24.0)
                                : 20.0;

                            if (_isLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (_monthlyMonitoring.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No data available',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              );
                            }
                            return BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: chartMaxY,
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
                                        int index = value.toInt() - 1;
                                        if (index >= 0 && index < _monthlyMonitoring.length) {
                                          String monthLabel = _monthlyMonitoring[index]['month'] ?? '';
                                          if (monthLabel.contains(' ')) {
                                            monthLabel = monthLabel.replaceFirst(' ', '\n');
                                          }
                                          return SideTitleWidget(
                                            axisSide: meta.axisSide,
                                            space: 8,
                                            child: Text(monthLabel, textAlign: TextAlign.center, style: style),
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
                                        const style = TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        );
                                        final val = value.toInt();
                                        if (val == 0) {
                                          return const Text('0', style: style);
                                        }
                                        if (val % 1000 == 0) {
                                          return Text('${val ~/ 1000}K', style: style);
                                        }
                                        final label = val >= 1000
                                            ? '${(val / 1000).toStringAsFixed(1).replaceAll('.0', '')}K'
                                            : '$val';
                                        return Text(label, style: style);
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                extraLinesData: ExtraLinesData(
                                  horizontalLines: [
                                    HorizontalLine(
                                      y: 1721.0,
                                      color: Colors.redAccent,
                                      strokeWidth: 2,
                                      dashArray: [6, 3],
                                    ),
                                  ],
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: gridInterval,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: const Color(0xFFE2E8F0),
                                    strokeWidth: 1,
                                    dashArray: [4, 4],
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(_monthlyMonitoring.length, (index) {
                                  final data = _monthlyMonitoring[index];
                                  final tandem = (data['tandem'] as num? ?? 0.0).toDouble();
                                  final blanking = (data['blanking'] as num? ?? 0.0).toDouble();
                                  final transver = (data['transver'] as num? ?? 0.0).toDouble();
                                  return _buildBarGroup(
                                    index + 1,
                                    tandem,
                                    blanking,
                                    transver,
                                    rodWidth: dynamicRodWidth,
                                  );
                                }),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLegend(showTarget: true),
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
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                        children: [
                                          TextSpan(text: '$_bestMonthName | ${_bestMonthValue.toInt()}', style: const TextStyle(color: AppColors.green)),
                                          const TextSpan(
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
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                        children: [
                                          TextSpan(text: '$_worstMonthName | ${_worstMonthValue.toInt()}', style: const TextStyle(color: Colors.red)),
                                          const TextSpan(
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

  BarChartGroupData _buildBarGroup(int x, double tandem, double blanking, double transver, {double rodWidth = 48}) {
    double total = tandem + blanking + transver;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: total,
          width: rodWidth,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          rodStackItems: [
            BarChartRodStackItem(0, tandem, Colors.green.shade700),
            BarChartRodStackItem(tandem, tandem + blanking, Colors.red.shade600),
            BarChartRodStackItem(tandem + blanking, total, Colors.orange.shade600),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend({bool showTarget = false}) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem('Tandem', Colors.green.shade700),
        _buildLegendItem('Blanking', Colors.red.shade600),
        _buildLegendItem('Transfer', Colors.orange.shade600),
        if (showTarget)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 2,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 6),
              const Text(
                'Target Line (1721 PPM)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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
              Expanded(
                child: _buildSmallDetailCard(
                  'PPM Tandem',
                  _isLoading
                      ? '...'
                      : '${(_lineDetails['tandem']['ppm'] as num).toInt()} | ${(_lineDetails['tandem']['hours'] as num).toInt()} Jam',
                  '',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSmallDetailCard(
                  'PPM Blanking',
                  _isLoading
                      ? '...'
                      : '${(_lineDetails['blanking']['ppm'] as num).toInt()} | ${(_lineDetails['blanking']['hours'] as num).toInt()} Jam',
                  '',
                ),
              ),
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
                  if (comparison.isNotEmpty) ...[
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
              'PPM Transver',
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
                  Text(
                    _isLoading
                        ? '...'
                        : '${(_lineDetails['transver']['ppm'] as num).toInt()} | ${(_lineDetails['transver']['hours'] as num).toInt()} Jam',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
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
        Expanded(child: _buildLargeDetailCard('PPM per Problem - Top 5', child: _buildImprovementContent())),
      ],
    );
  }

  Widget _buildBreakdownProblemContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_breakdownCategories.isEmpty) {
      return const Center(child: Text('No data found', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)));
    }

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
            itemCount: _breakdownCategories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _breakdownCategories[index];
              final problemName = item['problem'] ?? item['Problem'] ?? 'Unknown';
              final occ = ((item['occ'] ?? item['Occ'] ?? 0) as num).toInt();
              final percent = ((item['percentage'] ?? item['presentase'] ?? item['PERSENTASE'] ?? 0.0) as num).toDouble();
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(problemName as String, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: percent / 100.0,
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
                    child: Text('$occ', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('${percent.toInt()}%', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w600)),
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_trendOccurrence.isEmpty) {
      return const Center(child: Text('No data found', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)));
    }

    double calculatedMaxY = 10;
    for (var item in _trendOccurrence) {
      double blanking = ((item['blanking'] ?? 0) as num).toDouble();
      double tandem = ((item['tandem'] ?? 0) as num).toDouble();
      double transver = ((item['transver'] ?? 0) as num).toDouble();
      double m = [blanking, tandem, transver].reduce((curr, next) => curr > next ? curr : next);
      if (m > calculatedMaxY) {
        calculatedMaxY = m;
      }
    }
    calculatedMaxY = ((calculatedMaxY / 5).ceil() * 5).toDouble();
    if (calculatedMaxY < 10) calculatedMaxY = 10;

    final tandemValues = _trendOccurrence.map((item) => ((item['tandem'] ?? 0) as num).toDouble()).toList();
    final blankingValues = _trendOccurrence.map((item) => ((item['blanking'] ?? 0) as num).toDouble()).toList();
    final transverValues = _trendOccurrence.map((item) => ((item['transver'] ?? 0) as num).toDouble()).toList();

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
                      int index = value.toInt() - 1;
                      if (index >= 0 && index < _trendOccurrence.length) {
                        final monthName = _trendOccurrence[index]['month'] as String? ?? '';
                        final parts = monthName.split(' ');
                        final displayLabel = parts.length >= 2 ? '${parts[0]}\n${parts[1]}' : monthName;
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8,
                          child: Text(displayLabel, textAlign: TextAlign.center, style: style),
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
              maxX: _trendOccurrence.length.toDouble(),
              minY: 0,
              maxY: calculatedMaxY,
              lineBarsData: [
                _buildLineChartBarData(tandemValues, Colors.green.shade700),
                _buildLineChartBarData(blankingValues, Colors.red.shade600),
                _buildLineChartBarData(transverValues, Colors.orange.shade600),
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_improves.isEmpty && _worsens.isEmpty) {
      return const Center(child: Text('No data found', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)));
    }

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
                  itemCount: _improves.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _buildImprovementItem(_improves[index], true),
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
                  itemCount: _worsens.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _buildImprovementItem(_worsens[index], false),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImprovementItem(Map<String, dynamic> item, bool isImprove) {
    final problemName = item['problem'] ?? item['Problem'] ?? 'Unknown';
    final occ = ((item['occ'] ?? item['Occ'] ?? 0) as num).toInt();
    final ppm = ((item['ppm'] ?? 0) as num).toInt();
    final diffColor = isImprove ? AppColors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            problemName as String,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Inter'),
              children: [
                TextSpan(text: '$occ Occ | '),
                TextSpan(
                  text: '$ppm PPM',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: diffColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthYearRangePickerDialog extends StatefulWidget {
  final DateTime initialFromDate;
  final DateTime initialToDate;

  const _MonthYearRangePickerDialog({
    required this.initialFromDate,
    required this.initialToDate,
  });

  @override
  State<_MonthYearRangePickerDialog> createState() => _MonthYearRangePickerDialogState();
}

class _MonthYearRangePickerDialogState extends State<_MonthYearRangePickerDialog> {
  late DateTime fromDate;
  late DateTime toDate;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fromDate = widget.initialFromDate;
    toDate = widget.initialToDate;
  }

  void _validate() {
    final fromDateNorm = DateTime(fromDate.year, fromDate.month);
    final toDateNorm = DateTime(toDate.year, toDate.month);

    if (fromDateNorm.isAfter(toDateNorm)) {
      setState(() => errorMessage = '"From" month cannot be after "To" month.');
      return;
    }
    
    int monthsDiff = (toDateNorm.year - fromDateNorm.year) * 12 + toDateNorm.month - fromDateNorm.month;
    if (monthsDiff >= 12) {
      setState(() => errorMessage = 'Maximum range is 12 months.');
      return;
    }
    
    setState(() => errorMessage = null);
  }

  Future<void> _pickMonth(bool isFrom) async {
    final initialDate = isFrom ? fromDate : toDate;
    final selectedDate = await showMonthPicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        if (isFrom) {
          fromDate = selectedDate;
        } else {
          toDate = selectedDate;
        }
      });
      _validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Month/Year Range'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateSelector('From', fromDate, () => _pickMonth(true)),
          const SizedBox(height: 16),
          _buildDateSelector('To', toDate, () => _pickMonth(false)),
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ]
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: errorMessage == null 
            ? () => Navigator.pop(context, {'from': fromDate, 'to': toDate})
            : null,
          child: const Text('APPLY'),
        ),
      ],
    );
  }

  Widget _buildDateSelector(String label, DateTime date, VoidCallback onTap) {
    return Row(
      children: [
        SizedBox(width: 50, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600))),
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('MMMM yyyy').format(date)),
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
