import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../core/widgets/motion.dart';
import '../../core/widgets/wave_painter.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PullToRefresh(
        onRefresh: controller.fetchDashboardData,
        color: AppColors.pengelolaMain,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ─────────────────────────────────────────
            SliverToBoxAdapter(child: StaggeredEntrance(index: 0, child: _buildHeader(context))),

            // ── Statistik — ditarik naik menimpa wave ──────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Transform.translate(
                  offset: const Offset(0, -34),
                  child: StaggeredEntrance(
                    index: 1,
                    child: Obx(
                      () => controller.isFirstLoad.value
                          ? const _StatistikSkeleton()
                          : _buildStatistikRow(),
                    ),
                  ),
                ),
              ),
            ),

            // ── Menu Utama ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Transform.translate(
                  offset: const Offset(0, -18),
                  child: StaggeredEntrance(
                    index: 2,
                    child: _buildQuickActionMenu(),
                  ),
                ),
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
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(() => AnimatedValue(
                              value: controller.totalTransaksiHariIni.value
                                  .toDouble(),
                              builder: (v) => Text(
                                '${FormatHelper.number(v)} transaksi hari ini',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            )),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        if (Get.isRegistered<PengelolaMainController>()) {
                          Get.find<PengelolaMainController>()
                              .changePage(PengelolaTab.histori);
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
                            colors: [AppColors.pengelolaMain, AppColors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.pengelolaMain
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
              if (controller.isFirstLoad.value) {
                return const SliverToBoxAdapter(child: _AktivitasSkeleton());
              }
              if (controller.hasError.value) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: EmptyState(
                      message: 'Gagal Memuat Data',
                      subtitle:
                          'Terjadi kesalahan saat mengambil data dashboard. '
                          'Periksa koneksi internet Anda lalu coba lagi.',
                      icon: Icons.cloud_off_rounded,
                      actionLabel: 'Coba Lagi',
                      onAction: controller.fetchDashboardData,
                    ),
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
          size: Size(MediaQuery.of(context).size.width, 290),
          painter: WavePainter.green(),
        ),
        const AmbientBlob(color: Color(0x14FFFFFF), size: 220),

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
                          Get.find<PengelolaMainController>()
                              .changePage(PengelolaTab.profil);
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
                            color: AppColors.mintAccent,
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
                  colors: [AppColors.pengelolaMain, AppColors.secondary],
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
                color: AppColors.textPrimary,
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
                value: '', valueWidget: _animInt(controller.totalTransaksiBulanIni.value),
                satuan: 'entri',
                icon: Icons.receipt_long_outlined,
                gradientColors: const [AppColors.blueDeep, AppColors.kelurahanAccent],
                iconBg: const Color(0xFF0D47A1),
                height: 115,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Total Nilai',
                sublabel: 'Bulan Ini',
                value: '',
                valueWidget: _animDouble(
                  controller.totalNilaiBulanIni.value,
                  format: FormatHelper.currency,
                ),
                satuan: '',
                icon: Icons.payments_outlined,
                gradientColors: const [AppColors.orange, Color(0xFFFF7043)],
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
                value: '',
                valueWidget: _animDouble(
                  controller.totalKgBulanIni.value,
                  format: FormatHelper.number,
                ),
                satuan: 'kg',
                icon: Icons.scale_outlined,
                gradientColors: const [AppColors.pengelolaMain, AppColors.secondary],
                iconBg: AppColors.pengelolaDark,
                height: 115,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Sampah Cair',
                sublabel: 'Bulan Ini',
                value: '',
                valueWidget: _animDouble(
                  controller.totalLiterBulanIni.value,
                  format: FormatHelper.number,
                ),
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
                value: '',
                valueWidget: _animDouble(
                  controller.totalSatuanBulanIni.value,
                  format: FormatHelper.number,
                ),
                satuan: 'satuan',
                icon: Icons.category_outlined,
                gradientColors: const [AppColors.purple, Color(0xFF8E24AA)],
                iconBg: const Color(0xFF4A148C),
                height: 115,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Count-up helpers (angka statistik beranimasi) ──────────────────────────

  /// Animasi count-up untuk nilai int (jumlah transaksi).
  Widget _animInt(int target) {
    return AnimatedValue.formatted(
      value: target.toDouble(),
      format: (v) => v.round().toString(),
    );
  }

  /// Animasi count-up untuk nilai double (kg, liter, rupiah).
  Widget _animDouble(double target, {required String Function(num) format}) {
    return AnimatedValue.formatted(value: target, format: format);
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
        'color': AppColors.blueDeep,
        'bgColor': AppColors.kelurahanLight,
        'onTap': () {
          if (Get.isRegistered<PengelolaMainController>()) {
            Get.find<PengelolaMainController>().changePage(PengelolaTab.histori);
          } else {
            Get.toNamed(AppRoutes.historiSampah);
          }
        },
      },
      {
        'icon': Icons.description_outlined,
        'label': 'Laporan',
        'color': AppColors.orange,
        'bgColor': AppColors.orangeContainer,
        'onTap': () {
          if (Get.isRegistered<PengelolaMainController>()) {
            Get.find<PengelolaMainController>()
                .changePage(PengelolaTab.laporan);
          }
        },
      },
      {
        'icon': Icons.storefront_rounded,
        'label': 'Profil',
        'color': AppColors.purple,
        'bgColor': AppColors.purpleLight,
        'onTap': () {
          if (Get.isRegistered<PengelolaMainController>()) {
            Get.find<PengelolaMainController>()
                .changePage(PengelolaTab.profil);
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
                  colors: [AppColors.pengelolaMain, AppColors.secondary],
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
                color: AppColors.textPrimary,
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
              child: PressableScale(
                onTap: () {
                  HapticFeedback.lightImpact();
                  (item['onTap'] as VoidCallback)();
                },
                pressedScale: 0.93,
                splashColor: (item['color'] as Color).withValues(alpha: 0.06),
                borderRadius: 18,
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
                          color: AppColors.textPrimary,
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
    AppColors.pengelolaMain,
    AppColors.blueDeep,
    AppColors.orange,
    AppColors.purple,
  ];
  static const _accentBgs = [
    AppColors.pengelolaLight,
    AppColors.kelurahanLight,
    AppColors.orangeLight,
    AppColors.purpleLight,
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
                    color: AppColors.textPrimary,
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
}// ── Skeleton: Statistik ───────────────────────────────────────────────────────

class _StatistikSkeleton extends StatelessWidget {
  const _StatistikSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar({double? width, double height = 16}) => Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
        );

    Widget statCard() => Container(
          height: 115,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Spacer(),
              bar(width: 60, height: 10),
              const SizedBox(height: 8),
              bar(width: 90, height: 14),
            ],
          ),
        );

    return ShimmerLoading(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(width: 160, height: 18),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: statCard()),
              const SizedBox(width: 10),
              Expanded(child: statCard()),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: statCard()),
              const SizedBox(width: 10),
              Expanded(child: statCard()),
              const SizedBox(width: 10),
              Expanded(child: statCard()),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Skeleton: Aktivitas ──────────────────────────────────────────────────────

class _AktivitasSkeleton extends StatelessWidget {
  const _AktivitasSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 13,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 10,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 56,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

