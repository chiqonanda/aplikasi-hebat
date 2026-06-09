import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchDashboardData,
          color: AppColors.kelurahanMain,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),

                // Stat Cards
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _buildStatGrid(),
                ),

                // Menu Utama
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: _buildMenuGrid(),
                ),

                // Bank Sampah Teraktif
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: _buildTopBankSampah(),
                ),

                // Aktivitas Terbaru Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
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
                          const SizedBox(height: 3),
                          Text(
                            'Pengelolaan sampah hari ini',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.monitoringBankSampah),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                            ),
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.kelurahanMain.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 11, color: Colors.white),
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
                      padding: EdgeInsets.all(48),
                      child: LoadingWidget(message: 'Memuat aktivitas terbaru...'),
                    );
                  }
                  if (controller.aktivitasTerbaru.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: EmptyState(
                        message: 'Belum Ada Aktivitas',
                        subtitle: 'Belum ada aktivitas pengelolaan untuk hari ini.',
                        icon: Icons.inbox_outlined,
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.aktivitasTerbaru.length,
                    itemBuilder: (context, index) {
                      final item = controller.aktivitasTerbaru[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: _AktivitasKelurahanCard(item: item),
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

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Stack(
      children: [
        // Background gradient
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.kelurahanGradient,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
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
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BISA',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'Dashboard Kelurahan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.65),
                            letterSpacing: 0.5,
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
                  const SizedBox(width: 10),
                  _HeaderIconBtn(
                    icon: Icons.logout_rounded,
                    onTap: () => Get.find<AuthController>().logout(),
                    tooltip: 'Keluar',
                    isDestructive: true,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Greeting
              Text(
                'Selamat Datang 👋',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.85),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                controller.penggunaNama,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.8,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),

              // Kelurahan Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 14, color: AppColors.kelurahanLight),
                    const SizedBox(width: 6),
                    Text(
                      controller.namaKelurahan,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.95),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Decorative circles
        Positioned(
          top: -30,
          right: -20,
          child: IgnorePointer(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Stat Grid ────────────────────────────────────────────────────────────
  Widget _buildStatGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Ringkasan Bulan Ini',
              style: AppTextStyles.titleLg,
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.05,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Obx(() => _StatCard(
                  label: 'Total Sampah',
                  sublabel: 'Bulan Ini',
                  value: FormatHelper.number(
                      controller.totalJumlahBulanIni.value),
                  satuan: 'kg',
                  icon: Icons.scale_outlined,
                  gradientColors: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  accentColor: const Color(0xFF0D47A1),
                  percentChange: controller.persentasePerubahanJumlah,
                )),
            Obx(() => _StatCard(
                  label: 'Bank Sampah',
                  sublabel: 'Aktif',
                  value: controller.totalBankSampahAktif.value.toString(),
                  satuan: 'unit',
                  icon: Icons.store_rounded,
                  gradientColors: const [Color(0xFF00838F), Color(0xFF26C6DA)],
                  accentColor: const Color(0xFF006064),
                )),
            Obx(() => _StatCard(
                  label: 'Total Transaksi',
                  sublabel: 'Bulan Ini',
                  value: controller.totalTransaksiBulanIni.value.toString(),
                  satuan: 'entri',
                  icon: Icons.receipt_long_outlined,
                  gradientColors: const [Color(0xFF283593), Color(0xFF5C6BC0)],
                  accentColor: const Color(0xFF1A237E),
                )),
            Obx(() => _StatCard(
                  label: 'Nilai Total',
                  sublabel: 'Bulan Ini',
                  value: FormatHelper.currency(
                      controller.totalNilaiBulanIni.value),
                  satuan: '',
                  icon: Icons.account_balance_wallet_outlined,
                  gradientColors: const [Color(0xFF00695C), Color(0xFF26A69A)],
                  accentColor: const Color(0xFF004D40),
                )),
          ],
        ),
      ],
    );
  }

  // ── Menu Grid ────────────────────────────────────────────────────────────
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
              height: 22,
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
              style: AppTextStyles.titleLg,
            ),
          ],
        ),

        const SizedBox(height: 16),

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
                mainAxisExtent: itemWidth + 12,
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

  Widget _buildTopBankSampah() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Bank Sampah Teraktif',
              style: AppTextStyles.titleLg,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.topBankSampah.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceLowest,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.outlineVariant, width: 1.2),
              ),
              child: Text(
                'Belum ada data pengelolaan bulan ini',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
              ),
            );
          }

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLowest,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.kelurahanMain.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: AppColors.outlineVariant,
                width: 1.2,
              ),
            ),
            child: Column(
              children: List.generate(controller.topBankSampah.length, (index) {
                final item = controller.topBankSampah[index];
                final rank = index + 1;
                
                Color rankColor;
                IconData rankIcon;
                if (rank == 1) {
                  rankColor = const Color(0xFFFFD700);
                  rankIcon = Icons.emoji_events_rounded;
                } else if (rank == 2) {
                  rankColor = const Color(0xFFC0C0C0);
                  rankIcon = Icons.emoji_events_rounded;
                } else {
                  rankColor = const Color(0xFFCD7F32);
                  rankIcon = Icons.emoji_events_rounded;
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        // Rank badge
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: rankColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            rankIcon,
                            color: rankColor == const Color(0xFFC0C0C0) ? Colors.grey.shade600 : rankColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Bank Sampah Name
                        Expanded(
                          child: Text(
                            item['nama'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.kelurahanDark,
                            ),
                          ),
                        ),
                        // Total Managed Waste
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.kelurahanLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${FormatHelper.number(item['total'] as double)} kg',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.kelurahanMain,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (index < controller.topBankSampah.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(
                          color: AppColors.divider,
                          height: 1,
                        ),
                      ),
                  ],
                );
              }),
            ),
          );
        }),
      ],
    );
  }
}

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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDestructive
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.2),
              width: 1.2,
            ),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red.shade200 : Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final String value;
  final String satuan;
  final IconData icon;
  final List<Color> gradientColors;
  final Color accentColor;
  final double? percentChange;

  const _StatCard({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.satuan,
    required this.icon,
    required this.gradientColors,
    required this.accentColor,
    this.percentChange,
  });

  Widget _buildComparisonBadge(double pct) {
    final isUp = pct >= 0;
    final text = '${isUp ? '+' : ''}${pct.toStringAsFixed(1)}%';
    final icon = isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final color = isUp ? const Color(0xFFC6FFD8) : const Color(0xFFFFDAD6);
    final textColor = isUp ? const Color(0xFF216140) : const Color(0xFFBA1A1A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.noScaling,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.38),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (satuan.isNotEmpty) ...[
                    const SizedBox(width: 3),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        satuan,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              if (percentChange != null) ...[
                _buildComparisonBadge(percentChange!),
                const SizedBox(height: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    )
    );
  }
}

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
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.kelurahanMain.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: AppColors.outlineVariant,
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 4,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: item.bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 26,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Flexible(
              flex: 2,
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kelurahanDark,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AktivitasKelurahanCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _AktivitasKelurahanCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.kelurahanMain.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.kelurahanMain.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.store_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['bank_nama'] ?? '-',
                  style: const TextStyle(
                    fontSize: 15,
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
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.kelurahanLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 11,
                            color: AppColors.kelurahanMain,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            FormatHelper.dateFromString(
                                item['tanggal'] ?? ''),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.kelurahanMain,
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
          ),

          const SizedBox(width: 10),

          // Value Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.kelurahanLight, Color(0xFFBBDEFB)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              FormatHelper.jumlahSatuan(
                item['jumlah'],
                item['satuan_singkatan'],
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.kelurahanMain,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}