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

  // ── Theme Dashboard Kelurahan ────────────────────────────────────────────
  static const _blue900 = AppColors.kelurahanDark;
  static const _blue800 = AppColors.kelurahanDark;
  static const _blue500 = AppColors.kelurahanMain;
  static const _blue400 = Color(0xFF42A5F5);
  static const _blue200 = AppColors.kelurahanLight;
  static const _blue50 = AppColors.kelurahanLight;
  static const _bg = AppColors.scaffoldBg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────
              Obx(() => AppPageHeader(
                title: controller.isEditMode ? 'Edit Bank Sampah' : 'Tambah Bank Sampah',
                subtitle: controller.isEditMode ? 'Perbarui data bank sampah' : 'Tambahkan bank sampah baru',
                gradientColors: AppColors.kelurahanGradient,
                showBack: true,
              )),

              // ── Content ───────────────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
                  children: [
                    // ── Informasi Dasar ───────────────────────────────
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
                            validator: (v) =>
                                AppValidator.required(v, fieldName: 'Nama'),
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

                    // ── Wilayah ──────────────────────────────────────
                    _SectionCard(
                      title: 'Wilayah Cakupan',
                      subtitle: 'Pilih RT dan RW yang terhubung',
                      icon: Icons.map_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cakupan RT',
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _blue900,
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
                                constraints:
                                    const BoxConstraints(minHeight: 58),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: _blue50,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          _blue500.withValues(alpha: 0.05),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            _blue500,
                                            _blue400,
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.groups_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: selected.isEmpty
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                top: 10,
                                              ),
                                              child: Text(
                                                'Pilih RT...',
                                                style:
                                                    AppTextStyles.bodyLg
                                                        .copyWith(
                                                  color: Colors.grey
                                                      .shade500,
                                                ),
                                              ),
                                            )
                                          : Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children:
                                                  selected.map((rt) {
                                                return _RtChip(
                                                  key: ValueKey(
                                                      'rt_chip_$rt'),
                                                  label: rt,
                                                  onRemove: () =>
                                                      controller
                                                          .selectedRts
                                                          .remove(rt),
                                                );
                                              }).toList(),
                                            ),
                                    ),

                                    const Padding(
                                      padding:
                                          EdgeInsets.only(top: 10),
                                      child: Icon(
                                        Icons
                                            .keyboard_arrow_down_rounded,
                                        color: _blue900,
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
                            prefixIcon:
                                Icons.home_work_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Status ───────────────────────────────────────
                    _SectionCard(
                      title: 'Status Operasional',
                      subtitle:
                          'Atur apakah bank sampah aktif atau tidak',
                      icon: Icons.toggle_on_rounded,
                      child: Obx(
                        () => Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: controller.isAktif.value
                                  ? [
                                      const Color(0xFFE3F2FD),
                                      const Color(0xFFBBDEFB),
                                    ]
                                  : [
                                      Colors.grey.shade100,
                                      Colors.grey.shade200,
                                    ],
                            ),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(
                                    milliseconds: 250),
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: controller
                                            .isAktif.value
                                        ? [
                                            _blue500,
                                            _blue400,
                                          ]
                                        : [
                                            Colors.grey.shade400,
                                            Colors.grey.shade500,
                                          ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (controller
                                                  .isAktif.value
                                              ? _blue500
                                              : Colors.grey)
                                          .withValues(alpha: 0.25),
                                      blurRadius: 10,
                                      offset:
                                          const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  controller.isAktif.value
                                      ? Icons.check_rounded
                                      : Icons.close_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status Aktif',
                                      style:
                                          AppTextStyles.bodyLg
                                              .copyWith(
                                        fontWeight:
                                            FontWeight.w800,
                                        color: _blue900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      controller.isAktif.value
                                          ? 'Bank sampah sedang beroperasi'
                                          : 'Bank sampah tidak aktif',
                                      style:
                                          AppTextStyles.bodyMd
                                              .copyWith(
                                        color: Colors
                                            .grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Switch(
                                value: controller.isAktif.value,
                                onChanged: (v) =>
                                    controller.isAktif.value =
                                        v,
                                activeColor: _blue500,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Pengelola ───────────────────────────────────
                    Obx(() {
                      if (!controller.isEditMode) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: [
                          _SectionCard(
                            title: 'Pengelola Terhubung',
                            subtitle:
                                'Daftar pengelola yang tersambung',
                            icon: Icons.people_alt_rounded,
                            child: controller
                                    .listPengelolaTerhubung
                                    .isEmpty
                                ? Container(
                                    padding:
                                        const EdgeInsets.all(
                                            18),
                                    decoration: BoxDecoration(
                                      color: _blue50,
                                      borderRadius:
                                          BorderRadius
                                              .circular(18),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration:
                                              BoxDecoration(
                                            color:
                                                Colors.white,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        14),
                                          ),
                                          child: const Icon(
                                            Icons
                                                .person_off_outlined,
                                            color:
                                                _blue500,
                                          ),
                                        ),
                                        const SizedBox(
                                            width: 12),
                                        Expanded(
                                          child: Text(
                                            'Belum ada pengelola terhubung',
                                            style:
                                                AppTextStyles
                                                    .bodyMd,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: controller
                                        .listPengelolaTerhubung
                                        .map(
                                          (p) => Padding(
                                            padding:
                                                const EdgeInsets
                                                    .only(
                                                    bottom:
                                                        12),
                                            child:
                                                _PengelolaTile(
                                              nama: p
                                                  .namaLengkap,
                                              onRemove: () =>
                                                  controller
                                                      .lepaskanPengelola(
                                                          p),
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

                    // ── Buttons ─────────────────────────────────────
                    Obx(
                      () => Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              _blue500,
                              _blue400,
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _blue500.withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: AppButton(
                          label: controller.editData.value !=
                                  null
                              ? 'Simpan Perubahan'
                              : 'Buat Bank Sampah',
                          isLoading:
                              controller.isSaving.value,
                          onPressed: controller.simpan,
                          icon: Icons.save_rounded,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color: _blue50,
                          width: 1.5,
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
            final ctrl =
                Get.find<BankSampahController>();

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

// ─────────────────────────────────────────────────────────────────────────────
// Section Card
// ─────────────────────────────────────────────────────────────────────────────

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

  static const _blue900 = AppColors.kelurahanDark;
  static const _blue500 = AppColors.kelurahanMain;
  static const _blue400 = Color(0xFF42A5F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE3F2FD),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                _blue500.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        _blue500,
                        _blue400,
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(
                            18),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w800,
                          color: _blue900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color:
                              Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 1,
            color: const Color(
                0xFFE3F2FD),
          ),

          Padding(
            padding:
                const EdgeInsets.all(18),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RT Chip
// ─────────────────────────────────────────────────────────────────────────────

class _RtChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _RtChip({
    super.key,
    required this.label,
    required this.onRemove,
  });

  static const _blue500 = AppColors.kelurahanMain;
  static const _blue50 = AppColors.kelurahanLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _blue50,
            Color(0xFFBBDEFB),
          ],
        ),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'RT $label',
            style: const TextStyle(
              color: _blue500,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            behavior:
                HitTestBehavior.opaque,
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: _blue500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pengelola Tile
// ─────────────────────────────────────────────────────────────────────────────

class _PengelolaTile
    extends StatelessWidget {
  final String nama;
  final VoidCallback onRemove;

  const _PengelolaTile({
    required this.nama,
    required this.onRemove,
  });

  static const _blue900 = AppColors.kelurahanDark;
  static const _blue500 = AppColors.kelurahanMain;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE3F2FD),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  _blue500,
                  Color(0xFF42A5F5),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(
                      16),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              nama,
              style: const TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w700,
                color: _blue900,
              ),
            ),
          ),

          IconButton(
            icon: const Icon(
              Icons.link_off_rounded,
              color: Colors.red,
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RT Selection Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _RtSelectionSheet
    extends StatefulWidget {
  final List<String> initialSelected;
  final void Function(
      List<String> result) onConfirm;

  const _RtSelectionSheet({
    required this.initialSelected,
    required this.onConfirm,
  });

  @override
  State<_RtSelectionSheet>
      createState() =>
          _RtSelectionSheetState();
}

class _RtSelectionSheetState
    extends State<_RtSelectionSheet> {
  late final List<String> _selected;
  late final TextEditingController
      _customRtController;
  late final TextEditingController
      _searchController;

  String _searchQuery = '';

  static const _blue900 = AppColors.kelurahanDark;
  static const _blue500 = AppColors.kelurahanMain;
  static const _blue400 = Color(0xFF42A5F5);

  static final List<String>
      _defaultRts =
      List.generate(23, (i) {
    final n = i + 1;
    return n < 10 ? '0$n' : '$n';
  });

  @override
  void initState() {
    super.initState();
    _selected =
        List<String>.from(
            widget.initialSelected);

    _customRtController =
        TextEditingController();

    _searchController =
        TextEditingController();
  }

  @override
  void dispose() {
    _customRtController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addCustomRt() {
    final val =
        _customRtController.text.trim();

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
    widget.onConfirm(
      List<String>.from(_selected),
    );

    Navigator.pop(context);
  }

  List<String> get _filteredRts {
    final all = {
      ..._defaultRts,
      ..._selected
    }.toList()
      ..sort();

    if (_searchQuery.isEmpty) {
      return all;
    }

    return all
        .where(
          (rt) => rt
              .toLowerCase()
              .contains(
                  _searchQuery
                      .toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRts;

    final bottomInset =
        MediaQuery.of(context)
            .viewInsets
            .bottom;

    return Padding(
      padding:
          EdgeInsets.only(
        bottom: bottomInset,
      ),
      child: Container(
        height:
            MediaQuery.of(context)
                    .size
                    .height *
                0.78,
        decoration:
            const BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius:
              const BorderRadius.only(
            topLeft:
                Radius.circular(32),
            topRight:
                Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 6,
              margin:
                  const EdgeInsets.only(
                top: 14,
              ),
              decoration:
                  BoxDecoration(
                color: Colors
                    .grey.shade300,
                borderRadius:
                    BorderRadius
                        .circular(20),
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.all(
                      20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration:
                        BoxDecoration(
                      gradient:
                          const LinearGradient(
                        colors: [
                          _blue500,
                          _blue400,
                        ],
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                                  18),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color:
                          Colors.white,
                    ),
                  ),

                  const SizedBox(
                      width: 14),

                  const Expanded(
                    child: Text(
                      'Pilih Cakupan RT',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight
                                .w800,
                        color:
                            _blue900,
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons
                          .close_rounded,
                    ),
                    onPressed: () =>
                        Navigator.pop(
                            context),
                  ),
                ],
              ),
            ),

            Expanded(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                        20,
                        0,
                        20,
                        24),
                child: Column(
                  children: [
                    // Search
                    TextField(
                      controller:
                          _searchController,
                      decoration:
                          InputDecoration(
                        hintText:
                            'Cari RT...',
                        prefixIcon:
                            const Icon(
                          Icons
                              .search_rounded,
                        ),
                        filled: true,
                        fillColor:
                            Colors.white,
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  18),
                          borderSide:
                              BorderSide(
                            color: Colors
                                .grey
                                .shade200,
                          ),
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  18),
                          borderSide:
                              BorderSide(
                            color: Colors
                                .grey
                                .shade200,
                          ),
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _searchQuery =
                              v;
                        });
                      },
                    ),

                    const SizedBox(
                        height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customRtController,
                            decoration: InputDecoration(
                              hintText: 'Tambah RT kustom',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        SizedBox(
                          width: 110, // FIX INFINITE WIDTH
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _addCustomRt,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue500,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Tambah',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 20),

                    if (filtered.isEmpty)
                      Padding(
                        padding:
                            const EdgeInsets
                                .all(40),
                        child: Text(
                          'RT tidak ditemukan.\nTambahkan RT baru.',
                          textAlign:
                              TextAlign
                                  .center,
                          style:
                              TextStyle(
                            color: Colors
                                .grey
                                .shade600,
                            height: 1.6,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            filtered.map((rt) {
                          final isSelected =
                              _selected
                                  .contains(
                                      rt);

                          return GestureDetector(
                            onTap: () =>
                                _toggleRt(
                                    rt),
                            child:
                                AnimatedContainer(
                              duration:
                                  const Duration(
                                      milliseconds:
                                          180),
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal:
                                    16,
                                vertical:
                                    12,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: isSelected
                                    ? _blue500
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(16),
                                border:
                                    Border.all(
                                  color: isSelected
                                      ? _blue500
                                      : Colors.grey.shade300,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: _blue500
                                          .withValues(alpha: 0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: Text(
                                'RT $rt',
                                style:
                                    TextStyle(
                                  color: isSelected
                                      ? Colors
                                          .white
                                      : Colors
                                          .black87,
                                  fontWeight:
                                      FontWeight
                                          .w700,
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
              padding:
                  const EdgeInsets
                      .fromLTRB(
                      20,
                      10,
                      20,
                      24),
              child: SizedBox(
                width:
                    double.infinity,
                child:
                    ElevatedButton(
                  onPressed: _confirm,
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        _blue500,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 16,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  18),
                    ),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight
                              .w800,
                      color:
                          Colors.white,
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