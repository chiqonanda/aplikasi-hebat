import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../controllers/kelurahan/nasabah_controller.dart';
import '../../core/services/session_service.dart';
import '../../models/nasabah_model.dart';

class NasabahListView extends GetView<NasabahController> {
  const NasabahListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isPengelola = SessionService.to.isPengelola;
    final gradient = isPengelola ? AppColors.pengelolaGradient : AppColors.kelurahanGradient;
    final primaryColor = isPengelola ? AppColors.pengelolaMain : AppColors.kelurahanMain;
    final secondaryColor = isPengelola ? const Color(0xFF43A047) : const Color(0xFF42A5F5);
    final scaffoldBg = isPengelola ? const Color(0xFFF5F7FA) : const Color(0xFFF5F8FC);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => controller.fetchData(),
        color: primaryColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(context, gradient, secondaryColor),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: _buildInfoBanner(primaryColor, secondaryColor),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: _buildSearchBar(),
              ),
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                );
              }

              final filteredList = controller.listNasabahFiltered;

              if (filteredList.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(primaryColor, secondaryColor),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                sliver: SliverList.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final nasabah = filteredList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildNasabahCard(
                        context,
                        nasabah,
                        index,
                        secondaryColor,
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, List<Color> gradient, Color secondary) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 165),
          painter: _WavePainter(gradient: gradient, secondary: secondary),
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
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kelola Nasabah',
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
                        'Kelola nama-nama nasabah terdaftar',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.fetchData(),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
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

  Widget _buildInfoBanner(Color primary, Color secondary) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tentang Data Nasabah',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nasabah otomatis terdaftar saat Anda mencatat transaksi sampah baru. Anda dapat memperbarui ejaan nama atau menghapusnya dari riwayat transaksi.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11.5,
                    color: AppColors.info.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
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
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Cari nama nasabah...',
          hintStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 22),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: Colors.grey.shade500),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink()),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  // ── Nasabah Card ───────────────────────────────────────────────────────────

  static const _accents = [
    Color(0xFF1565C0),
    Color(0xFF00838F),
    Color(0xFF6A1B9A),
    Color(0xFF2E7D32),
    Color(0xFFE65100),
  ];
  static const _accentBgs = [
    Color(0xFFE3F2FD),
    Color(0xFFE0F7FA),
    Color(0xFFF3E5F5),
    Color(0xFFE8F5E9),
    Color(0xFFFBE9E7),
  ];

  Widget _buildNasabahCard(
    BuildContext context,
    NasabahModel nasabah,
    int index,
    Color secondary,
  ) {
    final initials = nasabah.nama.trim().isNotEmpty ? nasabah.nama.trim()[0].toUpperCase() : '?';
    final accent = _accents[index % _accents.length];
    final accentBg = _accentBgs[index % _accentBgs.length];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: accent, width: 3)),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              nasabah.nama,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              controller.initEdit(nasabah);
              _showFormDialog(context);
            },
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.edit_note_rounded, color: Color(0xFF1565C0), size: 20),
            ),
          ),
          GestureDetector(
            onTap: () => _showDeleteConfirm(context, nasabah),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFD32F2F), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────

  Widget _buildEmptyState(Color primary, Color secondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.people_outline_rounded, size: 38, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nasabah Tidak Ditemukan',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                controller.searchQuery.value.isNotEmpty
                    ? 'Tidak ada nama nasabah "${controller.searchQuery.value}"'
                    : 'Belum ada transaksi dengan nama nasabah di BSU ini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              )),
        ],
      ),
    );
  }

  // ── Form Dialog ────────────────────────────────────────────────────────────

  void _showFormDialog(BuildContext context) {
    final isPengelola = SessionService.to.isPengelola;
    final primary = isPengelola ? AppColors.pengelolaMain : AppColors.kelurahanMain;
    final secondary = isPengelola ? const Color(0xFF43A047) : const Color(0xFF42A5F5);
    final dark = isPengelola ? AppColors.pengelolaDark : AppColors.kelurahanDark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [primary, secondary]),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              controller.isEditMode ? 'Edit Nama Nasabah' : 'Tambah Nasabah',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: dark,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.resetForm();
                            Get.back();
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(Icons.close_rounded, size: 17, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    Text(
                      'Nama Lengkap *',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.namaController,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _buildInputDecoration('Masukkan nama nasabah...', primary),
                    ),
                    const SizedBox(height: 24),

                    Obx(() => Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: controller.isSaving.value
                                    ? null
                                    : () {
                                        controller.resetForm();
                                        Get.back();
                                      },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  'Batal',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: controller.isSaving.value
                                    ? null
                                    : () async {
                                        final success = await controller.simpan();
                                        if (success) Get.back();
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [primary, secondary]),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primary.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: controller.isSaving.value
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Simpan',
                                          style: TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String hint, Color primary) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 13,
        color: Colors.grey.shade400,
      ),
      fillColor: const Color(0xFFF5F7FA),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }

  // ── Delete Confirm ─────────────────────────────────────────────────────────

  void _showDeleteConfirm(BuildContext context, NasabahModel nasabah) {
    final isPengelola = SessionService.to.isPengelola;
    final dark = isPengelola ? AppColors.pengelolaDark : AppColors.kelurahanDark;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hapus Nasabah?',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Apakah Anda yakin ingin menghapus nasabah "${nasabah.nama}"? Tindakan ini akan mengosongkan nama nasabah dari seluruh riwayat transaksinya namun tidak menghapus data timbangan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                          controller.deleteNasabah(nasabah.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD32F2F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Hapus',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Colors.white,
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
      },
    );
  }
}

// ── Wave Painter ──────────────────────────────────────────────────────────────

class _WavePainter extends CustomPainter {
  final List<Color> gradient;
  final Color secondary;

  _WavePainter({required this.gradient, required this.secondary});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradient,
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

    final paint2 = Paint()..color = secondary.withValues(alpha: 0.3);

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

    final paintDot = Paint()..color = Colors.white.withValues(alpha: 0.06);

    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.3), 40, paintDot);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.15), 25, paintDot);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => false;
}