import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/design_tokens.dart';
import '../../controllers/kelurahan/monitoring_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/bank_sampah_model.dart';

class MonitoringView extends GetView<MonitoringController> {
  const MonitoringView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppPageHeader
            AppPageHeader(
              title: 'Monitoring',
              subtitle: 'Informasi Bank Sampah Kelurahan',
              gradientColors: AppColors.kelurahanGradient,
              showBack: true,
              trailing: Obx(() => GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: controller.filterAktifSaja.value
                                ? const Color(0xFF42A5F5).withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: controller.filterAktifSaja.value
                                  ? const Color(0xFF42A5F5).withValues(alpha: 0.6)
                                  : Colors.white.withValues(alpha: 0.25),
                              width: 1.2,
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
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF64FFDA),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )),
            ),

            // Search Bar & Global Summary
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildRingkasanGlobal(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
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
                  Obx(() => Text(
                        'Daftar Bank Sampah'
                        '${controller.filterAktifSaja.value ? ' · Aktif' : ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.kelurahanDark,
                          letterSpacing: -0.4,
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // List of Waste Banks
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const AppLoadingState(message: 'Memuat data monitoring...');
                }
                if (controller.listBankFiltered.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchMonitoring,
                  color: AppColors.kelurahanMain,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.listBankFiltered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final bank = controller.listBankFiltered[index];
                      final stat = controller.statistikPerBank[bank.id];
                      return _MonitoringCard(
                        bank: bank,
                        totalJumlah: stat?['total_jumlah'] ?? 0,
                        totalTransaksi: stat?['total_transaksi'] ?? 0,
                        totalNilai: stat?['total_nilai'] ?? 0,
                        onTap: () {
                          controller.selectBank(bank);
                          Get.toNamed(AppRoutes.detailBankSampah);
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search Bar Widget ────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBF2FA), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.kelurahanMain.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearch,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.kelurahanDark,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Cari bank sampah...',
          hintStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.kelurahanMain,
            size: 22,
          ),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: Color(0xFF42A5F5),
                  ),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink()),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ── Ringkasan Global Widget ──────────────────────────────────────────────
  Widget _buildRingkasanGlobal() {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.kelurahanGradient,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.kelurahanMain.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
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
                width: 1.2,
                height: 38,
                color: Colors.white.withValues(alpha: 0.18),
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
                width: 1.2,
                height: 38,
                color: Colors.white.withValues(alpha: 0.18),
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

  // ── Empty State Widget ───────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return AppEmptyState(
      title: 'Tidak Ada Bank Sampah',
      subtitle: controller.filterAktifSaja.value
          ? 'Tidak ada bank sampah aktif yang ditemukan.'
          : 'Tidak ada bank sampah yang ditemukan.',
      icon: Icons.store_outlined,
      actionLabel: controller.filterAktifSaja.value ? 'Tampilkan Semua' : null,
      onAction: controller.filterAktifSaja.value
          ? () => controller.filterAktifSaja.value = false
          : null,
    );
  }

  // ── Filter Bottom Sheet Widget ───────────────────────────────────────────
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                  'Filter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.kelurahanDark,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.kelurahanLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE3F2FD), width: 1.2),
              ),
              child: Obx(() => SwitchListTile(
                    value: controller.filterAktifSaja.value,
                    onChanged: (v) => controller.filterAktifSaja.value = v,
                    title: const Text(
                      'Tampilkan aktif saja',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.kelurahanDark,
                      ),
                    ),
                    subtitle: const Text(
                      'Hanya menampilkan bank sampah yang sedang aktif',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.kelurahanGradient,
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
                child: const Text(
                  'Terapkan Filter',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Redesigned Monitoring Card ───────────────────────────────────────────
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEBF2FA), width: 1.2),
          boxShadow: DesignTokens.kelurahanShadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Info & Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Icon Container
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

                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        bank.nama,
                        style: const TextStyle(
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
                            const Icon(
                              Icons.location_on_rounded,
                              size: 13,
                              color: Color(0xFF42A5F5),
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

                // Status Badge & Action Chevron
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
            const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
            const SizedBox(height: 16),

            // Bottom stats row
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
                    color: const Color(0xFF00838F),
                    bgColor: const Color(0xFFE0F7FA),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Nilai',
                    value: FormatHelper.currency(totalNilai),
                    color: const Color(0xFF00695C),
                    bgColor: const Color(0xFFE0F2F1),
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

// ── Redesigned Status Badge Widget ───────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
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
              color: isActive ? const Color(0xFF2E7D32) : const Color(0xFF757575),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Aktif' : 'Nonaktif',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isActive ? const Color(0xFF2E7D32) : const Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Redesigned Stat Item Widget ──────────────────────────────────────────
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

// ── Redesigned Global Summary Item Widget ────────────────────────────────
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