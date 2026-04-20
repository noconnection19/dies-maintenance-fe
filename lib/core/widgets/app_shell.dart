import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../session/session_store.dart';
import 'app_header.dart';
import 'app_footer.dart';

/// Shell layout untuk semua halaman setelah login.
///
/// Berisi: gradient background + [AppHeader] + [child] + [AppFooter].
/// Setiap screen baru cukup pakai ini sebagai pembungkus — tidak perlu
/// deklarasi header/footer berulang.
///
/// Contoh penggunaan pada screen baru:
/// ```dart
/// class LineStopScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return AppShell(
///       child: LineStopContent(),
///     );
///   }
/// }
/// ```
class AppShell extends StatelessWidget {
  /// Konten utama halaman (area antara header dan footer).
  final Widget child;

  /// Padding konten. Default: 32px semua sisi.
  final EdgeInsetsGeometry contentPadding;

  const AppShell({
    super.key,
    required this.child,
    this.contentPadding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    final user = SessionStore.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Gradient latar (hijau muda atas → putih) ──────────────
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

          // ── Layout utama ─────────────────────────────────────────
          Column(
            children: [
              // 1. Header — otomatis ambil dari SessionStore
              AppHeader(
                name: user?.fullName ?? '-',
                role: user?.role ?? '-',
              ),

              // 2. Konten halaman
              Expanded(
                child: Padding(
                  padding: contentPadding,
                  child: child,
                ),
              ),

              // 3. Footer
              const AppFooter(),
            ],
          ),
        ],
      ),
    );
  }
}
