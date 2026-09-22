import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../controllers/kelurahan/bank_sampah_controller.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/bank_sampah_model.dart';
import '../../core/widgets/bank_sampah_map.dart';
import '../../core/widgets/motion.dart';

class BankSampahListView extends GetView<BankSampahController> {
  const BankSampahListView({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final isFabVisible = true.obs;

    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (isFabVisible.value) isFabVisible.value = false;
      } else if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!isFabVisible.value) isFabVisible.value = true;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundKelurahan,
      bottomNavigationBar: const KelurahanBottomNavBar(currentIndex: 1),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: AppLoadingState(message: 'Memuat data bank sampah...'),
          );
        }

        return PullToRefresh(
          onRefresh: controller.fetchBankSampah,
          color: AppColors.kelurahanMain,
          child: CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildSearchField(),
                        const SizedBox(height: 14),
                        _buildFilterChips(),
                        const SizedBox(height: 14),
                        _buildStatsCard(),
                        const SizedBox(height: 22),
                        _buildSectionHeader(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),

              // ── List / Empty ──────────────────────────────────
              Obx(() {
                if (controller.listBankFiltered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AppEmptyState(
                        title: 'Belum Ada Bank Sampah',
                        subtitle:
                            'Tambahkan data bank sampah pertama untuk mulai mengelola aktivitas lingkungan.',
                        icon: Icons.storefront_rounded,
                        actionLabel: 'Tambah Bank Sampah',
                        onAction: () {
                          controller.resetForm();
                          Get.toNamed(AppRoutes.formBankSampah);
                        },
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final bank = controller.listBankFiltered[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _BsuCard(
                            bank: bank,
                            index: index,
                            onEdit: () {
                              controller.initEdit(bank);
                              Get.toNamed(AppRoutes.formBankSampah);
                            },
                            onDelete: () => controller.deleteBank(bank),
                            onToggleActive: () => controller.toggleAktif(bank),
                          ),
                        );
                      },
                      childCount: controller.listBankFiltered.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),

      // ── FAB ───────────────────────────────────────────────────
      floatingActionButton: Obx(
        () => AnimatedSlide(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          offset: isFabVisible.value ? Offset.zero : const Offset(0, 2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: isFabVisible.value ? 1 : 0,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppColors.kelurahanMain, AppColors.kelurahanAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.kelurahanMain.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                elevation: 0,
                highlightElevation: 0,
                backgroundColor: Colors.transparent,
                onPressed: () {
                  controller.resetForm();
                  Get.toNamed(AppRoutes.formBankSampah);
                },
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                label: const Text(
                  'Tambah Bank Sampah',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header (gradient biru sesuai mockup) ─────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.kelurahanDark,
            AppColors.kelurahanMain,
            AppColors.kelurahanAccent,
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 80,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WILAYAH BINAAN BISA',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Manajemen Bank Sampah',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                                height: 1.1,
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
                          Icons.map_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Chip wilayah + update
                  Row(
                    children: [
                      Obx(() => _HeaderChip(
                            icon: Icons.location_on_rounded,
                            text:
                                'Kel. Gunung Linggal • ${controller.jumlahRw} RW Binaan',
                          )),
                      const Spacer(),
                      Text(
                        'Update data: Hari ini',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Kelola operasional, pantau tonase penimbangan, dan dampaki seluruh unit Bank Sampah Unit (BSU).',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Field ────────────────────────────────────────────────────────
  Widget _buildSearchField() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearch,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.kelurahanDark,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          hintText: 'Cari BSU, nama ketua, RW / RT...',
          hintStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        onPressed: controller.clearSearch,
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.kelurahanLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: AppColors.kelurahanMain,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              IconButton(
                onPressed: () => showPetaSemuaBankSampah(
                  Get.context!,
                  items: controller.listBankSampah
                      .map((b) => BankSampahPetaItem(
                            nama: b.nama,
                            alamat: b.alamat,
                            jamOperasional: b.jamOperasional,
                            lat: b.latitude,
                            lng: b.longitude,
                            onLihatProfil: b.isActive
                                ? () => Get.toNamed(AppRoutes.detailBankSampah,
                                    arguments: b)
                                : null,
                          ))
                      .toList(),
                ),
                icon: Icon(Icons.filter_list_rounded,
                    color: Colors.grey.shade400, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Filter Chips ─────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          children: [
            _FilterChip(
              label: 'Semua RW',
              count: controller.listBankSampah.length,
              selected: controller.selectedFilter.value == 0,
              onTap: () => controller.selectedFilter.value = 0,
            ),
            const SizedBox(width: 10),
            _FilterChip(
              label: 'Aktif',
              count: controller.totalAktif,
              dotColor: AppColors.pengelolaMain,
              selected: controller.selectedFilter.value == 1,
              onTap: () => controller.selectedFilter.value = 1,
            ),
            const SizedBox(width: 10),
            _FilterChip(
              label: 'Perlu Pendampingan',
              count: controller.totalNonaktif,
              dotColor: AppColors.orange,
              selected: controller.selectedFilter.value == 2,
              onTap: () => controller.selectedFilter.value = 2,
            ),
          ],
        ),
      );
    });
  }

  // ── Stats Card ───────────────────────────────────────────────────────────
  Widget _buildStatsCard() {
    return Obx(() {
      final total = controller.listBankSampah.length;
      final aktif = controller.totalAktif;
      final nonaktif = controller.totalNonaktif;
      final partisipasi = total == 0 ? 0.0 : aktif / total;

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.kelurahanDark, AppColors.kelurahanMain],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.kelurahanMain.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.storefront_rounded,
                    value: '$total',
                    title: 'Total Unit',
                    iconBg: AppColors.kelurahanAccent,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.check_rounded,
                    value: '$aktif',
                    title: 'Aktif Rutin',
                    iconBg: AppColors.pengelolaMain,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.warning_amber_rounded,
                    value: '$nonaktif',
                    title: 'Evaluasi/Off',
                    iconBg: AppColors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.mintAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tingkat Partisipasi Wilayah: ',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${(partisipasi * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mintAccent,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.rekapBulanan),
                  child: Text(
                    'Rekap Bulanan →',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.85),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ── Section Header ───────────────────────────────────────────────────────
  Widget _buildSectionHeader() {
    return Obx(() => Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.kelurahanMain,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Daftar Bank Sampah Unit',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.kelurahanDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${controller.listBankFiltered.length} dari ${controller.listBankSampah.length} terhubung',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => showPetaSemuaBankSampah(
                Get.context!,
                items: controller.listBankSampah
                    .map((b) => BankSampahPetaItem(
                          nama: b.nama,
                          alamat: b.alamat,
                          jamOperasional: b.jamOperasional,
                          lat: b.latitude,
                          lng: b.longitude,
                          onLihatProfil: b.isActive
                              ? () =>
                                  Get.toNamed(AppRoutes.detailBankSampah, arguments: b)
                              : null,
                        ))
                    .toList(),
              ),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(Icons.map_rounded,
                    color: AppColors.kelurahanMain, size: 18),
              ),
            ),
          ],
        ));
  }
}

// ── Header Chip ──────────────────────────────────────────────────────────────

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.85)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final Color? dotColor;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.kelurahanMain : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                selected ? AppColors.kelurahanMain : AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.kelurahanMain.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.kelurahanDark,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Item ────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;
  final Color iconBg;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.title,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}

// ── BSU Stat Column ─────────────────────────────────────────────────────────

class _BsuStatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _BsuStatColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.kelurahanDark,
          ),
        ),
      ],
    );
  }
}

