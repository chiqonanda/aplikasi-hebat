import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
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
      backgroundColor: const Color(0xFFF5F8FC),
      bottomNavigationBar: const KelurahanBottomNavBar(currentIndex: 1),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: AppLoadingState(message: 'Memuat data bank sampah...'),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchBankSampah,
          color: AppColors.kelurahanMain,
          backgroundColor: Colors.white,
          child: CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ─────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader(context)),

              // ── Search & Quick Stats ─────────────────────────
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
                      const SizedBox(height: 18),

                      // Section header
                      Obx(() => Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
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
                                'Daftar Bank Sampah',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.kelurahanDark,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${controller.listBankFiltered.length} unit',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              // ── List / Empty ──────────────────────────────────
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
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ModernBankCard(
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
          top: 35,
          right: 65,
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
                        'Manajemen Bank Sampah',
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
                        'Kelola seluruh unit bank sampah kelurahan',
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
                    Icons.storefront_rounded,
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

  // ── Search Field ────────────────────────────────────────────────────────

  Widget _buildSearchField() {
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
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.kelurahanDark,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          hintText: 'Cari bank sampah...',
          hintStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade400,
            size: 20,
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

  // ── Quick Stats ──────────────────────────────────────────────────────────

  Widget _buildQuickStats() {
    return Obx(() {
      final total = controller.listBankFiltered.length;
      final aktif = controller.listBankFiltered.where((e) => e.isActive).length;
      final nonaktif = total - aktif;

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A2540), Color(0xFF1E88E5)],
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
        child: Row(
          children: [
            Expanded(
              child: _MiniStatItem(
                title: 'Total Unit',
                value: '$total',
                icon: Icons.storefront_rounded,
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            Expanded(
              child: _MiniStatItem(
                title: 'Aktif',
                value: '$aktif',
                icon: Icons.check_circle_rounded,
                valueColor: const Color(0xFF69F0AE),
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            Expanded(
              child: _MiniStatItem(
                title: 'Nonaktif',
                value: '$nonaktif',
                icon: Icons.pause_circle_rounded,
                valueColor: const Color(0xFFFFD180),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Mini Stat Item ────────────────────────────────────────────────────────────

class _MiniStatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color valueColor;

  const _MiniStatItem({
    required this.title,
    required this.value,
    required this.icon,
    this.valueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: valueColor,
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
      ),
    );
  }
}

// ── Modern Bank Card ──────────────────────────────────────────────────────────

class _ModernBankCard extends StatelessWidget {
  final BankSampahModel bank;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _ModernBankCard({
    required this.bank,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  static const _accents = [
    Color(0xFF1565C0),
    Color(0xFF00838F),
    Color(0xFF6A1B9A),
    Color(0xFF2E7D32),
  ];
  static const _accentBgs = [
    Color(0xFFE3F2FD),
    Color(0xFFE0F7FA),
    Color(0xFFF3E5F5),
    Color(0xFFE8F5E9),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = bank.isActive ? _accents[index % _accents.length] : Colors.grey.shade400;
    final accentBg = bank.isActive ? _accentBgs[index % _accentBgs.length] : Colors.grey.shade100;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(14),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accentBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.storefront_rounded,
                color: accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          bank.nama,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.kelurahanDark,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Status dot
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(left: 6, top: 3),
                        decoration: BoxDecoration(
                          color: bank.isActive
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFE65100),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // RT/RW + Alamat row
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (bank.rt != null || bank.rw != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accentBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            [
                              if (bank.rt != null) 'RT ${bank.rt}',
                              if (bank.rw != null) 'RW ${bank.rw}',
                            ].join(' • '),
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                          ),
                        ),
                      Text(
                        bank.isActive ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: bank.isActive
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),

                  if (bank.alamat != null && bank.alamat!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: Colors.grey.shade400,
                        ),
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
                ],
              ),
            ),
            const SizedBox(width: 4),

            // Action menu
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_horiz_rounded,
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
                      Icon(Icons.edit_rounded, size: 15, color: Colors.blue.shade700),
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
                        bank.isActive ? Icons.toggle_off_rounded : Icons.toggle_on_rounded,
                        size: 16,
                        color: bank.isActive ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
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
                      const Icon(Icons.delete_rounded, size: 15, color: AppColors.error),
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
        colors: AppColors.kelurahanGradient,
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
      ..color = const Color(0xFF42A5F5).withValues(alpha: 0.3);

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