/// Validator functions untuk form field Flutter, di-compose sesuai kebutuhan.
///
/// Penggunaan:
/// ```dart
/// validator: Validators.required('Nama Dies')
/// validator: Validators.compose([
///   Validators.required('No. Reg'),
///   Validators.maxLength(20),
/// ])
/// ```
class Validators {
  Validators._();

  /// Field tidak boleh kosong.
  static String? Function(String?) required(String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName wajib diisi';
      }
      return null;
    };
  }

  /// Panjang minimum.
  static String? Function(String?) minLength(int min, [String? message]) {
    return (value) {
      if (value != null && value.length < min) {
        return message ?? 'Minimal $min karakter';
      }
      return null;
    };
  }

  /// Panjang maksimum.
  static String? Function(String?) maxLength(int max, [String? message]) {
    return (value) {
      if (value != null && value.length > max) {
        return message ?? 'Maksimal $max karakter';
      }
      return null;
    };
  }

  /// Format email sederhana.
  static String? Function(String?) email([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return message ?? 'Format email tidak valid';
      }
      return null;
    };
  }

  /// Hanya angka.
  static String? Function(String?) numeric([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (double.tryParse(value) == null) {
        return message ?? 'Hanya boleh berisi angka';
      }
      return null;
    };
  }

  /// Gabungkan beberapa validator — dijalankan berurutan, berhenti di error pertama.
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final v in validators) {
        final result = v(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
