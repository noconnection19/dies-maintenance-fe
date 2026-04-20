import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

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
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ─── Maintenance Card ──────────────────────────────────────────────
class MaintenanceCard extends StatelessWidget {
  final String title;
  final int taskCount;
  final Color accentColor;
  final VoidCallback? onTap;

  const MaintenanceCard({
    super.key,
    required this.title,
    required this.taskCount,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.surface,
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
          Positioned(
            left: 0,
            top: 20,
            bottom: 20,
            child: Container(
              width: 5,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
              ),
            ),
          ),
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
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (taskCount > 0) _TaskBadge(count: taskCount),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: _SeeDetailButton(onTap: onTap),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskBadge extends StatelessWidget {
  final int count;
  const _TaskBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    const badgeColor = AppColors.lineStop;
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
            style: const TextStyle(color: badgeColor, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SeeDetailButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _SeeDetailButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.green,
        backgroundColor: AppColors.greenLight,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('See Detail', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 16),
        ],
      ),
    );
  }
}
