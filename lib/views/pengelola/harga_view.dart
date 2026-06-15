import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/pengelola/harga_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/utils/validator.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/harga_sampah_model.dart';

class HargaView extends GetView<HargaController> {
  const HargaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: controller.fetchHarga,
        color: AppColors.pengelolaMain,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ───────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(context)),

            // ── Content ──────────────────────────────────────
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: AppLoadingState(message: 'Memuat daftar harga...'),
                  ),
                );
              }

              if (controller.listHarga.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: AppEmptyState(
                      icon: Icons.sell_outlined,
                      title: 'Belum Ada Data Harga',
                      subtitle: 'Tambahkan harga untuk tiap jenis sampah.',
                      actionLabel: 'Tambah Harga',
                      onAction: () => _showFormSheet(context, null),
                    ),
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.infoContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.info,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Harga akan otomatis tersimpan saat input data sampah.',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12.5,
                                  color: AppColors.info,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      ...controller.hargaPerKategori.entries.toList().asMap().entries.map((mapEntry) {
                        final index = mapEntry.key;
                        final entry = mapEntry.value;
                        final accent = _accents[index % _accents.length];
                        final accentBg = _accentBgs[index % _accentBgs.length];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section header
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: accent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A1A2E),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: accentBg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${entry.value.length}',
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              ...entry.value.map((harga) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _HargaCard(
                                      harga: harga,
                                      accent: accent,
                                      accentBg: accentBg,
                                      onEdit: () => _showFormSheet(context, harga),
                                      onDelete: () => controller.deleteHarga(harga),
                                    ),
                                  )),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.pengelolaMain.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showFormSheet(context, null),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  static const _accents = [
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFFE65100),
    Color(0xFF6A1B9A),
    Color(0xFF00838F),
  ];
  static const _accentBgs = [
    Color(0xFFE8F5E9),
    Color(0xFFE3F2FD),
    Color(0xFFFBE9E7),
    Color(0xFFF3E5F5),
    Color(0xFFE0F7FA),
  ];

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

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
                        'Daftar Harga Sampah',
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
                        'Harga per satuan jenis sampah',
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
                    Icons.sell_rounded,
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

  void _showFormSheet(BuildContext context, HargaSampahModel? existing) {
    if (existing != null) {
      controller.initEdit(existing);
    } else {
      controller.resetForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HargaFormSheet(controller: controller),
    );
  }
}

// ── Harga Card ────────────────────────────────────────────────────────────────

class _HargaCard extends StatelessWidget {
  final HargaSampahModel harga;
  final Color accent;
  final Color accentBg;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HargaCard({
    required this.harga,
    required this.accent,
    required this.accentBg,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(Icons.sell_outlined, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  harga.namaItem,
                  style: AppTextStyles.titleSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  harga.breadcrumb,
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
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                FormatHelper.currency(harga.hargaPerSatuan),
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              Text(
                '/ ${harga.satuan?.singkatan ?? '-'}',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
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
              borderRadius: BorderRadius.circular(12),
            ),
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
    );
  }
}

// ── Harga Form Sheet ─────────────────────────────────────────────────────────

class _HargaFormSheet extends StatelessWidget {
  final HargaController controller;

  const _HargaFormSheet({required this.controller});

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
            20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Form(
          key: controller.formKey,
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
                        Icons.sell_outlined,
                        color: AppColors.pengelolaMain,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      controller.isEditMode ? 'Edit Harga' : 'Tambah Harga',
                      style: const TextStyle(
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
                Obx(() => _DropdownField<String>(
                      label: 'Kategori *',
                      hint: 'Pilih kategori',
                      value: controller.selectedKategoriId.value.isEmpty
                          ? null
                          : controller.selectedKategoriId.value,
                      items: controller.listKategori
                          .map((k) => DropdownMenuItem(
                                value: k.id,
                                child: Text(k.nama),
                              ))
                          .toList(),
                      validator: (v) =>
                          AppValidator.required(v, fieldName: 'Kategori'),
                      onChanged: controller.onKategoriChanged,
                    )),
                const SizedBox(height: 12),

                // Sub kategori (opsional)
                Obx(() {
                  if (controller.selectedKategoriId.value.isEmpty ||
                      controller.listSubKategori.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      _DropdownField<String>(
                        label: 'Sub Kategori (opsional)',
                        hint: 'Pilih sub kategori',
                        value: controller.selectedSubKategoriId.value.isEmpty
                            ? null
                            : controller.selectedSubKategoriId.value,
                        items: controller.listSubKategori
                            .map((s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Text(s.nama),
                                ))
                            .toList(),
                        onChanged: controller.onSubKategoriChanged,
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }),

                // Tipe (opsional)
                Obx(() {
                  if (controller.selectedSubKategoriId.value.isEmpty ||
                      controller.listTipe.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      _DropdownField<String>(
                        label: 'Tipe (opsional)',
                        hint: 'Pilih tipe material',
                        value: controller.selectedTipeId.value.isEmpty
                            ? null
                            : controller.selectedTipeId.value,
                        items: controller.listTipe
                            .map((t) => DropdownMenuItem(
                                  value: t.id,
                                  child: Text(t.nama),
                                ))
                            .toList(),
                        onChanged: controller.onTipeChanged,
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }),

                // Jenis (opsional)
                Obx(() {
                  if (controller.listJenisSampah.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  if (controller.listTipe.isNotEmpty &&
                      controller.selectedTipeId.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      _DropdownField<String>(
                        label: 'Jenis Sampah (opsional)',
                        hint: 'Pilih jenis sampah',
                        value: controller.selectedJenisId.value.isEmpty
                            ? null
                            : controller.selectedJenisId.value,
                        items: controller.listJenisSampah
                            .map((j) => DropdownMenuItem(
                                  value: j.id,
                                  child: Text(j.nama),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            controller.selectedJenisId.value = v ?? '',
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }),

                // Harga & Satuan
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        controller: controller.hargaController,
                        label: 'Harga *',
                        hint: 'Contoh: 2500',
                        prefixIcon: Icons.payments_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: AppValidator.harga,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => _DropdownField<String>(
                            label: 'Satuan *',
                            hint: 'Satuan',
                            value: controller.selectedSatuanId.value.isEmpty
                                ? null
                                : controller.selectedSatuanId.value,
                            items: controller.listSatuan
                                .map((s) => DropdownMenuItem(
                                      value: s.id,
                                      child: Text(s.singkatan),
                                    ))
                                .toList(),
                            validator: (v) =>
                                AppValidator.required(v, fieldName: 'Satuan'),
                            onChanged: (v) =>
                                controller.selectedSatuanId.value = v ?? '',
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tombol
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.back(),
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
                          child: Center(
                            child: Text(
                              'Batal',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        final isSaving = controller.isSaving.value;
                        return GestureDetector(
                          onTap: isSaving ? null : controller.simpan,
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
                            child: Center(
                              child: isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          controller.isEditMode
                                              ? 'Simpan'
                                              : 'Tambah',
                                          style: const TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.check_rounded,
                                            size: 16, color: Colors.white),
                                      ],
                                    ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dropdown Field ────────────────────────────────────────────────────────────

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true,
      style: AppTextStyles.bodyLg,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: enabled ? const Color(0xFFF5F7FA) : const Color(0xFFEDEFF2),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        ),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(14),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
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