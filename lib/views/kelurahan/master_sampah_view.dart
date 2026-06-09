import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/kelurahan/master_sampah_controller.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/kategori_model.dart';
import '../../models/sub_kategori_model.dart';
import '../../models/tipe_sampah_model.dart';
import '../../models/satuan_model.dart';

// ── Warna Utama (selaras dengan DashboardKelurahanView) ───────────────────────
const _blue900 = AppColors.kelurahanDark;
const _blue800 = AppColors.kelurahanDark;
const _blue600 = AppColors.kelurahanMain;
const _blue500 = AppColors.kelurahanMain;
const _blue400 = Color(0xFF42A5F5);
const _blue50  = AppColors.kelurahanLight;
const _bg      = AppColors.scaffoldBg;
const _purple  = Color(0xFF6A1B9A);
const _purpleBg = Color(0xFFF3E5F5);

class MasterSampahView extends GetView<MasterSampahController> {
  const MasterSampahView({super.key});

  static const _tabs = [
    _TabInfo('Kategori',    Icons.category_outlined,        _blue600,  _blue50),
    _TabInfo('Sub Kategori',Icons.layers_outlined,           Color(0xFF00838F), Color(0xFFE0F7FA)),
    _TabInfo('Tipe',        Icons.style_outlined,            Color(0xFF283593), Color(0xFFE8EAF6)),
    _TabInfo('Jenis',       Icons.eco_outlined,              Color(0xFF00695C), Color(0xFFE0F2F1)),
    _TabInfo('Satuan',      Icons.straighten_rounded,        _purple,   _purpleBg),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            AppPageHeader(
              title: 'Jenis Sampah',
              subtitle: 'Kelola kategori, jenis & satuan',
              gradientColors: AppColors.kelurahanGradient,
              showBack: true,
            ),
            // ── Tab Scroll ──────────────────────────────────────────────────
            _buildTabBar(),
            // ── Body ────────────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingWidget();
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

  // ── Tab Bar ────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
                          ? const LinearGradient(
                              colors: [_blue600, _blue500],
                            )
                          : null,
                      color: isActive ? null : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isActive
                            ? _blue500
                            : const Color(0xFFE3F2FD),
                        width: 1.5,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: _blue500.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [
                              BoxShadow(
                                color: _blue900.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          size: 16,
                          color: isActive ? Colors.white : tab.color,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isActive ? Colors.white : _blue900,
                            letterSpacing: -0.2,
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

// ── Tab Info Model ─────────────────────────────────────────────────────────────
class _TabInfo {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _TabInfo(this.label, this.icon, this.color, this.bgColor);
}

// ── Generic Add Form Sheet ─────────────────────────────────────────────────────
void _showAddSheet(
  BuildContext context, {
  required String title,
  required IconData titleIcon,
  required Color iconColor,
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
            // Handle bar
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
            // Title row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_blue600, _blue500],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _blue500.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(titleIcon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _blue900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 58),
              child: Text(
                'Isi form berikut dengan benar',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Divider
            Container(
              height: 1,
              color: const Color(0xFFE3F2FD),
              margin: const EdgeInsets.only(bottom: 20),
            ),
            formContent,
            const SizedBox(height: 24),
            // Tombol Simpan
            Obx(
              () => GestureDetector(
                onTap: controller.isSaving.value ? null : onSimpan,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: controller.isSaving.value
                          ? [Colors.grey.shade400, Colors.grey.shade400]
                          : const [_blue600, _blue500],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: controller.isSaving.value
                        ? []
                        : [
                            BoxShadow(
                              color: _blue500.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: Center(
                    child: controller.isSaving.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
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

// ── Shared Dropdown Decoration ─────────────────────────────────────────────────
InputDecoration _dropdownDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: _blue600, fontWeight: FontWeight.w600),
    prefixIcon: Icon(icon, size: 20, color: _blue500),
    filled: true,
    fillColor: _blue50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFBBDEFB), width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFBBDEFB), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _blue500, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

// ── Tab Kategori ──────────────────────────────────────────────────────────────
class _KategoriTab extends StatelessWidget {
  final MasterSampahController controller;
  const _KategoriTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _ModernFAB(
        label: 'Tambah Kategori',
        icon: Icons.add_rounded,
        onPressed: () => _showAddSheet(
          context,
          title: 'Tambah Kategori',
          titleIcon: Icons.category_outlined,
          iconColor: _blue600,
          controller: controller,
          onSimpan: controller.simpanKategori,
          formContent: Column(children: [
            _ModernTextField(
              controller: controller.namaController,
              label: 'Nama Kategori',
              hint: 'Contoh: Plastik, Kertas, Logam',
              icon: Icons.label_outline_rounded,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            _ModernTextField(
              controller: controller.deskripsiController,
              label: 'Deskripsi (opsional)',
              hint: 'Keterangan singkat kategori ini',
              icon: Icons.notes_rounded,
              maxLines: 2,
            ),
          ]),
        ),
      ),
      body: Obx(() {
        if (controller.listKategori.isEmpty) {
          return _ModernEmptyState(
            icon: Icons.category_outlined,
            title: 'Belum Ada Kategori',
            message: 'Tambahkan kategori sampah pertama Anda',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchAll,
          color: _blue500,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: controller.listKategori.length,
            itemBuilder: (_, i) {
              final item = controller.listKategori[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MasterItemCard(
                  nama: item.nama,
                  subtitle: item.deskripsi,
                  icon: Icons.category_outlined,
                  iconGradient: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  index: i,
                  onDelete: () => _confirmHapus(context,
                      nama: item.nama,
                      onConfirm: () => controller.hapusKategori(item.id)),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// ── Tab Sub Kategori ──────────────────────────────────────────────────────────
class _SubKategoriTab extends StatelessWidget {
  final MasterSampahController controller;
  const _SubKategoriTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _ModernFAB(
        label: 'Tambah Sub Kategori',
        icon: Icons.add_rounded,
        onPressed: () => _showAddSheet(
          context,
          title: 'Tambah Sub Kategori',
          titleIcon: Icons.layers_outlined,
          iconColor: const Color(0xFF00838F),
          controller: controller,
          onSimpan: controller.simpanSubKategori,
          formContent: Column(children: [
            Obx(
              () => DropdownButtonFormField<KategoriModel>(
                value: controller.selectedKategoriForm.value,
                decoration: _dropdownDecoration('Kategori *', Icons.category_outlined),
                items: controller.listKategoriDropdown
                    .map((k) => DropdownMenuItem(value: k, child: Text(k.nama)))
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
              validator: (v) =>
                  v == null || v.isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            _ModernTextField(
              controller: controller.deskripsiController,
              label: 'Deskripsi (opsional)',
              hint: 'Keterangan sub kategori',
              icon: Icons.notes_rounded,
              maxLines: 2,
            ),
          ]),
        ),
      ),
      body: Obx(() {
        if (controller.listSubKategori.isEmpty) {
          return _ModernEmptyState(
            icon: Icons.layers_outlined,
            title: 'Belum Ada Sub Kategori',
            message: 'Tambahkan sub kategori untuk mengklasifikasikan sampah',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchAll,
          color: _blue500,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: controller.listSubKategori.length,
            itemBuilder: (_, i) {
              final item = controller.listSubKategori[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MasterItemCard(
                  nama: item.nama,
                  subtitle: item.kategori != null
                      ? 'Kategori: ${item.kategori!.nama}'
                      : null,
                  icon: Icons.layers_outlined,
                  iconGradient: const [Color(0xFF00838F), Color(0xFF26C6DA)],
                  index: i,
                  onDelete: () => _confirmHapus(context,
                      nama: item.nama,
                      onConfirm: () => controller.hapusSubKategori(item.id)),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// ── Tab Tipe ──────────────────────────────────────────────────────────────────
class _TipeTab extends StatelessWidget {
  final MasterSampahController controller;
  const _TipeTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _ModernFAB(
        label: 'Tambah Tipe',
        icon: Icons.add_rounded,
        onPressed: () => _showAddSheet(
          context,
          title: 'Tambah Tipe Sampah',
          titleIcon: Icons.style_outlined,
          iconColor: const Color(0xFF283593),
          controller: controller,
          onSimpan: controller.simpanTipe,
          formContent: Column(children: [
            Obx(
              () => DropdownButtonFormField<KategoriModel>(
                value: controller.selectedKategoriForm.value,
                decoration: _dropdownDecoration('Kategori *', Icons.category_outlined),
                items: controller.listKategoriDropdown
                    .map((k) => DropdownMenuItem(value: k, child: Text(k.nama)))
                    .toList(),
                onChanged: (v) => controller.selectedKategoriForm.value = v,
                validator: (v) => v == null ? 'Pilih kategori' : null,
              ),
            ),
            const SizedBox(height: 14),
            Obx(
              () => DropdownButtonFormField<SubKategoriModel>(
                value: controller.selectedSubKategoriForm.value,
                decoration: _dropdownDecoration('Sub Kategori *', Icons.layers_outlined),
                items: controller.listSubKategoriDropdown
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.nama)))
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
              validator: (v) =>
                  v == null || v.isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            _ModernTextField(
              controller: controller.deskripsiController,
              label: 'Deskripsi (opsional)',
              hint: 'Keterangan tipe sampah',
              icon: Icons.notes_rounded,
              maxLines: 2,
            ),
          ]),
        ),
      ),
      body: Obx(() {
        if (controller.listTipe.isEmpty) {
          return _ModernEmptyState(
            icon: Icons.style_outlined,
            title: 'Belum Ada Tipe',
            message: 'Tambahkan tipe sampah seperti PET, PP, HDPE',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchAll,
          color: _blue500,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: controller.listTipe.length,
            itemBuilder: (_, i) {
              final item = controller.listTipe[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MasterItemCard(
                  nama: item.nama,
                  subtitle: item.subKategori != null
                      ? 'Sub Kategori: ${item.subKategori!.nama}'
                      : null,
                  icon: Icons.style_outlined,
                  iconGradient: const [Color(0xFF283593), Color(0xFF5C6BC0)],
                  index: i,
                  onDelete: () => _confirmHapus(context,
                      nama: item.nama,
                      onConfirm: () => controller.hapusTipe(item.id)),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// ── Tab Jenis ─────────────────────────────────────────────────────────────────
class _JenisTab extends StatelessWidget {
  final MasterSampahController controller;
  const _JenisTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _ModernFAB(
        label: 'Tambah Jenis',
        icon: Icons.add_rounded,
        onPressed: () => _showAddSheet(
          context,
          title: 'Tambah Jenis Sampah',
          titleIcon: Icons.eco_outlined,
          iconColor: const Color(0xFF00695C),
          controller: controller,
          onSimpan: controller.simpanJenis,
          formContent: SingleChildScrollView(
            child: Column(children: [
              Obx(
                () => DropdownButtonFormField<KategoriModel>(
                  value: controller.selectedKategoriForm.value,
                  decoration: _dropdownDecoration('Kategori *', Icons.category_outlined),
                  items: controller.listKategoriDropdown
                      .map((k) => DropdownMenuItem(value: k, child: Text(k.nama)))
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
                  value: controller.selectedSubKategoriForm.value,
                  decoration: _dropdownDecoration(
                      'Sub Kategori (opsional)', Icons.layers_outlined),
                  items: [
                    const DropdownMenuItem<SubKategoriModel>(
                      value: null,
                      child: Text('— Tidak ada —'),
                    ),
                    ...controller.listSubKategoriDropdown.map((s) =>
                        DropdownMenuItem(value: s, child: Text(s.nama))),
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
                    value: controller.selectedTipeForm.value,
                    decoration: _dropdownDecoration(
                        'Tipe (opsional)', Icons.style_outlined),
                    items: [
                      const DropdownMenuItem<TipeSampahModel>(
                        value: null,
                        child: Text('— Tidak ada —'),
                      ),
                      ...controller.listTipeDropdown.map((t) =>
                          DropdownMenuItem(value: t, child: Text(t.nama))),
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
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              Obx(
                () => DropdownButtonFormField<SatuanModel>(
                  value: controller.selectedSatuanForm.value,
                  decoration: _dropdownDecoration(
                      'Satuan Default (opsional)', Icons.straighten_rounded),
                  items: controller.listSatuan
                      .map((s) => DropdownMenuItem(
                          value: s, child: Text('${s.nama} (${s.singkatan})')))
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
                maxLines: 2,
              ),
            ]),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.listJenis.isEmpty) {
          return _ModernEmptyState(
            icon: Icons.eco_outlined,
            title: 'Belum Ada Jenis Sampah',
            message: 'Tambahkan jenis sampah yang diterima bank sampah',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchAll,
          color: _blue500,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: controller.listJenis.length,
            itemBuilder: (_, i) {
              final item = controller.listJenis[i];
              final parts = <String>[];
              if (item.subKategori?.kategori != null) {
                parts.add(item.subKategori!.kategori!.nama);
              } else if (item.kategori != null) {
                parts.add(item.kategori!.nama);
              }
              if (item.subKategori != null) parts.add(item.subKategori!.nama);
              if (item.tipe != null) parts.add(item.tipe!.nama);
              final breadcrumb = parts.isNotEmpty ? parts.join(' › ') : null;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MasterItemCard(
                  nama: item.nama,
                  subtitle: breadcrumb,
                  icon: Icons.eco_outlined,
                  iconGradient: const [Color(0xFF00695C), Color(0xFF26A69A)],
                  index: i,
                  trailing: item.satuanDefault != null
                      ? _SatuanBadge(satuan: item.satuanDefault!.singkatan)
                      : null,
                  onDelete: () => _confirmHapus(context,
                      nama: item.nama,
                      onConfirm: () => controller.hapusJenis(item.id)),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// ── Tab Satuan ────────────────────────────────────────────────────────────────
class _SatuanTab extends StatelessWidget {
  final MasterSampahController controller;
  const _SatuanTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _ModernFAB(
        label: 'Tambah Satuan',
        icon: Icons.add_rounded,
        onPressed: () => _showAddSheet(
          context,
          title: 'Tambah Satuan',
          titleIcon: Icons.straighten_rounded,
          iconColor: _purple,
          controller: controller,
          onSimpan: controller.simpanSatuan,
          formContent: Column(children: [
            _ModernTextField(
              controller: controller.namaController,
              label: 'Nama Satuan',
              hint: 'Contoh: Kilogram, Liter, Buah',
              icon: Icons.straighten_rounded,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            _ModernTextField(
              controller: controller.singkatanController,
              label: 'Singkatan',
              hint: 'Contoh: kg, L, bh',
              icon: Icons.short_text_rounded,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Singkatan wajib diisi' : null,
            ),
          ]),
        ),
      ),
      body: Obx(() {
        if (controller.listSatuan.isEmpty) {
          return _ModernEmptyState(
            icon: Icons.straighten_outlined,
            title: 'Belum Ada Satuan',
            message: 'Tambahkan satuan pengukuran seperti kg, liter, dll',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchAll,
          color: _blue500,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: controller.listSatuan.length,
            itemBuilder: (_, i) {
              final item = controller.listSatuan[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MasterItemCard(
                  nama: item.nama,
                  icon: Icons.straighten_rounded,
                  iconGradient: const [_purple, Color(0xFFAB47BC)],
                  index: i,
                  trailing: _SatuanBadge(satuan: item.singkatan),
                  onDelete: () => _confirmHapus(context,
                      nama: item.nama,
                      onConfirm: () => controller.hapusSatuan(item.id)),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// ── Modern FAB ────────────────────────────────────────────────────────────────
class _ModernFAB extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ModernFAB({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_blue600, _blue500],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _blue500.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Master Item Card (Modernized) ─────────────────────────────────────────────
class _MasterItemCard extends StatelessWidget {
  final String nama;
  final String? subtitle;
  final Widget? trailing;
  final IconData icon;
  final List<Color> iconGradient;
  final int index;
  final VoidCallback onDelete;

  const _MasterItemCard({
    required this.nama,
    this.subtitle,
    this.trailing,
    required this.icon,
    required this.iconGradient,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3F2FD), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _blue900.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Icon ─────────────────────────────────────────────────────────
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: iconGradient,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: iconGradient.first.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),

          // ── Info ─────────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _blue900,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.subdirectory_arrow_right_rounded,
                          size: 12, color: _blue400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
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

          // ── Trailing + Delete ─────────────────────────────────────────────
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100, width: 1.2),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red.shade400,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Modern Text Field ─────────────────────────────────────────────────────────
class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final int maxLines;
  final String? Function(String?)? validator;

  const _ModernTextField({
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
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
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: _blue900,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: _blue600,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, size: 20, color: _blue500),
        filled: true,
        fillColor: _blue50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBBDEFB), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBBDEFB), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _blue500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ── Satuan Badge ──────────────────────────────────────────────────────────────
class _SatuanBadge extends StatelessWidget {
  final String satuan;
  const _SatuanBadge({required this.satuan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBBDEFB), width: 1.2),
      ),
      child: Text(
        satuan,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: _blue600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Modern Empty State ─────────────────────────────────────────────────────────
class _ModernEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _ModernEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _blue500.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: _blue600, size: 42),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _blue900,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _blue50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBBDEFB), width: 1.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline_rounded,
                      size: 16, color: _blue600),
                  SizedBox(width: 8),
                  Text(
                    'Gunakan tombol di bawah untuk menambah',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _blue600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Confirm Hapus Dialog ───────────────────────────────────────────────────────
Future<void> _confirmHapus(
  BuildContext context, {
  required String nama,
  required VoidCallback onConfirm,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon warning
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.shade100, width: 1.5),
              ),
              child: Icon(Icons.warning_amber_rounded,
                  color: Colors.red.shade400, size: 34),
            ),
            const SizedBox(height: 18),
            const Text(
              'Hapus Data?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _blue900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
                children: [
                  const TextSpan(text: 'Yakin ingin menghapus\n'),
                  TextSpan(
                    text: '"$nama"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _blue900,
                    ),
                  ),
                  const TextSpan(
                      text: '?\nData yang terhubung mungkin ikut terpengaruh.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(false),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F6FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFBBDEFB), width: 1.5),
                      ),
                      child: const Center(
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _blue600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(true),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade500, Colors.red.shade400],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Hapus',
                              style: TextStyle(
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
          ],
        ),
      ),
    ),
  );
  if (ok == true) onConfirm();
}