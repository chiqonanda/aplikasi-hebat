import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/design_tokens.dart';
import '../../controllers/kelurahan/monitoring_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/bank_sampah_model.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/wave_painter.dart';

class MonitoringView extends GetView<MonitoringController> {
  const MonitoringView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundKelurahan,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: AppLoadingState(message: 'Memuat data monitoring...'),
          );
        }

        return PullToRefresh(
          onRefresh: controller.fetchMonitoring,
          color: AppColors.kelurahanMain,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header + Ringkasan Global ──────────
              SliverToBoxAdapter(
                child: StaggeredEntrance(index: 0, child: _buildHeader(context)),
              ),

              // ── Search & Section Label ──────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
                  child: StaggeredEntrance(index: 1, child: _buildSearchBar()),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
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
                      Obx(() => Text(
                            'Daftar Bank Sampah'
                            '${controller.filterAktifSaja.value ? ' · Aktif' : ''}',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.kelurahanDark,
                              letterSpacing: -0.3,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              if (controller.listBankFiltered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final bank = controller.listBankFiltered[index];
                        final stat = controller.statistikPerBank[bank.id];
                        return StaggeredEntrance(
                          index: index.clamp(0, 6),
                          delayMs: 60,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _MonitoringCard(
                              bank: bank,
                              totalJumlah: stat?['total_jumlah'] ?? 0,
                              totalTransaksi: stat?['total_transaksi'] ?? 0,
                              totalNilai: stat?['total_nilai'] ?? 0,
                              onTap: () {
                                controller.selectBank(bank);
                                Get.toNamed(AppRoutes.detailBankSampah);
                              },
                            ),
                          ),
                        );
                      },
                      childCount: controller.listBankFiltered.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  // ── Header + Ringkasan Global ───────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 250),
          painter: WavePainter.blue(),
        ),
        const AmbientBlob(color: Color(0x14FFFFFF), size: 220),
        Positioned(
          top: -15,
          right: -10,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          top: 35,
          right: 65,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PressableScale(
                      onTap: () => Get.back(),
                      pressedScale: 0.88,
                      child: Container(
                        width: 38,
                        height: 38,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monitoring',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() => AnimatedValue(
                                value: controller.listBankSampah.length
                                    .toDouble(),
                                builder: (v) => Text(
                                  '${FormatHelper.number(v)} bank sampah terpantau',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    // Filter button
                    Obx(() => PressableScale(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showFilterSheet(context);
                          },
                          pressedScale: 0.88,
                          borderRadius: 13,
                          child: Stack(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: controller.filterAktifSaja.value
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.filter_list_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              if (controller.filterAktifSaja.value)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.mintAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
        ),

        // Floating ringkasan global card (overlap bottom of header)
        Positioned(
          left: 20,
          right: 20,
          bottom: -34,
          child: _buildRingkasanGlobal(),
        ),
      ],
    );
  }

  // ── Ringkasan Global ─────────────────────────────────────────────────────

  Widget _buildRingkasanGlobal() {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.kelurahanDark, AppColors.kelurahanMain],
            ),
            borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
            boxShadow: DesignTokens.kelurahanShadowLg,
          ),
          child: Row(
            children: [
              Expanded(
                child: _RingkasanItem(
                  icon: Icons.store_rounded,
                  label: 'Bank Sampah',
                  value: '${controller.listBankFiltered.length}',
                ),
              ),
              Container(
                width: 1,
                height: 38,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              Expanded(
                child: _RingkasanItem(
                  icon: Icons.scale_outlined,
                  label: 'Total Sampah',
                  value: FormatHelper.number(controller.totalSampahGlobal.value),
                  satuan: 'kg',
                ),
              ),
              Container(
                width: 1,
                height: 38,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              Expanded(
                child: _RingkasanItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Total Nilai',
                  value: FormatHelper.currency(controller.totalNilaiGlobal.value),
                ),
              ),
            ],
          ),
        ));
  }

  // ── Search Bar ───────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: DesignTokens.shadowSm,
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearch,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          color: AppColors.kelurahanDark,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Cari bank sampah...',
          hintStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade400,
            size: 20,
          ),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink()),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Obx(() => AppEmptyState(
          title: 'Tidak Ada Bank Sampah',
          subtitle: controller.filterAktifSaja.value
              ? 'Tidak ada bank sampah aktif yang ditemukan.'
              : 'Tidak ada bank sampah yang ditemukan.',
          icon: Icons.store_outlined,
          actionLabel: controller.filterAktifSaja.value ? 'Tampilkan Semua' : null,
          onAction: controller.filterAktifSaja.value
              ? () => controller.filterAktifSaja.value = false
              : null,
        ));
  }

  // ── Filter Bottom Sheet ──────────────────────────────────────────────────

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.kelurahanLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.filter_list_rounded,
                      color: AppColors.kelurahanMain,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Filter Data',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.kelurahanDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.backgroundKelurahan,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Obx(() => SwitchListTile(
                      value: controller.filterAktifSaja.value,
                      onChanged: (v) => controller.filterAktifSaja.value = v,
                      title: const Text(
                        'Tampilkan aktif saja',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.kelurahanDark,
                        ),
                      ),
                      subtitle: Text(
                        'Hanya menampilkan bank sampah yang sedang aktif',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11.5,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      activeThumbColor: AppColors.kelurahanMain,
                      activeTrackColor: const Color(0xFF90CAF9),
                      contentPadding: EdgeInsets.zero,
                    )),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.kelurahanGradient,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.kelurahanMain.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Terapkan Filter',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
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

