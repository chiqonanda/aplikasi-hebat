import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../controllers/kelurahan/master_sampah_controller.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/kategori_model.dart';
import '../../models/sub_kategori_model.dart';
import '../../models/tipe_sampah_model.dart';
import '../../models/satuan_model.dart';

class MasterSampahView extends GetView<MasterSampahController> {
  const MasterSampahView({super.key});

  static const _tabs = [
    _TabInfo('Kategori',     Icons.category_outlined,    [Color(0xFF0A2540), Color(0xFF1E88E5)]),
    _TabInfo('Sub Kategori', Icons.layers_outlined,       [Color(0xFF00838F), Color(0xFF26C6DA)]),
    _TabInfo('Tipe',         Icons.style_outlined,        [Color(0xFF283593), Color(0xFF5C6BC0)]),
    _TabInfo('Jenis',        Icons.eco_outlined,          [Color(0xFF00695C), Color(0xFF26A69A)]),
    _TabInfo('Satuan',       Icons.straighten_rounded,    [Color(0xFF6A1B9A), Color(0xFFAB47BC)]),
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
          size: Size(MediaQuery.of(context).size.width, 160),
          painter: _WavePainter(),
        ),
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
                    Text(
                      'Kelola kategori, jenis & satuan',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
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
                            : const Color(0xFFEBF2FA),
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
            const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
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
    fillColor: const Color(0xFFF8FBFF),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFEBF2FA), width: 1.2),
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

  static const _grad = [Color(0xFF0A2540), Color(0xFF1E88E5)];

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
          formContent: Column(children: [
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
          ]),
        ),
      ),
      body: Obx(() {
        if (controller.listKategori.isEmpty) {
          return const AppEmptyState(
            icon: Icons.category_outlined,
            title: 'Belum Ada Kategori',
            subtitle: 'Tambahkan kategori sampah pertama Anda.',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchAll,
          color: _grad.first,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: controller.listKategori.length,
            itemBuilder: (context, i) {
              final item = controller.listKategori[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MasterItemCard(
                  nama: item.nama,
                  subtitle: item.deskripsi,
                  icon: Icons.category_outlined,
                  gradientColors: _grad,
                  index: i,
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

  static const _grad = [Color(0xFF00838F), Color(0xFF26C6DA)];

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
          formContent: Column(children: [
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
          ]),
        ),
      ),
      body: Obx(() {
        if (controller.listSubKategori.isEmpty) {
          return const AppEmptyState(
            icon: Icons.layers_outlined,
            title: 'Belum Ada Sub Kategori',
            subtitle:
                'Tambahkan sub kategori untuk mengklasifikasikan sampah.',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchAll,
          color: _grad.first,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: controller.listSubKategori.length,
            itemBuilder: (context, i) {
              final item = controller.listSubKategori[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MasterItemCard(
                  nama: item.nama,
                  subtitle: item.kategori != null
                      ? 'Kategori: ${item.kategori!.nama}'
                      : null,
                  icon: Icons.layers_outlined,
                  gradientColors: _grad,
                  index: i,
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

  static const _grad = [Color(0xFF283593), Color(0xFF5C6BC0)];

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
          formContent: Column(children: [
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
          ]),
        ),
      ),
      body: Obx(() {
        if (controller.listTipe.isEmpty) {
          return const AppEmptyState(
            icon: Icons.style_outlined,
            title: 'Belum Ada Tipe',
            subtitle: 'Tambahkan tipe sampah seperti PET, PP, HDPE.',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchAll,
          color: _grad.first,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: controller.listTipe.length,
            itemBuilder: (context, i) {
              final item = controller.listTipe[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MasterItemCard(
                  nama: item.nama,
                  subtitle: item.subKategori != null
                      ? 'Sub Kategori: ${item.subKategori!.nama}'
                      : null,
                  icon: Icons.style_outlined,
                  gradientColors: _grad,
                  index: i,
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

  static const _grad = [Color(0xFF00695C), Color(0xFF26A69A)];

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
          formContent: SingleChildScrollView(
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
          ),
        ),
      ),
      body: Obx(() {
        if (controller.listJenis.isEmpty) {
          return const AppEmptyState(
            icon: Icons.eco_outlined,
            title: 'Belum Ada Jenis Sampah',
            subtitle:
                'Tambahkan jenis sampah yang diterima bank sampah.',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchAll,
          color: _grad.first,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: controller.listJenis.length,
            itemBuilder: (context, i) {
              final item = controller.listJenis[i];
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
                  icon: Icons.eco_outlined,
                  gradientColors: _grad,
                  index: i,
                  trailing: item.satuanDefault != null
                      ? _SatuanBadge(
                          satuan: item.satuanDefault!.singkatan,
                          gradientColors: _grad,
                        )
                      : null,
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

  static const _grad = [Color(0xFF6A1B9A), Color(0xFFAB47BC)];

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
          formContent: Column(children: [
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
          ]),
        ),
      ),
      body: Obx(() {
        if (controller.listSatuan.isEmpty) {
          return const AppEmptyState(
            icon: Icons.straighten_outlined,
            title: 'Belum Ada Satuan',
            subtitle:
                'Tambahkan satuan pengukuran seperti kg, liter, dll.',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchAll,
          color: _grad.first,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: controller.listSatuan.length,
            itemBuilder: (context, i) {
              final item = controller.listSatuan[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MasterItemCard(
                  nama: item.nama,
                  icon: Icons.straighten_rounded,
                  gradientColors: _grad,
                  index: i,
                  trailing: _SatuanBadge(
                    satuan: item.singkatan,
                    gradientColors: _grad,
                  ),
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
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
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
  final IconData icon;
  final List<Color> gradientColors;
  final int index;
  final VoidCallback onDelete;

  const _MasterItemCard({
    required this.nama,
    this.subtitle,
    this.trailing,
    required this.icon,
    required this.gradientColors,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border(
          left: BorderSide(color: gradientColors.first, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.subdirectory_arrow_right_rounded,
                        size: 12,
                        color: gradientColors.last,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
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
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
          const SizedBox(width: 8),

          // Delete button
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFFFCDD2), width: 1),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFD32F2F),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Modern Text Field ────────────────────────────────────────────────────────
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
        fillColor: const Color(0xFFF8FBFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFEBF2FA), width: 1.2),
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
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: const Color(0xFFFFCDD2), width: 1.2),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFD32F2F),
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
                  child: GestureDetector(
                    onTap: () => Get.back(result: false),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.kelurahanLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFBBDEFB), width: 1),
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
                  child: GestureDetector(
                    onTap: () => Get.back(result: true),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD32F2F)
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
  );
  if (ok == true) onConfirm();
}

// ── Wave Painter ─────────────────────────────────────────────────────────────
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
        size.height * 0.60,
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
        Offset(size.width * 0.1, size.height * 0.3), 40, paintDot);
    canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.15), 25, paintDot);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => false;
}