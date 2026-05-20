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
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // ── Header gradient ──────────────────────────
          _buildHeader(context),

          // ── Form scrollable ──────────────────────────
          Expanded(
            child: Form(
              key: controller.formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                physics: const BouncingScrollPhysics(),
                children: [
                  // ── Jenis Sampah ────────────────────
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

                  // ── Jumlah & Satuan ─────────────────
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
                            () => _DropdownField<String>(
                              label: 'Satuan *',
                              hint: 'Satuan',
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Harga Manual (WIP) ──────────────
                  _HargaManualSection(),
                  const SizedBox(height: 14),

                  // ── Tanggal Pengelolaan ─────────────
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
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                    onPressed: controller.clearTanggal,
                                  )
                                : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Harga snapshot otomatis ─────────
                  Obx(() {
                    if (controller.hargaSnapshot.value == null) {
                      return const SizedBox.shrink();
                    }
                    return _buildHargaSnapshot();
                  }),

                  // ── Catatan ─────────────────────────
                  _SectionCard(
                    icon: Icons.notes_rounded,
                    iconColor: const Color(0xFF37474F),
                    iconBg: const Color(0xFFECEFF1),
                    title: 'Catatan',
                    child: AppTextField(
                      controller: controller.catatanController,
                      label: 'Catatan (opsional)',
                      hint: 'Tambahkan catatan jika perlu',
                      prefixIcon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Tombol Simpan ───────────────────
                  Obx(() => _buildSaveButton()),
                  const SizedBox(height: 12),
                  _buildCancelButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 22,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withOpacity(0.25), width: 1),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.isEditMode
                      ? 'Edit Data Sampah'
                      : 'Input Data Sampah',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  controller.isEditMode
                      ? 'Perbarui data pengelolaan'
                      : 'Tambah data pengelolaan baru',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Image.asset(
              'assets/images/logo.png', // sesuaikan path dengan lokasi file logo
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
          ),
        ],
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFF2E7D32).withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.sell_outlined,
                      color: Color(0xFF2E7D32), size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Harga Terdaftar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${FormatHelper.currency(controller.hargaSnapshot.value!.hargaPerSatuan)} / ${controller.hargaSnapshot.value!.satuan?.singkatan ?? ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
            if (controller.jumlahController.text.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                height: 1,
                color: Colors.grey.shade100,
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimasi Total',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
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
                  colors: [Color(0xFF2E7D32), Color(0xFF43A047)]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: controller.isLoading.value
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.35),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey.shade100,
          ),
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
// Harga Manual Section (WIP)
// ─────────────────────────────────────────

class _HargaManualSection extends StatelessWidget {
  const _HargaManualSection();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.sell_outlined,
                          color: Color(0xFFE65100), size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Harga Manual',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // WIP badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFB74D)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.construction_rounded,
                              size: 10, color: Color(0xFFE65100)),
                          SizedBox(width: 4),
                          Text(
                            'Segera Hadir',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.grey.shade100,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Info banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFFFD54F), width: 1),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 18, color: Color(0xFFF57F17)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Fitur input harga manual masih dalam pengembangan dan akan segera tersedia pada versi berikutnya.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF5D4037),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Disabled field
                    IgnorePointer(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.sell_outlined,
                                color: Colors.grey.shade400, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              'Harga per Satuan (Rp)',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Estimasi Total:',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400)),
                          Text('Rp —',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade400,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Absorb pointer overlay
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AbsorbPointer(
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
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
        color: Color(0xFF1A1A2E),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.red.shade300, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: Colors.grey.shade400),
    );
  }
}