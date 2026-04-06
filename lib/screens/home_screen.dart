import 'package:flutter/material.dart';

// ─── Color constants ───────────────────────────────────────────────
class _AppColors {
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
  static const green = Color(0xFF059669);
  static const greenLight = Color(0xFFD1FAE5);

  // Card accent colors
  static const lineStop = Color(0xFFEF4444); // red
  static const repair = Color(0xFF3B82F6);   // blue
  static const preventive = Color(0xFFF59E0B); // yellow/amber
}

// ─── Main Dashboard Screen ─────────────────────────────────────────
class DiesMaintenanceDashboard extends StatelessWidget {
  const DiesMaintenanceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            Expanded(child: _buildMainLayout()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _BrandLogo(),
        const UserProfileBadge(
          name: 'Zamzuli Qoricho',
          role: 'Member',
        ),
      ],
    );
  }

  Widget _buildMainLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Action Cards (scrollable)
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MaintenanceMenuHeader(title: 'Dies Maintenance Menu'),
                const SizedBox(height: 24),
                _buildGridMenu(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 32),
        // Right Column: Activity Report — fills full height
        const Expanded(
          flex: 1,
          child: ActivityReportPanel(),
        ),
      ],
    );
  }

  Widget _buildGridMenu() {
    return Column(
      children: [
        // Row 1: Line Stop + Repair
        Row(
          children: const [
            Expanded(
              child: MaintenanceCard(
                title: 'Dies Line Stop',
                taskCount: 10,
                accentColor: _AppColors.lineStop,
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              child: MaintenanceCard(
                title: 'Dies Repair',
                taskCount: 10,
                accentColor: _AppColors.repair,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Row 2: Preventive (full-width, same size as row 1)
        Row(
          children: const [
            Expanded(
              child: MaintenanceCard(
                title: 'Dies Preventive',
                taskCount: 0,
                accentColor: _AppColors.preventive,
              ),
            ),
            SizedBox(width: 24),
            Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}

// ─── Brand Logo ────────────────────────────────────────────────────
class _BrandLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/LogoNTC.png',
      height: 40,
      fit: BoxFit.contain,
    );
  }
}

// ─── Header Widget ─────────────────────────────────────────────────
class MaintenanceMenuHeader extends StatelessWidget {
  final String title;

  const MaintenanceMenuHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: _AppColors.textPrimary,
      ),
    );
  }
}

// ─── Maintenance Card ──────────────────────────────────────────────
class MaintenanceCard extends StatelessWidget {
  final String title;
  final int taskCount;
  final Color accentColor;

  const MaintenanceCard({
    super.key,
    required this.title,
    required this.taskCount,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Accent border on the left
          Positioned(
            left: 0,
            top: 20,
            bottom: 20,
            child: Container(
              width: 5,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(4),
                ),
              ),
            ),
          ),
          // Card content
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (taskCount > 0) _TaskBadge(count: taskCount),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: _SeeDetailButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Task Badge ────────────────────────────────────────────────────
class _TaskBadge extends StatelessWidget {
  final int count;

  const _TaskBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    const badgeColor = _AppColors.lineStop; // always red
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 8, color: badgeColor),
          const SizedBox(width: 8),
          Text(
            '$count Task Open',
            style: const TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── See Detail Button ─────────────────────────────────────────────
class _SeeDetailButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        // TODO: Navigate to Detail CRUD screen
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: _AppColors.green,
        backgroundColor: _AppColors.greenLight,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'See Detail',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 16),
        ],
      ),
    );
  }
}

// ─── Activity Report Panel ─────────────────────────────────────────
class ActivityReportPanel extends StatelessWidget {
  const ActivityReportPanel({super.key});

