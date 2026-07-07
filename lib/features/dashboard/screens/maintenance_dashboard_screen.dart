import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../widgets/custom_stacked_bar_chart.dart';
import '../widgets/custom_line_chart.dart';

class MaintenanceDashboardScreen extends StatefulWidget {
  const MaintenanceDashboardScreen({super.key});

  @override
  State<MaintenanceDashboardScreen> createState() => _MaintenanceDashboardScreenState();
}

class _MaintenanceDashboardScreenState extends State<MaintenanceDashboardScreen> {
  // Filter states
  String _selectedDateLabel = "Jul 2025 - Jul 2026";
  String _selectedLineLabel = "All Line";
  String _selectedShiftLabel = "All Shift";

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _dashboardData;

  // Date range mapping
  final Map<String, List<String>> _dateRangeMap = {
    "Jul 2025 - Jul 2026": ["2025-07-01", "2026-07-31"],
    "Jan 2024 - Dec 2024": ["2024-01-01", "2024-12-31"],
    "Jan 2025 - Dec 2025": ["2025-01-01", "2025-12-31"],
    "Jan 2026 - Dec 2026": ["2026-01-01", "2026-12-31"],
    "Jan 2027 - May 2027": ["2027-01-01", "2027-05-31"],
  };

  // Line code mapping
  final Map<String, String?> _lineCodeMap = {
    "All Line": null,
    "Blanking": "BL",
    "Tandem": "TD",
    "Transver 1": "TR1",
    "Transver 2": "TR2",
    "Transver 3": "TR3",
  };

