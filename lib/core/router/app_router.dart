import 'package:flutter/material.dart';
import '../session/session_store.dart';
import '../../features/landing/screens/landing_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/home_screen.dart';
import '../../features/line_stop/screens/line_stop_screen.dart';

/// Nama-nama route yang digunakan di seluruh aplikasi.
class AppRoutes {
  AppRoutes._();

  static const String landing   = '/';
  static const String login     = '/login';
  static const String dashboard = '/dashboard';
  static const String lineStop  = '/line-stop';
}

/// Router aplikasi: mengelola navigasi dan auth guard.
class AppRouter {
  AppRouter._();

  /// Route map yang didaftarkan ke [MaterialApp].
  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.landing: (_) => const LandingScreen(),
        AppRoutes.login:   (_) => const LoginScreen(),
        AppRoutes.dashboard: (context) {
          final user = SessionStore.instance.currentUser;
          if (user == null) return const LandingScreen();
          return HomeScreen(authUser: user);
        },
        AppRoutes.lineStop: (context) {
          final user = SessionStore.instance.currentUser;
          if (user == null) return const LandingScreen();
          return const LineStopScreen();
        },
      };

  /// Route awal saat app dibuka.
  /// Jika sudah login → langsung ke dashboard, jika belum → landing page.
  static String get initialRoute {
    return SessionStore.instance.isLoggedIn
        ? AppRoutes.dashboard
        : AppRoutes.landing;
  }

  // ── Navigation helpers ────────────────────────────────────────────

  /// Landing page → Login page, dengan nama modul yang dipilih.
  static void goToLogin(BuildContext context, {required String moduleName}) {
    Navigator.of(context).pushNamed(AppRoutes.login, arguments: moduleName);
  }

  /// Navigasi ke Dashboard setelah login berhasil (replace — tidak bisa back ke login).
  static void goToDashboard(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.dashboard,
      (_) => false,
    );
  }

  /// Navigasi ke Line Stop Screen.
  static void goToLineStop(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.lineStop);
  }

  /// Logout: bersihkan sesi lalu kembali ke Landing.
  static void logout(BuildContext context) {
    SessionStore.instance.clearSession();
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.landing,
      (_) => false,
    );
  }
}

/// Widget guard: redirect ke landing jika belum login.
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
