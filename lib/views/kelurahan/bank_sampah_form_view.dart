import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../controllers/kelurahan/bank_sampah_controller.dart';
import '../../core/utils/validator.dart';
import '../../core/widgets/app_widgets.dart';

class BankSampahFormView extends GetView<BankSampahController> {
  const BankSampahFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              // Header Page (Reactive with edit mode text)
              Obx(() => AppPageHeader(
                    title: controller.isEditMode ? 'Edit Bank Sampah' : 'Tambah Bank Sampah',
                    subtitle: controller.isEditMode ? 'Perbarui data bank sampah' : 'Tambahkan bank sampah baru',
                    gradientColors: AppColors.kelurahanGradient,
                    showBack: true,
                  )),

              // Scrollable Content Form
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
                  children: [
                    // Informasi Dasar Section
                    _SectionCard(
                      title: 'Informasi Bank Sampah',
                      subtitle: 'Lengkapi identitas bank sampah',
                      icon: Icons.store_rounded,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: controller.namaController,
                            label: 'Nama Bank Sampah *',
                            hint: 'Contoh: Bank Sampah RT 05',
                            prefixIcon: Icons.store_outlined,
                            validator: (v) => AppValidator.required(v, fieldName: 'Nama'),
                          ),
                          const SizedBox(height: 18),
                          AppTextField(
                            controller: controller.alamatController,
                            label: 'Alamat (opsional)',
                            hint: 'Masukkan alamat lengkap',
                            prefixIcon: Icons.location_on_outlined,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Wilayah Cakupan Section
                    _SectionCard(
                      title: 'Wilayah Cakupan',
                      subtitle: 'Pilih RT dan RW yang terhubung',
                      icon: Icons.map_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cakupan RT',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.kelurahanDark,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Obx(() {
                            final selected = controller.selectedRts.toList();

                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _showRtSelectionSheet(context),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                constraints: const BoxConstraints(minHeight: 56),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFEBF2FA),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.kelurahanMain.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: AppColors.kelurahanLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.groups_rounded,
                                        color: AppColors.kelurahanMain,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: selected.isEmpty
                                          ? const Padding(
                                              padding: EdgeInsets.only(top: 10),
                                              child: Text(
                                                'Pilih RT...',
                                                style: TextStyle(
                                                  color: AppColors.textTertiary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: selected.map((rt) {
                                                  return _RtChip(
                                                    key: ValueKey('rt_chip_$rt'),
                                                    label: rt,
                                                    onRemove: () => controller.selectedRts.remove(rt),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.kelurahanMain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 18),
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

                    const SizedBox(height: 18),

                    // Status Operasional Section
                    _SectionCard(
                      title: 'Status Operasional',
                      subtitle: 'Atur status aktif operasional bank sampah',
                      icon: Icons.toggle_on_rounded,
                      child: Obx(
                        () => Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: controller.isAktif.value ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: controller.isAktif.value ? const Color(0xFFA5D6A7) : const Color(0xFFE0E0E0),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: controller.isAktif.value ? const Color(0xFF2E7D32) : const Color(0xFF757575),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  controller.isAktif.value ? Icons.check_rounded : Icons.close_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Status Aktif',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.kelurahanDark,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      controller.isAktif.value
                                          ? 'Bank sampah sedang beroperasi aktif'
                                          : 'Bank sampah nonaktif operasional',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: controller.isAktif.value,
                                onChanged: (v) => controller.isAktif.value = v,
                                activeTrackColor: const Color(0xFF81C784),
                                activeThumbColor: const Color(0xFF2E7D32),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Pengelola Terhubung Section (Only visible in edit mode)
                    Obx(() {
                      if (!controller.isEditMode) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: [
                          _SectionCard(
                            title: 'Pengelola Terhubung',
                            subtitle: 'Daftar pengelola yang tersambung',
                            icon: Icons.people_alt_rounded,
                            child: controller.listPengelolaTerhubung.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: AppColors.kelurahanLight,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.person_off_outlined,
                                            color: AppColors.kelurahanMain,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Text(
                                            'Belum ada pengelola terhubung',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.kelurahanDark,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: controller.listPengelolaTerhubung
                                        .map(
                                          (p) => Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: _PengelolaTile(
                                              nama: p.namaLengkap,
                                              onRemove: () => controller.lepaskanPengelola(p),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      );
                    }),

                    // Submit Buttons
                    Obx(
                      () => Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.kelurahanMain.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: AppButton(
                          label: controller.editData.value != null ? 'Simpan Perubahan' : 'Buat Bank Sampah',
                          isLoading: controller.isSaving.value,
                          onPressed: controller.simpan,
                          icon: Icons.save_rounded,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFEBF2FA),
                          width: 1.2,
                        ),
                      ),
                      child: AppButton(
                        label: 'Batal',
                        outlined: true,
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRtSelectionSheet(BuildContext context) {
    final initialSelected = List<String>.from(
      Get.find<BankSampahController>().selectedRts,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _RtSelectionSheet(
          initialSelected: initialSelected,
          onConfirm: (result) {
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

// ── Redesigned Section Card Widget ────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEBF2FA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.kelurahanMain.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.kelurahanDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── Redesigned RT Chip Widget ─────────────────────────────────────────────
class _RtChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _RtChip({
    super.key,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.kelurahanLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBBDEFB), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'RT $label',
            style: const TextStyle(
              color: AppColors.kelurahanMain,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.kelurahanMain,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Redesigned Pengelola Connected Tile Widget ───────────────────────────
class _PengelolaTile extends StatelessWidget {
  final String nama;
  final VoidCallback onRemove;

  const _PengelolaTile({
    required this.nama,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEBF2FA),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nama,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.kelurahanDark,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.link_off_rounded,
              color: Colors.red,
              size: 20,
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

// ── Redesigned RT Selection Bottom Sheet ─────────────────────────────────
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
      _searchController.clear();
      _searchQuery = '';
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

    if (_searchQuery.isEmpty) {
      return all;
    }

    return all.where((rt) => rt.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRts;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.76,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 4,
              margin: const EdgeInsets.only(top: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Pilih Cakupan RT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.kelurahanDark,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    // Search bar inside sheet
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.kelurahanDark),
                      decoration: InputDecoration(
                        hintText: 'Cari RT...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: AppColors.scaffoldBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _searchQuery = v;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customRtController,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.kelurahanDark),
                            decoration: InputDecoration(
                              hintText: 'Tambah RT kustom',
                              filled: true,
                              fillColor: AppColors.scaffoldBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 100,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _addCustomRt,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kelurahanMain,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Tambah',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          'RT tidak ditemukan.\nTambahkan RT baru.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: filtered.map((rt) {
                          final isSelected = _selected.contains(rt);

                          return GestureDetector(
                            onTap: () => _toggleRt(rt),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.kelurahanMain : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? AppColors.kelurahanMain : Colors.grey.shade300,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: AppColors.kelurahanMain.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: Text(
                                'RT $rt',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.kelurahanDark,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kelurahanMain,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
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