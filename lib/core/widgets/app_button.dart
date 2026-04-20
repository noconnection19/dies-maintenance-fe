import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Tombol standar aplikasi dengan 4 varian: primary, secondary, danger, ghost.
///
/// Penggunaan:
/// ```dart
/// AppButton.primary(label: 'Simpan', onPressed: _save)
/// AppButton.secondary(label: 'Batal', onPressed: () => Navigator.pop(context))
/// AppButton.danger(label: 'Hapus', onPressed: _delete)
/// AppButton.ghost(label: 'Lihat Detail', onPressed: _view)
/// AppButton.primary(label: 'Proses', onPressed: _run, isLoading: true)
/// AppButton.primary(label: 'Simpan', onPressed: _save, fullWidth: true)
/// ```
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final IconData? prefixIcon;
  final _ButtonVariant _variant;
  final double? height;

  const AppButton._({
    required this.label,
    required _ButtonVariant variant,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.prefixIcon,
    this.height,
  }) : _variant = variant;

  factory AppButton.primary({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = false,
    IconData? prefixIcon,
  }) =>
      AppButton._(
        label: label,
        variant: _ButtonVariant.primary,
        onPressed: onPressed,
        isLoading: isLoading,
        fullWidth: fullWidth,
        prefixIcon: prefixIcon,
      );

  factory AppButton.secondary({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = false,
    IconData? prefixIcon,
  }) =>
      AppButton._(
        label: label,
        variant: _ButtonVariant.secondary,
        onPressed: onPressed,
        isLoading: isLoading,
        fullWidth: fullWidth,
        prefixIcon: prefixIcon,
      );

  factory AppButton.danger({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = false,
    IconData? prefixIcon,
  }) =>
      AppButton._(
        label: label,
        variant: _ButtonVariant.danger,
        onPressed: onPressed,
        isLoading: isLoading,
        fullWidth: fullWidth,
        prefixIcon: prefixIcon,
      );

  factory AppButton.ghost({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = false,
    IconData? prefixIcon,
  }) =>
      AppButton._(
        label: label,
        variant: _ButtonVariant.ghost,
        onPressed: onPressed,
        isLoading: isLoading,
        fullWidth: fullWidth,
        prefixIcon: prefixIcon,
      );

  @override
  Widget build(BuildContext context) {
    final bg = _background;
    final fg = _foreground;
    final border = _border;

    final btn = SizedBox(
      height: height ?? AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            side: border ?? BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, size: AppSizes.iconMd),
                    const SizedBox(width: AppSizes.sm),
                  ],
                  Text(
                    label,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }

  Color get _background {
    switch (_variant) {
      case _ButtonVariant.primary:   return AppColors.green;
      case _ButtonVariant.secondary: return AppColors.greenLight;
      case _ButtonVariant.danger:    return const Color(0xFFFEE2E2);
      case _ButtonVariant.ghost:     return AppColors.background;
    }
  }

  Color get _foreground {
    switch (_variant) {
      case _ButtonVariant.primary:   return const Color(0xFFFFFFFF);
      case _ButtonVariant.secondary: return AppColors.green;
      case _ButtonVariant.danger:    return AppColors.lineStop;
      case _ButtonVariant.ghost:     return AppColors.textSecondary;
    }
  }

  BorderSide? get _border {
    if (_variant == _ButtonVariant.ghost) {
      return const BorderSide(color: AppColors.divider);
    }
    return null;
  }
}

enum _ButtonVariant { primary, secondary, danger, ghost }
