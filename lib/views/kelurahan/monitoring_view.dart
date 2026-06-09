import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/kelurahan/monitoring_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../models/bank_sampah_model.dart';

class MonitoringView extends GetView<MonitoringController> {
  const MonitoringView({super.key});

  // ── Warna (sama dengan DashboardKelurahanView) ────────────────────────────
  static const _blue900 = Color(0xFF0A2540);
  static const _blue800 = Color(0xFF0D3461);
  static const _blue600 = Color(0xFF1565C0);
  static const _blue500 = Color(0xFF1E88E5);
  static const _blue400 = Color(0xFF42A5F5);
  static const _blue200 = Color(0xFFBBDEFB);
  static const _blue50  = Color(0xFFE3F2FD);
  static const _bg      = Color(0xFFF0F6FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Custom AppBar ──────────────────────────────────────────────
            _buildHeader(context),

            // ── Search + Ringkasan ─────────────────────────────────────────
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

            // ── Section Label ─────────────────────────────────────────────
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
                        colors: [_blue500, _blue400],
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
                          color: _blue900,
                          letterSpacing: -0.4,
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── List ──────────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: _blue500,
                      strokeWidth: 2.5,
                    ),
                  );
                }
                if (controller.listBankFiltered.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchMonitoring,
                  color: _blue500,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
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

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_blue900, _blue800, Color(0xFF1040A0)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2), width: 1.2),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              // Title
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monitoring',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Bank Sampah',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFBBDEFB),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Filter button
              Obx(() => GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: controller.filterAktifSaja.value
                                ? _blue400.withOpacity(0.3)
                                : Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: controller.filterAktifSaja.value
                                  ? _blue400.withOpacity(0.6)
                                  : Colors.white.withOpacity(0.2),
                              width: 1.2,
                            ),
                          ),
                          child: const Icon(Icons.filter_list_rounded,
                              color: Colors.white, size: 22),
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
            ],
          ),
        ),
        // Decorative circles — IgnorePointer agar tidak block tap pada tombol
        Positioned(
          top: -20,
          right: -10,
          child: IgnorePointer(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Search Bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _blue200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _blue600.withOpacity(0.07),
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
          color: _blue900,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Cari bank sampah...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              color: _blue500, size: 22),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      size: 18, color: _blue400),
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
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _blue600.withOpacity(0.32),
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
                color: Colors.white.withOpacity(0.2),
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
                color: Colors.white.withOpacity(0.2),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _blue50, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _blue600.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_blue50, _blue200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.store_outlined,
                    color: _blue600, size: 36),
              ),
              const SizedBox(height: 18),
              const Text(
                'Tidak Ada Bank Sampah',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _blue900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    controller.filterAktifSaja.value
                        ? 'Tidak ada bank sampah aktif\nyang ditemukan.'
                        : 'Tidak ada bank sampah\nyang ditemukan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      height: 1.6,
                    ),
                  )),
              Obx(() {
                if (!controller.filterAktifSaja.value) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () =>
                          controller.filterAktifSaja.value = false,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_blue600, _blue400],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _blue600.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Tampilkan Semua',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
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
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: _blue200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Title
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
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _blue900,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Switch tile
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: _blue50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _blue200, width: 1.2),
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
                        color: _blue900,
                      ),
                    ),
                    subtitle: Text(
                      'Hanya menampilkan bank sampah yang sedang aktif',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    activeColor: _blue600,
                    activeTrackColor: _blue200,
                    contentPadding: EdgeInsets.zero,
                  )),
            ),
            const SizedBox(height: 20),
            // Apply button
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_blue600, _blue400],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _blue600.withOpacity(0.3),
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

  static const _blue900 = Color(0xFF0A2540);
  static const _blue600 = Color(0xFF1565C0);
  static const _blue500 = Color(0xFF1E88E5);
  static const _blue400 = Color(0xFF42A5F5);
  static const _blue200 = Color(0xFFBBDEFB);
  static const _blue50  = Color(0xFFE3F2FD);

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _blue50, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _blue600.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row ──────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: bank.isActive
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_blue600, _blue400],
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
                              color: _blue600.withOpacity(0.3),
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
                // Name + RT/RW
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
                            color: _blue900,
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
                                color: _blue400,
                              ),

                              const SizedBox(width: 4),

                              Expanded(
                                child: Text(
                                  'RT ${bank.rt}'
                                  '${bank.rw != null ? ' / RW ${bank.rw}' : ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
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
                // Status badge
                Flexible(
                  flex: 0,
                  child: _StatusBadge(isActive: bank.isActive),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _blue50,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      color: _blue500, size: 20),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Divider ──────────────────────────────────────────────────
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _blue200.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Stats row ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.scale_outlined,
                    label: 'Bulan Ini',
                    value: '${FormatHelper.number(totalJumlah)} kg',
                    color: _blue600,
                    bgColor: _blue50,
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
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive
              ? const Color(0xFFA5D6A7)
              : Colors.grey.shade300,
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
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade400,
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
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade500,
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
              color: color.withOpacity(0.7),
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
        Icon(icon, size: 18, color: Colors.white.withOpacity(0.8)),
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
                    color: Colors.white.withOpacity(0.7),
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
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}