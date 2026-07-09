import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/session/session_store.dart';

class StartupGuardScreen extends StatefulWidget {
  const StartupGuardScreen({super.key});

  @override
  State<StartupGuardScreen> createState() => _StartupGuardScreenState();
}

class _StartupGuardScreenState extends State<StartupGuardScreen> {
  @override
  void initState() {
    super.initState();
    _performStartupCheck();
  }

  Future<void> _performStartupCheck() async {
    try {
      // 1. Cek apakah server online dan tidak sedang maintenance.
      // Kita panggil endpoint login menggunakan GET.
      await ApiClient.get('/auth/login');
      
      // Jika berhasil tembus (atau throw 405 Method Not Allowed), berarti server ONLINE.
      _proceedNavigation();
    } on ApiException catch (e) {
      if (e.statusCode == 503) {
        // Jika 503, ApiClient._handleResponse otomatis mengarahkan ke /maintenance.
        // Jadi kita tidak perlu melakukan apa-apa lagi di sini.
        return;
      }
      
      // Untuk status error lain (seperti 405, 401, dll), anggap server online
      _proceedNavigation();
    } catch (_) {
      // Jika terjadi error koneksi fisik (server mati total), arahkan juga ke halaman maintenance
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.maintenance,
          (_) => false,
        );
      }
    }
  }

  void _proceedNavigation() {
    if (!mounted) return;
    
    // 2. Cek status login lokal
    if (SessionStore.instance.isLoggedIn) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.selectMenu);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/icons/LogoNTC.png',
              height: 64,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 48),
            
            // Premium clean indicator
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)), // Emerald 600
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Initializing application...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B), // Slate 500
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
