/// Konstanta ukuran (spacing, radius, icon) agar tidak ada angka "magic" tersebar di kode.
///
/// Penggunaan:
/// ```dart
/// padding: EdgeInsets.all(AppSizes.md)
/// borderRadius: BorderRadius.circular(AppSizes.radiusMd)
/// ```
class AppSizes {
  AppSizes._();

  // ── Spacing ─────────────────────────────────────────────────────
  static const double xs   =  4.0;
  static const double sm   =  8.0;
  static const double md   = 16.0;
  static const double lg   = 24.0;
  static const double xl   = 32.0;
  static const double xxl  = 48.0;
  static const double xxxl = 64.0;

  // ── Border radius ────────────────────────────────────────────────
  static const double radiusSm  =  8.0;
  static const double radiusMd  = 12.0;
  static const double radiusLg  = 16.0;
  static const double radiusXl  = 20.0;
  static const double radiusFull = 999.0;

  // ── Icon sizes ───────────────────────────────────────────────────
  static const double iconSm  = 16.0;
  static const double iconMd  = 20.0;
  static const double iconLg  = 24.0;
  static const double iconXl  = 32.0;

  // ── Button ───────────────────────────────────────────────────────
  static const double buttonHeight = 48.0;
  static const double buttonHeightSm = 36.0;

  // ── Layout ───────────────────────────────────────────────────────
  static const double pageHorizontalPadding = 32.0;
  static const double pageVerticalPadding   = 32.0;
  static const double cardPadding          = 28.0;
  static const double headerHeight         = 72.0;
  static const double footerHeight         = 44.0;
}
