import 'dart:async';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ────────────────────────────────────────────────────────────────────────────
/// Micro-interaction primitives untuk seluruh aplikasi.
///
/// Pakai [PressableScale] untuk semua elemen interaktif (card, menu, button)
/// agar punya efek "press" yang hidup. Pakai [StaggeredEntrance] untuk
/// konten yang masuk berurutan saat halaman dibuka.
/// ────────────────────────────────────────────────────────────────────────────

/// Wrapper interaktif: efek menekuk saat ditekan + haptic + optional ripple.
///
/// ```dart
/// PressableScale(
///   onTap: () => Get.toNamed(AppRoutes.inputSampah),
///   child: MyCard(),
/// )
/// ```
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Skala saat ditekan. 0.96 terasa pas untuk card besar,
  /// 0.94 untuk tombol.
  final double pressedScale;

  /// Latar Material untuk efek ripple. Jika null, hanya efek skala.
  final Color? splashColor;

  /// Radius clip ripple (harus sama dengan radius card).
  final double? borderRadius;

  /// Rasio skala maksimum efek ripple terhadap ukuran child.
  final double splashExtentRatio;

  /// Intensitas glow warna saat ditekan (0 = nonaktif, 1 = penuh).
  final double glowIntensity;

  /// Warna glow; jika null memakai [splashColor].
  final Color? glowColor;

  /// Kedalaman efek: elemen "turun" beberapa px saat ditekan (0 = nonaktif).
  final double pressElevation;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.96,
    this.splashColor,
    this.borderRadius,
    this.splashExtentRatio = 1.0,
    this.glowIntensity = 0,
    this.glowColor,
    this.pressElevation = 0,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      reverseDuration: const Duration(milliseconds: 300),
      value: 1,
    );
    _scale = Tween<double>(
      begin: 1,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      // Release memakai kurva squash-back: sedikit melewati posisi diam
      // lalu kembali — terasa seperti spring, bukan tween datar.
      reverseCurve: const _SquashBackCurve(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _down(DragDownDetails _) {
    if (_enabled) _controller.forward();
  }

  void _cancel() {
    if (_enabled) _controller.reverse();
  }

  void _up(DragEndDetails _) {
    if (_enabled) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        final press = (1 - _scale.value).clamp(0.0, 1.0);
        Widget content = child!;
        if (widget.glowIntensity > 0 || widget.pressElevation > 0) {
          content = _PressableDecoration(
            press: press,
            glowIntensity: widget.glowIntensity,
            glowColor: widget.glowColor ?? widget.splashColor,
            pressElevation: widget.pressElevation,
            borderRadius: widget.borderRadius,
            child: content,
          );
        }
        return Transform.scale(scale: _scale.value, child: content);
      },
      child: widget.child,
    );

    final hasSplash =
        widget.splashColor != null || widget.borderRadius != null;
    if (hasSplash) {
      final color = widget.splashColor;
      final shape = widget.borderRadius == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius!),
            );
      result = InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        splashColor: color,
        highlightColor: Colors.transparent,
        borderRadius: shape is RoundedRectangleBorder
            ? (shape.borderRadius as BorderRadius?)
            : null,
        customBorder: shape,
        child: result,
      );
    } else {
      result = GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        behavior: HitTestBehavior.opaque,
        child: result,
      );
    }

    return GestureDetector(
      onPanDown: _down,
      onPanCancel: _cancel,
      onPanEnd: _up,
      onTap: null,
      child: result,
    );
  }
}

/// Animasi entri berurutan: fade + slide-up ringan untuk setiap item.
///
/// ```dart
/// Column(children: [
///   StaggeredEntrance(index: 0, child: HeaderWidget()),
///   StaggeredEntrance(index: 1, child: StatGrid()),
///   ...
/// ])
/// ```
class StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final int index;

  /// Jeda antar-item (ms).
  final int delayMs;

  /// Aktifkan getar halus saat item muncul (hanya untuk item terpenting).
  final bool hapticOnEnter;

  const StaggeredEntrance({
    super.key,
    required this.child,
    required this.index,
    this.delayMs = 45,
    this.hapticOnEnter = false,
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    final start = (widget.index * widget.delayMs).clamp(0, 600);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 1, curve: Curves.easeOutCubic),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 1, curve: Curves.easeOutCubic),
    ));

    if (widget.hapticOnEnter) {
      Future.delayed(Duration(milliseconds: start), () {
        if (mounted) HapticFeedback.lightImpact();
      });
    }
    Future.delayed(Duration(milliseconds: start), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

/// Angka yang beranimasi dari nilai lama ke baru dengan easing halus.
///
/// ```dart
/// AnimatedValue(
///   value: controller.totalKgBulanIni.value,
///   builder: (v) => FormatHelper.number(v),
/// )
/// ```
class AnimatedValue extends StatefulWidget {
  final double value;
  final Widget Function(double value) builder;
  final Duration duration;
  final Curve curve;

  /// Buat [AnimatedValue] yang menampilkan string terformat.
  ///
  /// ```dart
  /// AnimatedValue.formatted(
  ///   value: total,
  ///   format: FormatHelper.number,
  /// )
  /// ```
  static Widget formatted({
    Key? key,
    required double value,
    required String Function(num) format,
    Duration duration = const Duration(milliseconds: 850),
  }) {
    return AnimatedValue(
      key: key,
      value: value,
      duration: duration,
      builder: (v) => Text(format(v)),
    );
  }

  const AnimatedValue({
    super.key,
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedValue> createState() => _AnimatedValueState();
}

class _AnimatedValueState extends State<AnimatedValue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _anim;
  double _from = 0;
  double _to = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _from = 0;
    _to = widget.value;
    _anim = Tween<double>(begin: _from, end: _to)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _from = _anim.value;
      _to = widget.value;
      _anim = Tween<double>(begin: _from, end: _to)
          .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => widget.builder(_anim.value),
    );
  }
}

