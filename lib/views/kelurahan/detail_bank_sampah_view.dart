import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/kelurahan/monitoring_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/pengelolaan_sampah_model.dart';

class DetailBankSampahView extends GetView<MonitoringController> {
  const DetailBankSampahView({super.key});

  // ── Theme Colors ────────────────────────────────────────────────────────
  static const _blue900 = AppColors.kelurahanDark;
  static const _blue500 = AppColors.kelurahanMain;
  static const _blue400 = Color(0xFF42A5F5);
  static const _blue200 = AppColors.kelurahanLight;
  static const _bg = AppColors.scaffoldBg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Obx(() {
        final bank = controller.selectedBankSampah.value;

        if (bank == null) {
          return const Center(
            child: Text(
              'Bank sampah tidak ditemukan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _blue900,
              ),
            ),
          );
        }

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.refresh,
            color: _blue500,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Header ────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: AppPageHeader(
                    title: 'Detail',
                    subtitle: 'Bank Sampah',
                    gradientColors: AppColors.kelurahanGradient,
                    showBack: true,
                  ),
                ),

                // ── Info Bank Card ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _buildBankInfoCard(bank),
                  ),
                ),

                // ── Statistik ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _buildStatSection(),
                  ),
                ),

                // ── Riwayat Header ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 22,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [_blue500, _blue400],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Riwayat Transaksi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _blue900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Riwayat Content ──────────────────────────────────────
                Obx(() {
                  if (controller.isLoadingDetail.value) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: LoadingWidget(),
                      ),
                    );
                  }

                  if (controller.detailTransaksi.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                        child: EmptyState(
                          message: 'Belum Ada Transaksi',
                          subtitle: 'Belum ada transaksi pengelolaan sampah pada bulan ini.',
                          icon: Icons.receipt_long_rounded,
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    sliver: SliverList.builder(
                      itemCount: controller.detailTransaksi.length,
                      itemBuilder: (context, index) {
                        final transaksi =
                            controller.detailTransaksi[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TransaksiCard(
                            transaksi: transaksi,
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Info Bank Card Helper ────────────────────────────────────────────────
  Widget _buildBankInfoCard(dynamic bank) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _blue200.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: AppTheme.cardShadowLight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.kelurahanGradient,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: _blue500.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.store_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: AppTheme.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bank.nama,
                  style: AppTextStyles.titleLg.copyWith(
                    color: _blue900,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: bank.isActive
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: bank.isActive
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            bank.isActive ? 'Aktif' : 'Tidak Aktif',
                            style: AppTextStyles.bodySm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: bank.isActive
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (bank.rt != null || bank.rw != null) ...[
                  const SizedBox(height: AppTheme.spacingMd),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_city_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'RT ${bank.rt ?? '-'} / RW ${bank.rw ?? '-'}',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (bank.alamat != null && bank.alamat.toString().isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingSm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bank.alamat!,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Statistik ─────────────────────────────────────────────────────────────
  Widget _buildStatSection() {
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
                  colors: [_blue500, _blue400],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Statistik Bulan Ini',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _blue900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Obx(
          () => Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Transaksi',
                  value: '${controller.statTransaksi.value}x',
                  icon: Icons.receipt_long_rounded,
                  gradient: const [
                    Color(0xFF1565C0),
                    Color(0xFF42A5F5),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Jumlah',
                  value: FormatHelper.number(
                    controller.statJumlah.value,
                  ),
                  icon: Icons.scale_rounded,
                  gradient: const [
                    Color(0xFF00838F),
                    Color(0xFF26C6DA),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Nilai',
                  value: FormatHelper.currency(
                    controller.statNilai.value,
                  ),
                  icon: Icons.payments_rounded,
                  gradient: const [
                    Color(0xFF00695C),
                    Color(0xFF26A69A),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat Card
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.noScaling,
      ),
      child: Container(
        height: 132,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),

          const Spacer(),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    )
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transaksi Card
// ─────────────────────────────────────────────────────────────────────────────

class _TransaksiCard extends StatelessWidget {
  final PengelolaanSampahModel transaksi;

  const _TransaksiCard({
    required this.transaksi,
  });

  static const _blue900 = AppColors.kelurahanDark;
  static const _blue500 = AppColors.kelurahanMain;
  static const _blue50 = AppColors.kelurahanLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _blue50,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _blue500.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Icon ───────────────────────────────────────────────
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_blue500, Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _blue500.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.recycling_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          // ── Content ───────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaksi.namaItem,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _blue900,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${FormatHelper.number(transaksi.jumlah)} ${transaksi.satuan?.singkatan ?? ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                if (transaksi.profile != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          transaksi.profile!.namaLengkap,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _blue50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    FormatHelper.date(
                      transaksi.tanggalPengelolaan,
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      color: _blue500,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ── Harga ─────────────────────────────────────────────
          if (transaksi.totalHarga != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE3F2FD),
                    Color(0xFFBBDEFB),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                FormatHelper.currency(
                  transaksi.totalHarga,
                ),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: _blue500,
                  letterSpacing: -0.3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}