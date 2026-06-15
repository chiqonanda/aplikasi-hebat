import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/pengelola/dashboard_controller.dart';
import '../../controllers/pengelola/pengelola_main_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/pengelolaan_sampah_model.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: controller.fetchDashboardData,
        color: AppColors.pengelolaMain,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ─────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(context)),

            // ── Statistik ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Obx(() => _buildStatistikRow()),
              ),
            ),

            // ── Menu Utama ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildQuickActionMenu(),
              ),
            ),

            // ── Aktivitas Header ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aktivitas Terbaru',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Riwayat pencatatan sampah',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        if (Get.isRegistered<PengelolaMainController>()) {
                          Get.find<PengelolaMainController>().changePage(1);
                        } else {
                          Get.toNamed(AppRoutes.historiSampah);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E7D32)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Aktivitas List ─────────────────────────────────
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: LoadingWidget(
                        message: 'Memuat aktivitas terbaru...'),
                  ),
                );
              }
              if (controller.aktivitasTerbaru.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: EmptyState(
                      message: 'Belum Ada Data',
                      subtitle: 'Mulai input data sampah sekarang.',
                      icon: Icons.inbox_outlined,
                      actionLabel: 'Input Data',
                      onAction: () => Get.toNamed(AppRoutes.inputSampah),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = controller.aktivitasTerbaru[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: _AktivitasCard(item: item, index: index),
                    );
                  },
                  childCount: controller.aktivitasTerbaru.length,
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // ── Background wave ──────────────────────────────────
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 240),
          painter: _WavePainter(),
        ),

        // ── Decorative circles ───────────────────────────────
        Positioned(
          top: -30,
          right: -20,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: 50,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),

        // ── Content ──────────────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  children: [
                    // Logo + title
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BISA',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'Dashboard Pengelola',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action buttons
                    _HeaderIconBtn(
                      icon: Icons.store_outlined,
                      onTap: () {
                        if (Get.isRegistered<PengelolaMainController>()) {
                          Get.find<PengelolaMainController>().changePage(3);
                        } else {
                          Get.toNamed(AppRoutes.profilBankSampah);
                        }
                      },
                      tooltip: 'Profil Bank Sampah',
                    ),
                    const SizedBox(width: 8),
                    _HeaderIconBtn(
                      icon: Icons.swap_horiz_rounded,
                      onTap: () => Get.toNamed(AppRoutes.pilihBankSampah),
                      tooltip: 'Ganti Bank Sampah',
                    ),
                    const SizedBox(width: 8),
                    _HeaderIconBtn(
                      icon: Icons.logout_rounded,
                      onTap: () => Get.find<AuthController>().logout(),
                      tooltip: 'Keluar',
                      isDestructive: true,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Greeting
                Text(
                  'Selamat Datang,',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.penggunaNama,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Bank sampah badge
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF69F0AE),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.store_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            controller.bankSampahNama,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Statistik Row ─────────────────────────────────────────────────────────

  Widget _buildStatistikRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Ringkasan Bulan Ini',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Baris 1: Transaksi & Total Nilai
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Transaksi',
                sublabel: 'Bulan Ini',
                value:
                    controller.totalTransaksiBulanIni.value.toString(),
                satuan: 'entri',
                icon: Icons.receipt_long_outlined,
                gradientColors: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
                iconBg: const Color(0xFF0D47A1),
                height: 115,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Total Nilai',
                sublabel: 'Bulan Ini',
                value: FormatHelper.currency(
                    controller.totalNilaiBulanIni.value),
                satuan: '',
                icon: Icons.payments_outlined,
                gradientColors: const [Color(0xFFE65100), Color(0xFFFF7043)],
                iconBg: const Color(0xFFBF360C),
                height: 115,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Baris 2: Sampah Padat, Cair, Satuan
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Sampah Padat',
                sublabel: 'Bulan Ini',
                value: FormatHelper.number(
                    controller.totalKgBulanIni.value),
                satuan: 'kg',
                icon: Icons.scale_outlined,
                gradientColors: const [Color(0xFF2E7D32), Color(0xFF43A047)],
                iconBg: const Color(0xFF1B5E20),
                height: 115,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Sampah Cair',
                sublabel: 'Bulan Ini',
                value: FormatHelper.number(
                    controller.totalLiterBulanIni.value),
                satuan: 'liter',
                icon: Icons.water_drop_rounded,
                gradientColors: const [Color(0xFF0277BD), Color(0xFF00ACC1)],
                iconBg: const Color(0xFF01579B),
                height: 115,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Satuan',
                sublabel: 'Bulan Ini',
                value: FormatHelper.number(
                    controller.totalSatuanBulanIni.value),
                satuan: 'satuan',
                icon: Icons.category_outlined,
                gradientColors: const [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                iconBg: const Color(0xFF4A148C),
                height: 115,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Quick Action Menu ─────────────────────────────────────────────────────

  Widget _buildQuickActionMenu() {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.add_circle_outline_rounded,
        'label': 'Input Data',
        'color': AppColors.pengelolaMain,
        'bgColor': AppColors.pengelolaLight,
        'onTap': () => controller.goToInputSampah(),
      },
      {
        'icon': Icons.assignment_outlined,
        'label': 'Histori',
        'color': const Color(0xFF1565C0),
        'bgColor': const Color(0xFFE3F2FD),
        'onTap': () {
          if (Get.isRegistered<PengelolaMainController>()) {
            Get.find<PengelolaMainController>().changePage(1);
          } else {
            Get.toNamed(AppRoutes.historiSampah);
          }
        },
      },
      {
        'icon': Icons.description_outlined,
        'label': 'Laporan',
        'color': const Color(0xFFE65100),
        'bgColor': const Color(0xFFFFF3E0),
        'onTap': () {
          if (Get.isRegistered<PengelolaMainController>()) {
            Get.find<PengelolaMainController>().changePage(2);
          }
        },
      },
      {
        'icon': Icons.storefront_rounded,
        'label': 'Profil',
        'color': const Color(0xFF6A1B9A),
        'bgColor': const Color(0xFFF3E5F5),
        'onTap': () {
          if (Get.isRegistered<PengelolaMainController>()) {
            Get.find<PengelolaMainController>().changePage(3);
          } else {
            Get.toNamed(AppRoutes.profilBankSampah);
          }
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Menu Utama',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        Row(
          children: menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Expanded(
              child: GestureDetector(
                onTap: item['onTap'] as VoidCallback,
                child: Container(
                  margin: EdgeInsets.only(
                    right: index == menuItems.length - 1 ? 0 : 10,
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border(
                      top: BorderSide(
                        color: item['color'] as Color,
                        width: 2,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (item['color'] as Color)
                            .withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: item['bgColor'] as Color,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['label'] as String,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Header Icon Button ────────────────────────────────────────────────────────

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool isDestructive;

  const _HeaderIconBtn({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white
                .withValues(alpha: isDestructive ? 0.08 : 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red.shade200 : Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ── Aktivitas Card ────────────────────────────────────────────────────────────

class _AktivitasCard extends StatelessWidget {
  final PengelolaanSampahModel item;
  final int index;

  const _AktivitasCard({required this.item, required this.index});

  static const _accents = [
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFFE65100),
    Color(0xFF6A1B9A),
  ];
  static const _accentBgs = [
    Color(0xFFE8F5E9),
    Color(0xFFE3F2FD),
    Color(0xFFFBE9E7),
    Color(0xFFF3E5F5),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _accents[index % _accents.length];
    final accentBg = _accentBgs[index % _accentBgs.length];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(color: accent, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.recycling_rounded,
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaItem,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                if (item.namaNasabah != null && item.namaNasabah!.isNotEmpty) ...[
                  Text(
                    'Nasabah: ${item.namaNasabah}',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      FormatHelper.dateFromString(
                        item.tanggalPengelolaan.toIso8601String(),
                      ),
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Jumlah badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              FormatHelper.jumlahSatuan(
                item.jumlah,
                item.satuan?.singkatan,
              ),
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wave Painter ──────────────────────────────────────────────────────────────

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path1 = Path()
      ..lineTo(0, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.95,
        size.width * 0.5,
        size.height * 0.82,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.68,
        size.width,
        size.height * 0.80,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = const Color(0xFF43A047).withValues(alpha: 0.3);

    final path2 = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.5,
        size.width * 0.55,
        size.height * 0.65,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.78,
        size.width,
        size.height * 0.62,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path2, paint2);

    final paintDot = Paint()
      ..color = Colors.white.withValues(alpha: 0.06);

    canvas.drawCircle(
        Offset(size.width * 0.12, size.height * 0.35), 45, paintDot);
    canvas.drawCircle(
        Offset(size.width * 0.88, size.height * 0.18), 28, paintDot);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => false;
}