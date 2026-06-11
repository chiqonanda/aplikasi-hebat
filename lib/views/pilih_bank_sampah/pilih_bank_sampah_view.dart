import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/session_controller.dart';
import '../../core/services/session_service.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/bank_sampah_model.dart';

class PilihBankSampahView extends GetView<SessionController> {
  const PilihBankSampahView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F4),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Obx(() {
              final activeBank = SessionService.to.activeBankSampah.value;

              if (controller.isLoading.value) {
                return const LoadingWidget();
              }

              if (controller.listBankSampah.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.fetchBankSampahSaya,
                color: AppColors.primary,
                child: Stack(
                  children: [
                    // ── Background pattern organik ──────────────────────
                    Positioned.fill(
                      child: CustomPaint(painter: _OrganicPatternPainter()),
                    ),
                    ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.listBankSampah.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) return _buildSectionLabel();
                        final bank = controller.listBankSampah[index - 1];
                        final isSelected = activeBank?.id == bank.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _BankSampahCard(
                            bank: bank,
                            isSelected: isSelected,
                            onTap: () => controller.pilihBankSampah(bank),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Orb dekoratif ─────────────────────────────────────────────
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: 10,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // ── Daun SVG dekoratif ────────────────────────────────────────
          Positioned(
            top: -8,
            right: 16,
            child: Opacity(
              opacity: 0.13,
              child: CustomPaint(
                size: const Size(88, 88),
                painter: _LeafPainter(),
              ),
            ),
          ),

          // ── Konten ───────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BISA',
                          style: AppTextStyles.titleMd.copyWith(
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Basis Informasi Sampah',
                          style: AppTextStyles.labelSm.copyWith(
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.find<AuthController>().logout(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Greeting
              Text(
                'Selamat datang kembali',
                style: AppTextStyles.bodyMd.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 2),
              Obx(() {
                final nama = SessionService.to.profile.value?.namaLengkap ?? '';
                return Text(
                  nama,
                  style: AppTextStyles.headlineMd.copyWith(
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                );
              }),

              const SizedBox(height: 14),

              // Info pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pilih bank sampah yang dikelola',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Label seksi ────────────────────────────────────────────────────────

  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          const Icon(Icons.format_list_bulleted_rounded,
              size: 14, color: AppColors.primaryContainer),
          const SizedBox(width: 6),
          Text(
            'BANK SAMPAH SAYA',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.primaryContainer,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(height: 1, color: const Color(0xFFC8E6C9)),
          ),
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: controller.fetchBankSampahSaya,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: AppColors.primary,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Belum terhubung',
                style: AppTextStyles.titleLg,
              ),
              const SizedBox(height: 10),
              Text(
                'Akun Anda belum terhubung dengan bank sampah manapun. Hubungi pihak kelurahan untuk mendapatkan akses.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 160,
                child: ElevatedButton.icon(
                  onPressed: controller.fetchBankSampahSaya,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Muat Ulang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card bank sampah ─────────────────────────────────────────────────────────

class _BankSampahCard extends StatelessWidget {
  final BankSampahModel bank;
  final bool isSelected;
  final VoidCallback onTap;

  const _BankSampahCard({
    required this.bank,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF8FDF9)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : const Color(0xFFE0F0E4),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: isSelected ? 14 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Aksen kiri ──────────────────────────────────────────────
            if (isSelected)
              Container(
                width: 4,
                height: 52,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

            // ── Ikon ────────────────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : const Color(0xFFEAF5EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.storefront_rounded,
                size: 22,
                color: isSelected ? Colors.white : AppColors.primaryContainer,
              ),
            ),

            const SizedBox(width: 12),

            // ── Info ─────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bank.nama,
                    style: AppTextStyles.titleMd.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onBackground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: isSelected
                            ? AppColors.primaryContainer
                            : AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          [
                            if (bank.rt != null) 'RT ${bank.rt}',
                            if (bank.rw != null) 'RW ${bank.rw}',
                            if (bank.alamat != null &&
                                bank.alamat!.isNotEmpty)
                              bank.alamat!,
                          ].join(' • '),
                          style: AppTextStyles.labelSm.copyWith(
                            color: isSelected
                                ? AppColors.primaryContainer
                                : AppColors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Badge + chevron ───────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFEAF5EC),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    isSelected ? 'Aktif' : 'Pilih',
                    style: AppTextStyles.labelSm.copyWith(
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white
                          : AppColors.primaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Painter: daun dekoratif di header ────────────────────────────────────────

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    // Bentuk daun utama
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.06);
    path.cubicTo(
      size.width * 0.78, size.height * 0.06,
      size.width * 0.95, size.height * 0.28,
      size.width * 0.89, size.height * 0.56,
    );
    path.cubicTo(
      size.width * 0.83, size.height * 0.78,
      size.width * 0.61, size.height * 0.90,
      size.width * 0.39, size.height * 0.81,
    );
    path.cubicTo(
      size.width * 0.17, size.height * 0.71,
      size.width * 0.09, size.height * 0.50,
      size.width * 0.17, size.height * 0.28,
    );
    path.cubicTo(
      size.width * 0.24, size.height * 0.09,
      size.width * 0.39, size.height * 0.06,
      size.width * 0.5, size.height * 0.06,
    );
    canvas.drawPath(path, paint);

    // Tulang daun tengah
    final stem = Path();
    stem.moveTo(size.width * 0.5, size.height * 0.06);
    stem.lineTo(size.width * 0.45, size.height * 0.95);
    canvas.drawPath(stem, linePaint);

    // Urat daun kanan
    final v1 = Path();
    v1.moveTo(size.width * 0.48, size.height * 0.22);
    v1.cubicTo(
      size.width * 0.60, size.height * 0.27,
      size.width * 0.70, size.height * 0.35,
      size.width * 0.75, size.height * 0.47,
    );
    canvas.drawPath(v1, linePaint);

    final v2 = Path();
    v2.moveTo(size.width * 0.47, size.height * 0.40);
    v2.cubicTo(
      size.width * 0.57, size.height * 0.44,
      size.width * 0.64, size.height * 0.51,
      size.width * 0.68, size.height * 0.60,
    );
    canvas.drawPath(v2, linePaint);

    // Urat daun kiri
    final v3 = Path();
    v3.moveTo(size.width * 0.48, size.height * 0.22);
    v3.cubicTo(
      size.width * 0.36, size.height * 0.27,
      size.width * 0.26, size.height * 0.36,
      size.width * 0.22, size.height * 0.47,
    );
    canvas.drawPath(v3, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Painter: pattern organik di background body ───────────────────────────────

class _OrganicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const baseColor = Color(0xFF216140);

    final blobPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    // Blob besar kanan atas
    final b1 = Path();
    b1.addOval(Rect.fromCenter(
      center: Offset(size.width * 0.92, size.height * 0.08),
      width: 120,
      height: 120,
    ));
    canvas.drawPath(b1, blobPaint);

    // Blob kiri tengah
    final b2 = Path();
    b2.addOval(Rect.fromCenter(
      center: Offset(size.width * -0.03, size.height * 0.42),
      width: 160,
      height: 160,
    ));
    canvas.drawPath(b2, blobPaint..color = baseColor.withValues(alpha: 0.03));

    // Blob bawah tengah
    final b3 = Path();
    b3.addOval(Rect.fromCenter(
      center: Offset(size.width * 0.58, size.height * 0.88),
      width: 140,
      height: 140,
    ));
    canvas.drawPath(b3, blobPaint..color = baseColor.withValues(alpha: 0.04));

    final leafPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    final leafLinePaint = Paint()
      ..color = baseColor.withValues(alpha: 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    // Daun mini pojok kanan atas
    _drawMiniLeaf(canvas, Offset(size.width * 0.77, 60), 52, leafPaint, leafLinePaint);

    // Daun mini pojok kiri bawah
    _drawMiniLeaf(canvas, Offset(20, size.height * 0.72), 42, leafPaint, leafLinePaint);

    // Daun mini kanan bawah
    _drawMiniLeaf(canvas, Offset(size.width * 0.85, size.height * 0.60), 36, leafPaint, leafLinePaint);

    // Dot grid kecil di bagian tengah atas
    final dotPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 4; col++) {
        canvas.drawCircle(
          Offset(
            size.width * 0.38 + col * 16.0,
            18 + row * 14.0,
          ),
          2.5,
          dotPaint..color = baseColor.withValues(alpha: 0.10 - row * 0.02),
        );
      }
    }
  }

  void _drawMiniLeaf(
    Canvas canvas,
    Offset center,
    double size,
    Paint fill,
    Paint stroke,
  ) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size * 0.44);
    path.cubicTo(
      center.dx + size * 0.30, center.dy - size * 0.44,
      center.dx + size * 0.45, center.dy - size * 0.16,
      center.dx + size * 0.40, center.dy + size * 0.12,
    );
    path.cubicTo(
      center.dx + size * 0.35, center.dy + size * 0.35,
      center.dx + size * 0.12, center.dy + size * 0.44,
      center.dx - size * 0.08, center.dy + size * 0.36,
    );
    path.cubicTo(
      center.dx - size * 0.28, center.dy + size * 0.22,
      center.dx - size * 0.34, center.dy - size * 0.04,
      center.dx - size * 0.24, center.dy - size * 0.24,
    );
    path.cubicTo(
      center.dx - size * 0.14, center.dy - size * 0.40,
      center.dx - size * 0.05, center.dy - size * 0.44,
      center.dx, center.dy - size * 0.44,
    );
    canvas.drawPath(path, fill);

    // Tulang daun
    final stem = Path();
    stem.moveTo(center.dx, center.dy - size * 0.44);
    stem.lineTo(center.dx - size * 0.05, center.dy + size * 0.44);
    canvas.drawPath(stem, stroke);

    // Satu urat
    final vein = Path();
    vein.moveTo(center.dx - size * 0.02, center.dy - size * 0.10);
    vein.cubicTo(
      center.dx + size * 0.18, center.dy,
      center.dx + size * 0.28, center.dy + size * 0.18,
      center.dx + size * 0.28, center.dy + size * 0.28,
    );
    canvas.drawPath(vein, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}