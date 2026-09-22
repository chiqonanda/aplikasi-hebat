import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/design_tokens.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/kelurahan/dashboard_kelurahan_controller.dart';
import '../../core/widgets/exit_confirm.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/wave_painter.dart';
import 'widgets/dashboard_kelurahan_widgets.dart';

class DashboardKelurahanView extends GetView<DashboardKelurahanController> {
  const DashboardKelurahanView({super.key});

  @override
  Widget build(BuildContext context) {
    return ExitConfirmScope(
      child: Scaffold(
        backgroundColor: AppColors.backgroundKelurahan,
        bottomNavigationBar: const KelurahanBottomNavBar(currentIndex: 0),
        body: SafeArea(
          child: PullToRefresh(
            onRefresh: controller.fetchDashboardData,
            color: AppColors.kelurahanMain,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StaggeredEntrance(index: 0, child: _buildHeader(context)),

                  // ── Baris Filter Interaktif ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: StaggeredEntrance(
                      index: 1,
                      child: _buildFilterBar(context),
                    ),
                  ),

                  // ── Section Volume Sampah & Kartu Statistik ─────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: StaggeredEntrance(
                      index: 2,
                      child: _buildVolumeSection(context),
                    ),
                  ),

                  // ── Menu Utama Grid ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: StaggeredEntrance(
                      index: 3,
                      child: _buildMenuGrid(),
                    ),
                  ),

                  // ── Bank Sampah Teraktif ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: StaggeredEntrance(
                      index: 4,
                      child: _buildTopBankSampah(),
                    ),
                  ),

                  // ── Aktivitas Terbaru Header ────────────────────────────────
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
                                  colors: [
                                    AppColors.kelurahanMain,
                                    AppColors.kelurahanAccent
                                  ],
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
                                Obx(() => AnimatedValue(
                                      value: controller
                                          .totalTransaksiBulanIni.value
                                          .toDouble(),
                                      builder: (v) => Text(
                                        '${FormatHelper.number(v)} transaksi',
                                        style: AppTextStyles.bodySm.copyWith(
                                          fontFamily: 'PlusJakartaSans',
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () =>
                              Get.toNamed(AppRoutes.monitoringBankSampah),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.kelurahanMain,
                                  AppColors.kelurahanAccent
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.kelurahanMain
                                      .withValues(alpha: 0.3),
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
                        child: AppLoadingState(
                            message: 'Memuat aktivitas terbaru...'),
                      );
                    }
                    if (controller.aktivitasTerbaru.isEmpty) {
                      return const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: AppEmptyState(
                          title: 'Belum Ada Aktivitas',
                          subtitle:
                              'Belum ada aktivitas pengelolaan sampah untuk periode ini.',
                          icon: Icons.assignment_outlined,
                        ),
                      );
                    }
                    final limitCount = controller.aktivitasTerbaru.length > 3
                        ? 3
                        : controller.aktivitasTerbaru.length;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: limitCount,
                      itemBuilder: (context, index) {
                        final item = controller.aktivitasTerbaru[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child:
                              AktivitasKelurahanCard(item: item, index: index),
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
      ),
    );
  }

  // ── Header Widget (Fluid & Organik Wave Header) ─────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 245),
          painter: WavePainter.blue(),
        ),
        const AmbientBlob(color: Color(0x14FFFFFF), size: 220),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  HeaderIconBtn(
                    icon: Icons.person_outline_rounded,
                    onTap: () => Get.toNamed(AppRoutes.profilKelurahan),
                    tooltip: 'Profil',
                  ),
                  const SizedBox(width: 8),
                  HeaderIconBtn(
                    icon: Icons.logout_rounded,
                    onTap: () => Get.find<AuthController>().logout(),
                    tooltip: 'Keluar',
                    isDestructive: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                        color: AppColors.mintAccent,
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

  // ── Filter Bar ───────────────────────────────────────────────────────────
  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: DesignTokens.shadowSm,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // 1. Filter Waktu / Periode
          Expanded(
            child: Obx(() => _FilterChipButton(
                  icon: Icons.calendar_today_rounded,
                  label: controller.filterPeriodLabel,
                  onTap: () => _showPeriodPickerSheet(context),
                )),
          ),
          const SizedBox(width: 8),

          // 2. Filter Bank Sampah
          Expanded(
            child: Obx(() => _FilterChipButton(
                  icon: Icons.storefront_rounded,
                  label: controller.filterBankLabel,
                  onTap: () => _showBankSampahSheet(context),
                )),
          ),
          const SizedBox(width: 8),

          // 3. Tombol Reset / Refresh
          InkWell(
            onTap: controller.resetFilters,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Volume Sampah & Seluruh Kartu Statistik Berformat Sama ───────
  Widget _buildVolumeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header dengan Badge "Data Terverifikasi"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.kelurahanMain,
                        AppColors.kelurahanAccent
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Volume Sampah Bulan Ini',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.kelurahanDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            // Badge Lencana "Data Terverifikasi"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFB2DFDB), width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 13,
                    color: Color(0xFF00897B),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Data Terverifikasi',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF00897B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 1. TOTAL TIMBULAN TERKELOLA
        Obx(() => _TimbulanCard(
              value: controller.totalTimbulanTon.value,
            )),
        const SizedBox(height: 12),

        // 2. Sampah Padat
        Obx(() => _SampahPadatCard(
              totalPadat: controller.totalSampahPadat.value,
              anorganik: controller.totalSampahPadatAnorganik.value,
              organik: controller.totalSampahPadatOrganik.value,
            )),
        const SizedBox(height: 12),

        // 3. Sampah Cair (Format persis Sampah Padat)
        Obx(() => _FullDetailStatCard(
              label: 'Sampah Cair',
              topBadgeText: 'Bulan Ini',
              value: controller.totalSampahCair.value,
              unit: 'liter',
              icon: Icons.water_drop_rounded,
              accentColor: const Color(0xFF0288D1),
              iconBgColor: const Color(0xFFE1F5FE),
              leftDetailLabel: 'Minyak Jelantah & Cairan',
              rightDetailLabel: 'Terkelola',
            )),
        const SizedBox(height: 12),

        // 4. Satuan (Format persis Sampah Padat)
        Obx(() => _FullDetailStatCard(
              label: 'Satuan',
              topBadgeText: 'Bulan Ini',
              value: controller.totalSampahSatuan.value,
              unit: 'satuan',
              icon: Icons.inventory_2_rounded,
              accentColor: const Color(0xFF7B1FA2),
              iconBgColor: const Color(0xFFF3E5F5),
              leftDetailLabel: 'Kemasan / Non-Berat',
              rightDetailLabel: 'Terkelola',
            )),

        const SizedBox(height: 24),

        // ── Kinerja & Statistik Wilayah ─────────────────────────────────────
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.kelurahanMain, AppColors.kelurahanAccent],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Kinerja & Statistik Wilayah',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.kelurahanDark,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 5. Bank Sampah (Format persis Sampah Padat)
        Obx(() => _FullDetailStatCard(
              label: 'Bank Sampah',
              topBadgeText: 'Aktif Wilayah',
              value: controller.totalBankSampahAktif.value.toDouble(),
              unit: 'unit',
              icon: Icons.store_rounded,
              accentColor: const Color(0xFF00ACC1),
              iconBgColor: const Color(0xFFE0F7FA),
              leftDetailLabel:
                  'Total Terdaftar: ${controller.totalBankSampah.value} unit',
              rightDetailLabel: 'Aktif Beroperasi',
              isInt: true,
            )),
        const SizedBox(height: 12),

        // 6. Total Transaksi (Format persis Sampah Padat)
        Obx(() => _FullDetailStatCard(
              label: 'Total Transaksi',
              topBadgeText: 'Bulan Ini',
              value: controller.totalTransaksiBulanIni.value.toDouble(),
              unit: 'entri',
              icon: Icons.receipt_long_rounded,
              accentColor: const Color(0xFF3F51B5),
              iconBgColor: const Color(0xFFE8EAF6),
              leftDetailLabel: 'Pencatatan Masuk',
              rightDetailLabel: 'Terverifikasi',
              isInt: true,
            )),
        const SizedBox(height: 12),

        // 7. Nilai Total (Format persis Sampah Padat)
        Obx(() => _FullDetailStatCard(
              label: 'Nilai Total',
              topBadgeText: 'Bulan Ini',
              value: controller.totalNilaiBulanIni.value,
              unit: '',
              icon: Icons.account_balance_wallet_rounded,
              accentColor: const Color(0xFF00695C),
              iconBgColor: const Color(0xFFE0F2F1),
              leftDetailLabel: 'Akumulasi Tabungan Sampah',
              rightDetailLabel: 'Tercatat',
              isCurrency: true,
            )),
      ],
    );
  }

  // ── Menu Grid Widget ─────────────────────────────────────────────────────
  Widget _buildMenuGrid() {
    final menus = [
      MenuItem(
        icon: Icons.bar_chart_rounded,
        label: 'Monitoring',
        color: AppColors.kelurahanMain,
        bgColor: AppColors.kelurahanLight,
        onTap: () => Get.toNamed(AppRoutes.monitoringBankSampah),
      ),
      MenuItem(
        icon: Icons.store_rounded,
        label: 'Bank Sampah',
        color: const Color(0xFF00ACC1),
        bgColor: AppColors.tealLight,
        onTap: () => Get.toNamed(AppRoutes.manajemenBankSampah),
      ),
      MenuItem(
        icon: Icons.people_outline_rounded,
        label: 'Pengelola',
        color: AppColors.blueDeep,
        bgColor: AppColors.kelurahanLight,
        onTap: () => Get.toNamed(AppRoutes.manajemenPengelola),
      ),
      MenuItem(
        icon: Icons.category_outlined,
        label: 'Jenis Sampah',
        color: AppColors.purple,
        bgColor: AppColors.purpleLight,
        onTap: () => Get.toNamed(AppRoutes.masterSampah),
      ),
      MenuItem(
        icon: Icons.assessment_outlined,
        label: 'Laporan',
        color: AppColors.tealDark,
        bgColor: AppColors.tealContainer,
        onTap: () => Get.toNamed(AppRoutes.generatorLaporan),
      ),
      MenuItem(
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
                  colors: [AppColors.kelurahanMain, AppColors.kelurahanAccent],
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
                return MenuCard(item: menus[index]);
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
                  colors: [AppColors.kelurahanMain, AppColors.kelurahanAccent],
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
              padding:
                  const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: DesignTokens.shadowSm,
              ),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 36, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text(
                    'Belum ada data pengelolaan pada periode ini',
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
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

  // ── Bottom Sheets Filter ──────────────────────────────────────────────────

  void _showBankSampahSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Bank Sampah',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.kelurahanDark,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Opsi 1: Semua Bank Sampah
                  Obx(() {
                    final isSelected = controller.selectedBankSampahId.value == null;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: isSelected
                          ? AppColors.kelurahanLight
                          : Colors.transparent,
                      leading: Icon(
                        Icons.storefront_rounded,
                        color: isSelected
                            ? AppColors.kelurahanMain
                            : Colors.grey.shade600,
                      ),
                      title: Text(
                        'Semua Bank Sampah',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? AppColors.kelurahanMain
                              : AppColors.kelurahanDark,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppColors.kelurahanMain)
                          : null,
                      onTap: () {
                        controller.setBankSampahFilter(null);
                        Get.back();
                      },
                    );
                  }),
                  const Divider(height: 1),

                  // Opsi List Bank Sampah Aktif
                  ...controller.bankSampahAktif.map((bank) {
                    return Obx(() {
                      final isSelected =
                          controller.selectedBankSampahId.value == bank.id;
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: isSelected
                            ? AppColors.kelurahanLight
                            : Colors.transparent,
                        leading: Icon(
                          Icons.store_rounded,
                          color: isSelected
                              ? AppColors.kelurahanMain
                              : Colors.grey.shade600,
                        ),
                        title: Text(
                          bank.namaLengkap,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? AppColors.kelurahanMain
                                : AppColors.kelurahanDark,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppColors.kelurahanMain)
                            : null,
                        onTap: () {
                          controller.setBankSampahFilter(bank.id);
                          Get.back();
                        },
                      );
                    });
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPeriodPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Periode Waktu',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.kelurahanDark,
              ),
            ),
            const SizedBox(height: 14),

            // Opsi 1: Bulan Ini
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(Icons.calendar_month_rounded,
                  color: AppColors.kelurahanMain),
              title: const Text(
                'Bulan Ini',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kelurahanDark,
                ),
              ),
              subtitle: const Text('Tampilkan data bulan berjalan'),
              onTap: () {
                final now = DateTime.now();
                controller.setMonthFilter(now.year, now.month);
                Get.back();
              },
            ),

            // Opsi 2: Bulan Lalu
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(Icons.history_toggle_off_rounded,
                  color: AppColors.indigo),
              title: const Text(
                'Bulan Lalu',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kelurahanDark,
                ),
              ),
              subtitle: const Text('Tampilkan data 1 bulan sebelumnya'),
              onTap: () {
                final now = DateTime.now();
                final prevMonth = DateTime(now.year, now.month - 1, 1);
                controller.setMonthFilter(prevMonth.year, prevMonth.month);
                Get.back();
              },
            ),

            // Opsi 3: Rentang Tanggal Spesifik
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(Icons.date_range_rounded,
                  color: AppColors.teal),
              title: const Text(
                'Pilih Rentang Tanggal Spesifik...',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kelurahanDark,
                ),
              ),
              subtitle: const Text('Tentukan tanggal mulai dan akhir secara kustom'),
              onTap: () async {
                Get.back();
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDateRange: DateTimeRange(
                    start: controller.selectedStartDate.value,
                    end: controller.selectedEndDate.value,
                  ),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.kelurahanMain,
                          onPrimary: Colors.white,
                          onSurface: AppColors.kelurahanDark,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (range != null) {
                  controller.setDateRangeFilter(range.start, range.end);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET KARTU LOKAL & STYLING UNIFORM (SESUAI GAMBAR ACUAN SAMPAH PADAT)
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kelurahanDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card 1: TOTAL TIMBULAN TERKELOLA ──────────────────────────────────────
class _TimbulanCard extends StatelessWidget {
  final double value;

  const _TimbulanCard({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: const Border(
          top: BorderSide(color: Color(0xFF0D47A1), width: 3.5),
        ),
        boxShadow: DesignTokens.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAF6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete_sweep_rounded,
              color: Color(0xFF1A237E),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL TIMBULAN TERKELOLA',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AnimatedValue(
                      value: value,
                      builder: (v) => Text(
                        v.toStringAsFixed(1),
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.kelurahanDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Ton',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card 2: Sampah Padat dengan Breakdown Organik & Anorganik ────────────────
class _SampahPadatCard extends StatelessWidget {
  final double totalPadat;
  final double anorganik;
  final double organik;

  const _SampahPadatCard({
    required this.totalPadat,
    required this.anorganik,
    required this.organik,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: const Border(
          top: BorderSide(color: Color(0xFF00897B), width: 3.5),
        ),
        boxShadow: DesignTokens.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.scale_rounded,
                  color: Color(0xFF00695C),
                  size: 22,
                ),
              ),
              const Text(
                'Bulan Ini',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedValue(
                value: totalPadat,
                builder: (v) => Text(
                  FormatHelper.number(v),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.kelurahanDark,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'kg',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Sampah Padat',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.kelurahanDark,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Anorganik: ${FormatHelper.number(anorganik)} kg',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                'Organik: ${FormatHelper.number(organik)} kg',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00897B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Widget Kartu Statistik Seragam (Persis Sampah Padat) ───────────────────
class _FullDetailStatCard extends StatelessWidget {
  final String label;
  final String topBadgeText;
  final double value;
  final String unit;
  final IconData icon;
  final Color accentColor;
  final Color iconBgColor;
  final String leftDetailLabel;
  final String rightDetailLabel;
  final bool isInt;
  final bool isCurrency;

  const _FullDetailStatCard({
    required this.label,
    required this.topBadgeText,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accentColor,
    required this.iconBgColor,
    required this.leftDetailLabel,
    required this.rightDetailLabel,
    this.isInt = false,
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          top: BorderSide(color: accentColor, width: 3.5),
        ),
        boxShadow: DesignTokens.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              Text(
                topBadgeText,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedValue(
                value: value,
                builder: (v) {
                  String textVal;
                  if (isCurrency) {
                    textVal = FormatHelper.currency(v);
                  } else if (isInt) {
                    textVal = v.round().toString();
                  } else {
                    textVal = FormatHelper.number(v);
                  }
                  return Text(
                    textVal,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.kelurahanDark,
                      letterSpacing: -0.5,
                    ),
                  );
                },
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 5),
                Text(
                  unit,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.kelurahanDark,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                leftDetailLabel,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                rightDetailLabel,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
