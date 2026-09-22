import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shared decorative wave painter for app headers.
///
/// Replaces the previously duplicated `_WavePainter` classes scattered
/// across view files. Use via [CustomPaint]:
///
/// ```dart
/// CustomPaint(
///   size: Size(width, height),
///   painter: WavePainter.green(),   // role pengelola
///   // or: WavePainter.blue(),      // role kelurahan
/// )
/// ```
class WavePainter extends CustomPainter {
  /// Gradient used for the base wave layer.
  final List<Color> gradient;

  /// Color of the lighter overlay wave (drawn with alpha 0.3).
  final Color overlayColor;

  /// Whether to draw the subtle white accent dots.
  final bool showDots;

  /// Skala vertikal gelombang (0.5 = wave hanya di 50% atas, agak "tenang").
  /// Dipakai header dengan konten padat agar pola tidak menutupi card statistik.
  final double waveScale;

  const WavePainter({
    required this.gradient,
    required this.overlayColor,
    this.showDots = true,
    this.waveScale = 1.0,
  });

  /// Green variant for the auth & pengelola (bank sampah) areas.
  const WavePainter.green({this.showDots = true, this.waveScale = 1.0})
      : gradient = const [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        overlayColor = const Color(0xFF43A047);

  /// Blue variant for the kelurahan area.
  const WavePainter.blue({this.showDots = true, this.waveScale = 1.0})
      : gradient = const [Color(0xFF0A2540), Color(0xFF1E88E5)],
        overlayColor = const Color(0xFF42A5F5);

  @override
  void paint(Canvas canvas, Size size) {
    paintWaves(canvas, size);
    if (showDots) paintDots(canvas, size);
  }

  /// Gambar tiga lapis wave organik nan halus (dipanggil ulang oleh [AnimatedWavePainter]).
  void paintWaves(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradient,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    double hs(double f) => size.height * f * waveScale;

    final path1 = Path()
      ..lineTo(0, hs(0.78))
      ..cubicTo(
        size.width * 0.22,
        hs(0.98),
        size.width * 0.42,
        hs(0.74),
        size.width * 0.65,
        hs(0.86),
      )
      ..cubicTo(
        size.width * 0.82,
        hs(0.94),
        size.width * 0.93,
        hs(0.84),
        size.width,
        hs(0.80),
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path1, paint1);

    // Lapis wave translusen kedua (efek kedalaman fluid)
    final paint2 = Paint()..color = overlayColor.withValues(alpha: 0.25);

    final path2 = Path()
      ..moveTo(0, hs(0.62))
      ..cubicTo(
        size.width * 0.28,
        hs(0.46),
        size.width * 0.52,
        hs(0.68),
        size.width * 0.76,
        hs(0.55),
      )
      ..cubicTo(
        size.width * 0.88,
        hs(0.48),
        size.width * 0.95,
        hs(0.58),
        size.width,
        hs(0.54),
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path2, paint2);

    // Lapis wave translusen ketiga (cahaya ambien organik)
    final paint3 = Paint()..color = Colors.white.withValues(alpha: 0.08);

    final path3 = Path()
      ..moveTo(0, hs(0.40))
      ..cubicTo(
        size.width * 0.35,
        hs(0.56),
        size.width * 0.65,
        hs(0.34),
        size.width,
        hs(0.42),
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path3, paint3);
  }

  /// Gambar dots dekoratif statis.
  void paintDots(Canvas canvas, Size size) {
    final paintDot = Paint()..color = Colors.white.withValues(alpha: 0.06);

    canvas.drawCircle(
      Offset(size.width * 0.11, size.height * 0.32),
      42,
      paintDot,
    );
    canvas.drawCircle(
      Offset(size.width * 0.89, size.height * 0.17),
      26,
      paintDot,
    );
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) =>
      oldDelegate.gradient != gradient ||
      oldDelegate.overlayColor != overlayColor ||
      oldDelegate.showDots != showDots ||
      oldDelegate.waveScale != waveScale;
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATED WAVE — wave hidup: bergoyang halus + dots berdenyut
// ═══════════════════════════════════════════════════════════════════════════

/// Painter wave dengan fase animasi [t] (0..1). Gelombang bergeser
/// ping-pong ~2% lebar (tanpa "lompatan" loop) dan dots berdenyut.
class AnimatedWavePainter extends WavePainter {
  /// Fase animasi 0..1.
  final double t;

  const AnimatedWavePainter({
    required this.t,
    required super.gradient,
    required super.overlayColor,
    super.showDots,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sway = math.sin(t * 2 * math.pi) * size.width * 0.018;
    canvas.save();
    canvas.translate(sway, 0);
    paintWaves(canvas, size);
    canvas.restore();

    if (showDots) _paintPulsingDots(canvas, size, t);
  }

  void _paintPulsingDots(Canvas canvas, Size size, double t) {
    final pulse = math.sin(t * 2 * math.pi);
    final paintDot = Paint()
      ..color = Colors.white.withValues(alpha: 0.06 + 0.03 * pulse);

    canvas.drawCircle(
      Offset(size.width * 0.11, size.height * 0.32),
      42 * (1 + 0.08 * pulse),
      paintDot,
    );
    canvas.drawCircle(
      Offset(size.width * 0.89, size.height * 0.17),
      26 * (1 - 0.08 * pulse),
      paintDot,
    );
  }

  @override
  bool shouldRepaint(AnimatedWavePainter oldDelegate) =>
      oldDelegate.t != t || super.shouldRepaint(oldDelegate);
}

/// Widget wave beranimasi — drop-in pengganti
/// `CustomPaint(size: ..., painter: WavePainter.green())`.
/// Loop 9 detik: wave bergoyang halus, dots bernapas.
class AnimatedWave extends StatefulWidget {
  final Size size;
  final List<Color> gradient;
  final Color overlayColor;
  final bool showDots;

  const AnimatedWave.green({super.key, required this.size, this.showDots = true})
      : gradient = const [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        overlayColor = const Color(0xFF43A047);

  const AnimatedWave.blue({super.key, required this.size, this.showDots = true})
      : gradient = const [Color(0xFF0A2540), Color(0xFF1E88E5)],
        overlayColor = const Color(0xFF42A5F5);

  const AnimatedWave({
    super.key,
    required this.size,
    required this.gradient,
    required this.overlayColor,
    this.showDots = true,
  });

  @override
  State<AnimatedWave> createState() => _AnimatedWaveState();
}

class _AnimatedWaveState extends State<AnimatedWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        size: widget.size,
        painter: AnimatedWavePainter(
          t: _controller.value,
          gradient: widget.gradient,
          overlayColor: widget.overlayColor,
          showDots: widget.showDots,
        ),
      ),
    );
  }
}