// ── BSU Card (gaya mockup) ───────────────────────────────────────────────

class _BsuCard extends StatelessWidget {
  final BankSampahModel bank;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _BsuCard({
    required this.bank,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  BankSampahController get controller => Get.find<BankSampahController>();

  static const _accents = [
    AppColors.blueDeep,
    AppColors.teal,
    AppColors.purple,
    AppColors.pengelolaMain,
  ];
  static const _accentBgs = [
    AppColors.kelurahanLight,
    AppColors.tealLight,
    AppColors.purpleLight,
    AppColors.pengelolaLight,
  ];

  @override
  Widget build(BuildContext context) {
    final accent =
        bank.isActive ? _accents[index % _accents.length] : Colors.grey.shade500;
    final accentBg =
        bank.isActive ? _accentBgs[index % _accentBgs.length] : Colors.grey.shade100;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(color: accent, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accentBg,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(Icons.storefront_rounded, color: accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bank.nama,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.kelurahanDark,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          [
                            if (bank.rw != null && bank.rw!.isNotEmpty)
                              'RW ${bank.rw}',
                            if (bank.rt != null && bank.rt!.isNotEmpty)
                              '• RT ${bank.rt!.split(',').map((e) => e.trim()).join(', ')}',
                          ].join(' '),
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: bank.isActive
                        ? AppColors.pengelolaLight
                        : AppColors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    bank.isActive ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: bank.isActive
                          ? AppColors.pengelolaMain
                          : AppColors.orange,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  offset: const Offset(0, 30),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'toggle') onToggleActive();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      height: 40,
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded,
                              size: 15, color: Colors.blue.shade700),
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
                      value: 'toggle',
                      height: 40,
                      child: Row(
                        children: [
                          Icon(
                            bank.isActive
                                ? Icons.toggle_off_rounded
                                : Icons.toggle_on_rounded,
                            size: 16,
                            color: bank.isActive
                                ? AppColors.orange
                                : AppColors.pengelolaMain,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            bank.isActive ? 'Nonaktifkan' : 'Aktifkan',
                            style: const TextStyle(
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
            if (bank.alamat != null && bank.alamat!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      bank.alamat!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // Stats row — data nyata dari pengelolaan_sampah
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.backgroundKelurahan,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(() => Row(
                    children: [
                      Expanded(
                        child: _BsuStatColumn(
                          label: 'Terekelola',
                          value:
                              '${controller.tonTerekelola(bank.id)} Ton',
                        ),
                      ),
                      Expanded(
                        child: _BsuStatColumn(
                          label: 'Nasabah',
                          value:
                              '${controller.statJumlahNasabah[bank.id] ?? 0} KK',
                        ),
                      ),
                      Expanded(
                        child: _BsuStatColumn(
                          label: 'Jadwal Timbang',
                          value: bank.isActive ? 'Rutin' : 'Evaluasi',
                          valueColor: bank.isActive
                              ? AppColors.pengelolaMain
                              : AppColors.orange,
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
