import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/kelurahan/bank_sampah_controller.dart';
import '../../models/bank_sampah_model.dart';

class BankSampahListView extends GetView<BankSampahController> {
  const BankSampahListView({super.key});

  // ── Theme Colors (Sama dengan Dashboard Kelurahan) ──────────────────────
  static const _blue900 = Color(0xFF0A2540);
  static const _blue800 = Color(0xFF0D3461);
  static const _blue500 = Color(0xFF1E88E5);
  static const _blue400 = Color(0xFF42A5F5);
  static const _blue50 = Color(0xFFE3F2FD);

  static const _bg = Color(0xFFF0F6FF);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final isFabVisible = true.obs;

    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (isFabVisible.value) isFabVisible.value = false;
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!isFabVisible.value) isFabVisible.value = true;
      }
    });

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: _blue500,
                strokeWidth: 2.6,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchBankSampah,
            color: _blue500,
            backgroundColor: Colors.white,
            child: CustomScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),

                // ── Search + Stats ────────────────────────────
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
                            offset: isFabVisible.value
                                ? Offset.zero
                                : const Offset(0, -0.2),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: isFabVisible.value ? 1 : 0,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                height: isFabVisible.value ? null : 0,
                                margin: EdgeInsets.only(
                                  top: isFabVisible.value ? 18 : 0,
                                ),
                                child: isFabVisible.value
                                    ? _buildQuickStats()
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // ── Empty State ───────────────────────────────
                if (controller.listBankFiltered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ModernEmptyState(
                      onAdd: () {
                        controller.resetForm();
                        Get.toNamed(AppRoutes.formBankSampah);
                      },
                    ),
                  )

                // ── List Data ─────────────────────────────────
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final bank =
                              controller.listBankFiltered[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ModernBankCard(
                              bank: bank,
                              onEdit: () {
                                controller.initEdit(bank);
                                Get.toNamed(
                                    AppRoutes.formBankSampah);
                              },
                              onDelete: () =>
                                  controller.deleteBank(bank),
                              onToggleActive: () =>
                                  controller.toggleAktif(bank),
                            ),
                          );
                        },
                        childCount:
                            controller.listBankFiltered.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),

      // ── Floating Action Button ──────────────────────────────────────────
      floatingActionButton: Obx(
        () => AnimatedSlide(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          offset: isFabVisible.value
              ? Offset.zero
              : const Offset(0, 2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: isFabVisible.value ? 1 : 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [_blue500, _blue400],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _blue500.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                elevation: 0,
                backgroundColor: Colors.transparent,
                onPressed: () {
                  controller.resetForm();
                  Get.toNamed(AppRoutes.formBankSampah);
                },
                icon: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  'Tambah Bank Sampah',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // Header
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
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
              bottomLeft: Radius.circular(34),
              bottomRight: Radius.circular(34),
            ),
          ),
          child: Column(
            children: [
              // Top Bar
              Row(
                children: [
                  _HeaderButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Get.back(),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manajemen',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'Bank Sampah',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),

        // Decorative Circle
        Positioned(
          top: -30,
          right: -20,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // Search Field
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _blue50,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: _blue500.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearch,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _blue900,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          hintText: 'Cari bank sampah...',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _blue500,
          ),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    onPressed: controller.clearSearch,
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _blue50,
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: _blue500,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // Quick Stats
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildQuickStats() {
    return Obx(() {
      final total = controller.listBankFiltered.length;
      final aktif = controller.listBankFiltered
          .where((e) => e.isActive)
          .length;

      final nonaktif = total - aktif;

      return Row(
        children: [
          Expanded(
            child: _MiniStatCard(
              title: 'Total',
              value: '$total',
              icon: Icons.store_rounded,
              gradient: const [
                _blue500,
                _blue400,
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MiniStatCard(
              title: 'Aktif',
              value: '$aktif',
              icon: Icons.check_circle_rounded,
              gradient: const [
                Color(0xFF26A69A),
                Color(0xFF4DD0E1),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MiniStatCard(
              title: 'Nonaktif',
              value: '$nonaktif',
              icon: Icons.pause_circle_rounded,
              gradient: const [
                Color(0xFFFF9800),
                Color(0xFFFFC107),
              ],
            ),
          ),
        ],
      );
    });
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Header Button
// ────────────────────────────────────────────────────────────────────────────

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Mini Stat Card
// ────────────────────────────────────────────────────────────────────────────

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.92),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Modern Bank Card
// ────────────────────────────────────────────────────────────────────────────

class _ModernBankCard extends StatelessWidget {
  final BankSampahModel bank;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  static const _blue900 = Color(0xFF0A2540);
  static const _blue500 = Color(0xFF1E88E5);
  static const _blue400 = Color(0xFF42A5F5);
  static const _blue50 = Color(0xFFE3F2FD);

  static const _green = Color(0xFF2E7D32);
  static const _greenBg = Color(0xFFE8F5E9);

  static const _orange = Color(0xFFF57C00);
  static const _orangeBg = Color(0xFFFFF3E0);

  static const _red = Color(0xFFD32F2F);

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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _blue50,
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: _blue500.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                gradient: bank.isActive
                    ? const LinearGradient(
                        colors: [_blue500, _blue400],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.grey.shade400,
                          Colors.grey.shade500,
                        ],
                      ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (bank.isActive
                            ? _blue500
                            : Colors.grey)
                        .withOpacity(0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          bank.nama,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _blue900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (bank.rt != null || bank.rw != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _blue50,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Text(
                        [
                          if (bank.rt != null)
                            'RT ${bank.rt}',
                          if (bank.rw != null)
                            'RW ${bank.rw}',
                        ].join(' • '),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _blue500,
                        ),
                      ),
                    ),

                  if (bank.alamat != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            bank.alamat!,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color:
                                  Colors.grey.shade700,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Status
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: bank.isActive
                          ? _greenBg
                          : _orangeBg,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          bank.isActive
                              ? Icons.check_circle
                              : Icons.pause_circle,
                          size: 15,
                          color: bank.isActive
                              ? _green
                              : _orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          bank.isActive
                              ? 'Aktif'
                              : 'Nonaktif',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w700,
                            color: bank.isActive
                                ? _green
                                : _orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Popup Menu
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _blue50,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.more_vert_rounded,
                  color: _blue500,
                  size: 20,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
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
                        size: 20,
                        color: _blue500,
                      ),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        bank.isActive
                            ? Icons.toggle_off_rounded
                            : Icons.toggle_on_rounded,
                        size: 20,
                        color: bank.isActive
                            ? _orange
                            : _green,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        bank.isActive
                            ? 'Nonaktifkan'
                            : 'Aktifkan',
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
                        size: 20,
                        color: _red,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Hapus',
                        style:
                            TextStyle(color: _red),
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

// ────────────────────────────────────────────────────────────────────────────
// Empty State
// ────────────────────────────────────────────────────────────────────────────

class _ModernEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  static const _blue900 = Color(0xFF0A2540);
  static const _blue500 = Color(0xFF1E88E5);
  static const _blue400 = Color(0xFF42A5F5);

  const _ModernEmptyState({
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _blue500.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_blue500, _blue400],
                  ),
                  borderRadius:
                      BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.store_mall_directory_rounded,
                  color: Colors.white,
                  size: 46,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Belum Ada Bank Sampah',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _blue900,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Tambahkan data bank sampah pertama untuk mulai mengelola aktivitas lingkungan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 20,
                  ),
                  label: const Text(
                    'Tambah Bank Sampah',
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _blue500,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}