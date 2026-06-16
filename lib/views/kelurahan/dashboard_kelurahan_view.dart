import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/design_tokens.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/kelurahan/dashboard_kelurahan_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/utils/tooltip_helper.dart';
import '../../core/widgets/app_widgets.dart';

class DashboardKelurahanView extends GetView<DashboardKelurahanController> {
  const DashboardKelurahanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      bottomNavigationBar: const KelurahanBottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchDashboardData,
          color: AppColors.kelurahanMain,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _buildStatGrid(),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: _buildMenuGrid(),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: _buildTopBankSampah(),
                ),

                // Aktivitas Terbaru Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Aktivitas Terbaru',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.kelurahanDark,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'Pengelolaan sampah hari ini',
                                style: AppTextStyles.bodySm.copyWith(
                                  fontFamily: 'PlusJakartaSans',
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.monitoringBankSampah),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.kelurahanMain.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
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

                // Aktivitas List
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: AppLoadingState(message: 'Memuat aktivitas terbaru...'),
                    );
                  }
                  if (controller.aktivitasTerbaru.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: const AppEmptyState(
                        title: 'Belum Ada Aktivitas',
                        subtitle: 'Belum ada aktivitas pengelolaan sampah untuk hari ini.',
                        icon: Icons.assignment_outlined,
                      ),
                    );
                  }
                  final limitCount = controller.aktivitasTerbaru.length > 3 ? 3 : controller.aktivitasTerbaru.length;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: limitCount,
                    itemBuilder: (context, index) {
                      final item = controller.aktivitasTerbaru[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: _AktivitasKelurahanCard(item: item, index: index),
                      );
                    },
                  );
                }),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header Widget ────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Wave painter background
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 195),
          painter: _WavePainter(),
        ),

        // Decorative circles
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

        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
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
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.eco_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
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
                          'Basis Informasi Sampah',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _HeaderIconBtn(
                    icon: Icons.person_outline_rounded,
                    onTap: () => Get.toNamed(AppRoutes.profilKelurahan),
                    tooltip: 'Profil',
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

              const SizedBox(height: 12),

              // Greeting
              Text(
                'Selamat Datang,',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
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

              const SizedBox(height: 10),

              // Kelurahan badge dengan dot
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
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
                      Icons.location_on_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      controller.namaKelurahan,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Stat Grid Widget ─────────────────────────────────────────────────────
  Widget _buildStatGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Volume Sampah Bulan Ini',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.kelurahanDark,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() => _WasteTypeCard(
              label: 'Sampah Padat',
              value: FormatHelper.number(controller.totalSampahPadat.value),
              unit: 'kg',
              icon: Icons.scale_rounded,
              iconColor: Colors.white,
              iconBgColor: const Color(0xFF388E3C),
            )),
        Obx(() => _WasteTypeCard(
              label: 'Sampah Cair',
              value: FormatHelper.number(controller.totalSampahCair.value),
              unit: 'liter',
              icon: Icons.water_drop_rounded,
              iconColor: Colors.white,
              iconBgColor: const Color(0xFF0288D1),
            )),
        Obx(() => _WasteTypeCard(
              label: 'Satuan',
              value: FormatHelper.number(controller.totalSampahSatuan.value),
              unit: 'satuan',
              icon: Icons.inventory_2_rounded,
              iconColor: Colors.white,
              iconBgColor: const Color(0xFF7B1FA2),
            )),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Kinerja & Statistik Wilayah',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.kelurahanDark,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Obx(() => _StatCard(
                      label: 'Bank Sampah',
                      sublabel: 'Aktif',
                      value: controller.totalBankSampahAktif.value.toString(),
                      satuan: 'unit',
                      icon: Icons.store_rounded,
                      gradientColors: const [Color(0xFF00838F), Color(0xFF00ACC1)],
                      iconBg: const Color(0xFF006064),
                    )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => _StatCard(
                      label: 'Total Transaksi',
                      sublabel: 'Bulan Ini',
                      value: controller.totalTransaksiBulanIni.value.toString(),
                      satuan: 'entri',
                      icon: Icons.receipt_long_outlined,
                      gradientColors: const [Color(0xFF283593), Color(0xFF5C6BC0)],
                      iconBg: const Color(0xFF1A237E),
                    )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => _StatCard(
              label: 'Nilai Total',
              sublabel: 'Bulan Ini',
              value: FormatHelper.currency(controller.totalNilaiBulanIni.value),
              satuan: '',
              icon: Icons.account_balance_wallet_outlined,
              gradientColors: const [Color(0xFF00695C), Color(0xFF26A69A)],
              iconBg: const Color(0xFF004D40),
            )),
      ],
    );
  }

  // ── Menu Grid Widget ─────────────────────────────────────────────────────
  Widget _buildMenuGrid() {
    final menus = [
      _MenuItem(
        icon: Icons.bar_chart_rounded,
        label: 'Monitoring',
        color: AppColors.kelurahanMain,
        bgColor: AppColors.kelurahanLight,
        onTap: () => Get.toNamed(AppRoutes.monitoringBankSampah),
      ),
      _MenuItem(
        icon: Icons.store_rounded,
        label: 'Bank Sampah',
        color: const Color(0xFF00ACC1),
        bgColor: const Color(0xFFE0F7FA),
        onTap: () => Get.toNamed(AppRoutes.manajemenBankSampah),
      ),
      _MenuItem(
        icon: Icons.people_outline_rounded,
        label: 'Pengelola',
        color: const Color(0xFF1565C0),
        bgColor: const Color(0xFFE3F2FD),
        onTap: () => Get.toNamed(AppRoutes.manajemenPengelola),
      ),
      _MenuItem(
        icon: Icons.category_outlined,
        label: 'Jenis Sampah',
        color: const Color(0xFF6A1B9A),
        bgColor: const Color(0xFFF3E5F5),
        onTap: () => Get.toNamed(AppRoutes.masterSampah),
      ),
      _MenuItem(
        icon: Icons.assessment_outlined,
        label: 'Laporan',
        color: const Color(0xFF00695C),
        bgColor: const Color(0xFFE0F2F1),
        onTap: () => Get.toNamed(AppRoutes.generatorLaporan),
      ),
      _MenuItem(
        icon: Icons.manage_accounts_outlined,
        label: 'Profil',
        color: const Color(0xFF37474F),
        bgColor: const Color(0xFFECEFF1),
        onTap: () => Get.toNamed(AppRoutes.profilKelurahan),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
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
                color: AppColors.kelurahanDark,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 24) / 3;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menus.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: itemWidth + 16,
              ),
              itemBuilder: (context, index) {
                return _MenuCard(item: menus[index]);
              },
            );
          },
        ),
      ],
    );
  }

  // ── Top Bank Sampah Widget ───────────────────────────────────────────────
  Widget _buildTopBankSampah() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Bank Sampah Teraktif',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.kelurahanDark,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (controller.topBankSampah.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: DesignTokens.shadowSm,
              ),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 36, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text(
                    'Belum ada data pengelolaan bulan ini',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: List.generate(controller.topBankSampah.length, (index) {
              final item = controller.topBankSampah[index];
              final rank = index + 1;

              Color rankColor;
              Color rankBg;
              if (rank == 1) {
                rankColor = const Color(0xFFFFA000);
                rankBg = const Color(0xFFFFF8E1);
              } else if (rank == 2) {
                rankColor = const Color(0xFF78909C);
                rankBg = const Color(0xFFECEFF1);
              } else {
                rankColor = const Color(0xFF8D6E63);
                rankBg = const Color(0xFFEFEBE9);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      left: BorderSide(color: rankColor, width: 3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: rankColor.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: rankBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: rankColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item['nama'] as String,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.kelurahanDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.kelurahanLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${FormatHelper.number(item['total'] as double)} kg',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.kelurahanMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }
}

// ── Header Action Button Widget ───────────────────────────────────────────
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

// ── Redesigned Stat Card Widget ───────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final String value;
  final String satuan;
  final IconData icon;
  final List<Color> gradientColors;
  final Color iconBg;

  const _StatCard({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.satuan,
    required this.icon,
    required this.gradientColors,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Icon Container
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),

            // Value
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.kelurahanDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (satuan.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        satuan,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Label + Sublabel
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.kelurahanDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              sublabel,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Menu Item Data Class ─────────────────────────────────────────────────
class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
}

// ── Redesigned Menu Card Widget ──────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final _MenuItem item;

  const _MenuCard({required this.item});

  void _showTooltip() {
    final title = item.label;
    String description = '';
    switch (item.label) {
      case 'Monitoring':
        description = 'Pantau aktivitas semua bank sampah dalam kelurahan';
        break;
      case 'Bank Sampah':
        description = 'Kelola informasi dan status keaktifan bank sampah';
        break;
      case 'Pengelola':
        description = 'Kelola akun petugas pengelola bank sampah';
        break;
      case 'Jenis Sampah':
        description = 'Kelola kategori, jenis, dan satuan sampah';
        break;
      case 'Laporan':
        description = 'Generate dan export laporan dalam format Excel atau CSV';
        break;
      case 'Profil':
        description = 'Atur profil kelurahan Anda';
        break;
      default:
        description = 'Keterangan fitur belum ditambahkan.';
    }
    showFeatureTooltip(title, description);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      onLongPress: _showTooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            top: BorderSide(color: item.color, width: 2),
          ),
          boxShadow: [
            BoxShadow(
              color: item.color.withValues(alpha: 0.08),
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
                color: item.bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.kelurahanDark,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Redesigned Aktivitas Card Widget ─────────────────────────────────────
class _AktivitasKelurahanCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;

  const _AktivitasKelurahanCard({required this.item, required this.index});

  static const _accents = [
    Color(0xFF1565C0),
    Color(0xFF00838F),
    Color(0xFF6A1B9A),
    Color(0xFF2E7D32),
  ];
  static const _accentBgs = [
    Color(0xFFE3F2FD),
    Color(0xFFE0F7FA),
    Color(0xFFF3E5F5),
    Color(0xFFE8F5E9),
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.store_rounded,
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['bank_nama'] ?? '-',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.kelurahanDark,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item['jenis_nama'] ?? '-',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 11, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      FormatHelper.dateFromString(item['tanggal'] ?? ''),
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              FormatHelper.jumlahSatuan(
                item['jumlah'],
                item['satuan_singkatan'],
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
        colors: AppColors.kelurahanGradient,
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
      ..color = const Color(0xFF42A5F5).withValues(alpha: 0.3);

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

class _WasteTypeCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const _WasteTypeCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3.5,
                color: iconBgColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: iconBgColor.withValues(alpha: 0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              icon,
                              color: iconColor,
                              size: 15,
                            ),
                          ),
                          Text(
                            'Bulan Ini',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            value,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            unit,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
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
    );
  }
}