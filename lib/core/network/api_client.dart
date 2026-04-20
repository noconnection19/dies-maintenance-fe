import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../session/session_store.dart';
import 'api_exception.dart';

/// HTTP client bersama untuk seluruh aplikasi.
///
/// Fitur:
///  - Base URL dari [ApiConstants.baseUrl]
///  - Token JWT otomatis diambil dari [SessionStore] dan disisipkan ke header
///  - Error di-parse menjadi [ApiException] yang informatif
///  - Method tersedia: [get], [post], [put], [patch], [delete]
///
/// Cara pakai di service lain:
/// ```dart
/// final data = await ApiClient.get(ApiConstants.lineStop);
/// final created = await ApiClient.post(ApiConstants.repair, body: payload);
/// ```
class ApiClient {
  ApiClient._(); // tidak bisa di-instantiate

  // ── Headers ─────────────────────────────────────────────────────

  static Map<String, String> get _headers {
    final token = SessionStore.instance.token;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── URL builder ─────────────────────────────────────────────────

  static Uri _uri(String endpoint) =>
      Uri.parse('${ApiConstants.baseUrl}$endpoint');

  // ── Public methods ───────────────────────────────────────────────

  /// HTTP GET
  static Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final uri = queryParams != null
        ? _uri(endpoint).replace(queryParameters: queryParams)
        : _uri(endpoint);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  /// HTTP POST
  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      _uri(endpoint),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// HTTP PUT (replace seluruh resource)
  static Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.put(
      _uri(endpoint),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// HTTP PATCH (update sebagian resource)
  static Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.patch(
      _uri(endpoint),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// HTTP DELETE
  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(_uri(endpoint), headers: _headers);
    return _handleResponse(response);
  }

  // ── Response handler ─────────────────────────────────────────────

  /// Parse response:
  ///  - 2xx  → return decoded JSON (Map / List)
  ///  - 204  → return null (no content)
  ///  - 4xx/5xx → throw [ApiException]
  static dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    // Success
    if (statusCode >= 200 && statusCode < 300) {
      if (statusCode == 204 || response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    }

    // Error — coba ambil pesan dari body
    String message = 'Request failed ($statusCode)';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = (body['detail'] ?? body['message'] ?? message).toString();
    } catch (_) {
      // body bukan JSON, pakai message default
    }

    throw ApiException(statusCode: statusCode, message: message);
  }
}
