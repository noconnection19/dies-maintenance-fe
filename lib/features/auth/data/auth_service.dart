import '../../../core/session/session_store.dart';

// ─── Model ─────────────────────────────────────────────────────────

/// Representasi user yang sudah berhasil login.
class AuthUser {
  final int id;
  final String username;
  final String fullName;
  final String role;
  final String token;

  const AuthUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.token,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json, String token) {
    final u = json['user'] as Map<String, dynamic>;
    return AuthUser(
      id: u['id'] as int,
      username: u['username'] as String,
      fullName: (u['full_name'] as String?) ?? u['username'] as String,
      role: u['role'] as String,
      token: token,
    );
  }
}

// ─── Service ───────────────────────────────────────────────────────

/// Service autentikasi — satu-satunya service yang TIDAK menggunakan [ApiClient]
/// karena belum ada token saat login.
///
/// Setelah login berhasil, token disimpan ke [SessionStore] sehingga
/// [ApiClient] dapat menggunakannya secara otomatis di semua request berikutnya.
class AuthService {
  AuthService._();

  /// [MOCK] Login tanpa hit API — loloskan semua credential yang tidak kosong.
  /// Ganti dengan implementasi asli saat backend sudah siap.
  static Future<AuthUser> login(String username, String password) async {
    // Simulasi network delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (username.isEmpty || password.isEmpty) {
      throw Exception('Username / Password salah');
    }

    final user = AuthUser(
      id: 1,
      username: username,
      fullName: username,
      role: 'Member',
      token: 'mock-token-${DateTime.now().millisecondsSinceEpoch}',
    );

    // Simpan ke SessionStore agar ApiClient bisa pakai token
    SessionStore.instance.setSession(user);

    return user;
  }

  /// Logout: hapus sesi dari [SessionStore].
  static void logout() => SessionStore.instance.clearSession();
}
