import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Widget loading dan overlay loading yang konsisten dengan estetika premium.
class AppLoading extends StatefulWidget {
  final bool _isOverlay;
  final String? message;

  const AppLoading({super.key, this.message}) : _isOverlay = false;

  const AppLoading.overlay({super.key, this.message}) : _isOverlay = true;

  @override
  State<AppLoading> createState() => _AppLoadingState();
}

class _AppLoadingState extends State<AppLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _rotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _pulseScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.9, end: 1.25).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.25, end: 0.9).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_controller);

    _pulseOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.2, end: 0.6).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 0.6, end: 0.2).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget._isOverlay) return _buildOverlay();
    return _buildInline();
  }

  Widget _buildInline() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnimatedSpinner(),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            _buildAnimatedMessage(widget.message!),
          ],
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        // Frosted glass background
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              color: Colors.black.withOpacity(0.15),
            ),
          ),
        ),
        // Glassmorphism card dialog in the center
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimatedSpinner(),
                if (widget.message != null) ...[
                  const SizedBox(height: 20),
                  _buildAnimatedMessage(widget.message!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSpinner() {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulsing glow
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseScale.value,
                child: Opacity(
                  opacity: _pulseOpacity.value,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.green.withOpacity(0.15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Inner gradient rotating spinner
          RotationTransition(
            turns: _rotation,
            child: CustomPaint(
              size: const Size(40, 40),
              painter: _GradientSpinnerPainter(
                color: AppColors.green,
                strokeWidth: 3.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMessage(String msg) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Subtle fade in and out syncing with pulse
        final opacityVal = 0.6 + (_pulseOpacity.value * 0.4);
        return Opacity(
          opacity: opacityVal,
          child: Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: AppColors.textPrimary,
            ),
          ),
        );
      },
    );
  }
}

class _GradientSpinnerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _GradientSpinnerPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Background track ring
    paint.color = color.withOpacity(0.1);
    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);

    // Gradient sweep arc
    paint.shader = SweepGradient(
      colors: [
        color.withOpacity(0.0),
        color.withOpacity(0.4),
        color,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(rect);

    // Draw arc (about 270 degrees)
    canvas.drawArc(
      rect,
      -1.5,
      4.7,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
