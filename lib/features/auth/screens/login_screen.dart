import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/validators.dart';
import '../data/auth_service.dart';

/// Login screen — desain single-column centered, sesuai mockup.
/// Menerima [moduleName] dari [LandingScreen] via route arguments.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  /// Nama modul yang dipilih dari landing page.
  String get _moduleName {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is String ? args : 'Dies Maintenance';
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Flag terpisah agar navigasi tidak masuk ke catch block
    bool success = false;
    try {
      await AuthService.login(_userCtrl.text.trim(), _passCtrl.text);
      success = true;
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Incorrect Username / Password. Please check and try again!');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    // Navigasi dilakukan di luar try-catch
    if (success && mounted) {
      AppRouter.goToDashboard(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Gradient latar (hijau muda atas → putih) ─────────────
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

          // ── Konten utama ─────────────────────────────────────────
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.xl,
                vertical: AppSizes.xxl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/icons/LogoNTC.png',
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xl),

                      // Title & subtitle
                      Text(
                        'Welcome to $_moduleName System',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      const Text(
                        'Please log in to access your dashboard',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xxl),

                      // ── Username ────────────────────────────────
                      const _FieldLabel('Username'),
                      const SizedBox(height: AppSizes.sm),
                      _LoginField(
                        controller: _userCtrl,
                        hint: 'Input username here...',
                        validator: Validators.required('Username'),
                      ),
                      const SizedBox(height: AppSizes.md + AppSizes.xs),

                      // ── Password ────────────────────────────────
                      const _FieldLabel('Password'),
                      const SizedBox(height: AppSizes.sm),
                      _LoginField(
                        controller: _passCtrl,
                        hint: 'Input your password',
                        obscureText: _obscurePassword,
                        validator: Validators.required('Password'),
                        onFieldSubmitted: (_) => _submit(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textMuted,
                            size: AppSizes.iconMd,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),

                      // ── Error message ───────────────────────────
                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppSizes.md),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md,
                            vertical: AppSizes.sm + AppSizes.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lineStop.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            border: Border.all(color: AppColors.lineStop.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.lineStop, size: 18),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.lineStop,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: AppSizes.xl),

                      // ── Login button ────────────────────────────
                      SizedBox(
                        height: AppSizes.buttonHeight + 6,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.green.withOpacity(0.5),
                            elevation: 0,
                            shape: const StadiumBorder(), // pill shape
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),

                      // ── Back to Option ──────────────────────────
                      SizedBox(
                        height: AppSizes.buttonHeight + 6,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded, size: AppSizes.iconMd),
                          label: const Text(
                            'Back to Option',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.green,
                            backgroundColor: AppColors.greenLight,
                            side: BorderSide.none,
                            shape: const StadiumBorder(), // pill shape
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Field Label ───────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ─── Login Field ───────────────────────────────────────────────────
class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;

  const _LoginField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.green, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.lineStop),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.lineStop, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
