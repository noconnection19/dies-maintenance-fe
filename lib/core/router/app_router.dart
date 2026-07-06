import 'package:flutter/material.dart';
import '../session/session_store.dart';
import '../../features/landing/screens/landing_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/dashboard/screens/home_screen.dart';
import '../../features/dashboard/screens/maintenance_dashboard_screen.dart';
import '../../features/line_stop/screens/line_stop_screen.dart';
import '../../features/report_dashboard/screens/line_stop_monitoring_dashboard_screen.dart';
import '../../features/inventory/screens/inventory_screen.dart';

/// Nama-nama route yang digunakan di seluruh aplikasi.
class AppRoutes {
  AppRoutes._();

  static const String landing   = '/'; // Maps to Login Screen
  static const String login     = '/login'; // Maps to Login Screen
  static const String selectMenu = '/select-menu'; // Maps to List Menu
  static const String dashboard = '/dashboard'; // Maps to Dies Maintenance Homepage
  static const String lineStop  = '/line-stop';
  static const String maintenanceDashboard = '/maintenance-dashboard';
  static const String reportDashboard = '/report-dashboard'; // Maps to Page Dashboard Report
  static const String inventory = '/inventory'; // Maps to Homepage Inventory Management
}

/// Router aplikasi: mengelola navigasi dan auth guard.
class AppRouter {
  AppRouter._();

  /// Route map yang didaftarkan ke [MaterialApp].
  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.landing: (_) => const LoginScreen(),
        AppRoutes.login:   (_) => const LoginScreen(),
        AppRoutes.selectMenu: (context) {
          final user = SessionStore.instance.currentUser;
          if (user == null) return const LoginScreen();
          return const LandingScreen(); // Displays the module choice menu
        },
        AppRoutes.dashboard: (context) {
          final user = SessionStore.instance.currentUser;
          if (user == null) return const LoginScreen();
          return HomeScreen(authUser: user);
        },
        AppRoutes.lineStop: (context) {
          final user = SessionStore.instance.currentUser;
          if (user == null) return const LoginScreen();
          return const LineStopScreen();
        },
        AppRoutes.maintenanceDashboard: (context) {
          final user = SessionStore.instance.currentUser;
          if (user == null) return const LoginScreen();
          return const MaintenanceDashboardScreen();
        },
        AppRoutes.reportDashboard: (context) {
          final user = SessionStore.instance.currentUser;
          if (user == null) return const LoginScreen();
          return const LineStopMonitoringDashboardScreen();
        },
        AppRoutes.inventory: (context) {
          final user = SessionStore.instance.currentUser;
          if (user == null) return const LoginScreen();
          return const InventoryHomeScreen();
        },
      };

  /// Route awal saat app dibuka.
  /// Jika sudah login → langsung ke select menu, jika belum → login.
  static String get initialRoute {
    return SessionStore.instance.isLoggedIn
        ? AppRoutes.selectMenu
        : AppRoutes.landing;
  }

  // ── Navigation helpers ────────────────────────────────────────────

  /// Navigasi ke halaman pilihan menu (List Menu).
  static void goToSelectMenu(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.selectMenu,
      (_) => false,
    );
  }

  /// Navigasi ke Dies Maintenance (Homepage).
  static void goToDashboard(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.dashboard);
  }

  /// Navigasi ke Page Dashboard Report.
  static void goToReportDashboard(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.reportDashboard);
  }

  /// Navigasi ke Homepage Inventory Management.
  static void goToInventory(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.inventory);
  }

  /// Navigasi ke Line Stop Screen.
  static void goToLineStop(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.lineStop);
  }

  /// Navigasi ke Maintenance Dashboard Screen.
  static void goToMaintenanceDashboard(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.maintenanceDashboard);
  }

  /// Logout: bersihkan sesi lalu kembali ke Login.
  static void logout(BuildContext context) {
    AuthService.logout(); // Panggil API backend & bersihkan SessionStore
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.landing,
      (_) => false,
    );
  }
}

/// Widget guard: redirect ke login jika belum login.
class AuthGuard extends StatelessWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!SessionStore.instance.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.landing);
      });
      return const SizedBox.shrink();
    }
    return child;
  }
}
