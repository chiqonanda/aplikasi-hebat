import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../app/themes/design_tokens.dart';
import '../../controllers/pengelola/histori_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/pengelolaan_sampah_model.dart';

class HistoriView extends GetView<HistoriController> {
  const HistoriView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchHistori,
          color: AppColors.pengelolaMain,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: AppPageHeader(
                  title: 'Histori Pengelolaan',
                  subtitle: 'Data pengelolaan sampah',
                  gradientColors: AppColors.pengelolaGradient,
                  showBack: ModalRoute.of(context)?.canPop ?? false,
                ),
              ),

              // Search
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _SearchBar(controller: controller),
                ),
              ),

              // Summary
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.listHistori.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: _SummaryCard(
                      totalEntri: controller.listHistori.length,
                      totalNilai: controller.totalNilai,
                    ),
                  );
                }),
              ),

              // Section header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data Pengelolaan',
                            style: AppTextStyles.titleLg,
                          ),
                          const SizedBox(height: 2),
                          Obx(() => Text(
                                '${controller.listHistori.length} entri tercatat',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              )),
                        ],
                      ),
                      // Filter & Export buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Export Excel button
                          Obx(() {
                            final isListEmpty = controller.listHistori.isEmpty;
                            final isExporting = controller.isExporting.value;
                            final isBtnDisabled = isListEmpty || isExporting;

                            return GestureDetector(
                              onTap: isBtnDisabled ? null : () => controller.exportExcel(),
                              child: Opacity(
                                opacity: isBtnDisabled ? 0.5 : 1.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.pengelolaMain,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isExporting)
                                        const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      else
                                        const Icon(
                                          Icons.table_chart_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      const SizedBox(width: 5),
                                      const Text(
                                        'Excel',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 8),
                          // Filter button
                          Obx(() {
                            final isActive =
                                controller.filterKategoriId.value.isNotEmpty ||
                                    controller.filterTanggalMulai.value != null ||
                                    controller.filterTanggalAkhir.value != null;
                            return GestureDetector(
                              onTap: () => _showFilterSheet(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.pengelolaMain : AppColors.pengelolaLight,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.tune_rounded,
                                      size: 14,
                                      color: isActive
                                          ? Colors.white
                                          : AppColors.pengelolaMain,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      isActive ? 'Terfilter' : 'Filter',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isActive
                                            ? Colors.white
                                            : AppColors.pengelolaMain,
                                      ),
                                    ),
                                    if (isActive) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFFD166),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // List / Loading / Empty
              Obx(() {
                if (controller.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: AppLoadingState(message: 'Memuat histori pengelolaan...'),
                    ),
                  );
                }

                if (controller.listHistori.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: AppEmptyState(
                        title: controller.searchQuery.value.isNotEmpty
                            ? 'Data Tidak Ditemukan'
                            : controller.isFilterActive
                                ? 'Filter Terlalu Spesifik'
                                : 'Belum Ada Data',
                        subtitle: controller.searchQuery.value.isNotEmpty
                            ? 'Coba kata kunci lain atau hapus pencarian.'
                            : controller.isFilterActive
                                ? 'Ubah atau reset filter untuk melihat lebih banyak data.'
                                : 'Data pengelolaan sampah yang dicatat akan muncul di sini.',
                        icon: Icons.history_rounded,
                        actionLabel: controller.isFilterActive ? 'Reset Filter' : null,
                        onAction: controller.isFilterActive ? controller.resetFilter : null,
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = controller.listHistori[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: _HistoriCard(
                          item: item,
                          index: index,
                          onEdit: () => controller.editItem(item),
                          onDelete: () => controller.deleteItem(item),
                        ),
                      );
                    },
                    childCount: controller.listHistori.length,
                  ),
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(controller: controller),
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final HistoriController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppTextField(
        controller: controller.searchController,
        label: 'Cari data pengelolaan...',
        prefixIcon: Icons.search_rounded,
        onChanged: controller.onSearch,
        suffixIcon: Obx(
          () => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.cancel_rounded,
                      size: 18, color: AppColors.textTertiary),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// ── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final int totalEntri;
  final double totalNilai;

  const _SummaryCard({
    required this.totalEntri,
    required this.totalNilai,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.pengelolaGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.pengelolaMain.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.pengelolaDark.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Total Entri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Entri',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$totalEntri data',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 36,
            color: Colors.white.withValues(alpha: 0.25),
          ),
          const SizedBox(width: 16),

          // Total Nilai
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Nilai',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  FormatHelper.currency(totalNilai),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Histori Card ─────────────────────────────────────────────────────────────

class _HistoriCard extends StatelessWidget {
  final PengelolaanSampahModel item;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HistoriCard({
    required this.item,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  static const _accents = [
    AppColors.pengelolaMain,
    AppColors.kelurahanMain,
    Color(0xFFE65100),
    Color(0xFF37474F),
  ];
  static const _accentBgs = [
    AppColors.pengelolaLight,
    AppColors.kelurahanLight,
    Color(0xFFFBE9E7),
    Color(0xFFECEFF1),
  ];

  @override
  Widget build(BuildContext context) {
    final accent   = _accents[index % _accents.length];
    final accentBg = _accentBgs[index % _accentBgs.length];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: DesignTokens.shadowSm,
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
                  color: accentBg,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(Icons.recycling_rounded,
                    color: accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaItem,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.folder_open_rounded,
                            size: 11,
                            color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.breadcrumb,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action menu
              PopupMenuButton<String>(
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.more_horiz_rounded,
                      color: AppColors.textSecondary, size: 18),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.12),
                offset: const Offset(0, 40),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    height: 48,
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.kelurahanLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              size: 16, color: AppColors.kelurahanMain),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Edit Data',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(height: 1),
                  PopupMenuItem(
                    value: 'delete',
                    height: 48,
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.delete_rounded,
                              size: 16, color: AppColors.error),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Hapus Data',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),

          // Info chips + value
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _InfoChip(
                      icon: Icons.scale_outlined,
                      label: FormatHelper.jumlahSatuan(
                          item.jumlah, item.satuan?.singkatan),
                    ),
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: FormatHelper.dateFromString(
                          item.tanggalPengelolaan.toIso8601String()),
                    ),
                  ],
                ),
              ),
              if (item.totalHarga != null && item.totalHarga! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.pengelolaLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    FormatHelper.currency(item.totalHarga),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pengelolaMain,
                    ),
                  ),
                ),
            ],
          ),

          // Catatan
          if (item.catatan != null && item.catatan!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded,
                      size: 13, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.catatan!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Info Chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Sheet ──────────────────────────────────────────────────────────────

class _FilterSheet extends StatelessWidget {
  final HistoriController controller;

  const _FilterSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
  
              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.pengelolaLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune_rounded,
                        color: AppColors.pengelolaMain, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Filter Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
  
              // Kategori
              const _SectionLabel(label: 'Kategori Sampah'),
              const SizedBox(height: 10),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'Semua',
                        isSelected:
                            controller.filterKategoriId.value.isEmpty,
                        onTap: () =>
                            controller.filterKategoriId.value = '',
                      ),
                      ...controller.listKategoriFilter.map(
                        (k) => _FilterChip(
                          label: k.nama,
                          isSelected:
                              controller.filterKategoriId.value == k.id,
                          onTap: () =>
                              controller.filterKategoriId.value = k.id,
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 24),
  
              // Periode
              const _SectionLabel(label: 'Periode Waktu'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => _DatePickerField(
                          label: 'Dari Tanggal',
                          value: controller.filterTanggalMulai.value,
                          onTap: () =>
                              controller.pickTanggalMulai(context),
                        )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => _DatePickerField(
                          label: 'Sampai Tanggal',
                          value: controller.filterTanggalAkhir.value,
                          onTap: () =>
                              controller.pickTanggalAkhir(context),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 28),
  
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        controller.resetFilter();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh_rounded,
                                size: 16, color: AppColors.textPrimary),
                            const SizedBox(width: 6),
                            Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        controller.applyFilter();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.pengelolaGradient,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.pengelolaMain.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_rounded,
                                size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Terapkan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.pengelolaMain,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pengelolaMain
              : AppColors.background,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isSelected
                ? AppColors.pengelolaMain
                : AppColors.outlineVariant,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.pengelolaMain.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Date Picker Field ─────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: hasValue
              ? AppColors.pengelolaLight
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? AppColors.pengelolaMain.withValues(alpha: 0.4)
                : AppColors.outlineVariant,
            width: hasValue ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 16,
              color: hasValue
                  ? AppColors.pengelolaMain
                  : AppColors.textTertiary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasValue ? FormatHelper.date(value) : label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      hasValue ? FontWeight.w600 : FontWeight.w400,
                  color: hasValue
                      ? AppColors.pengelolaMain
                      : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}