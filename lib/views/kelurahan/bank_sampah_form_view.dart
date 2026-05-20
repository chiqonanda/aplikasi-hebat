import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/kelurahan/bank_sampah_controller.dart';
import '../../core/utils/validator.dart';
import '../../core/widgets/app_widgets.dart';

class BankSampahFormView extends GetView<BankSampahController> {
  const BankSampahFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isEditMode ? 'Edit Bank Sampah' : 'Tambah Bank Sampah',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Informasi dasar ──────────────────────────
            _SectionCard(
              title: 'Informasi Bank Sampah',
              child: Column(
                children: [
                  AppTextField(
                    controller: controller.namaController,
                    label: 'Nama Bank Sampah *',
                    hint: 'Contoh: Bank Sampah RT 05',
                    prefixIcon: Icons.store_outlined,
                    validator: (v) =>
                        AppValidator.required(v, fieldName: 'Nama'),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: controller.alamatController,
                    label: 'Alamat (opsional)',
                    hint: 'Masukkan alamat lengkap',
                    prefixIcon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Wilayah RT/RW ────────────────────────────
            _SectionCard(
              title: 'Wilayah Cakupan',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cakupan RT',
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ── RT Multi-select field ────────────────
                  Obx(() {
                    final selected = controller.selectedRts.toList();
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showRtSelectionSheet(context),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 52),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLg,
                          ),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: selected.isEmpty
                                  ? Text(
                                      'Pilih RT...',
                                      style: AppTextStyles.bodyLg.copyWith(
                                        color: AppColors.onSurfaceVariant
                                            .withOpacity(0.6),
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: selected.map((rt) {
                                        return _RtChip(
                                          key: ValueKey('rt_chip_$rt'),
                                          label: rt,
                                          onRemove: () =>
                                              controller.selectedRts.remove(rt),
                                        );
                                      }).toList(),
                                    ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: controller.rwController,
                    label: 'RW (opsional)',
                    hint: 'Contoh: 02',
                    prefixIcon: Icons.home_work_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Status aktif ─────────────────────────────
            _SectionCard(
              title: 'Status',
              child: Obx(
                () => Row(
                  children: [
                    const Icon(
                      Icons.toggle_on_outlined,
                      color: AppColors.outline,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status Aktif', style: AppTextStyles.bodyLg),
                          Text(
                            controller.isAktif.value
                                ? 'Bank sampah sedang beroperasi'
                                : 'Bank sampah tidak aktif',
                            style: AppTextStyles.bodyMd,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: controller.isAktif.value,
                      onChanged: (v) => controller.isAktif.value = v,
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Pengelola yang terhubung (edit mode) ─────
            Obx(() {
              if (!controller.isEditMode) return const SizedBox.shrink();
              return Column(
                children: [
                  _SectionCard(
                    title: 'Pengelola Terhubung',
                    child: controller.listPengelolaTerhubung.isEmpty
                        ? Row(
                            children: [
                              const Icon(
                                Icons.person_off_outlined,
                                color: AppColors.outline,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Belum ada pengelola terhubung',
                                style: AppTextStyles.bodyMd,
                              ),
                            ],
                          )
                        : Column(
                            children: controller.listPengelolaTerhubung
                                .map(
                                  (p) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: const BoxDecoration(
                                            color: AppColors.secondaryContainer,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.person_rounded,
                                            size: 18,
                                            color:
                                                AppColors.onSecondaryContainer,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            p.namaLengkap,
                                            style: AppTextStyles.bodyLg,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.link_off_rounded,
                                            size: 18,
                                            color: AppColors.error,
                                          ),
                                          onPressed: () =>
                                              controller.lepaskanPengelola(p),
                                          tooltip: 'Lepas pengelola',
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),

            // ── Tombol simpan ─────────────────────────────
            Obx(
              () => AppButton(
                label: controller.editData.value != null
                    ? 'Simpan Perubahan'
                    : 'Buat Bank Sampah',
                isLoading: controller.isSaving.value,
                onPressed: controller.simpan,
                icon: Icons.save_rounded,
              ),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Batal',
              outlined: true,
              onPressed: () => Get.back(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showRtSelectionSheet(BuildContext context) {
    // FIX: Snapshot list dulu sebelum masuk sheet
    // supaya tidak bergantung pada RxList reaktif di dalam StatelessWidget sheet
    final initialSelected = List<String>.from(
      Get.find<BankSampahController>().selectedRts,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // FIX: Pakai builder context yang benar (bukan _)
      builder: (sheetContext) {
        return _RtSelectionSheet(
          initialSelected: initialSelected,
          onConfirm: (result) {
            // Update RxList hanya sekali saat sheet ditutup via tombol Selesai
            final ctrl = Get.find<BankSampahController>();
            ctrl.selectedRts
              ..clear()
              ..addAll(result)
              ..sort();
          },
        );
      },
    );
  }
}

// ── RT Chip widget ────────────────────────────────────────────────────────────

class _RtChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _RtChip({super.key, required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'RT $label',
            style: TextStyle(
              color: Colors.green.shade800,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RtSelectionSheet extends StatefulWidget {
  final List<String> initialSelected;
  final void Function(List<String> result) onConfirm;

  const _RtSelectionSheet({
    required this.initialSelected,
    required this.onConfirm,
  });

  @override
  State<_RtSelectionSheet> createState() => _RtSelectionSheetState();
}

class _RtSelectionSheetState extends State<_RtSelectionSheet> {
  // FIX: State lokal — tidak menyentuh RxList parent sama sekali
  late final List<String> _selected;
  late final TextEditingController _customRtController;
  late final TextEditingController _searchController;
  String _searchQuery = '';

  static final List<String> _defaultRts = List.generate(23, (i) {
    final n = i + 1;
    return n < 10 ? '0$n' : '$n';
  });

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.initialSelected);
    _customRtController = TextEditingController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    // FIX: Dispose controller agar tidak memory leak
    _customRtController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addCustomRt() {
    final val = _customRtController.text.trim();
    if (val.isEmpty) return;
    setState(() {
      if (!_selected.contains(val)) {
        _selected.add(val);
        _selected.sort();
      }
      _customRtController.clear();
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _toggleRt(String rt) {
    setState(() {
      if (_selected.contains(rt)) {
        _selected.remove(rt);
      } else {
        _selected.add(rt);
        _selected.sort();
      }
    });
  }

  void _confirm() {
    widget.onConfirm(List<String>.from(_selected));
    Navigator.pop(context);
  }

  List<String> get _filteredRts {
    final all = {..._defaultRts, ..._selected}.toList()..sort();

    if (_searchQuery.isEmpty) return all;
    return all
        .where((rt) => rt.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRts;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      // Dorong konten ke atas saat keyboard muncul
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        // FIX: Berikan height eksplisit supaya Column punya bounded constraint.
        // Tanpa ini Column tidak tahu harus seberapa tinggi.
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          // FIX: mainAxisSize.max — Column mengisi seluruh height Container
          // sehingga Flutter bisa layout semua children dengan benar
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header (fixed, tidak scroll) ─────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Cakupan RT',
                    style: AppTextStyles.titleLg.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),

            // ── Search field ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari RT...',
                  isDense: true,
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            const SizedBox(height: 12),

            // ── Input RT Kustom ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customRtController,
                      decoration: InputDecoration(
                        hintText: 'Tambah RT kustom (misal: 05A)',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addCustomRt(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 90,
                    child: ElevatedButton(
                      onPressed: _addCustomRt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Tambah'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'RT "$_searchQuery" tidak ditemukan.\nTambahkan sebagai RT kustom.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: filtered.map((rt) {
                            final isSelected = _selected.contains(rt);
                            return GestureDetector(
                              key: ValueKey('rt_sheet_chip_$rt'),
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _toggleRt(rt),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.green.shade100
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.green.shade400
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  'RT $rt',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.green.shade800
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(title, style: AppTextStyles.titleMd),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}