  // Shift mapping
  final Map<String, String?> _shiftMap = {
    "All Shift": null,
    "Red Shift": "R",
    "Blue Shift": "B",
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dates = _dateRangeMap[_selectedDateLabel]!;
      final queryParams = {
        'start_date': dates[0],
        'end_date': dates[1],
        if (_lineCodeMap[_selectedLineLabel] != null) 'line_cd': _lineCodeMap[_selectedLineLabel]!,
        if (_shiftMap[_selectedShiftLabel] != null) 'shift': _shiftMap[_selectedShiftLabel]!,
      };

      final response = await ApiClient.get(
        '/dashboard/monitoring',
        queryParams: queryParams,
      );

      if (response != null && response['success'] == true) {
        setState(() {
          _dashboardData = response['data'] as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        throw Exception("Gagal memuat data dari server");
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: _isLoading
          ? const Center(child: AppLoading())
          : _errorMessage != null
              ? Center(
                  child: AppErrorWidget(
                    message: _errorMessage!,
                    onRetry: _fetchData,
                  ),
                )
              : _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    if (_dashboardData == null) return const SizedBox();

    final kpi = _dashboardData!['kpi'] as Map<String, dynamic>;
    final monthlyMonitoring = List<Map<String, dynamic>>.from(_dashboardData!['monthly_monitoring'] ?? []);
    final lineDetails = _dashboardData!['line_details'] as Map<String, dynamic>;
    final breakdown = List<Map<String, dynamic>>.from(_dashboardData!['breakdown_categories'] ?? []);
    final trendOcc = List<Map<String, dynamic>>.from(_dashboardData!['trend_occurrence'] ?? []);
    final improvements = _dashboardData!['improvements'] as Map<String, dynamic>;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header & Filter Row ──────────────────────────────────────────
          _buildFilterRow(),
          const SizedBox(height: 16),

          // ─── Top KPI Cards (Dark Navy Row) ────────────────────────────────
          _buildKPIHeaderRow(kpi),
          const SizedBox(height: 16),

          // ─── Middle Section (Stacked Bar + Detail Cards) ──────────────────
          _buildMiddleSection(monthlyMonitoring, lineDetails),
          const SizedBox(height: 16),

          // ─── Bottom Section (Breakdown + Trend + Improvements) ────────────
          _buildBottomSection(breakdown, trendOcc, improvements),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Dashboard Line Stop Monitoring",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Row(
          children: [
            // Date Filter
            _buildDropdown(
              label: "Date",
              value: _selectedDateLabel,
              items: _dateRangeMap.keys.toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedDateLabel = val);
                  _fetchData();
                }
              },
            ),
            const SizedBox(width: 12),
            // Line Filter
            _buildDropdown(
              label: "Line",
              value: _selectedLineLabel,
              items: _lineCodeMap.keys.toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedLineLabel = val);
                  _fetchData();
                }
              },
            ),
            const SizedBox(width: 12),
            // Shift Filter
            _buildDropdown(
              label: "Shift",
              value: _selectedShiftLabel,
              items: _shiftMap.keys.toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedShiftLabel = val);
                  _fetchData();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$label  ",
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
              )).toList(),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKPIHeaderRow(Map<String, dynamic> kpi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF030D26), // Dark Navy Background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildKPICard(
              title: "PPM vs Target - Current Month",
              value: "${(kpi['ppm_current'] as num).toInt()} / ${(kpi['ppm_target'] as num).toInt()} PPM",
              subTitle: "▲ ${(kpi['ppm_change'] as num).toInt()} vs last month",
              isPositiveChange: true,
              valueColor: Colors.redAccent,
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildKPICard(
              title: "AVG PPM",
              value: "${(kpi['avg_ppm'] as num).toInt()} | ${(kpi['avg_mh_hours'] as num).toInt()} Jam",
              subTitle: "▲ ${(kpi['avg_mh_change'] as num).toInt()} vs last month",
              isPositiveChange: true,
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildKPICard(
              title: "Incident Line Stop",
              value: "${(kpi['incident_occ'] as num).toInt()} Occ",
              subTitle: "Dalam range filter",
              isPositiveChange: false,
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildKPICard(
              title: "Worst Line - Current Month",
              value: "${kpi['worst_line_name']} / ${(kpi['worst_line_target'] as num).toInt()} PPM",
              subTitle: "▼ ${(kpi['worst_line_change'] as num).toInt()} vs last month",
              isPositiveChange: false,
              valueColor: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 48,
      width: 1,
      color: Colors.white12,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String subTitle,
    required bool isPositiveChange,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              isPositiveChange ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: isPositiveChange ? Colors.redAccent : const Color(0xFF10B981),
              size: 14,
            ),
            Text(
              subTitle.replaceAll("▲ ", "").replaceAll("▼ ", ""),
              style: TextStyle(
                fontSize: 10,
                color: isPositiveChange ? Colors.redAccent : const Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiddleSection(List<Map<String, dynamic>> monthlyData, Map<String, dynamic> lineDetails) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (PPM Monthly Monitoring Chart)
        Expanded(
          flex: 2,
          child: _buildCardContainer(
            title: "PPM Monthly Monitoring",
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: CustomStackedBarChart(data: monthlyData),
                ),
                const SizedBox(width: 16),
                // Monthly highlights
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildHighlightBox(
                        title: "Best Month",
                        value: "${_dashboardData!['best_month_name'] ?? "-"} | ${(_dashboardData!['best_month_value'] as num).toInt()} PPM",
                        color: Colors.green[50]!,
                        textColor: Colors.green[700]!,
                      ),
                      const SizedBox(height: 12),
                      _buildHighlightBox(
                        title: "Worst Month",
                        value: "${_dashboardData!['worst_month_name'] ?? "-"} | ${(_dashboardData!['worst_month_value'] as num).toInt()} PPM",
                        color: Colors.red[50]!,
                        textColor: Colors.red[700]!,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Right Column (Details cards)
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildLineDetailCard(
                title: "PPM Tandem",
                value: "${(lineDetails['tandem']['ppm'] as num).toInt()}  |  ${(lineDetails['tandem']['hours'] as num).toInt()} Jam",
                indicatorText: "▲ 2% vs last month",
                borderColor: const Color(0xFF10B981),
                isUp: true,
              ),
              const SizedBox(height: 8),
              _buildLineDetailCard(
                title: "PPM Blanking",
                value: "${(lineDetails['blanking']['ppm'] as num).toInt()}  |  ${(lineDetails['blanking']['hours'] as num).toInt()} Jam",
                indicatorText: "▼ 2% vs last month",
                borderColor: Colors.orange,
                isUp: false,
              ),
              const SizedBox(height: 8),
              _buildLineDetailCard(
                title: "PPM Transver 1 - 3",
                value: "${(lineDetails['transver']['ppm'] as num).toInt()}  |  ${(lineDetails['transver']['hours'] as num).toInt()} Jam",
                indicatorText: "▲ 2% vs last month",
                borderColor: Colors.amber,
                isUp: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightBox({
    required String title,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildLineDetailCard({
    required String title,
    required String value,
    required String indicatorText,
    required Color borderColor,
    required bool isUp,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: borderColor, width: 4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Row(
                    children: [
                      Icon(isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: isUp ? Colors.red : Colors.green, size: 16),
                      Text(
                        indicatorText.replaceAll("▲ ", "").replaceAll("▼ ", ""),
                        style: TextStyle(fontSize: 9, color: isUp ? Colors.red : Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(List<Map<String, dynamic>> breakdown, List<Map<String, dynamic>> trendOcc, Map<String, dynamic> improvements) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Breakdown Problem categories)
        Expanded(
          flex: 1,
          child: _buildCardContainer(
            title: "Breakdown Problem per Categories",
            child: Column(
              children: [
                _buildTableHeader("Problem", "Occ", "%"),
                const Divider(),
                ...breakdown.map((item) => _buildBreakdownRow(
                  name: item['problem'],
                  occ: (item['occ'] as num).toInt(),
                  pct: (item['percentage'] as num).toDouble(),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Middle Column (Trend Occurrence per Line)
        Expanded(
          flex: 1,
          child: _buildCardContainer(
            title: "Trend Occurrence per LINE",
            child: CustomLineChart(data: trendOcc),
          ),
        ),
        const SizedBox(width: 16),

        // Right Column (Improvements Top 5)
        Expanded(
          flex: 1,
          child: _buildCardContainer(
            title: "Improvement PPM per Dies - Top 5",
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("PPM Improves", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...List<Map<String, dynamic>>.from(improvements['improves'] ?? []).map((item) => _buildImproveRow(item, isImprove: true)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("PPM Worsens", style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...List<Map<String, dynamic>>.from(improvements['worsens'] ?? []).map((item) => _buildImproveRow(item, isImprove: false)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String col1, String col2, String col3) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(flex: 3, child: Text(col1, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold))),
        const Expanded(flex: 3, child: SizedBox()), // Spacer menyelaraskan kolom progress bar data row
        Expanded(flex: 1, child: Text(col2, textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold))),
        Expanded(flex: 1, child: Text(col3, textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildBreakdownRow({required String name, required int occ, required double pct}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: const TextStyle(fontSize: 10, color: Colors.blueAccent),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 10,
                  width: (pct * 2).clamp(4.0, 70.0),
                  color: const Color(0xFF10B981),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text("$occ", textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: AppColors.textPrimary)),
          ),
          Expanded(
            flex: 1,
            child: Text("${pct.toStringAsFixed(1)}%", textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildImproveRow(Map<String, dynamic> item, {required bool isImprove}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['part_no'],
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${(item['from_ppm'] as num).toInt()} → ${(item['to_ppm'] as num).toInt()} | ${(item['occ'] as num).toInt()} Occ",
                style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
              ),
              Row(
                children: [
                  Icon(
                    isImprove ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                    color: isImprove ? Colors.green : Colors.red,
                    size: 12,
                  ),
                  Text(
                    "${(item['diff'] as num).toStringAsFixed(1)}",
                    style: TextStyle(fontSize: 8, color: isImprove ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
