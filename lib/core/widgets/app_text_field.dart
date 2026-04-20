import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../utils/validators.dart';

/// Input field standar aplikasi — pengganti [TextFormField] yang harus dikonfigurasi ulang tiap screen.
///
/// Penggunaan:
/// ```dart
/// AppTextField(
///   controller: _ctrl,
///   label: 'No. Registrasi',
///   hint: 'Contoh: 2026/097/LN001',
///   prefixIcon: Icons.numbers,
///   validator: Validators.required('No. Registrasi'),
/// )
///
/// AppTextField.password(controller: _passCtrl, label: 'Password')
/// AppTextField.readOnly(controller: _ctrl, label: 'Dibuat oleh', value: userName)
/// ```
class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final bool readOnly;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? initialValue;

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.readOnly = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.keyboardType,
    this.maxLines = 1,
    this.initialValue,
  });

  /// Field password dengan tombol show/hide bawaan.
  factory AppTextField.password({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    ValueChanged<String>? onFieldSubmitted,
  }) =>
      _PasswordTextField(
        controller: controller,
        label: label,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
      );

  /// Field yang tidak bisa diedit (tampilan saja).
  factory AppTextField.readOnly({
    required String label,
    required String value,
    IconData? prefixIcon,
  }) =>
      AppTextField(
        label: label,
        hint: value,
        prefixIcon: prefixIcon,
        readOnly: true,
        controller: TextEditingController(text: value),
      );

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  @override
  Widget build(BuildContext context) => _buildField(obscureText: widget.obscureText);

  Widget _buildField({required bool obscureText, Widget? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        // Input
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: obscureText,
          readOnly: widget.readOnly,
          keyboardType: widget.keyboardType,
          maxLines: obscureText ? 1 : widget.maxLines,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          validator: widget.validator,
          style: TextStyle(
            fontSize: 14,
            color: widget.readOnly ? AppColors.textSecondary : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.textMuted, size: AppSizes.iconMd)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: widget.readOnly ? const Color(0xFFF1F5F9) : AppColors.background,
            border: _border(AppColors.divider),
            enabledBorder: _border(AppColors.divider),
            focusedBorder: _border(AppColors.green, width: 1.5),
            errorBorder: _border(AppColors.lineStop),
            focusedErrorBorder: _border(AppColors.lineStop, width: 1.5),
            disabledBorder: _border(AppColors.divider),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

// ─── Password variant (internal) ──────────────────────────────────
class _PasswordTextField extends AppTextField {
  const _PasswordTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    ValueChanged<String>? onFieldSubmitted,
  }) : super(
          controller: controller,
          label: label,
          obscureText: true,
          prefixIcon: Icons.lock_outline_rounded,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
        );

  @override
  State<AppTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends _AppTextFieldState {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return _buildField(
      obscureText: _obscure,
      suffixIcon: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textMuted,
          size: AppSizes.iconMd,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}
