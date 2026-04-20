import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Bottom footer: copyright dan versi aplikasi.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  static const String _version = 'v1.0.0';
  static const String _company = 'NTC – Dies Maintenance System';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '© ${DateTime.now().year} $_company',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          Text(
            _version,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
