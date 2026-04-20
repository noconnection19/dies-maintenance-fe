import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Badge status yang konsisten untuk task dies maintenance.
///
/// Penggunaan:
/// ```dart
/// AppBadge.status('OPEN')          // merah
/// AppBadge.status('IN_PROGRESS')   // biru
/// AppBadge.status('CLOSED')        // hijau
///
/// AppBadge.count(10, color: AppColors.lineStop)   // "10 Task Open"
/// AppBadge.label('Dies Line Stop', color: AppColors.repair)
/// ```
class AppBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final double fontSize;

  const AppBadge._({
    required this.text,
    required this.color,
    this.icon,
    this.fontSize = 12,
  });

  /// Badge berdasarkan status task: OPEN / IN_PROGRESS / CLOSED.
  factory AppBadge.status(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return AppBadge._(text: 'Open', color: AppColors.lineStop, icon: Icons.circle);
      case 'IN_PROGRESS':
        return AppBadge._(text: 'In Progress', color: AppColors.repair, icon: Icons.circle);
      case 'CLOSED':
        return AppBadge._(text: 'Closed', color: AppColors.green, icon: Icons.check_circle);
      default:
        return AppBadge._(text: status, color: AppColors.textMuted);
    }
  }

  /// Badge jumlah task dengan warna kustom.
  factory AppBadge.count(int count, {required Color color, String? suffix}) {
    return AppBadge._(
      text: '$count ${suffix ?? "Task"}',
      color: color,
      icon: Icons.circle,
    );
  }

  /// Badge label bebas dengan warna kustom.
  factory AppBadge.label(String text, {required Color color}) {
    return AppBadge._(text: text, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm + AppSizes.xs,
        vertical: AppSizes.xs + 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSizes.xs + 4, color: color),
            const SizedBox(width: AppSizes.sm),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
