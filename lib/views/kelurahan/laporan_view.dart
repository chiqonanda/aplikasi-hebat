import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/kelurahan/laporan_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../models/bank_sampah_model.dart';

class LaporanView extends GetView<LaporanController> {
  const LaporanView({super.key});

  // ── Theme Colors (Sama dengan Dashboard) ────────────────────────────────
  static const _blue900 = Color(0xFF0A2540);
  static const _blue800 = Color(0xFF0D3461);
  static const _blue600 = Color(0xFF1565C0);
  static const _blue500 = Color(0xFF1E88E5);
  static const _blue400 = Color(0xFF42A5F5);
  static const _blue200 = Color(0xFFBBDEFB);
  static const _blue50 = Color(0xFFE3F2FD);
  static const _bg = Color(0xFFF0F6FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────
              _buildHeader(),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Ringkasan ─────────────────────────────────────
                    _buildSectionTitle(
                      title: 'Generator Laporan',
                      subtitle: 'Atur filter dan export laporan',
                    ),

                    const SizedBox(height: 18),

                    // ── Filter Card ───────────────────────────────────
                    _buildFilterCard(),

                    const SizedBox(height: 22),

                    // ── Action Buttons ────────────────────────────────
                    _buildActionButtons(),

                    // ── Preview ───────────────────────────────────────
                    Obx(() {
                      if (!controller.hasPreview.value) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),

                          _buildSectionTitle(
                            title:
                                'Preview Data (${controller.previewData.length})',
                            subtitle: 'Hasil laporan berdasarkan filter',
                          ),

                          const SizedBox(height: 16),

                          if (controller.previewData.isEmpty)
                            _buildEmptyState()
                          else
                            Column(
                              children: controller.previewData.map((item) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 14),
                                  child: _PreviewCard(item: item),
                                );
                              }).toList(),
                            ),

                          if (controller.previewData.isNotEmpty) ...[
                            const SizedBox(height: 18),
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
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _blue900,
                _blue800,
                Color(0xFF1040A0),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Bar ──────────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Laporan',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.7,
                          ),
                        ),
                        Text(
                          'Export & Preview Data',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Info Banner ─────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_blue500, _blue400],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.description_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Buat laporan pengelolaan sampah dengan tampilan modern dan mudah digunakan.',
                        style: TextStyle(
                          height: 1.5,
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Decorative Circle
        Positioned(
          top: -30,
          right: -20,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),
      ],
    );
  }

  // ── Section Title ───────────────────────────────────────────────────────
  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [_blue500, _blue400],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _blue900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Filter Card ─────────────────────────────────────────────────────────
  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: _blue50,
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: _blue500.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Dropdown ───────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bank Sampah',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _blue900,
                ),
              ),
              const SizedBox(height: 10),

              Obx(
                () => DropdownButtonFormField<BankSampahModel?>(
                  value: controller.selectedBankSampah.value,
                  isExpanded: true, // ✅ WAJIB supaya tidak overflow
                  borderRadius: BorderRadius.circular(18),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _bg,
                    hintText: 'Semua bank sampah',
                    prefixIcon: const Icon(
                      Icons.store_rounded,
                      color: _blue500,
                    ),

                    // ✅ padding lebih aman
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: _blue200.withOpacity(0.7),
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: _blue500,
                        width: 1.5,
                      ),
                    ),
                  ),

                  items: [
                    const DropdownMenuItem<BankSampahModel?>(
                      value: null,
                      child: Text(
                        'Semua Bank Sampah',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),

                    ...controller.listBankSampah.map(
                      (b) => DropdownMenuItem<BankSampahModel?>(
                        value: b,

                        // ✅ FIX overflow text
                        child: Text(
                          b.namaLengkap,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],

                  onChanged: (v) {
                    controller.selectedBankSampah.value = v;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Date Picker ───────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Periode Laporan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _blue900,
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
                            value:
                                controller.selectedTanggalMulai.value,
                            onPick: (d) => controller
                                .selectedTanggalMulai.value = d,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => _DatePickerField(
                            label: 'Tanggal Akhir',
                            value:
                                controller.selectedTanggalAkhir.value,
                            onPick: (d) => controller
                                .selectedTanggalAkhir.value = d,
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
                            value:
                                controller.selectedTanggalMulai.value,
                            onPick: (d) => controller
                                .selectedTanggalMulai.value = d,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => _DatePickerField(
                            label: 'Tanggal Akhir',
                            value:
                                controller.selectedTanggalAkhir.value,
                            onPick: (d) => controller
                                .selectedTanggalAkhir.value = d,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ──────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Preview Button
        SizedBox(
          width: double.infinity,
          child: Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isGenerating.value
                  ? null
                  : controller.previewLaporan,
              icon: controller.isGenerating.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.visibility_rounded),
              label: const Text(
                'Tampilkan Preview',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _blue500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Export Buttons
        Row(
          children: [
            Expanded(
              child: Obx(
                () => OutlinedButton.icon(
                  onPressed: controller.isGenerating.value
                      ? null
                      : controller.exportExcel,
                  icon: const Icon(Icons.table_chart_rounded),
                  label: const Text(
                    'Excel',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _blue600,
                    side: BorderSide(
                      color: _blue200.withOpacity(0.8),
                    ),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => OutlinedButton.icon(
                  onPressed: controller.isGenerating.value
                      ? null
                      : controller.exportCsv,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text(
                    'CSV',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _blue600,
                    side: BorderSide(
                      color: _blue200.withOpacity(0.8),
                    ),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
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

  // ── Empty State ─────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _blue50),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_blue50, _blue200],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 38,
              color: _blue500,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Data Tidak Ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _blue900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada data pada periode\nyang dipilih.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary Card ────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    final total = controller.previewData.fold<double>(
      0,
      (sum, e) => sum + (e.totalHarga ?? 0),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_blue500, _blue400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _blue500.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 7),
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
            width: 1,
            height: 50,
            color: Colors.white.withOpacity(0.25),
          ),
          Expanded(
            child: _SummaryItem(
              title: 'Transaksi',
              value: '${controller.previewData.length}x',
              icon: Icons.receipt_long_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Date Picker
// ───────────────────────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  static const _blue500 = Color(0xFF1E88E5);
  static const _blue200 = Color(0xFFBBDEFB);
  static const _bg = Color(0xFFF0F6FF);

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
                  primary: _blue500,
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
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _blue200.withOpacity(0.7),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: _blue500,
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
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value != null
                        ? FormatHelper.date(value)
                        : 'Pilih tanggal',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: value != null
                          ? const Color(0xFF0A2540)
                          : Colors.grey.shade500,
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

// ───────────────────────────────────────────────────────────────────────────
// Preview Card
// ───────────────────────────────────────────────────────────────────────────

class _PreviewCard extends StatelessWidget {
  static const _blue900 = Color(0xFF0A2540);
  static const _blue500 = Color(0xFF1E88E5);
  static const _blue50 = Color(0xFFE3F2FD);

  final dynamic item;

  const _PreviewCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _blue50,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _blue500.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_blue500, Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.recycling_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaItem,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _blue900,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  item.bankSampah?.nama ?? '-',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.calendar_today_rounded,
                      text:
                          FormatHelper.date(item.tanggalPengelolaan),
                    ),
                    _InfoChip(
                      icon: Icons.scale_rounded,
                      text:
                          '${FormatHelper.number(item.jumlah)} ${item.satuan?.singkatan ?? ''}',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Price
          if (item.totalHarga != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_blue50, Color(0xFFBBDEFB)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                FormatHelper.currency(item.totalHarga),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _blue500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Info Chip
// ───────────────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  static const _blue500 = Color(0xFF1E88E5);

  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: _blue500,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: _blue500,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Summary Item
// ───────────────────────────────────────────────────────────────────────────

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
          color: Colors.white.withOpacity(0.9),
          size: 24,
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}