import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'user_profile_badge.dart';

/// Top app bar — floating rounded card, tidak menempel ke tepi layar.
class AppHeader extends StatelessWidget {
  final String name;
  final String role;

  const AppHeader({
    super.key,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Margin dari atas dan samping agar rounded corner terlihat
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,  // kiri
        AppSizes.md,  // atas
        AppSizes.md,  // kanan
        0,            // bawah — dihandle oleh content padding
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/icons/LogoNTC.png',
              height: 36,
              fit: BoxFit.contain,
            ),
            UserProfileBadge(name: name, role: role),
          ],
        ),
      ),
    );
  }
}
