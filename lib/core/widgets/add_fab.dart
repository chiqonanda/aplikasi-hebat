import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion.dart';

/// FAB "Tambah" modern — dipakai bersama oleh Manajemen Pengelola dan
/// Master Sampah (kategori, sub kategori, tipe, jenis, satuan).
///
/// Bahasa visual:
/// - Pill gradient dengan inner-highlight glossy + hairline border.
/// - Glow di bawah tombol "bernapas" pelan saat idle (terasa hidup).
/// - Shimmer sapuan tipis melintasi permukaan setiap beberapa detik.
/// - Saat ditekan: kompresi depth + glow membesar (PressableScale) dan
///   ikon berputar 45° playful lalu spring kembali.
class AddFab extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const AddFab({
    super.key,
    required this.label,
    this.icon = Icons.add_rounded,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<AddFab> createState() => _AddFabState();
}

class _AddFabState extends State<AddFab> with SingleTickerProviderStateMixin {
  /// Satu siklus (3,8 dtk) menggerakkan glow bernapas + satu sapuan shimmer.
  late final AnimationController _cycle;
  bool _pressing = false;

  @override
  void initState() {
    super.initState();
    _cycle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat();
  }

  @override
  void dispose() {
    _cycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressing = true),
      onPointerUp: (_) => setState(() => _pressing = false),
      onPointerCancel: (_) => setState(() => _pressing = false),
      child: PressableScale(
        onTap: widget.onTap,
        pressedScale: 0.93,
        pressElevation: 2.0,
        glowIntensity: 0.55,
        glowColor: widget.gradientColors.first,
        child: AnimatedBuilder(
          animation: _cycle,
          builder: (context, child) {
            final breathe = math.sin(_cycle.value * 2 * math.pi);
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradientColors.first
                        .withValues(alpha: 0.30 + 0.10 * breathe),
                    blurRadius: 16 + 6 * breathe,
                    offset: const Offset(0, 7),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              children: [
                // ── Permukaan gradient + konten ──
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedRotation(
                        turns: _pressing ? 0.125 : 0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Icon(widget.icon,
                              color: Colors.white, size: 17),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Inner highlight glossy (atas terang → bawah transparan) ──
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.20),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: const [0, 0.55],
                        ),
                      ),
                    ),
                  ),
                ),
                // ── Hairline border halus ──
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                // ── Shimmer sapuan periodik ──
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _cycle,
                      builder: (context, _) {
                        final t = _cycle.value;
                        if (t >= 0.42) return const SizedBox.shrink();
                        final p = t / 0.42; // 0..1
                        return Align(
                          alignment: Alignment(-1 + 2 * p, 0),
                          child: Transform.rotate(
                            angle: 0.35,
                            child: Container(
                              width: 46,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: 0.25),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
