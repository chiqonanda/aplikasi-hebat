import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../controllers/pengelola/laporan_pengelola_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';

class LaporanPengelolaView extends GetView<LaporanPengelolaController> {
  const LaporanPengelolaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchNamaNasabah();
          if (controller.hasPreview.value) {
            await controller.previewLaporan();
          }
        },
        color: AppColors.pengelolaMain,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ───────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(context)),

            // ── Content ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoBanner(),
                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      title: 'Generator Laporan',
                      subtitle: 'Atur filter dan export laporan Anda',
                    ),
                    const SizedBox(height: 14),

                    _buildFilterCard(),
                    const SizedBox(height: 20),

                    _buildActionButtons(),

                    Obx(() {
                      if (!controller.hasPreview.value) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 28),
                          _buildSectionTitle(
                            title: 'Preview Data (${controller.previewData.length})',
                            subtitle: 'Hasil laporan berdasarkan filter terpilih',
                          ),
                          const SizedBox(height: 14),

                          if (controller.previewData.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: AppEmptyState(
                                title: 'Data Tidak Ditemukan',
                                subtitle: 'Tidak ada data transaksi pada periode yang dipilih.',
                                icon: Icons.receipt_long_outlined,
                              ),
                            )
                          else
                            Column(
                              children: controller.previewData
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _PreviewCard(item: entry.value, index: entry.key),
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
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 165),
          painter: _WavePainter(),
        ),
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
          top: 30,
          right: 60,
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Laporan',
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
                      Text(
                        'Export & preview data laporan',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Info Banner ────────────────────────────────────────────────────────────

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.info,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Buat laporan pengelolaan sampah dengan mudah. Filter berdasarkan nasabah dan rentang tanggal yang diinginkan.',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                height: 1.4,
                fontSize: 12.5,
                color: AppColors.info,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Title ──────────────────────────────────────────────────────────

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
            ),
            borderRadius: BorderRadius.circular(4),
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
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Filter Card ────────────────────────────────────────────────────────────

  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: const Border(
          top: BorderSide(color: AppColors.pengelolaMain, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.pengelolaMain.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nasabah',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => DropdownButtonFormField<String?>(
              initialValue: controller.selectedNasabah.value,
              isExpanded: true,
              borderRadius: BorderRadius.circular(14),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade400,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                hintText: 'Semua nasabah',
                prefixIcon: const Icon(
                  Icons.person_rounded,
                  color: AppColors.pengelolaMain,
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.pengelolaMain, width: 1.5),
                ),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    'Semua Nasabah',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w600),
                  ),
                ),
                ...controller.listNamaNasabah.map(
                  (n) => DropdownMenuItem<String?>(
                    value: n,
                    child: Text(
                      n,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w600),
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

          const Text(
            'Periode Laporan',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
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

  // ── Action Buttons ─────────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Preview Button — gradient
        Obx(() {
          final isLoading = controller.isGenerating.value;
          return GestureDetector(
            onTap: isLoading ? null : controller.previewLaporan,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: isLoading
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.pengelolaMain.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility_rounded, size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Tampilkan Preview',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.white,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        }),

        const SizedBox(height: 12),

        // Export Excel & CSV
        Row(
          children: [
            Expanded(
              child: Obx(() => _OutlineActionButton(
                    label: 'Excel',
                    icon: Icons.table_chart_rounded,
                    onTap: controller.isGenerating.value ? null : controller.exportExcel,
                  )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => _OutlineActionButton(
                    label: 'CSV',
                    icon: Icons.download_rounded,
                    onTap: controller.isGenerating.value ? null : controller.exportCsv,
                  )),
            ),
          ],
        ),
      ],
    );
  }

  // ── Summary Card ───────────────────────────────────────────────────────────

  Widget _buildSummaryCard() {
    final total = controller.previewData.fold<double>(
      0,
      (sum, e) => sum + (e.totalHarga ?? 0),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.pengelolaMain.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
            height: 44,
            color: Colors.white.withValues(alpha: 0.15),
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

// ── Outline Action Button ──────────────────────────────────────────────────

class _OutlineActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _OutlineActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: AppColors.pengelolaMain),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: AppColors.pengelolaMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Date Picker Field ──────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
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
    final hasValue = value != null;
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
                  primary: AppColors.pengelolaMain,
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
          color: hasValue ? AppColors.pengelolaLight : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasValue
                ? AppColors.pengelolaMain.withValues(alpha: 0.3)
                : AppColors.outlineVariant.withValues(alpha: 0.4),
            width: hasValue ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.pengelolaMain,
                size: 17,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasValue ? FormatHelper.date(value) : 'Pilih tanggal',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: hasValue ? AppColors.pengelolaMain : Colors.grey.shade500,
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

// ── Preview Card ──────────────────────────────────────────────────────────────

class _PreviewCard extends StatelessWidget {
  final dynamic item;
  final int index;

  const _PreviewCard({required this.item, required this.index});

  static const _accents = [
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFFE65100),
    Color(0xFF6A1B9A),
  ];
  static const _accentBgs = [
    Color(0xFFE8F5E9),
    Color(0xFFE3F2FD),
    Color(0xFFFBE9E7),
    Color(0xFFF3E5F5),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _accents[index % _accents.length];
    final accentBg = _accentBgs[index % _accentBgs.length];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: accent, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(Icons.recycling_rounded, color: accent, size: 22),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaItem,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Nasabah: ${item.namaNasabah ?? '-'}',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11.5,
                    color: Colors.grey.shade500,
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
                      accent: accent,
                      accentBg: accentBg,
                    ),
                    _InfoChip(
                      icon: Icons.scale_rounded,
                      text: '${FormatHelper.number(item.jumlah)} ${item.satuan?.singkatan ?? ''}',
                      accent: accent,
                      accentBg: accentBg,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          if (item.totalHarga != null)
            Text(
              FormatHelper.currency(item.totalHarga),
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Info Chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color accent;
  final Color accentBg;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.accent,
    required this.accentBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accentBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: accent),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary Item ──────────────────────────────────────────────────────────────

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
        Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.75),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

// ── Wave Painter ──────────────────────────────────────────────────────────────

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path1 = Path()
      ..lineTo(0, size.height * 0.74)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.98,
        size.width * 0.5,
        size.height * 0.80,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.62,
        size.width,
        size.height * 0.76,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = const Color(0xFF43A047).withValues(alpha: 0.3);

    final path2 = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.42,
        size.width * 0.55,
        size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.74,
        size.width,
        size.height * 0.56,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path2, paint2);

    final paintDot = Paint()
      ..color = Colors.white.withValues(alpha: 0.06);

    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.3),
      40,
      paintDot,
    );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.15),
      25,
      paintDot,
    );
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => false;
}