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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchDashboardData,
          color: AppColors.pengelolaMain,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(child: _buildHeader()),

              // Statistik cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Obx(() => _buildStatistikRow()),
                ),
              ),

              // Tombol CTA Input Sampah Full-Width
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildInputSampahCTA(),
                ),
              ),

              // Aktivitas terbaru header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aktivitas Terbaru',
                            style: AppTextStyles.titleLg,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Riwayat pengelolaan sampah',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
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
                            color: AppColors.pengelolaLight,
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.pengelolaMain,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: AppColors.pengelolaMain,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Aktivitas list
              Obx(() {
                if (controller.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: LoadingWidget(message: 'Memuat aktivitas terbaru...'),
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
                        child: _AktivitasCard(item: item),
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
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final context = Get.context!;
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.pengelolaGradient,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            children: [
              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BISA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Dashboard Pengelola',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.75),
                        letterSpacing: 0.3,
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

          // Greeting "Selamat Datang, [Nama]"
          Obx(
            () => Text(
              'Selamat Datang, ${controller.penggunaNama}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Lencana Nama Bank Sampah yang Aktif
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.store_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      controller.bankSampahNama,
                      style: const TextStyle(
                        fontSize: 14,
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
    );
  }

  Widget _buildInputSampahCTA() {
    return GestureDetector(
      onTap: controller.goToInputSampah,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.pengelolaGradient,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.pengelolaMain.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Input Data Sampah Baru',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Statistik Row ────────────────────────────────────────────────────────

  Widget _buildStatistikRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 14),
          child: Text(
            'Ringkasan Bulan Ini',
            style: AppTextStyles.titleLg,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              SizedBox(
                width: 135,
                child: StatCard(
                  label: 'Transaksi',
                  sublabel: 'Bulan Ini',
                  value: controller.totalTransaksiBulanIni.value.toString(),
                  satuan: 'entri',
                  icon: Icons.receipt_long_outlined,
                  gradientColors: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  iconBg: const Color(0xFF0D47A1),
                  height: 125,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 135,
                child: StatCard(
                  label: 'Total Nilai',
                  sublabel: 'Bulan Ini',
                  value: FormatHelper.currency(
                      controller.totalNilaiBulanIni.value),
                  satuan: '',
                  icon: Icons.payments_outlined,
                  gradientColors: const [Color(0xFFE65100), Color(0xFFFF7043)],
                  iconBg: const Color(0xFFBF360C),
                  height: 125,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 135,
                child: StatCard(
                  label: 'Sampah Padat',
                  sublabel: 'Bulan Ini',
                  value: FormatHelper.number(
                      controller.totalKgBulanIni.value),
                  satuan: 'kg',
                  icon: Icons.scale_outlined,
                  gradientColors: const [Color(0xFF2E7D32), Color(0xFF43A047)],
                  iconBg: const Color(0xFF1B5E20),
                  height: 125,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 135,
                child: StatCard(
                  label: 'Sampah Cair',
                  sublabel: 'Bulan Ini',
                  value: FormatHelper.number(
                      controller.totalLiterBulanIni.value),
                  satuan: 'liter',
                  icon: Icons.water_drop_rounded,
                  gradientColors: const [Color(0xFF0277BD), Color(0xFF00ACC1)],
                  iconBg: const Color(0xFF01579B),
                  height: 125,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 135,
                child: StatCard(
                  label: 'Sampah Satuan',
                  sublabel: 'Bulan Ini',
                  value: FormatHelper.number(
                      controller.totalSatuanBulanIni.value),
                  satuan: 'satuan',
                  icon: Icons.category_outlined,
                  gradientColors: const [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                  iconBg: const Color(0xFF4A148C),
                  height: 125,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Header Icon Button
// ─────────────────────────────────────────

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
            color: Colors.white.withValues(alpha: isDestructive ? 0.08 : 0.15),
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

// ─────────────────────────────────────────


// ─────────────────────────────────────────
// Aktivitas Card
// ─────────────────────────────────────────

class _AktivitasCard extends StatelessWidget {
  final PengelolaanSampahModel item;

  const _AktivitasCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.pengelolaLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.recycling_rounded,
              color: AppColors.pengelolaMain,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaItem,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.breadcrumb,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      FormatHelper.dateFromString(
                        item.tanggalPengelolaan.toIso8601String(),
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pengelolaLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  FormatHelper.jumlahSatuan(
                    item.jumlah,
                    item.satuan?.singkatan,
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pengelolaMain,
                  ),
                ),
              ),
              if (item.totalHarga != null && item.totalHarga! > 0) ...[
                const SizedBox(height: 4),
                Text(
                  FormatHelper.currency(item.totalHarga),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}