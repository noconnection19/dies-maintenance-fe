import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'role': role,
      'token': token,
    };
  }

  factory AuthUser.fromStoredJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      token: json['token'] as String,
    );
  }
}

// ─── Service ───────────────────────────────────────────────────────

/// Service autentikasi — menggunakan [ApiClient] untuk menghubungi backend.
class AuthService {
  AuthService._();

  /// Login ke backend dengan memverifikasi credential.
  static Future<AuthUser> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw Exception('Username atau password tidak boleh kosong');
    }

    final Map<String, dynamic> data = await ApiClient.post(
      ApiConstants.authLogin,
      body: {
        'username': username,
        'password': password,
      },
    ) as Map<String, dynamic>;

    final token = data['access_token'] as String;
    final user = AuthUser.fromJson(data, token);

    // Simpan ke SessionStore agar ApiClient bisa pakai token
    SessionStore.instance.setSession(user);

    // Simpan ke SharedPreferences untuk persistensi reload page
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_session', jsonEncode(user.toJson()));

    return user;
  }

  /// Logout: bersihkan sesi di server dan di local client.
  static Future<void> logout() async {
    try {
      await ApiClient.post(ApiConstants.authLogout);
    } catch (_) {
      // Abaikan error agar client tetap ter-logout meskipun server tidak aktif/token kadaluarsa
    } finally {
      // Bersihkan SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_session');

      SessionStore.instance.clearSession();
    }
  }
}

