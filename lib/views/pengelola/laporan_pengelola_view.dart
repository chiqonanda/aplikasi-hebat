import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';

import '../../controllers/pengelola/laporan_pengelola_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';

class LaporanPengelolaView extends GetView<LaporanPengelolaController> {
  const LaporanPengelolaView({super.key});

  // ── Theme Colors ────────────────────────────────────────────────────────
  static const _green900 = AppColors.pengelolaDark;
  static const _green500 = AppColors.pengelolaMain;
  static const _green400 = Color(0xFF43A047);
  static const _bg = AppColors.scaffoldBg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchNamaNasabah();
            if (controller.hasPreview.value) {
              await controller.previewLaporan();
            }
          },
          color: _green500,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Page
                const AppPageHeader(
                  title: 'Laporan',
                  subtitle: 'Export & Preview Data Laporan',
                  gradientColors: AppColors.pengelolaGradient,
                  showBack: false,
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info Banner
                      _buildInfoBanner(),
                      const SizedBox(height: 24),

                      // Section Title
                      _buildSectionTitle(
                        title: 'Generator Laporan',
                        subtitle: 'Atur filter dan export laporan Anda',
                      ),
                      const SizedBox(height: 18),

                      // Filter Card
                      _buildFilterCard(),
                      const SizedBox(height: 22),

                      // Action Buttons
                      _buildActionButtons(),

                      // Preview Results
                      Obx(() {
                        if (!controller.hasPreview.value) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            _buildSectionTitle(
                              title: 'Preview Data (${controller.previewData.length})',
                              subtitle: 'Hasil laporan berdasarkan filter terpilih',
                            ),
                            const SizedBox(height: 16),

                            if (controller.previewData.isEmpty)
                              const AppEmptyState(
                                title: 'Data Tidak Ditemukan',
                                subtitle: 'Tidak ada data transaksi pada periode yang dipilih.',
                                icon: Icons.receipt_long_outlined,
                              )
                            else
                              Column(
                                children: controller.previewData.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _PreviewCard(item: item),
                                  );
                                }).toList(),
                              ),

                            if (controller.previewData.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              _buildSummaryCard(),
                            ],
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Info Banner Widget ───────────────────────────────────────────────────
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEBF2FA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_green500, _green400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Buat laporan pengelolaan sampah dengan mudah. Filter berdasarkan nasabah dan rentang tanggal yang diinginkan.',
              style: TextStyle(
                height: 1.4,
                fontSize: 12.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Title Widget ──────────────────────────────────────────────────
  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [_green500, _green400],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _green900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Filter Card Widget ────────────────────────────────────────────────────
  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEBF2FA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown Nasabah Selector
          const Text(
            'Nasabah',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _green900,
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => DropdownButtonFormField<String?>(
              initialValue: controller.selectedNasabah.value,
              isExpanded: true,
              borderRadius: BorderRadius.circular(18),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _green500,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: _bg,
                hintText: 'Semua nasabah',
                prefixIcon: const Icon(
                  Icons.person_rounded,
                  color: _green500,
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _green500, width: 1.5),
                ),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    'Semua Nasabah',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ...controller.listNamaNasabah.map(
                  (n) => DropdownMenuItem<String?>(
                    value: n,
                    child: Text(
                      n,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
              onChanged: (v) {
                controller.selectedNasabah.value = v;
              },
            ),
          ),

          const SizedBox(height: 18),

          // Date Period Selectors
          const Text(
            'Periode Laporan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _green900,
            ),
          ),
          const SizedBox(height: 10),

          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;

              if (isSmall) {
                return Column(
                  children: [
                    Obx(
                      () => _DatePickerField(
                        label: 'Tanggal Mulai',
                        value: controller.selectedTanggalMulai.value,
                        onPick: (d) => controller.selectedTanggalMulai.value = d,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => _DatePickerField(
                        label: 'Tanggal Akhir',
                        value: controller.selectedTanggalAkhir.value,
                        onPick: (d) => controller.selectedTanggalAkhir.value = d,
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => _DatePickerField(
                        label: 'Tanggal Mulai',
                        value: controller.selectedTanggalMulai.value,
                        onPick: (d) => controller.selectedTanggalMulai.value = d,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => _DatePickerField(
                        label: 'Tanggal Akhir',
                        value: controller.selectedTanggalAkhir.value,
                        onPick: (d) => controller.selectedTanggalAkhir.value = d,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Action Buttons Widget ─────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Preview Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isGenerating.value ? null : controller.previewLaporan,
              icon: controller.isGenerating.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.visibility_rounded, size: 20),
              label: const Text(
                'Tampilkan Preview',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  letterSpacing: 0.1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _green500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Export Excel & CSV Buttons Row
        Row(
          children: [
            Expanded(
              child: Obx(
                () => OutlinedButton.icon(
                  onPressed: controller.isGenerating.value ? null : controller.exportExcel,
                  icon: const Icon(Icons.table_chart_rounded, size: 18),
                  label: const Text(
                    'Excel',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _green500,
                    side: const BorderSide(color: Color(0xFFEBF2FA), width: 1.2),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => OutlinedButton.icon(
                  onPressed: controller.isGenerating.value ? null : controller.exportCsv,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text(
                    'CSV',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _green500,
                    side: const BorderSide(color: Color(0xFFEBF2FA), width: 1.2),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Summary Card Widget ──────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    final total = controller.previewData.fold<double>(
      0,
      (sum, e) => sum + (e.totalHarga ?? 0),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_green500, _green400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _green500.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              title: 'Total Nilai',
              value: FormatHelper.currency(total),
              icon: Icons.account_balance_wallet_rounded,
            ),
          ),
          Container(
            width: 1.2,
            height: 48,
            color: Colors.white.withValues(alpha: 0.25),
          ),
          Expanded(
            child: _SummaryItem(
              title: 'Total Transaksi',
              value: '${controller.previewData.length}x',
              icon: Icons.receipt_long_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Redesigned Date Picker Field Widget ────────────────────────────────────
class _DatePickerField extends StatelessWidget {
  static const _green500 = AppColors.pengelolaMain;
  static const _bg = AppColors.pengelolaLight;

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPick;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(DateTime.now().year + 5),
          builder: (ctx, child) {
            return Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: _green500,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          onPick(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _bg.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _green500.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEBF2FA), width: 1),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: _green500,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value != null ? FormatHelper.date(value) : 'Pilih tanggal',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: value != null ? const Color(0xFF0A2540) : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Redesigned Preview Card Widget ────────────────────────────────────────
class _PreviewCard extends StatelessWidget {
  static const _green900 = AppColors.pengelolaDark;
  static const _green500 = AppColors.pengelolaMain;
  static const _green400 = Color(0xFF43A047);
  static const _greenLight = AppColors.pengelolaLight;

  final dynamic item;

  const _PreviewCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _greenLight.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Recycle Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_green500, _green400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.recycling_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Main info details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaItem,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: _green900,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Nasabah: ${item.namaNasabah ?? '-'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _InfoChip(
                      icon: Icons.calendar_today_rounded,
                      text: FormatHelper.date(item.tanggalPengelolaan),
                    ),
                    _InfoChip(
                      icon: Icons.scale_rounded,
                      text: '${FormatHelper.number(item.jumlah)} ${item.satuan?.singkatan ?? ''}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Pricing Badge
          if (item.totalHarga != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
              ),
              child: Text(
                FormatHelper.currency(item.totalHarga),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _green900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Redesigned Info Chip Widget ───────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  static const _green500 = AppColors.pengelolaMain;
  static const _greenLight = AppColors.pengelolaLight;

  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _greenLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: _green500,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _green500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Redesigned Summary Item Widget ────────────────────────────────────────
class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
