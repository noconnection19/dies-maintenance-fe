import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_shell.dart';
import '../widgets/add_dies_dialog.dart';

// ─── Dummy Model ───────────────────────────────────────────────────
class _LineStopItem {
  final String dateTime;
  final String partNumber;
  final String model;
  final String shift;
  final String line;
  final String machine;
  final int pic;
  final String status; // ON_PROGRESS | COMPLETED

  const _LineStopItem({
    required this.dateTime,
    required this.partNumber,
    required this.model,
    required this.shift,
    required this.line,
    required this.machine,
    required this.pic,
    required this.status,
  });
}

const _dummyData = [
  _LineStopItem(dateTime: '7 May 2025, 13:02', partNumber: '47781.2-0K090', model: '660A', shift: 'Red',  line: 'TR-01', machine: 'TR1', pic: 2, status: 'ON_PROGRESS'),
  _LineStopItem(dateTime: '7 May 2025, 13:02', partNumber: '47781.2-0K241', model: '650A', shift: 'Red',  line: 'TR-01', machine: 'TD',  pic: 3, status: 'ON_PROGRESS'),
  _LineStopItem(dateTime: '7 May 2025, 13:02', partNumber: '48733-0K010',   model: '699N', shift: 'Blue', line: 'TR-01', machine: 'TR2', pic: 2, status: 'ON_PROGRESS'),
  _LineStopItem(dateTime: '7 May 2025, 13:02', partNumber: '51161.2-KK010', model: '660A', shift: 'Blue', line: 'TR-01', machine: 'TD',  pic: 1, status: 'ON_PROGRESS'),
  _LineStopItem(dateTime: '6 May 2025, 09:15', partNumber: '47781.2-0K090', model: '660A', shift: 'Red',  line: 'TR-02', machine: 'TR1', pic: 2, status: 'ON_PROGRESS'),
  _LineStopItem(dateTime: '5 May 2025, 08:00', partNumber: '52301-0K070',   model: '650A', shift: 'Blue', line: 'TR-03', machine: 'TD',  pic: 1, status: 'COMPLETED'),
  _LineStopItem(dateTime: '5 May 2025, 10:30', partNumber: '55410-0K010',   model: '699N', shift: 'Red',  line: 'TR-01', machine: 'TR2', pic: 3, status: 'COMPLETED'),
  _LineStopItem(dateTime: '4 May 2025, 14:00', partNumber: '65900-0K010',   model: '660A', shift: 'Blue', line: 'TR-02', machine: 'TR1', pic: 2, status: 'COMPLETED'),
];

// ─── Screen ────────────────────────────────────────────────────────
class LineStopScreen extends StatefulWidget {
  const LineStopScreen({super.key});

  @override
  State<LineStopScreen> createState() => _LineStopScreenState();
}

