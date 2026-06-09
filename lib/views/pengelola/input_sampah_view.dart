import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/pengelola/input_sampah_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/utils/validator.dart';
import '../../core/widgets/app_widgets.dart';

class InputSampahView extends GetView<InputSampahController> {
  const InputSampahView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppPageHeader replacing default header
            AppPageHeader(
              title: controller.isEditMode ? 'Edit Data Sampah' : 'Input Data Sampah',
              subtitle: controller.isEditMode
                  ? 'Perbarui data pengelolaan'
                  : 'Tambah data pengelolaan baru',
              gradientColors: AppColors.pengelolaGradient,
              showBack: true,
            ),

            // Form scrollable
            Expanded(
              child: Form(
                key: controller.formKey,
                child: ListView(
                  padding: AppTheme.pagePaddingAll,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Jenis Sampah
                    _SectionCard(
                      icon: Icons.category_outlined,
                      iconColor: const Color(0xFF6A1B9A),
                      iconBg: const Color(0xFFF3E5F5),
                      title: 'Jenis Sampah',
                      child: Column(
                        children: [
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
                                validator: (v) => AppValidator.required(v,
                                    fieldName: 'Kategori'),
                                onChanged: controller.onKategoriChanged,
                              )),

                          // Sub Kategori
                          Obx(() {
                            if (controller.selectedKategoriId.value.isEmpty ||
                                controller.listSubKategori.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(children: [
                              const SizedBox(height: 14),
                              _DropdownField<String>(
                                label: 'Sub Kategori *',
                                hint: 'Pilih sub kategori',
                                value: controller
                                        .selectedSubKategoriId.value.isEmpty
                                    ? null
                                    : controller.selectedSubKategoriId.value,
                                items: controller.listSubKategori
                                    .map((s) => DropdownMenuItem(
                                          value: s.id,
                                          child: Text(s.nama),
                                        ))
                                    .toList(),
                                validator: (v) => AppValidator.required(v,
                                    fieldName: 'Sub Kategori'),
                                onChanged: controller.onSubKategoriChanged,
                              ),
                            ]);
                          }),

                          // Tipe
                          Obx(() {
                            if (controller.selectedSubKategoriId.value.isEmpty ||
                                controller.listTipe.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(children: [
                              const SizedBox(height: 14),
                              _DropdownField<String>(
                                label: 'Tipe *',
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
                                validator: (v) =>
                                    AppValidator.required(v, fieldName: 'Tipe'),
                                onChanged: controller.onTipeChanged,
                              ),
                            ]);
                          }),

                          // Jenis Sampah
                          Obx(() {
                            if (controller.listJenisSampah.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            if (controller.listTipe.isNotEmpty &&
                                controller.selectedTipeId.value.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(children: [
                              const SizedBox(height: 14),
                              _DropdownField<String>(
                                label: 'Jenis Sampah *',
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
                                validator: (v) => AppValidator.required(v,
                                    fieldName: 'Jenis Sampah'),
                                onChanged: controller.onJenisChanged,
                              ),
                            ]);
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Jumlah & Satuan
                    _SectionCard(
                      icon: Icons.scale_outlined,
                      iconColor: const Color(0xFF1565C0),
                      iconBg: const Color(0xFFE3F2FD),
                      title: 'Jumlah & Satuan',
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: AppTextField(
                              controller: controller.jumlahController,
                              label: 'Jumlah *',
                              hint: 'Contoh: 12.5',
                              prefixIcon: Icons.scale_outlined,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: AppValidator.jumlah,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(
                              () => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _DropdownField<String>(
                                    label: 'Satuan *',
                                    hint: 'Satuan',
                                    enabled: !controller.isKategoriAnorganik && !controller.isMinyakJelantah,
                                    value:
                                        controller.selectedSatuanId.value.isEmpty
                                            ? null
                                            : controller.selectedSatuanId.value,
                                    items: controller.listSatuan
                                        .map((s) => DropdownMenuItem(
                                              value: s.id,
                                              child: Text(s.singkatan),
                                            ))
                                        .toList(),
                                    validator: (v) => AppValidator.required(v,
                                        fieldName: 'Satuan'),
                                    onChanged: (v) =>
                                        controller.selectedSatuanId.value =
                                            v ?? '',
                                  ),
                                  if (controller.isKategoriAnorganik) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.infoContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.lock_outline_rounded,
                                              size: 12,
                                              color: AppColors.info,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Kunci kg (An Organik)',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.info,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ] else if (controller.isMinyakJelantah) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.infoContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.lock_outline_rounded,
                                              size: 12,
                                              color: AppColors.info,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Kunci ltr (Minyak Jelantah)',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.info,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ] else if (controller.isSatuanAuto) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.auto_awesome,
                                              size: 12,
                                              color: AppColors.onSecondaryContainer,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Otomatis dari jenis sampah',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    AppColors.onSecondaryContainer,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tanggal Pengelolaan
                    _SectionCard(
                      icon: Icons.calendar_today_outlined,
                      iconColor: const Color(0xFF00838F),
                      iconBg: const Color(0xFFE0F7FA),
                      title: 'Tanggal Pengelolaan',
                      child: Obx(
                        () => AppTextField(
                          controller: controller.tanggalController,
                          label: 'Tanggal *',
                          hint: 'Pilih tanggal',
                          prefixIcon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onTap: () => controller.pickTanggal(context),
                          validator: (_) => AppValidator.tanggal(
                              controller.selectedTanggal.value),
                          suffixIcon:
                              controller.selectedTanggal.value != null
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear_rounded,
                                        color: AppColors.outline,
                                        size: 18,
                                      ),
                                      onPressed: controller.clearTanggal,
                                    )
                                  : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Harga snapshot otomatis
                    Obx(() {
                      if (controller.hargaSnapshot.value == null) {
                        return const SizedBox.shrink();
                      }
                      return _buildHargaSnapshot();
                    }),

                    // Summary Card
                    _SummaryCard(controller: controller),
                    const SizedBox(height: 14),

                    // Catatan Collapsible
                    _CollapsibleCatatanSection(controller: controller),
                    const SizedBox(height: 24),

                    // Tombol Simpan
                    Obx(() => _buildSaveButton()),
                    const SizedBox(height: 12),
                    _buildCancelButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Harga Snapshot ──────────────────────────────────────────────────────

  Widget _buildHargaSnapshot() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.pengelolaMain.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.pengelolaMain.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.pengelolaLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.sell_outlined,
                      color: AppColors.pengelolaMain, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Harga Terdaftar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.pengelolaLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${FormatHelper.currency(controller.hargaSnapshot.value!.hargaPerSatuan)} / ${controller.hargaSnapshot.value!.satuan?.singkatan ?? ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pengelolaMain,
                    ),
                  ),
                ),
              ],
            ),
            if (controller.jumlahController.text.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estimasi Total',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    FormatHelper.currency(
                      (double.tryParse(controller.jumlahController.text
                                  .replaceAll(',', '.')) ??
                              0) *
                          controller.hargaSnapshot.value!.hargaPerSatuan,
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00838F),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Save Button ─────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: controller.isLoading.value ? null : controller.simpan,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: controller.isLoading.value
              ? const LinearGradient(
                  colors: [Color(0xFF81C784), Color(0xFF81C784)])
              : const LinearGradient(
                  colors: AppColors.pengelolaGradient),
          borderRadius: BorderRadius.circular(18),
          boxShadow: controller.isLoading.value
              ? []
              : [
                  BoxShadow(
                    color: AppColors.pengelolaMain.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (controller.isLoading.value)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              const Icon(Icons.save_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              controller.isEditMode ? 'Simpan Perubahan' : 'Simpan Data',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Cancel Button ────────────────────────────────────────────────────────

  Widget _buildCancelButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.pengelolaMain, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Batal',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.pengelolaMain,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Section Card
// ─────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _SectionCard({
    required this.title,
    required this.child,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Dropdown Field
// ─────────────────────────────────────────

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
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: enabled ? AppColors.surfaceLowest : AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.pengelolaMain, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      dropdownColor: AppColors.surfaceLowest,
      borderRadius: BorderRadius.circular(16),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.outline),
    );
  }
}

// ─────────────────────────────────────────
// Summary Card
// ─────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final InputSampahController controller;

  const _SummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.pengelolaLight, Color(0xFFC8E6C9)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF81C784).withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.pengelolaMain.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8E6C9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.assignment_outlined, color: AppColors.pengelolaMain, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Ringkasan Input',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.pengelolaDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 1,
              color: const Color(0xFF81C784).withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
            
            _buildSummaryRow('Jenis Sampah', controller.jenisSampahBreadcrumb),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Jumlah', 
              '${FormatHelper.number(controller.rxJumlah.value)} ${controller.selectedSatuanSingkatan}',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow('Tanggal', controller.selectedTanggalFormat),
            
            if (controller.hargaSnapshot.value != null) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Harga/Satuan',
                '${FormatHelper.currency(controller.hargaSnapshot.value!.hargaPerSatuan)} / ${controller.hargaSnapshot.value!.satuan?.singkatan ?? ''}',
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Estimasi Total',
                FormatHelper.currency(
                  controller.rxJumlah.value * controller.hargaSnapshot.value!.hargaPerSatuan,
                ),
                isHighlight: true,
              ),
            ],
          ],
        ),
      ),
    ));
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.pengelolaDark.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(
          ': ',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.pengelolaDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isHighlight ? AppColors.pengelolaDark : AppColors.pengelolaMain,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Collapsible Catatan Section
// ─────────────────────────────────────────

class _CollapsibleCatatanSection extends StatelessWidget {
  final InputSampahController controller;

  const _CollapsibleCatatanSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notes_rounded, color: AppColors.textSecondary, size: 18),
          ),
          title: const Text(
            'Tambah Catatan (Opsional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          children: [
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppTextField(
                controller: controller.catatanController,
                label: 'Catatan (opsional)',
                hint: 'Tambahkan catatan jika perlu',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}