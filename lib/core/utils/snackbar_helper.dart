import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Helper untuk menampilkan SnackBar yang konsisten di seluruh aplikasi.
///
/// Penggunaan:
/// ```dart
/// SnackBarHelper.success(context, 'Data berhasil disimpan');
/// SnackBarHelper.error(context, 'Gagal: $e');
/// SnackBarHelper.info(context, 'Sinkronisasi sedang berjalan...');
/// ```
class SnackBarHelper {
  SnackBarHelper._();

  static void success(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: const Color(0xFF064E3B),
      iconColor: const Color(0xFF6EE7B7),
    );
  }

  static void error(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: const Color(0xFF7F1D1D),
      iconColor: const Color(0xFFFCA5A5),
    );
  }

  static void info(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: const Color(0xFF1E3A5F),
      iconColor: const Color(0xFF93C5FD),
    );
  }

  static void warning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: const Color(0xFF78350F),
      iconColor: const Color(0xFFFCD34D),
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
