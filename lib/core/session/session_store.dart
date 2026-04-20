import '../../features/auth/data/auth_service.dart';

/// Singleton yang menyimpan sesi user yang sedang login.
///
/// Diisi oleh [AuthService] setelah login berhasil.
/// Dibaca oleh [ApiClient] untuk mengambil token secara otomatis.
class SessionStore {
  SessionStore._();

  /// Satu-satunya instance (singleton).
  static final SessionStore instance = SessionStore._();

  AuthUser? _currentUser;

  // ── Getters ────────────────────────────────────────────────────
  AuthUser? get currentUser => _currentUser;
  String?   get token       => _currentUser?.token;
  bool      get isLoggedIn  => _currentUser != null;

  // ── Mutators ───────────────────────────────────────────────────

  /// Dipanggil oleh [AuthService] setelah login berhasil.
  void setSession(AuthUser user) {
    _currentUser = user;
  }

  /// Dipanggil saat logout.
  void clearSession() {
    _currentUser = null;
  }
}
