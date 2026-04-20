import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

// ─── Activity Data Model ───────────────────────────────────────────
class ActivityItem {
  final String category;
  final String id;
  final String detail;
  final String date;

  const ActivityItem({
    required this.category,
    required this.id,
    required this.detail,
    required this.date,
  });
}

// ─── Activity Report Panel ─────────────────────────────────────────
class ActivityReportPanel extends StatelessWidget {
  const ActivityReportPanel({super.key});

  static const _activities = [
    ActivityItem(category: 'DIES LINE STOP', id: '2026/097/LN001', detail: 'D2100 – Outer Panel Fender RH', date: '06/04/2026 08:15'),
    ActivityItem(category: 'DIES REPAIR', id: '2026/097/RP045', detail: 'D3301 – Side Sill Inner LH', date: '06/04/2026 09:02'),
    ActivityItem(category: 'DIES PREVENTIVE', id: '2026/097/PV012', detail: 'D1101 – Hood Outer Panel', date: '06/04/2026 09:45'),
    ActivityItem(category: 'DIES REPAIR', id: '2026/097/RP046', detail: 'D4402 – Floor Tunnel Reinf', date: '06/04/2026 10:30'),
    ActivityItem(category: 'DIES LINE STOP', id: '2026/097/LN002', detail: 'D2201 – Roof Panel Assembly', date: '06/04/2026 11:10'),
    ActivityItem(category: 'DIES PREVENTIVE', id: '2026/097/PV013', detail: 'D5503 – Rear Panel Lower', date: '06/04/2026 11:55'),
    ActivityItem(category: 'DIES LINE STOP', id: '2026/097/LN003', detail: 'D2102 – A-Pillar Outer RH', date: '06/04/2026 12:20'),
    ActivityItem(category: 'DIES REPAIR', id: '2026/097/RP047', detail: 'D3302 – Door Inner Panel LH', date: '06/04/2026 13:05'),
    ActivityItem(category: 'DIES PREVENTIVE', id: '2026/097/PV014', detail: 'D1102 – Trunk Lid Outer', date: '06/04/2026 13:40'),
    ActivityItem(category: 'DIES REPAIR', id: '2026/097/RP048', detail: 'D4403 – Cross Member Rear', date: '06/04/2026 14:15'),
    ActivityItem(category: 'DIES LINE STOP', id: '2026/097/LN004', detail: 'D2103 – B-Pillar Inner LH', date: '06/04/2026 15:00'),
    ActivityItem(category: 'DIES PREVENTIVE', id: '2026/097/PV015', detail: 'D5504 – Wheel Arch Outer RH', date: '06/04/2026 15:50'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        _SeeMoreButton(),
      ],
    );
  }
}

class _SeeMoreButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // TODO: Navigate to full activity report
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.greenLight,
        foregroundColor: AppColors.green,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('See More', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 16),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final ActivityItem activity;
  final bool isLast;

  const _TimelineItem({required this.activity, required this.isLast});

  Color get _categoryColor {
    switch (activity.category) {
      case 'DIES LINE STOP':   return AppColors.lineStop;
      case 'DIES REPAIR':      return AppColors.repair;
      case 'DIES PREVENTIVE':  return AppColors.preventive;
      default:                 return AppColors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: AppColors.divider)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(activity.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                          const SizedBox(width: 6),
                          Text(activity.id, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                        ],
                      ),
                      Text(activity.date, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(activity.detail, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
