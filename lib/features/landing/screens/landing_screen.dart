import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';

/// Model data untuk tiap pilihan modul.
class _AppModule {
  final String name;
  final String description;
  final IconData icon;

  const _AppModule({
    required this.name,
    required this.description,
    required this.icon,
  });
}

/// Landing page — user memilih modul sebelum login.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const _modules = [
    _AppModule(
      name: 'Dies Maintenance',
      description:
          'Track maintenance status and ensure optimal dies performance.',
      icon: Icons.settings_suggest_rounded,
    ),
    _AppModule(
      name: 'Inventory Management',
      description:
          'Monitor stock movement, availability, and warehouse performance in real time.',
      icon: Icons.inventory_2_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Gradient background (hijau muda atas → putih bawah) ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Color(0xFFDCFCE7), Colors.white],
                ),
              ),
            ),
          ),

          // ── Konten utama ─────────────────────────────────────────
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.xl,
                vertical: AppSizes.xxl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/icons/LogoNTC.png',
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: AppSizes.xl),

                    // Title
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    const Text(
                      'Choose your login role below to access features\nthat match your tasks.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xxl),

                    // Module cards
                    ..._modules.map(
                      (module) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.md),
                        child: _ModuleCard(
                          module: module,
                          onTap: () => AppRouter.goToLogin(context, moduleName: module.name),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Module Card ───────────────────────────────────────────────────
class _ModuleCard extends StatefulWidget {
  final _AppModule module;
  final VoidCallback onTap;

  const _ModuleCard({required this.module, required this.onTap});

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: _hovering ? AppColors.green : const Color(0xFFE2E8F0),
            width: _hovering ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovering
                  ? AppColors.green.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
              blurRadius: _hovering ? 20 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md + AppSizes.xs),
            child: Row(
              children: [
                // Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _hovering
                        ? AppColors.green.withOpacity(0.12)
                        : AppColors.greenLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(
                    widget.module.icon,
                    size: 36,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: AppSizes.md),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.module.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        widget.module.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.md),

                // Arrow button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _hovering ? AppColors.green : AppColors.greenLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: AppSizes.iconMd,
                    color: _hovering ? Colors.white : AppColors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