// ── Monitoring Card ───────────────────────────────────────────────────────────

class _MonitoringCard extends StatelessWidget {
  final BankSampahModel bank;
  final num totalJumlah;
  final num totalTransaksi;
  final num totalNilai;
  final VoidCallback onTap;

  const _MonitoringCard({
    required this.bank,
    required this.totalJumlah,
    required this.totalTransaksi,
    required this.totalNilai,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = bank.isActive ? AppColors.kelurahanMain : Colors.grey.shade400;

    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      pressedScale: 0.97,
      splashColor: accent.withValues(alpha: 0.05),
      borderRadius: DesignTokens.radiusLg,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border(
            top: BorderSide(color: accent, width: 2),
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: bank.isActive
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.kelurahanGradient,
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.shade300,
                              Colors.grey.shade400,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.store_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        bank.nama,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.kelurahanDark,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (bank.rt != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.kelurahanLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'RT ${bank.rt}'
                                '${bank.rw != null ? ' / RW ${bank.rw}' : ''}',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 10.5,
                                  color: AppColors.kelurahanMain,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusBadge(isActive: bank.isActive),
                    const SizedBox(height: 8),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.kelurahanLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.kelurahanMain,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade100, height: 1, thickness: 1),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.scale_outlined,
                    label: 'Bulan Ini',
                    value: '${FormatHelper.number(totalJumlah)} kg',
                    color: AppColors.kelurahanMain,
                    bgColor: AppColors.kelurahanLight,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Transaksi',
                    value: totalTransaksi.toString(),
                    color: AppColors.teal,
                    bgColor: AppColors.tealLight,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Nilai',
                    value: FormatHelper.currency(totalNilai),
                    color: AppColors.tealDark,
                    bgColor: AppColors.tealContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.pengelolaLight : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? const Color(0xFFA5D6A7) : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppColors.pengelolaMain : AppColors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Aktif' : 'Nonaktif',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isActive ? AppColors.pengelolaMain : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Item ─────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Global Summary Item ─────────────────────────────────────────────────────

class _RingkasanItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? satuan;

  const _RingkasanItem({
    required this.icon,
    required this.label,
    required this.value,
    this.satuan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.8)),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            if (satuan != null) ...[
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: Text(
                  satuan!,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Wave Painter ──────────────────────────────────────────────────────────────