  static const _activities = [
    _ActivityItem(
      category: 'DIES LINE STOP',
      id: '2026/097/LN001',
      detail: 'D2100 – Outer Panel Fender RH',
      date: '06/04/2026 08:15',
    ),
    _ActivityItem(
      category: 'DIES REPAIR',
      id: '2026/097/RP045',
      detail: 'D3301 – Side Sill Inner LH',
      date: '06/04/2026 09:02',
    ),
    _ActivityItem(
      category: 'DIES PREVENTIVE',
      id: '2026/097/PV012',
      detail: 'D1101 – Hood Outer Panel',
      date: '06/04/2026 09:45',
    ),
    _ActivityItem(
      category: 'DIES REPAIR',
      id: '2026/097/RP046',
      detail: 'D4402 – Floor Tunnel Reinf',
      date: '06/04/2026 10:30',
    ),
    _ActivityItem(
      category: 'DIES LINE STOP',
      id: '2026/097/LN002',
      detail: 'D2201 – Roof Panel Assembly',
      date: '06/04/2026 11:10',
    ),
    _ActivityItem(
      category: 'DIES PREVENTIVE',
      id: '2026/097/PV013',
      detail: 'D5503 – Rear Panel Lower',
      date: '06/04/2026 11:55',
    ),
    _ActivityItem(
      category: 'DIES LINE STOP',
      id: '2026/097/LN003',
      detail: 'D2102 – A-Pillar Outer RH',
      date: '06/04/2026 12:20',
    ),
    _ActivityItem(
      category: 'DIES REPAIR',
      id: '2026/097/RP047',
      detail: 'D3302 – Door Inner Panel LH',
      date: '06/04/2026 13:05',
    ),
    _ActivityItem(
      category: 'DIES PREVENTIVE',
      id: '2026/097/PV014',
      detail: 'D1102 – Trunk Lid Outer',
      date: '06/04/2026 13:40',
    ),
    _ActivityItem(
      category: 'DIES REPAIR',
      id: '2026/097/RP048',
      detail: 'D4403 – Cross Member Rear',
      date: '06/04/2026 14:15',
    ),
    _ActivityItem(
      category: 'DIES LINE STOP',
      id: '2026/097/LN004',
      detail: 'D2103 – B-Pillar Inner LH',
      date: '06/04/2026 15:00',
    ),
    _ActivityItem(
      category: 'DIES PREVENTIVE',
      id: '2026/097/PV015',
      detail: 'D5504 – Wheel Arch Outer RH',
      date: '06/04/2026 15:50',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) => _TimelineItem(
                activity: _activities[index],
                isLast: index == _activities.length - 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Last Activity Report',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _AppColors.textPrimary,
          ),
        ),
        _SeeMoreButton(),
      ],
    );
  }
}

// ─── See More Button ───────────────────────────────────────────────
class _SeeMoreButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // TODO: Navigate to full activity report
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _AppColors.greenLight,
        foregroundColor: _AppColors.green,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'See More',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 16),
        ],
      ),
    );
  }
}

// ─── Activity Data Model ───────────────────────────────────────────
class _ActivityItem {
  final String category;
  final String id;
  final String detail;
  final String date;

  const _ActivityItem({
    required this.category,
    required this.id,
    required this.detail,
    required this.date,
  });
}

// ─── Timeline Item ─────────────────────────────────────────────────
class _TimelineItem extends StatelessWidget {
  final _ActivityItem activity;
  final bool isLast;

  const _TimelineItem({required this.activity, required this.isLast});

  Color get _categoryColor {
    switch (activity.category) {
      case 'DIES LINE STOP':
        return _AppColors.lineStop;
      case 'DIES REPAIR':
        return _AppColors.repair;
      case 'DIES PREVENTIVE':
        return _AppColors.preventive;
      default:
        return _AppColors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + line
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: const Color(0xFFE2E8F0)),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: [category · reg no]  ·············  [date]
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Category + reg no side by side
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            activity.category,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            activity.id,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      // Date right-aligned
                      Text(
                        activity.date,
                        style: const TextStyle(
                          fontSize: 10,
                          color: _AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Row 2: detail / part no
                  Text(
                    activity.detail,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _AppColors.textSecondary,
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
}

// ─── User Profile Badge ────────────────────────────────────────────
class UserProfileBadge extends StatelessWidget {
  final String name;
  final String role;

  const UserProfileBadge({
    super.key,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _AppColors.textPrimary,
                ),
              ),
              Text(
                role,
                style: const TextStyle(
                  fontSize: 10,
                  color: _AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 16, color: _AppColors.textMuted),
        ],
      ),
    );
  }
}
