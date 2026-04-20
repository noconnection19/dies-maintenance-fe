import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/router/app_router.dart';
import '../../auth/data/auth_service.dart';
import '../widgets/maintenance_card.dart';
import '../widgets/activity_report_panel.dart';

/// Dashboard screen — hanya berisi konten, shell dihandle oleh [AppShell].
class HomeScreen extends StatelessWidget {
  final AuthUser authUser;
  const HomeScreen({super.key, required this.authUser});

  @override
  Widget build(BuildContext context) {
    return const AppShell(
      child: _DashboardContent(),
    );
  }
}

// ─── Dashboard Content ─────────────────────────────────────────────
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left: Menu cards
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MaintenanceMenuHeader(title: 'Dies Maintenance Menu'),
                const SizedBox(height: 24),
                _GridMenu(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 32),
        // Right: Activity report panel
        const Expanded(
          flex: 1,
          child: ActivityReportPanel(),
        ),
      ],
    );
  }
}

// ─── Grid Menu ─────────────────────────────────────────────────────
class _GridMenu extends StatelessWidget {
  const _GridMenu();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MaintenanceCard(
                title: 'Dies Line Stop',
                taskCount: 10,
                accentColor: AppColors.lineStop,
                onTap: () => AppRouter.goToLineStop(context),
              ),
            ),
            const SizedBox(width: 24),
            const Expanded(
              child: MaintenanceCard(
                title: 'Dies Repair',
                taskCount: 10,
                accentColor: AppColors.repair,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            Expanded(
              child: MaintenanceCard(
                title: 'Dies Preventive',
                taskCount: 0,
                accentColor: AppColors.preventive,
              ),
            ),
            SizedBox(width: 24),
            Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}