/// Blob dekoratif untuk latar halaman — menggantikan "lingkaran putih
/// statis" yang terasa kaku. Tempatkan di dalam Stack di belakang konten.
class AmbientBlob extends StatelessWidget {
  final Color color;
  final double size;
  final Alignment alignment;

  const AmbientBlob({
    super.key,
    required this.color,
    required this.size,
    this.alignment = Alignment.topRight,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: _BlurBlob(color: color, size: size),
      ),
    );
  }
}

class _BlurBlob extends StatefulWidget {
  final Color color;
  final double size;

  const _BlurBlob({required this.color, required this.size});

  @override
  State<_BlurBlob> createState() => _BlurBlobState();
}

class _BlurBlobState extends State<_BlurBlob>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _phase;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _phase = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _phase,
      builder: (context, _) {
        final t = _phase.value;
        return Transform.translate(
          offset: Offset(0, ui.lerpDouble(-10, 14, t)!),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.color,
                  widget.color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Skala + fade saat widget pertama kali muncul — untuk kartu/section yang
/// tidak butuh stagger, tapi tetap ingin kesan "hidup".
class PopIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const PopIn({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.97, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

/// ────────────────────────────────────────────────────────────────────────────
/// Pull-to-refresh dengan indikator custom: cincin lingkaran yang memuat
/// (stroke progress sesuai jarak tarik) + rotasi saat refresh berlangsung,/// diganti spinner kecil saat refresh aktif. Pengganti drop-in untuk
/// [RefreshIndicator] — API sama: [child] harus scrollable.
/// ────────────────────────────────────────────────────────────────────────────
/// Kombinasi praktis: konten muncul pop-in + slide halus sesuai urutan [index].
/// Dipakai untuk kartu-kartu utama (login, dashboard) agar satu widget
/// memberi efek pop-in (scale spring) sekaligus entrance stagger.
class PopInEntrance extends StatelessWidget {
  final Widget child;
  final int index;
  final int delayMs;

  const PopInEntrance({
    super.key,
    required this.child,
    required this.index,
    this.delayMs = 70,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredEntrance(
      index: index,
      delayMs: delayMs,
      child: PopIn(
        delay: Duration(milliseconds: (index * delayMs).clamp(0, 600)),
        child: child,
      ),
    );
  }
}

class PullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color color;

  const PullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    required this.color,
  });

  @override
  State<PullToRefresh> createState() => _PullToRefreshState();
}

class _PullToRefreshState extends State<PullToRefresh>
    with TickerProviderStateMixin {
  static const double _triggerDistance = 92;
  static const double _maxDrag = 140;

  late final AnimationController _spin;
  double _dragDistance = 0;
  bool _armed = false;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _refreshing = true);
    HapticFeedback.mediumImpact();
    _spin.repeat();
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _spin.stop();
        setState(() {
          _refreshing = false;
          _dragDistance = 0;
          _armed = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: widget.color,
      backgroundColor: Colors.white,
      displacement: 40,
      edgeOffset: 0,
      notificationPredicate: (notif) => notif.depth == 0,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notif) {
          if (notif is OverscrollNotification &&
              !_refreshing &&
              notif.overscroll < 0) {
            setState(() {
              _dragDistance = (_dragDistance +
                      notif.overscroll.abs() * 0.42)
                  .clamp(0, _maxDrag);
              _armed = _dragDistance >= _triggerDistance;
            });
          } else if (notif is ScrollEndNotification) {
            setState(() {
              _dragDistance = 0;
              _armed = false;
            });
          }
          return false;
        },
        child: Stack(
          children: [
            widget.child,
            // Indikator custom mengambang di atas konten
            Positioned(
              top: 28,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: _RingIndicator(
                    progress: (_dragDistance / _triggerDistance).clamp(0.0, 1.0),
                    visible: _dragDistance > 6 || _refreshing,
                    armed: _armed,
                    refreshing: _refreshing,
                    spin: _spin,
                    color: widget.color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingIndicator extends StatelessWidget {
  final double progress;
  final bool visible;
  final bool armed;
  final bool refreshing;
  final AnimationController spin;
  final Color color;

  const _RingIndicator({
    required this.progress,
    required this.visible,
    required this.armed,
    required this.refreshing,
    required this.spin,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: visible ? 1 : 0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: visible ? 1 : 0.4,
        curve: Curves.easeOutBack,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: refreshing
                ? RotationTransition(
                    turns: spin,
                    child: _RingPainter(progress: 0.75, color: color),
                  )
                : _RingPainter(
                    progress: progress,
                    color: armed ? color : color.withValues(alpha: 0.45),
                  ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends StatelessWidget {
  final double progress;
  final Color color;

  const _RingPainter({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RingPainterDelegate(progress: progress, color: color),
      size: const Size.square(30),
    );
  }
}

class _RingPainterDelegate extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainterDelegate({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.15);

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      stroke,
    );

    if (progress <= 0) return;

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ),
      -3.14159 / 2,
      2 * 3.14159 * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainterDelegate old) =>
      old.progress != progress || old.color != color;
}

/// ────────────────────────────────────────────────────────────────────────────
/// Page transition & route progress
/// ────────────────────────────────────────────────────────────────────────────

/// Observer navigasi yang memberi tahu [RouteProgressLine] setiap kali
/// halaman berpindah (push/pop/replace). Pasang SEKALI di
/// `GetMaterialApp.navigatorObservers`.
class RouteProgressObserver extends NavigatorObserver with ChangeNotifier {
  void _notify() {
    // Post-frame agar tidak memicu rebuild saat frame sedang dibangun.
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _notify();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _notify();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _notify();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _notify();
}

/// Progress line tipis di tepi atas layar yang muncul otomatis saat
/// pindah halaman — sinyal "memuat" ala aplikasi native modern.
///
/// ```dart
/// GetMaterialApp(
///   navigatorObservers: [BisaApp.routeObserver],
///   builder: (context, child) => RouteProgressLine(
///     observer: BisaApp.routeObserver,
///     color: AppColors.primary,
///     child: child!,
///   ),
/// )
/// ```
class RouteProgressLine extends StatefulWidget {
  final Widget child;
  final Color color;
  final RouteProgressObserver observer;

  /// Berapa lama garis terlihat sebelum diredam.
  final Duration activeDuration;

  const RouteProgressLine({
    super.key,
    required this.child,
    required this.color,
    required this.observer,
    this.activeDuration = const Duration(milliseconds: 800),
  });

  @override
  State<RouteProgressLine> createState() => _RouteProgressLineState();
}

class _RouteProgressLineState extends State<RouteProgressLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep;
  Timer? _hideTimer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
    widget.observer.addListener(_onRouteChanged);
  }

  void _onRouteChanged() {
    if (!mounted) return;
    _hideTimer?.cancel();
    setState(() => _visible = true);
    _hideTimer = Timer(widget.activeDuration, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    widget.observer.removeListener(_onRouteChanged);
    _hideTimer?.cancel();
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              height: _visible ? 2.5 : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _visible ? 1 : 0,
                child: AnimatedBuilder(
                  animation: _sweep,
                  builder: (context, _) => CustomPaint(
                    painter: _RouteSweepPainter(
                      t: _sweep.value,
                      color: widget.color,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Sapuan gradient tipis yang bergerak dari kiri ke kanan berulang.
class _RouteSweepPainter extends CustomPainter {
  final double t;
  final Color color;

  _RouteSweepPainter({required this.t, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final band = size.width * 0.35;
    final x = -band + (size.width + band) * t;
    final shader = ui.Gradient.linear(
      Offset(x, 0),
      Offset(x + band, 0),
      [
        color.withValues(alpha: 0),
        color.withValues(alpha: 0.9),
        color.withValues(alpha: 0),
      ],
      const [0.0, 0.5, 1.0],
    );
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_RouteSweepPainter old) => old.t != t || old.color != color;
}

/// Kurva release [PressableScale]: sedikit overshoot lalu settle — rasa
/// spring tanpa physics engine.
class _SquashBackCurve extends Curve {
  const _SquashBackCurve();

  @override
  double transform(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    final x = t - 1;
    return 1 + c3 * x * x * x + c1 * x * x;
  }
}

/// Glow + depth yang mengikuti progres tekan (0 = idle, 1 = tertekan penuh).
class _PressableDecoration extends StatelessWidget {
  final Widget child;
  final double press;
  final double glowIntensity;
  final Color? glowColor;
  final double pressElevation;
  final double? borderRadius;

  const _PressableDecoration({
    required this.child,
    required this.press,
    required this.glowIntensity,
    required this.pressElevation,
    this.glowColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;
    final color = glowColor;
    if (color != null && glowIntensity > 0) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius == null
              ? null
              : BorderRadius.circular(borderRadius!),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: glowIntensity * 0.45 * press),
              blurRadius: 12 + 16 * press,
              spreadRadius: 1 + 2 * press,
            ),
          ],
        ),
        child: result,
      );
    }
    if (pressElevation > 0) {
      result = Transform.translate(
        offset: Offset(0, pressElevation * press),
        child: result,
      );
    }
    return result;
  }
}
