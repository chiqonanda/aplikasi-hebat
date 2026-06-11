import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/design_tokens.dart';
import '../../controllers/kelurahan/bank_sampah_controller.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/bank_sampah_model.dart';

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
      backgroundColor: AppColors.background,
      bottomNavigationBar: const KelurahanBottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const AppLoadingState(message: 'Memuat data bank sampah...');
          }

          return RefreshIndicator(
            onRefresh: controller.fetchBankSampah,
            color: AppColors.kelurahanMain,
            backgroundColor: Colors.white,
            child: CustomScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header Page
                SliverToBoxAdapter(
                  child: AppPageHeader(
                    title: 'Manajemen',
                    subtitle: 'Bank Sampah',
                    gradientColors: AppColors.kelurahanGradient,
                    showBack: false,
                  ),
                ),

                // Search Bar & Stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      children: [
                        _buildSearchField(),
                        Obx(
                          () => AnimatedSlide(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            offset: isFabVisible.value ? Offset.zero : const Offset(0, -0.2),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: isFabVisible.value ? 1 : 0,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                height: isFabVisible.value ? null : 0,
                                margin: EdgeInsets.only(
                                  top: isFabVisible.value ? 18 : 0,
                                ),
                                child: isFabVisible.value ? _buildQuickStats() : const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // List Data or Empty State
                Obx(() {
                  if (controller.listBankFiltered.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppEmptyState(
                        title: 'Belum Ada Bank Sampah',
                        subtitle: 'Tambahkan data bank sampah pertama untuk mulai mengelola aktivitas lingkungan.',
                        icon: Icons.storefront_rounded,
                        actionLabel: 'Tambah Bank Sampah',
                        onAction: () {
                          controller.resetForm();
                          Get.toNamed(AppRoutes.formBankSampah);
                        },
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final bank = controller.listBankFiltered[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ModernBankCard(
                              bank: bank,
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
      ),

      // Floating Action Button with visual enhancements
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
                  colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
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
                icon: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                label: const Text(
                  'Tambah Bank Sampah',
                  style: TextStyle(
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

  // ── Search Field Widget ──────────────────────────────────────────────────
  Widget _buildSearchField() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEBF2FA),
          width: 1.2,
        ),
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
          fontWeight: FontWeight.w600,
          color: AppColors.kelurahanDark,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintText: 'Cari bank sampah...',
          hintStyle: const TextStyle(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.kelurahanMain,
            size: 22,
          ),
          suffixIcon: Obx(
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
        ),
      ),
    );
  }

  // ── Quick Stats Widget ───────────────────────────────────────────────────
  Widget _buildQuickStats() {
    return Obx(() {
      final total = controller.listBankFiltered.length;
      final aktif = controller.listBankFiltered.where((e) => e.isActive).length;
      final nonaktif = total - aktif;

      return Row(
        children: [
          Expanded(
            child: _MiniStatCard(
              title: 'Total',
              value: '$total',
              icon: Icons.store_rounded,
              iconBgColor: AppColors.kelurahanLight,
              iconColor: AppColors.kelurahanMain,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniStatCard(
              title: 'Aktif',
              value: '$aktif',
              icon: Icons.check_circle_rounded,
              iconBgColor: const Color(0xFFE8F5E9),
              iconColor: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniStatCard(
              title: 'Nonaktif',
              value: '$nonaktif',
              icon: Icons.pause_circle_rounded,
              iconBgColor: const Color(0xFFFFF3E0),
              iconColor: const Color(0xFFE65100),
            ),
          ),
        ],
      );
    });
  }
}

// ── Redesigned Mini Stat Card Widget ──────────────────────────────────────
class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEBF2FA),
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
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.kelurahanDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Redesigned Modern Bank Card Widget ────────────────────────────────────
class _ModernBankCard extends StatelessWidget {
  final BankSampahModel bank;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _ModernBankCard({
    required this.bank,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFEBF2FA),
            width: 1.2,
          ),
          boxShadow: DesignTokens.kelurahanShadowSm,
        ),
        child: Row(
          children: [
            // Store Icon Container
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: bank.isActive
                    ? const LinearGradient(
                        colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          Colors.grey.shade400,
                          Colors.grey.shade500,
                        ],
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (bank.isActive ? AppColors.kelurahanMain : Colors.grey).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Content Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 6),

                  // RT/RW Badge
                  if (bank.rt != null || bank.rw != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.kelurahanLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        [
                          if (bank.rt != null) 'RT ${bank.rt}',
                          if (bank.rw != null) 'RW ${bank.rw}',
                        ].join(' • '),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.kelurahanMain,
                        ),
                      ),
                    ),

                  // Alamat
                  if (bank.alamat != null && bank.alamat!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Color(0xFF42A5F5),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            bank.alamat!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: bank.isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: bank.isActive ? const Color(0xFFA5D6A7) : const Color(0xFFFFCC80),
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
                            color: bank.isActive ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          bank.isActive ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: bank.isActive ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Redesigned Action 3-dot popup
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.kelurahanLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.kelurahanMain,
                  size: 18,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'toggle') onToggleActive();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.kelurahanMain,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Edit',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.kelurahanDark),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        bank.isActive ? Icons.toggle_off_rounded : Icons.toggle_on_rounded,
                        size: 18,
                        color: bank.isActive ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        bank.isActive ? 'Nonaktifkan' : 'Aktifkan',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.kelurahanDark),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Colors.red,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Hapus',
                        style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
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