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
      backgroundColor: AppColors.background,
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
                // Header Section
                _buildHeader(),

                // Stat Cards Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _buildStatGrid(),
                ),

                // Menu Utama Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: _buildMenuGrid(),
                ),

                // Bank Sampah Teraktif Section
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.kelurahanDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pengelolaan sampah hari ini',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.monitoringBankSampah),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.kelurahanMain.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 6),
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
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: AppEmptyState(
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

  // ── Header Widget ────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Stack(
      children: [
        // Gradient container
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.kelurahanGradient,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Action Row
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 42,
                      height: 42,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.eco_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BISA',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'Basis Informasi Sampah',
                          style: TextStyle(
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

              const SizedBox(height: 28),

              // Greeting & User Name (Personalized)
              Text(
                'Selamat Datang 👋',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.penggunaNama,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),

              // Prominent Kelurahan Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppColors.kelurahanLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.namaKelurahan,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Floating geometric shapes for visual aesthetics
        Positioned(
          top: -20,
          right: -20,
          child: IgnorePointer(
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
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
              height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Ringkasan Bulan Ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.kelurahanDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.15,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Obx(() => _StatCard(
                  label: 'Total Sampah',
                  sublabel: 'Bulan Ini',
                  value: FormatHelper.number(controller.totalJumlahBulanIni.value),
                  satuan: 'kg',
                  icon: Icons.scale_outlined,
                  iconColor: const Color(0xFF1565C0),
                  iconBgColor: const Color(0xFFE3F2FD),
                  percentChange: controller.persentasePerubahanJumlah,
                )),
            Obx(() => _StatCard(
                  label: 'Bank Sampah',
                  sublabel: 'Aktif',
                  value: controller.totalBankSampahAktif.value.toString(),
                  satuan: 'unit',
                  icon: Icons.store_rounded,
                  iconColor: const Color(0xFF00ACC1),
                  iconBgColor: const Color(0xFFE0F7FA),
                )),
            Obx(() => _StatCard(
                  label: 'Total Transaksi',
                  sublabel: 'Bulan Ini',
                  value: controller.totalTransaksiBulanIni.value.toString(),
                  satuan: 'entri',
                  icon: Icons.receipt_long_outlined,
                  iconColor: const Color(0xFF1A237E),
                  iconBgColor: const Color(0xFFE8EAF6),
                )),
            Obx(() => _StatCard(
                  label: 'Nilai Total',
                  sublabel: 'Bulan Ini',
                  value: FormatHelper.currency(controller.totalNilaiBulanIni.value),
                  satuan: '',
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFF00897B),
                  iconBgColor: const Color(0xFFE0F2F1),
                )),
          ],
        ),
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
              height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Menu Utama',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.kelurahanDark,
              ),
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
              height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Bank Sampah Teraktif',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.kelurahanDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.topBankSampah.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.divider, width: 1),
                boxShadow: DesignTokens.shadowSm,
              ),
              child: Text(
                'Belum ada data pengelolaan bulan ini',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: DesignTokens.kelurahanShadowSm,
              border: Border.all(
                color: const Color(0xFFEBF2FA),
                width: 1,
              ),
            ),
            child: Column(
              children: List.generate(controller.topBankSampah.length, (index) {
                final item = controller.topBankSampah[index];
                final rank = index + 1;

                Color rankColor;
                IconData rankIcon;
                if (rank == 1) {
                  rankColor = const Color(0xFFFFA000);
                  rankIcon = Icons.emoji_events_rounded;
                } else if (rank == 2) {
                  rankColor = const Color(0xFF78909C);
                  rankIcon = Icons.emoji_events_rounded;
                } else {
                  rankColor = const Color(0xFF8D6E63);
                  rankIcon = Icons.emoji_events_rounded;
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        // Rank Badge
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: rankColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            rankIcon,
                            color: rankColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Bank Name
                        Expanded(
                          child: Text(
                            item['nama'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.kelurahanDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Total Waste Chip
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
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.kelurahanMain,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (index < controller.topBankSampah.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          color: Color(0xFFF1F5F9),
                          height: 1,
                          thickness: 1,
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDestructive
                ? const Color(0xFFFFEBEE)
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDestructive
                  ? const Color(0xFFFFCDD2)
                  : Colors.white.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Icon(
            icon,
            color: isDestructive ? const Color(0xFFD32F2F) : Colors.white,
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
  final Color iconColor;
  final Color iconBgColor;
  final double? percentChange;

  const _StatCard({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.satuan,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.percentChange,
  });

  Widget _buildComparisonBadge(double pct) {
    final isUp = pct >= 0;
    final text = '${isUp ? '+' : ''}${pct.toStringAsFixed(1)}%';
    final badgeColor = isUp ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final textColor = isUp ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final arrowIcon = isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(arrowIcon, size: 10, color: textColor),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEBF2FA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Icon Container and Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              if (percentChange != null) _buildComparisonBadge(percentChange!),
            ],
          ),

          // Middle: Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.kelurahanDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (satuan.isNotEmpty) ...[
                      const SizedBox(width: 2),
                      Text(
                        satuan,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 2),
              // Label
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kelurahanDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Sublabel
              Text(
                sublabel,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.kelurahanMain.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFEBF2FA),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
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
            const SizedBox(height: 8),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
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

  const _AktivitasKelurahanCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEBF2FA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Modern Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.store_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Main Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['bank_nama'] ?? '-',
                  style: const TextStyle(
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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.kelurahanLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 10,
                            color: AppColors.kelurahanMain,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            FormatHelper.dateFromString(item['tanggal'] ?? ''),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.kelurahanMain,
                              fontWeight: FontWeight.w700,
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
          const SizedBox(width: 12),

          // Weight / Quantity Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFBBDEFB),
                width: 1,
              ),
            ),
            child: Text(
              FormatHelper.jumlahSatuan(
                item['jumlah'],
                item['satuan_singkatan'],
              ),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.kelurahanMain,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}