import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
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
            // Custom AppPageHeader replacing default header
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: controller.filterAktifSaja.value
                                ? const Color(0xFF42A5F5).withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: controller.filterAktifSaja.value
                                  ? const Color(0xFF42A5F5).withValues(alpha: 0.6)
                                  : Colors.white.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: const Icon(Icons.filter_list_rounded,
                              color: Colors.white, size: 20),
                        ),
                        if (controller.filterAktifSaja.value)
                          Positioned(
                            right: 8,
                            top: 8,
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

            // Search + Ringkasan
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 14),
                  _buildRingkasanGlobal(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
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
                  Obx(() => Text(
                        'Daftar Bank Sampah'
                        '${controller.filterAktifSaja.value ? ' · Aktif' : ''}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.kelurahanDark,
                          letterSpacing: -0.4,
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingWidget(message: 'Memuat data monitoring...');
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
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final bank = controller.listBankFiltered[index];
                      final stat =
                          controller.statistikPerBank[bank.id];
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

  // ── Search Bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.kelurahanMain.withValues(alpha: 0.07),
            blurRadius: 12,
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
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Cari bank sampah...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.kelurahanMain, size: 22),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      size: 18, color: Color(0xFF42A5F5)),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink()),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ── Ringkasan Global ─────────────────────────────────────────────────────
  Widget _buildRingkasanGlobal() {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.kelurahanGradient,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.kelurahanMain.withValues(alpha: 0.32),
                blurRadius: 14,
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
                width: 1,
                height: 36,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _RingkasanItem(
                  icon: Icons.scale_outlined,
                  label: 'Total Sampah',
                  value: FormatHelper.number(
                      controller.totalSampahGlobal.value),
                  satuan: 'kg',
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _RingkasanItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Total Nilai',
                  value: FormatHelper.currency(
                      controller.totalNilaiGlobal.value),
                ),
              ),
            ],
          ),
        ));
  }

  // ── Empty State ──────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return EmptyState(
      message: 'Tidak Ada Bank Sampah',
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

  // ── Filter Sheet ─────────────────────────────────────────────────────────
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
                  'Filter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.kelurahanDark,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.kelurahanLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant, width: 1.2),
              ),
              child: Obx(() => SwitchListTile(
                    value: controller.filterAktifSaja.value,
                    onChanged: (v) =>
                        controller.filterAktifSaja.value = v,
                    title: const Text(
                      'Tampilkan aktif saja',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.kelurahanDark,
                      ),
                    ),
                    subtitle: const Text(
                      'Hanya menampilkan bank sampah yang sedang aktif',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    activeColor: AppColors.kelurahanMain,
                    activeTrackColor: AppColors.kelurahanLight,
                    contentPadding: EdgeInsets.zero,
                  )),
            ),
            const SizedBox(height: 20),
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
                      color: AppColors.kelurahanMain.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Text(
                  'Terapkan Filter',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
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

// ─────────────────────────────────────────────────────────────────────────────
// Monitoring Card
// ─────────────────────────────────────────────────────────────────────────────

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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.kelurahanLight, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.kelurahanMain.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
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
                  width: 52,
                  height: 52,
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
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: bank.isActive
                        ? [
                            BoxShadow(
                              color: AppColors.kelurahanMain.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: const Icon(Icons.store_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          bank.nama,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.kelurahanDark,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        if (bank.rt != null) ...[
                          const SizedBox(height: 4),

                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: Color(0xFF42A5F5),
                              ),

                              const SizedBox(width: 4),

                              Expanded(
                                child: Text(
                                  'RT ${bank.rt}'
                                  '${bank.rw != null ? ' / RW ${bank.rw}' : ''}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 0,
                  child: _StatusBadge(isActive: bank.isActive),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.kelurahanLight,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.kelurahanMain, size: 20),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.outlineVariant.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

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

// ─────────────────────────────────────────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.pengelolaLight
            : AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive
              ? const Color(0xFFA5D6A7)
              : AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.pengelolaMain
                    : AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              isActive ? 'Aktif' : 'Nonaktif',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? AppColors.pengelolaMain
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat Item (dalam card)
// ─────────────────────────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 5),
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
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ringkasan Item (dalam banner global)
// ─────────────────────────────────────────────────────────────────────────────

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
        const SizedBox(height: 5),
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
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
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
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}