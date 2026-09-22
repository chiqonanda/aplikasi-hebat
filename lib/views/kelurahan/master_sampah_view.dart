import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../controllers/kelurahan/master_sampah_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/add_fab.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/kategori_model.dart';
import '../../models/sub_kategori_model.dart';
import '../../models/tipe_sampah_model.dart';
import '../../models/satuan_model.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/sampah_visuals.dart';
import '../../core/widgets/wave_painter.dart';

class MasterSampahView extends GetView<MasterSampahController> {
  const MasterSampahView({super.key});

  static const _tabs = [
    _TabInfo('Kategori',     Icons.category_outlined,    [AppColors.kelurahanDark, AppColors.kelurahanMain]),
    _TabInfo('Sub Kategori', Icons.layers_outlined,       [AppColors.teal, AppColors.cyan]),
    _TabInfo('Tipe',         Icons.style_outlined,        [AppColors.indigoDark, AppColors.indigo]),
    _TabInfo('Jenis',        Icons.eco_outlined,          [AppColors.tealDark, AppColors.tealMid]),
    _TabInfo('Satuan',       Icons.straighten_rounded,    [AppColors.purple, AppColors.purpleMid]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      bottomNavigationBar: const KelurahanBottomNavBar(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            // ── Wave Header ─────────────────────────────────────────────
            _buildWaveHeader(context),

            // ── Tab Bar ──────────────────────────────────────────────────
            _buildTabBar(),

            // ── Tab Content ──────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: AppLoadingState(message: 'Memuat data master sampah...'),
                  );
                }
                return switch (controller.activeTab.value) {
                  0 => _KategoriTab(controller: controller),
                  1 => _SubKategoriTab(controller: controller),
                  2 => _TipeTab(controller: controller),
                  3 => _JenisTab(controller: controller),
                  4 => _SatuanTab(controller: controller),
                  _ => const SizedBox.shrink(),
                };
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Wave Header ─────────────────────────────────────────────────────────
  Widget _buildWaveHeader(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 210),
          painter: WavePainter.blue(),
        ),
        const AmbientBlob(color: Color(0x14FFFFFF), size: 220),
        // Decorative circles
        Positioned(
          top: -20,
          right: -15,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          top: 35,
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
        Positioned(
          top: 10,
          left: -15,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jenis Sampah',
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
                    Obx(() => AnimatedValue(
                          value: (controller.listKategori.length +
                                  controller.listJenis.length)
                              .toDouble(),
                          builder: (v) => Text(
                            '${FormatHelper.number(v)} item dikelola',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              // Icon badge
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tab Bar ──────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: AppColors.scaffoldBg,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final isActive = controller.activeTab.value == i;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => controller.activeTab.value = i,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? LinearGradient(
                              colors: tab.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isActive ? null : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isActive
                            ? tab.gradientColors.first
                            : AppColors.kelurahanSurface,
                        width: 1.2,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: tab.gradientColors.first
                                    .withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          size: 15,
                          color: isActive
                              ? Colors.white
                              : tab.gradientColors.first,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: isActive
                                ? Colors.white
                                : AppColors.kelurahanDark,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Tab Info Model ───────────────────────────────────────────────────────────
class _TabInfo {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  const _TabInfo(this.label, this.icon, this.gradientColors);
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED: Bottom Sheet Tambah
// ─────────────────────────────────────────────────────────────────────────────
void _showAddSheet(
  BuildContext context, {
  required String title,
  required IconData titleIcon,
  required List<Color> gradientColors,
  required Widget formContent,
  required VoidCallback onSimpan,
  required MasterSampahController controller,
}) {
  Get.bottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        top: 0,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sheet Title
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(titleIcon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.kelurahanDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'Isi form dengan benar',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),
            const Divider(color: AppColors.dividerLight, height: 1, thickness: 1),
            const SizedBox(height: 18),

            formContent,
            const SizedBox(height: 24),

            // Submit button
            Obx(
              () => GestureDetector(
                onTap: controller.isSaving.value ? null : onSimpan,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: controller.isSaving.value
                          ? [Colors.grey.shade300, Colors.grey.shade400]
                          : gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: controller.isSaving.value
                        ? []
                        : [
                            BoxShadow(
                              color: gradientColors.first.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: Center(
                    child: controller.isSaving.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.save_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Simpan Data',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
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
      ),
    ),
  ).then((_) => controller.resetForm());
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED: Dropdown decoration
// ─────────────────────────────────────────────────────────────────────────────
InputDecoration _dropdownDecoration(
    String label, IconData icon, List<Color> gradientColors) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      fontFamily: 'PlusJakartaSans',
      color: gradientColors.first,
      fontWeight: FontWeight.w700,
      fontSize: 13,
    ),
    prefixIcon: Icon(icon, size: 18, color: gradientColors.first),
    filled: true,
    fillColor: AppColors.blueBg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.kelurahanSurface, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: gradientColors.first, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB: KATEGORI
// ─────────────────────────────────────────────────────────────────────────────
class _KategoriTab extends StatelessWidget {
  final MasterSampahController controller;
  const _KategoriTab({required this.controller});

  static const _grad = [AppColors.kelurahanDark, AppColors.kelurahanMain];

  Widget _buildFormFields() => Column(children: [
        _ModernTextField(
          controller: controller.namaController,
          label: 'Nama Kategori',
          hint: 'Contoh: Plastik, Kertas, Logam',
          icon: Icons.label_outline_rounded,
          gradientColors: _grad,
          validator: (v) =>
              v == null || v.isEmpty ? 'Nama wajib diisi' : null,
        ),
        const SizedBox(height: 14),
        _ModernTextField(
          controller: controller.deskripsiController,
          label: 'Deskripsi (opsional)',
          hint: 'Keterangan singkat kategori ini',
          icon: Icons.notes_rounded,
          gradientColors: _grad,
          maxLines: 2,
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _ModernFAB(
        label: 'Tambah Kategori',
        gradientColors: _grad,
        onPressed: () => _showAddSheet(
          context,
          title: 'Tambah Kategori',
          titleIcon: Icons.category_outlined,
          gradientColors: _grad,
          controller: controller,
          onSimpan: controller.simpanKategori,
          formContent: _buildFormFields(),
        ),
      ),
      body: Obx(() {
        final items = controller.listKategoriFiltered;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: _SearchFilterBar(
                  controller: controller, gradientColors: _grad),
            ),
            Expanded(
              child: items.isEmpty
                  ? const AppEmptyState(
                      icon: Icons.category_outlined,
                      title: 'Belum Ada Kategori',
                      subtitle: 'Tambahkan kategori sampah pertama Anda.',
                    )
                  : PullToRefresh(
                      onRefresh: controller.fetchAll,
                      color: _grad.first,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MasterItemCard(
                  nama: item.nama,
                  subtitle: item.deskripsi,
                  kategori: item.nama,
                  gradientColors: _grad,
                  index: i,
                  onTap: () => showKategoriDetailSheet(context,
                      nama: item.nama, deskripsi: item.deskripsi),
                  onEdit: () {
                    controller.mulaiEditKategori(item);
                    _showAddSheet(
                      context,
                      title: 'Edit Kategori',
                      titleIcon: Icons.edit_outlined,
                      gradientColors: _grad,
                      controller: controller,
                      onSimpan: controller.updateKategori,
                      formContent: _buildFormFields(),
                    );
                  },
                  onDelete: () => _confirmHapus(
                    context,
                    nama: item.nama,
                    gradientColors: _grad,
                    onConfirm: () => controller.hapusKategori(item.id),
                  ),
                ),
              );
            },
          ),
                      ),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB: SUB KATEGORI
// ─────────────────────────────────────────────────────────────────────────────
class _SubKategoriTab extends StatelessWidget {
  final MasterSampahController controller;
  const _SubKategoriTab({required this.controller});

  static const _grad = [AppColors.teal, AppColors.cyan];

  Widget _buildFormFields() => Column(children: [
        Obx(
          () => DropdownButtonFormField<KategoriModel>(
            initialValue: controller.selectedKategoriForm.value,
            decoration: _dropdownDecoration(
                'Kategori *', Icons.category_outlined, _grad),
            items: controller.listKategoriDropdown
                .map((k) => DropdownMenuItem(
                    value: k,
                    child: Text(k.nama,
                        style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600))))
                .toList(),
            onChanged: (v) => controller.selectedKategoriForm.value = v,
            validator: (v) => v == null ? 'Pilih kategori' : null,
          ),
        ),
        const SizedBox(height: 14),
        _ModernTextField(
          controller: controller.namaController,
          label: 'Nama Sub Kategori',
          hint: 'Contoh: Plastik Keras, Kertas Bekas',
          icon: Icons.label_outline_rounded,
          gradientColors: _grad,
          validator: (v) =>
              v == null || v.isEmpty ? 'Nama wajib diisi' : null,
        ),
        const SizedBox(height: 14),
        _ModernTextField(
          controller: controller.deskripsiController,
          label: 'Deskripsi (opsional)',
          hint: 'Keterangan sub kategori',
          icon: Icons.notes_rounded,
          gradientColors: _grad,
          maxLines: 2,
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _ModernFAB(
        label: 'Tambah Sub Kategori',
        gradientColors: _grad,
        onPressed: () => _showAddSheet(
          context,
          title: 'Tambah Sub Kategori',
          titleIcon: Icons.layers_outlined,
          gradientColors: _grad,
          controller: controller,
          onSimpan: controller.simpanSubKategori,
          formContent: _buildFormFields(),
        ),
      ),
      body: Obx(() {
        final items = controller.listSubKategoriFiltered;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: _SearchFilterBar(
                  controller: controller, gradientColors: _grad),
            ),
            Expanded(
              child: items.isEmpty
                  ? const AppEmptyState(
                      icon: Icons.layers_outlined,
                      title: 'Belum Ada Sub Kategori',
                      subtitle:
                          'Tambahkan sub kategori untuk mengklasifikasikan sampah.',
                    )
                  : PullToRefresh(
                      onRefresh: controller.fetchAll,
                      color: _grad.first,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
              final item = items[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MasterItemCard(
                  nama: item.nama,
                  subtitle: item.kategori != null
                      ? 'Kategori: ${item.kategori!.nama}'
                      : null,
                  kategori: item.kategori?.nama,
                  gradientColors: _grad,
                  index: i,
                  onEdit: () {
                    controller.mulaiEditSubKategori(item);
                    _showAddSheet(
                      context,
                      title: 'Edit Sub Kategori',
                      titleIcon: Icons.edit_outlined,
                      gradientColors: _grad,
                      controller: controller,
                      onSimpan: controller.updateSubKategori,
                      formContent: _buildFormFields(),
                    );
                  },
                  onDelete: () => _confirmHapus(
                    context,
                    nama: item.nama,
                    gradientColors: _grad,
                    onConfirm: () => controller.hapusSubKategori(item.id),
                  ),
                ),
              );
            },
          ),
                      ),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB: TIPE
// ─────────────────────────────────────────────────────────────────────────────
class _TipeTab extends StatelessWidget {
  final MasterSampahController controller;
  const _TipeTab({required this.controller});

  static const _grad = [AppColors.indigoDark, AppColors.indigo];

  Widget _buildFormFields() => Column(children: [
        Obx(
          () => DropdownButtonFormField<KategoriModel>(
            initialValue: controller.selectedKategoriForm.value,
            decoration: _dropdownDecoration(
                'Kategori *', Icons.category_outlined, _grad),
            items: controller.listKategoriDropdown
                .map((k) => DropdownMenuItem(
                    value: k,
                    child: Text(k.nama,
                        style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600))))
                .toList(),
            onChanged: (v) => controller.selectedKategoriForm.value = v,
            validator: (v) => v == null ? 'Pilih kategori' : null,
          ),
        ),
        const SizedBox(height: 14),
        Obx(
          () => DropdownButtonFormField<SubKategoriModel>(
            initialValue: controller.selectedSubKategoriForm.value,
            decoration: _dropdownDecoration(
                'Sub Kategori *', Icons.layers_outlined, _grad),
            items: controller.listSubKategoriDropdown
                .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.nama,
                        style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600))))
                .toList(),
            onChanged: (v) => controller.selectedSubKategoriForm.value = v,
            validator: (v) => v == null ? 'Pilih sub kategori' : null,
          ),
        ),
        const SizedBox(height: 14),
        _ModernTextField(
          controller: controller.namaController,
          label: 'Nama Tipe',
          hint: 'Contoh: PET, PP, HDPE, ABS',
          icon: Icons.label_outline_rounded,
          gradientColors: _grad,
          validator: (v) =>
              v == null || v.isEmpty ? 'Nama wajib diisi' : null,
        ),
        const SizedBox(height: 14),
        _ModernTextField(
          controller: controller.deskripsiController,
          label: 'Deskripsi (opsional)',
          hint: 'Keterangan tipe sampah',
          icon: Icons.notes_rounded,
          gradientColors: _grad,
          maxLines: 2,
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _ModernFAB(
        label: 'Tambah Tipe',
        gradientColors: _grad,
        onPressed: () => _showAddSheet(
          context,
          title: 'Tambah Tipe Sampah',
          titleIcon: Icons.style_outlined,
          gradientColors: _grad,
          controller: controller,
          onSimpan: controller.simpanTipe,
          formContent: _buildFormFields(),
        ),
      ),
      body: Obx(() {
        final items = controller.listTipeFiltered;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: _SearchFilterBar(
                  controller: controller, gradientColors: _grad),
            ),
            Expanded(
              child: items.isEmpty
                  ? const AppEmptyState(
                      icon: Icons.style_outlined,
                      title: 'Belum Ada Tipe',
                      subtitle:
                          'Tambahkan tipe sampah seperti PET, PP, HDPE.',
                    )
                  : PullToRefresh(
                      onRefresh: controller.fetchAll,
                      color: _grad.first,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
              final item = items[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MasterItemCard(
                  nama: item.nama,
                  subtitle: item.subKategori != null
                      ? 'Sub Kategori: ${item.subKategori!.nama}'
                      : null,
                  kategori: item.subKategori?.kategori?.nama,
                  gradientColors: _grad,
                  index: i,
                  onEdit: () {
                    controller.mulaiEditTipe(item);
                    _showAddSheet(
                      context,
                      title: 'Edit Tipe',
                      titleIcon: Icons.edit_outlined,
                      gradientColors: _grad,
                      controller: controller,
                      onSimpan: controller.updateTipe,
                      formContent: _buildFormFields(),
                    );
                  },
                  onDelete: () => _confirmHapus(
                    context,
                    nama: item.nama,
                    gradientColors: _grad,
                    onConfirm: () => controller.hapusTipe(item.id),
                  ),
                ),
              );
            },
          ),
                      ),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB: JENIS
// ─────────────────────────────────────────────────────────────────────────────
class _JenisTab extends StatelessWidget {
  final MasterSampahController controller;
  const _JenisTab({required this.controller});

  static const _grad = [AppColors.tealDark, AppColors.tealMid];

  Widget _buildFormFields() => SingleChildScrollView(
        child: Column(children: [
          Obx(
            () => DropdownButtonFormField<KategoriModel>(
              initialValue: controller.selectedKategoriForm.value,
              decoration: _dropdownDecoration(
                  'Kategori *', Icons.category_outlined, _grad),
              items: controller.listKategoriDropdown
                  .map((k) => DropdownMenuItem(
                      value: k,
                      child: Text(k.nama,
                          style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontWeight: FontWeight.w600))))
                  .toList(),
              onChanged: (v) {
                controller.selectedKategoriForm.value = v;
                controller.selectedSubKategoriForm.value = null;
                controller.selectedTipeForm.value = null;
              },
              validator: (v) => v == null ? 'Pilih kategori' : null,
            ),
          ),
          const SizedBox(height: 14),
          Obx(
            () => DropdownButtonFormField<SubKategoriModel>(
              initialValue: controller.selectedSubKategoriForm.value,
              decoration: _dropdownDecoration(
                  'Sub Kategori (opsional)', Icons.layers_outlined, _grad),
              items: [
                const DropdownMenuItem<SubKategoriModel>(
                  value: null,
                  child: Text('— Tidak ada —',
                      style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w600)),
                ),
                ...controller.listSubKategoriDropdown.map((s) =>
                    DropdownMenuItem(
                        value: s,
                        child: Text(s.nama,
                            style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontWeight: FontWeight.w600)))),
              ],
              onChanged: (v) =>
                  controller.selectedSubKategoriForm.value = v,
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            if (controller.listTipeDropdown.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(children: [
              DropdownButtonFormField<TipeSampahModel>(
                initialValue: controller.selectedTipeForm.value,
                decoration: _dropdownDecoration(
                    'Tipe (opsional)', Icons.style_outlined, _grad),
                items: [
                  const DropdownMenuItem<TipeSampahModel>(
                    value: null,
                    child: Text('— Tidak ada —',
                        style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600)),
                  ),
                  ...controller.listTipeDropdown.map((t) =>
                      DropdownMenuItem(
                          value: t,
                          child: Text(t.nama,
                              style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontWeight: FontWeight.w600)))),
                ],
                onChanged: (v) => controller.selectedTipeForm.value = v,
              ),
              const SizedBox(height: 14),
            ]);
          }),
          _ModernTextField(
            controller: controller.namaController,
            label: 'Nama Jenis',
            hint: 'Contoh: Botol Air Mineral, Koran Bekas',
            icon: Icons.label_outline_rounded,
            gradientColors: _grad,
            validator: (v) =>
                v == null || v.isEmpty ? 'Nama wajib diisi' : null,
          ),
          const SizedBox(height: 14),
          Obx(
            () => DropdownButtonFormField<SatuanModel>(
              initialValue: controller.selectedSatuanForm.value,
              decoration: _dropdownDecoration(
                  'Satuan Default (opsional)',
                  Icons.straighten_rounded,
                  _grad),
              items: controller.listSatuan
                  .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text('${s.nama} (${s.singkatan})',
                          style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontWeight: FontWeight.w600))))
                  .toList(),
              onChanged: (v) => controller.selectedSatuanForm.value = v,
            ),
          ),
          const SizedBox(height: 14),
          _ModernTextField(
            controller: controller.deskripsiController,
            label: 'Deskripsi (opsional)',
            hint: 'Keterangan tambahan',
            icon: Icons.notes_rounded,
            gradientColors: _grad,
            maxLines: 2,
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _ModernFAB(
        label: 'Tambah Jenis',
        gradientColors: _grad,
        onPressed: () => _showAddSheet(
          context,
          title: 'Tambah Jenis Sampah',
          titleIcon: Icons.eco_outlined,
          gradientColors: _grad,
          controller: controller,
          onSimpan: controller.simpanJenis,
          formContent: _buildFormFields(),
        ),
      ),
      body: Obx(() {
        final items = controller.listJenisFiltered;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: _SearchFilterBar(
                  controller: controller, gradientColors: _grad),
            ),
            Expanded(
              child: items.isEmpty
                  ? const AppEmptyState(
                      icon: Icons.eco_outlined,
                      title: 'Belum Ada Jenis Sampah',
                      subtitle:
                          'Tambahkan jenis sampah yang diterima bank sampah.',
                    )
                  : PullToRefresh(
                      onRefresh: controller.fetchAll,
                      color: _grad.first,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
              final item = items[i];
              final parts = <String>[];
              if (item.subKategori?.kategori != null) {
                parts.add(item.subKategori!.kategori!.nama);
              } else if (item.kategori != null) {
                parts.add(item.kategori!.nama);
              }
              if (item.subKategori != null) parts.add(item.subKategori!.nama);
              if (item.tipe != null) parts.add(item.tipe!.nama);
              final breadcrumb =
                  parts.isNotEmpty ? parts.join(' › ') : null;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MasterItemCard(
                  nama: item.nama,
                  subtitle: breadcrumb,
                  kategori: item.subKategori?.kategori?.nama ??
                      item.kategori?.nama,
                  gradientColors: _grad,
                  index: i,
                  trailing: item.satuanDefault != null
                      ? _SatuanBadge(
                          satuan: item.satuanDefault!.singkatan,
                          gradientColors: _grad,
                        )
                      : null,
                  onEdit: () {
                    controller.mulaiEditJenis(item);
                    _showAddSheet(
                      context,
                      title: 'Edit Jenis Sampah',
                      titleIcon: Icons.edit_outlined,
                      gradientColors: _grad,
                      controller: controller,
                      onSimpan: controller.updateJenis,
                      formContent: _buildFormFields(),
                    );
                  },
                  onDelete: () => _confirmHapus(
                    context,
                    nama: item.nama,
                    gradientColors: _grad,
                    onConfirm: () => controller.hapusJenis(item.id),
                  ),
                ),
              );
            },
          ),
                      ),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB: SATUAN
// ─────────────────────────────────────────────────────────────────────────────
class _SatuanTab extends StatelessWidget {
  final MasterSampahController controller;
  const _SatuanTab({required this.controller});

  static const _grad = [AppColors.purple, AppColors.purpleMid];

  Widget _buildFormFields() => Column(children: [
        _ModernTextField(
          controller: controller.namaController,
          label: 'Nama Satuan',
          hint: 'Contoh: Kilogram, Liter, Buah',
          icon: Icons.straighten_rounded,
          gradientColors: _grad,
          validator: (v) =>
              v == null || v.isEmpty ? 'Nama wajib diisi' : null,
        ),
        const SizedBox(height: 14),
        _ModernTextField(
          controller: controller.singkatanController,
          label: 'Singkatan',
          hint: 'Contoh: kg, L, bh',
          icon: Icons.short_text_rounded,
          gradientColors: _grad,
          validator: (v) =>
              v == null || v.isEmpty ? 'Singkatan wajib diisi' : null,
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _ModernFAB(
        label: 'Tambah Satuan',
        gradientColors: _grad,
        onPressed: () => _showAddSheet(
          context,
          title: 'Tambah Satuan',
          titleIcon: Icons.straighten_rounded,
          gradientColors: _grad,
          controller: controller,
          onSimpan: controller.simpanSatuan,
          formContent: _buildFormFields(),
        ),
      ),
      body: Obx(() {
        final items = controller.listSatuanFiltered;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: _SearchFilterBar(
                  controller: controller, gradientColors: _grad),
            ),
            Expanded(
              child: items.isEmpty
                  ? const AppEmptyState(
                      icon: Icons.straighten_outlined,
                      title: 'Belum Ada Satuan',
                      subtitle:
                          'Tambahkan satuan pengukuran seperti kg, liter, dll.',
                    )
                  : PullToRefresh(
                      onRefresh: controller.fetchAll,
                      color: _grad.first,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
              final item = items[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MasterItemCard(
                  nama: item.nama,
                  satuan: item.singkatan,
                  gradientColors: _grad,
                  index: i,
                  trailing: _SatuanBadge(
                    satuan: item.singkatan,
                    gradientColors: _grad,
                  ),
                  onEdit: () {
                    controller.mulaiEditSatuan(item);
                    _showAddSheet(
                      context,
                      title: 'Edit Satuan',
                      titleIcon: Icons.edit_outlined,
                      gradientColors: _grad,
                      controller: controller,
                      onSimpan: controller.updateSatuan,
                      formContent: _buildFormFields(),
                    );
                  },
                  onDelete: () => _confirmHapus(
                    context,
                    nama: item.nama,
                    gradientColors: _grad,
                    onConfirm: () => controller.hapusSatuan(item.id),
                  ),
                ),
              );
            },
          ),
                      ),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// ── Modern FAB ───────────────────────────────────────────────────────────────
class _ModernFAB extends StatelessWidget {
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onPressed;

  const _ModernFAB({
    required this.label,
    required this.gradientColors,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // FAB modern bersama: glow bernapas + shimmer + inner highlight glossy.
    return AddFab(
      label: label,
      gradientColors: gradientColors,
      onTap: onPressed,
    );
  }
}

// ── Search + Filter Status Bar ──────────────────────────────────────────────
// Dipakai bersama oleh kelima tab master sampah.
class _SearchFilterBar extends StatelessWidget {
  final MasterSampahController controller;
  final List<Color> gradientColors;

  const _SearchFilterBar({
    required this.controller,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  size: 19, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  onChanged: controller.setSearchQuery,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Cari nama atau deskripsi...',
                    hintStyle: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Obx(() {
                if (controller.searchQuery.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return GestureDetector(
                  onTap: () => controller.setSearchQuery(''),
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.textSecondary),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Chip filter status
        Obx(() => Row(
              children: [
                _StatusChip(
                  label: 'Semua',
                  selected: controller.statusFilter.value == 'semua',
                  gradientColors: gradientColors,
                  onTap: () => controller.setStatusFilter('semua'),
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: '● Aktif',
                  selected: controller.statusFilter.value == 'aktif',
                  gradientColors: gradientColors,
                  onTap: () => controller.setStatusFilter('aktif'),
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: '○ Nonaktif',
                  selected: controller.statusFilter.value == 'nonaktif',
                  gradientColors: gradientColors,
                  onTap: () => controller.setStatusFilter('nonaktif'),
                ),
              ],
            )),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.kelurahanSurface,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : AppColors.kelurahanDark,
          ),
        ),
      ),
    );
  }
}

// ── Item Card ────────────────────────────────────────────────────────────────
class _MasterItemCard extends StatelessWidget {
  final String nama;
  final String? subtitle;
  final Widget? trailing;
  final List<Color> gradientColors;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Nama kategori induk — menentukan ikon visual khusus
  /// (mis. residu, daur ulang, organik) via [resolveSampahVisual].
  final String? kategori;

  /// Singkatan satuan (tab Satuan) — menentukan ikon via [resolveSampahVisual].
  final String? satuan;

  /// Tap card: buka detail ringkas. Long-press: akses cepat hapus.
  final VoidCallback? onTap;

  const _MasterItemCard({
    required this.nama,
    this.subtitle,
    this.trailing,
    required this.gradientColors,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    this.kategori,
    this.satuan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = resolveSampahVisual(
      kategori: kategori,
      satuan: satuan,
    );

    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ikon visual — rounded square gelap ala mockup
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: resolved.gradient,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: resolved.accent.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(resolved.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),

          // Info: chips (opsional) + nama + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(height: 5),
                ],
                Text(
                  nama,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.kelurahanDark,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11.5,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Tombol Edit (abu) + Hapus (merah) ala mockup
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.backgroundKelurahan,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.kelurahanSurface, width: 1),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.kelurahanDark,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.dangerLighter, width: 1),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );

    final interactive = onTap == null
        ? card
        : PressableScale(
            onTap: onTap,
            pressedScale: 0.965,
            splashColor: resolved.accent.withValues(alpha: 0.06),
            borderRadius: 20,
            glowIntensity: 0.35,
            glowColor: resolved.accent,
            onLongPress: onDelete,
            child: card,
          );

    return StaggeredEntrance(index: index, child: interactive);
  }
}

class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final List<Color> gradientColors;
  final int maxLines;
  final String? Function(String?)? validator;

  const _ModernTextField({
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
    required this.gradientColors,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: AppColors.kelurahanDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          color: gradientColors.first,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        hintStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          color: Colors.grey.shade400,
          fontSize: 13.5,
        ),
        prefixIcon: Icon(icon, size: 18, color: gradientColors.first),
        filled: true,
        fillColor: AppColors.blueBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.kelurahanSurface, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: gradientColors.first, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ── Satuan Badge ─────────────────────────────────────────────────────────────
class _SatuanBadge extends StatelessWidget {
  final String satuan;
  final List<Color> gradientColors;

  const _SatuanBadge({
    required this.satuan,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        satuan,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Confirm Hapus ────────────────────────────────────────────────────────────
Future<void> _confirmHapus(
  BuildContext context, {
  required String nama,
  required List<Color> gradientColors,
  required VoidCallback onConfirm,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: PopIn(
        child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: AppColors.dangerLighter, width: 1.2),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.danger,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Hapus Data?',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.kelurahanDark,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13.5,
                  color: Colors.grey.shade600,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  const TextSpan(text: 'Yakin ingin menghapus\n'),
                  TextSpan(
                    text: '"$nama"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.kelurahanDark,
                    ),
                  ),
                  const TextSpan(
                      text: '?\nData terhubung mungkin terpengaruh.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: PressableScale(
                    onTap: () => Get.back(result: false),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.kelurahanLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.blueLight, width: 1),
                      ),
                      child: const Center(
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.kelurahanMain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PressableScale(
                    onTap: () => Get.back(result: true),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.dangerMid, AppColors.danger],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.danger
                                .withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_rounded,
                                color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Hapus',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
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
      ),
    ),
  );
  if (ok == true) onConfirm();
}

// ── Wave Painter ─────────────────────────────────────────────────────────────
