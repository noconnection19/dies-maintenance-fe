/// Exception custom yang dilempar oleh [ApiClient] untuk error HTTP.
///
/// Berisi [statusCode] dan [message] agar UI bisa menampilkan pesan yang tepat.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  /// Apakah error karena token tidak valid / sudah expired.
  bool get isUnauthorized => statusCode == 401;

  /// Apakah error karena tidak punya izin.
  bool get isForbidden => statusCode == 403;

  /// Apakah resource tidak ditemukan.
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
