import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Widget loading dan overlay loading yang konsisten.
///
/// Penggunaan:
/// ```dart
/// // Inline: ganti konten dengan spinner
/// if (_isLoading) const AppLoading() else _buildContent()
///
/// // Overlay: tumpuk di atas konten (gunakan dalam Stack)
/// Stack(children: [
///   _buildContent(),
///   if (_isLoading) const AppLoading.overlay(),
/// ])
/// ```
class AppLoading extends StatelessWidget {
  final bool _isOverlay;
  final String? message;

  const AppLoading({super.key, this.message}) : _isOverlay = false;

  const AppLoading.overlay({super.key, this.message}) : _isOverlay = true;

  @override
  Widget build(BuildContext context) {
    if (_isOverlay) return _buildOverlay();
    return _buildInline();
  }

  Widget _buildInline() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.green,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.35),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.green),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