class _LineStopScreenState extends State<LineStopScreen> {
  int _tabIndex = 0; // 0 = On Progress, 1 = Completed
  String _sortValue = 'Latest';
  final _searchCtrl = TextEditingController();
  int _currentPage = 1;
  static const _perPage = 10;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_LineStopItem> get _filtered {
    final status = _tabIndex == 0 ? 'ON_PROGRESS' : 'COMPLETED';
    final query = _searchCtrl.text.toLowerCase();
    return _dummyData
        .where((e) => e.status == status)
        .where((e) =>
            query.isEmpty ||
            e.partNumber.toLowerCase().contains(query) ||
            e.line.toLowerCase().contains(query) ||
            e.machine.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top bar: Back + Title ─────────────────────────────────
          Row(
            children: [
              _BackButton(onTap: () => Navigator.of(context).pop()),
              const SizedBox(width: AppSizes.md),
              const Text(
                'LIST DIES LINE STOP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // ── Main card ─────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ── Tabs ────────────────────────────────────────
                  _TabBar(
                    selectedIndex: _tabIndex,
                    onChanged: (i) => setState(() {
                      _tabIndex = i;
                      _currentPage = 1;
                    }),
                  ),

                  // ── Toolbar ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        // Add button
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => const AddDiesDialog(),
                            );
                          },
                          icon: const Icon(Icons.add, size: AppSizes.iconMd),
                          label: const Text(
                            'Add New Dies',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),

                        // Sort dropdown
                        _SortDropdown(
                          value: _sortValue,
                          onChanged: (v) => setState(() => _sortValue = v ?? 'Latest'),
                        ),
                        const SizedBox(width: AppSizes.md),

                        // Search field
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search by part no, line, and machine here...',
                              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: AppSizes.iconMd),
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                borderSide: const BorderSide(color: AppColors.divider),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                borderSide: const BorderSide(color: AppColors.divider),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                borderSide: const BorderSide(color: AppColors.green, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),

                        // Search button
                        OutlinedButton(
                          onPressed: () => setState(() {}),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.green,
                            side: const BorderSide(color: AppColors.green),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text('Search', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),

                  // ── Data table ──────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        ),
                        clipBehavior: Clip.antiAlias, // Potong pinggiran agar rounded
                        child: _filtered.isEmpty
                            ? const Center(
                                child: Text(
                                  'Tidak ada data.',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              )
                            : _DataTable(items: _filtered),
                      ),
                    ),
                  ),

                  // ── Pagination ──────────────────────────────────
                  _PaginationBar(
                    total: _filtered.length,
                    perPage: _perPage,
                    currentPage: _currentPage,
                    onPrev: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                    onNext:
                        _currentPage < (_filtered.length / _perPage).ceil()
                            ? () => setState(() => _currentPage++)
                            : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Back Button ───────────────────────────────────────────────────
class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.arrow_back_rounded, size: AppSizes.iconMd),
      label: const Text('Back', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.green,
        backgroundColor: AppColors.greenLight,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}

// ─── Tab Bar ───────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _TabBar({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const tabs = ['On Progress', 'Completed'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = selectedIndex == i;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.only(bottom: 10),
              margin: const EdgeInsets.only(right: AppSizes.xl),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: active ? AppColors.green : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.bold : FontWeight.w400,
                  color: active ? AppColors.green : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Sort Dropdown ─────────────────────────────────────────────────
class _SortDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _SortDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          items: const [
            DropdownMenuItem(value: 'Latest', child: Text('Latest')),
            DropdownMenuItem(value: 'Oldest', child: Text('Oldest')),
            DropdownMenuItem(value: 'Part No', child: Text('Part No')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── Data Table ────────────────────────────────────────────────────
class _DataTable extends StatelessWidget {
  final List<_LineStopItem> items;
  const _DataTable({required this.items});

  static const _headers = [
    'Date Time', 'Part Number', 'Model', 'Shift', 'Line', 'Machine', 'PIC', 'Action'
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: SingleChildScrollView(
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent, // Fix paling ampuh merebus garis antar row
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  showBottomBorder: false,
                  border: const TableBorder(
                    horizontalInside: BorderSide.none,
                    verticalInside: BorderSide.none,
                    top: BorderSide.none,
                    bottom: BorderSide.none,
                    left: BorderSide.none,
                    right: BorderSide.none,
                  ),
                  dividerThickness: 0.0, // Prevent default horizontal thin line
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 52,
                  horizontalMargin: 20,
                  columnSpacing: 32,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                columns: _headers
                    .map((h) => DataColumn(label: Text(h)))
                    .toList(),
                rows: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>((states) {
                      // Zebra styling: selang-seling antara putih dan sedikit abu-abu (mirip row teratas)
                      return index.isEven ? Colors.white : const Color(0xFFF9FAFB); 
                    }),
                    cells: [
                      DataCell(Text(item.dateTime, style: _cellStyle)),
                      DataCell(Text(item.partNumber, style: _cellStyle)),
                      DataCell(Text(item.model, style: _cellStyle)),
                      DataCell(_ShiftBadge(shift: item.shift)),
                      DataCell(Text(item.line, style: _cellStyle)),
                      DataCell(Text(item.machine, style: _cellStyle)),
                      DataCell(Text(item.pic.toString(), style: _cellStyle)),
                      DataCell(_DetailButton(onTap: () {
                        // TODO: navigate to detail
                      })),
                    ],
                  );
                }).toList(),
              ),
            ), // Tutup Theme
          ), // Tutup SingleChildScrollView child
        ), // Tutup ConstrainedBox
      ); // Tutup SingleChildScrollView horizontal
    }, // Tutup Builder
  ); // Tutup LayoutBuilder
  }

  static const _cellStyle = TextStyle(fontSize: 13, color: AppColors.textPrimary);
}

class _ShiftBadge extends StatelessWidget {
  final String shift;
  const _ShiftBadge({required this.shift});

  @override
  Widget build(BuildContext context) {
    final isRed = shift == 'Red';
    final color = isRed ? AppColors.lineStop : const Color(0xFF3B82F6);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        shift,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _DetailButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DetailButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.menu, size: AppSizes.iconSm),
      label: const Text('Detail', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.green,
        side: const BorderSide(color: AppColors.green),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

// ─── Pagination Bar ────────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final int total;
  final int perPage;
  final int currentPage;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PaginationBar({
    required this.total,
    required this.perPage,
    required this.currentPage,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final start = ((currentPage - 1) * perPage) + 1;
    final end = (currentPage * perPage).clamp(0, total);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $start-$end of $total Data',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onPrev,
                icon: const Icon(Icons.arrow_back_ios_rounded, size: AppSizes.iconSm),
                color: onPrev != null ? AppColors.green : AppColors.textMuted,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Page $currentPage',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: AppSizes.iconSm),
                color: onNext != null ? AppColors.green : AppColors.textMuted,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
