/// Konfigurasi URL backend, dipusatkan agar mudah diganti saat pindah environment.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:8000/api/v1';

  // ── Endpoint paths ──────────────────────────────────────────────
  static const String authLogin      = '/auth/login';
  static const String lineStop       = '/line-stop';
  static const String repair         = '/repair';
  static const String preventive     = '/preventive';
}
