import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/pengelola/histori_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/pengelolaan_sampah_model.dart';

class HistoriView extends GetView<HistoriController> {
  const HistoriView({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: controller.fetchHistori,
        color: AppColors.pengelolaMain,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ───────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildHeader(context, canPop),
            ),

            // ── Search ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _SearchBar(controller: controller),
              ),
            ),

            // ── Summary Banner ────────────────────────────────
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

            // ── Section Header ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Accent bar + title
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF2E7D32),
                                Color(0xFF43A047),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data Pengelolaan',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E),
                                letterSpacing: -0.3,
                              ),
                            ),
                            Obx(
                              () => Text(
                                '${controller.listHistori.length} entri tercatat',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Export + Filter buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Export Excel
                        Obx(() {
                          final isEmpty = controller.listHistori.isEmpty;
                          final isExporting = controller.isExporting.value;
                          final disabled = isEmpty || isExporting;

                          return GestureDetector(
                            onTap: disabled
                                ? null
                                : () => controller.exportExcel(),
                            child: Opacity(
                              opacity: disabled ? 0.45 : 1.0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2E7D32),
                                      Color(0xFF43A047),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: disabled
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: const Color(0xFF2E7D32)
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isExporting)
                                      const SizedBox(
                                        width: 13,
                                        height: 13,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.table_chart_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'Excel',
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
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

                        // Filter
                        Obx(() {
                          final isActive = controller.isFilterActive;
                          return GestureDetector(
                            onTap: () => _showFilterSheet(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.pengelolaMain
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.pengelolaMain
                                      : AppColors.outlineVariant
                                          .withValues(alpha: 0.4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isActive
                                        ? AppColors.pengelolaMain
                                            .withValues(alpha: 0.25)
                                        : Colors.black
                                            .withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    size: 13,
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.pengelolaMain,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isActive ? 'Terfilter' : 'Filter',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isActive
                                          ? Colors.white
                                          : AppColors.pengelolaMain,
                                    ),
                                  ),
                                  if (isActive) ...[
                                    const SizedBox(width: 5),
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

            // ── List / Loading / Empty ────────────────────────
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: AppLoadingState(
                      message: 'Memuat histori pengelolaan...',
                    ),
                  ),
                );
              }

              if (controller.listHistori.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
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
                      actionLabel:
                          controller.isFilterActive ? 'Reset Filter' : null,
                      onAction: controller.isFilterActive
                          ? controller.resetFilter
                          : null,
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = controller.listHistori[index];
                    void onEdit() => controller.editItem(item);
                    void onDelete() => controller.deleteItem(item);

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            onDelete();
                            return false;
                          } else {
                            onEdit();
                            return false;
                          }
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.delete_rounded,
                              color: Colors.white),
                        ),
                        child: _HistoriCard(
                          item: item,
                          index: index,
                          onEdit: onEdit,
                          onDelete: onDelete,
                        ),
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
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, bool canPop) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 200),
          painter: _WavePainter(),
        ),

        // Dekoratif circles
        Positioned(
          top: -20,
          right: -10,
          child: Container(
            width: 130,
            height: 130,
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  children: [
                    if (canPop)
                      GestureDetector(
                        onTap: () => Get.back(),
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
                            'Histori Pengelolaan',
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
                            'Riwayat pencatatan sampah',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Icon history dekoratif
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
                        Icons.history_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearch,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontFamily: 'PlusJakartaSans',
        ),
        decoration: InputDecoration(
          hintText: 'Cari data pengelolaan, catatan...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade400,
            fontFamily: 'PlusJakartaSans',
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade400,
            size: 20,
          ),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.cancel_rounded,
                        size: 18, color: Colors.grey.shade400),
                    onPressed: controller.clearSearch,
                  )
                : const SizedBox.shrink(),
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.pengelolaMain.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RINGKASAN KEUANGAN',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.75),
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF69F0AE),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Aktif',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            FormatHelper.currency(totalNilai),
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total Nilai Sampah Dikelola',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 15,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total Volume Catatan',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const Spacer(),
                Text(
                  '$totalEntri data',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Histori Card ──────────────────────────────────────────────────────────────

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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(color: accent, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accentBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.recycling_rounded,
                    color: accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Title + breadcrumb
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
                        item.breadcrumb,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Harga + menu
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (item.totalHarga != null && item.totalHarga! > 0)
                          ? FormatHelper.currency(item.totalHarga)
                          : 'Rp 0',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: (item.totalHarga != null &&
                                item.totalHarga! > 0)
                            ? AppColors.pengelolaMain
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_horiz_rounded,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      offset: const Offset(0, 24),
                      onSelected: (v) {
                        if (v == 'edit') onEdit();
                        if (v == 'delete') onDelete();
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'edit',
                          height: 40,
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded,
                                  size: 15,
                                  color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              const Text(
                                'Edit',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          height: 40,
                          child: Row(
                            children: [
                              const Icon(Icons.delete_rounded,
                                  size: 15, color: AppColors.error),
                              const SizedBox(width: 8),
                              const Text(
                                'Hapus',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
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
              ],
            ),

            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 10),

            // Metadata
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.scale_outlined,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        FormatHelper.jumlahSatuan(
                          item.jumlah,
                          item.satuan?.singkatan,
                        ),
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.calendar_today_outlined,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        FormatHelper.dateFromString(
                          item.tanggalPengelolaan.toIso8601String(),
                        ),
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Catatan badge
                if (item.catatan != null && item.catatan!.isNotEmpty)
                  Tooltip(
                    message: 'Ketuk untuk detail catatan',
                    child: GestureDetector(
                      onTap: () => _showCatatanDialog(
                        context,
                        item.catatan!,
                        accent,
                        accentBg,
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.notes_rounded,
                                  size: 11, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                'Catatan',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCatatanDialog(
      BuildContext context, String catatan, Color accent, Color accentBg) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon header with accent color
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: accentBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sticky_note_2_rounded,
                      color: accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  const Text(
                    'Catatan Transaksi',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Note content
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                      ),
                    ),
                    constraints: const BoxConstraints(
                      maxHeight: 180,
                    ),
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          catatan,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            height: 1.5,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
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
          20,
          16,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
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
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.pengelolaLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.pengelolaMain,
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
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Kategori
              const _SectionLabel(label: 'Kategori Sampah'),
              const SizedBox(height: 10),
              Obx(
                () => Wrap(
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
                ),
              ),
              const SizedBox(height: 24),

              // Nasabah
              const _SectionLabel(label: 'Nasabah / Pelanggan'),
              const SizedBox(height: 10),
              Obx(
                () => _DropdownField<String>(
                  label: 'Pilih Nasabah',
                  value: controller.filterNamaNasabah.value.isEmpty
                      ? null
                      : controller.filterNamaNasabah.value,
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Semua Nasabah'),
                    ),
                    ...controller.listNamaNasabah.map(
                      (name) => DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    controller.filterNamaNasabah.value = val ?? '';
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Periode
              const _SectionLabel(label: 'Periode Waktu'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => _DatePickerField(
                        label: 'Dari Tanggal',
                        value: controller.filterTanggalMulai.value,
                        onTap: () =>
                            controller.pickTanggalMulai(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => _DatePickerField(
                        label: 'Sampai Tanggal',
                        value: controller.filterTanggalAkhir.value,
                        onTap: () =>
                            controller.pickTanggalAkhir(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Tombol
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
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.outlineVariant
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh_rounded,
                                size: 15,
                                color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              'Reset',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
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
                              color: AppColors.pengelolaMain
                                  .withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_rounded,
                                size: 15, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Terapkan',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
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
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pengelolaMain
              : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isSelected
                ? AppColors.pengelolaMain
                : AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.pengelolaMain
                        .withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : Colors.grey.shade600,
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
              : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: hasValue
                ? AppColors.pengelolaMain.withValues(alpha: 0.4)
                : AppColors.outlineVariant.withValues(alpha: 0.4),
            width: hasValue ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 15,
              color: hasValue
                  ? AppColors.pengelolaMain
                  : Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasValue ? FormatHelper.date(value) : label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                  color: hasValue
                      ? AppColors.pengelolaMain
                      : Colors.grey.shade500,
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

// ── Dropdown Field ────────────────────────────────────────────────────────────

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textPrimary,
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade400,
          fontFamily: 'PlusJakartaSans',
        ),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.pengelolaMain,
            width: 1.5,
          ),
        ),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.grey.shade400,
      ),
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
      ..lineTo(0, size.height * 0.76)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.95,
        size.width * 0.5,
        size.height * 0.80,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.66,
        size.width,
        size.height * 0.78,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = const Color(0xFF43A047).withValues(alpha: 0.3);

    final path2 = Path()
      ..moveTo(0, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.48,
        size.width * 0.55,
        size.height * 0.63,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.76,
        size.width,
        size.height * 0.60,
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