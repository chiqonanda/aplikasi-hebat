import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../controllers/pengelola/input_sampah_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/utils/validator.dart';
import '../../core/widgets/app_widgets.dart';

class InputSampahView extends StatefulWidget {
  const InputSampahView({super.key});

  @override
  State<InputSampahView> createState() => _InputSampahViewState();
}

class _InputSampahViewState extends State<InputSampahView> {
  final controller = Get.find<InputSampahController>();
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    if (controller.isEditMode) {
      _currentStep = 0;
    }
  }

  bool _validateStep1({bool showSnackbar = false}) {
    if (controller.selectedKategoriId.value.isEmpty) {
      if (showSnackbar) {
        AppSnackbar.info('Silakan pilih kategori sampah.', title: 'Kategori Kosong');
      }
      return false;
    }
    if (controller.listSubKategori.isNotEmpty && controller.selectedSubKategoriId.value.isEmpty) {
      if (showSnackbar) {
        AppSnackbar.info('Silakan pilih sub kategori sampah.', title: 'Sub Kategori Kosong');
      }
      return false;
    }
    if (controller.listTipe.isNotEmpty && controller.selectedTipeId.value.isEmpty) {
      if (showSnackbar) {
        AppSnackbar.info('Silakan pilih tipe material.', title: 'Tipe Kosong');
      }
      return false;
    }
    if (controller.listJenisSampah.isNotEmpty && controller.selectedJenisId.value.isEmpty) {
      if (showSnackbar) {
        AppSnackbar.info('Silakan pilih jenis sampah.', title: 'Jenis Sampah Kosong');
      }
      return false;
    }
    return true;
  }

  bool _validateStep2({bool showSnackbar = false}) {
    final nasabahText = controller.nasabahController.text.trim();
    if (nasabahText.isEmpty) {
      if (showSnackbar) {
        AppSnackbar.info('Silakan isi nama nasabah.', title: 'Nama Nasabah Kosong');
      }
      return false;
    }
    final jumlahText = controller.jumlahController.text.trim();
    final parseJumlah = double.tryParse(jumlahText.replaceAll(',', '.'));
    if (jumlahText.isEmpty || parseJumlah == null || parseJumlah <= 0) {
      if (showSnackbar) {
        AppSnackbar.info('Masukkan jumlah sampah yang valid (lebih dari 0).', title: 'Jumlah Tidak Valid');
      }
      return false;
    }
    if (controller.selectedSatuanId.value.isEmpty) {
      if (showSnackbar) {
        AppSnackbar.info('Silakan tentukan satuan sampah.', title: 'Satuan Kosong');
      }
      return false;
    }
    final hargaText = controller.hargaPerSatuanController.text.trim();
    final parseHarga = double.tryParse(hargaText.replaceAll(',', '.'));
    if (hargaText.isEmpty || parseHarga == null || parseHarga < 0) {
      if (showSnackbar) {
        AppSnackbar.info('Masukkan harga per satuan yang valid.', title: 'Harga Tidak Valid');
      }
      return false;
    }
    if (controller.selectedTanggal.value == null) {
      if (showSnackbar) {
        AppSnackbar.info('Silakan pilih tanggal pengelolaan.', title: 'Tanggal Kosong');
      }
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildStepIndicator(),
            Expanded(
              child: Form(
                key: controller.formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    if (_currentStep == 0) ...[
                      _SectionCard(
                        icon: Icons.category_outlined,
                        iconColor: const Color(0xFF6A1B9A),
                        iconBg: const Color(0xFFF3E5F5),
                        accentColor: const Color(0xFF6A1B9A),
                        title: 'Jenis Sampah',
                        child: Column(
                          children: [
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
                    ] else if (_currentStep == 1) ...[
                      _SectionCard(
                        icon: Icons.person_outline_rounded,
                        iconColor: const Color(0xFF0D47A1),
                        iconBg: const Color(0xFFE3F2FD),
                        accentColor: const Color(0xFF1565C0),
                        title: 'Data Nasabah',
                        child: RawAutocomplete<String>(
                          textEditingController: controller.nasabahController,
                          focusNode: FocusNode(),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            final currentText = textEditingValue.text.trim();
                            final matches = controller.listNamaNasabah.where((String option) {
                              return option.toLowerCase().contains(currentText.toLowerCase());
                            }).toList();

                            if (currentText.isNotEmpty && !controller.listNamaNasabah.contains(currentText)) {
                              matches.add('Tambah: "$currentText"');
                            }
                            return matches;
                          },
                          onSelected: (String selection) {
                            if (selection.startsWith('Tambah: "') && selection.endsWith('"')) {
                              final name = selection.substring(9, selection.length - 1);
                              controller.nasabahController.text = name;
                            } else {
                              controller.nasabahController.text = selection;
                            }
                          },
                          fieldViewBuilder: (BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted) {
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontFamily: 'PlusJakartaSans',
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Nama Nasabah *',
                                hintText: 'Ketik nama nasabah...',
                                prefixIcon: Icon(Icons.person_search_rounded, size: 20, color: AppColors.outline),
                              ),
                              validator: (v) => AppValidator.required(v, fieldName: 'Nama nasabah'),
                            );
                          },
                          optionsViewBuilder: (BuildContext context,
                              AutocompleteOnSelected<String> onSelected,
                              Iterable<String> options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                child: Container(
                                  width: 320,
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final String option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option, style: AppTextStyles.bodyMd),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),

                      _SectionCard(
                        icon: Icons.scale_outlined,
                        iconColor: const Color(0xFF1565C0),
                        iconBg: const Color(0xFFE3F2FD),
                        accentColor: const Color(0xFF1565C0),
                        title: 'Jumlah, Satuan & Harga',
                        child: Column(
                          children: [
                            Row(
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
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: controller.hargaPerSatuanController,
                              label: 'Harga per Satuan (Rp) *',
                              hint: 'Masukkan harga per satuan...',
                              prefixIcon: Icons.attach_money_rounded,
                              keyboardType: const TextInputType.numberWithOptions(decimal: false),
                              inputFormatters: [
                                ThousandsSeparatorInputFormatter(),
                              ],
                              validator: AppValidator.harga,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      _SectionCard(
                        icon: Icons.calendar_today_outlined,
                        iconColor: const Color(0xFF00838F),
                        iconBg: const Color(0xFFE0F7FA),
                        accentColor: const Color(0xFF00838F),
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

                      _CollapsibleCatatanSection(controller: controller),
                    ] else ...[
                      Obx(() {
                        if (controller.hargaSnapshot.value == null) {
                          return const SizedBox.shrink();
                        }
                        return _buildHargaSnapshot();
                      }),

                      _SummaryCard(controller: controller),
                    ],
                  ],
                ),
              ),
            ),

            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
          child: Row(
            children: [
              if (canPop)
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
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
                    Text(
                      controller.isEditMode ? 'Edit Data Sampah' : 'Input Data Sampah',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.4,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.isEditMode
                          ? 'Perbarui data pengelolaan bank sampah'
                          : 'Tambah pencatatan pengelolaan baru',
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
                child: Icon(
                  controller.isEditMode
                      ? Icons.edit_note_rounded
                      : Icons.add_circle_outline_rounded,
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

  // ── Step Indicator ────────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepNode(0, 'Pilih Jenis', Icons.category_outlined),
          _buildStepLine(0),
          _buildStepNode(1, 'Isi Detail', Icons.edit_note_rounded),
          _buildStepLine(1),
          _buildStepNode(2, 'Konfirmasi', Icons.fact_check_outlined),
        ],
      ),
    );
  }

  Widget _buildStepNode(int index, String label, IconData icon) {
    final isCompleted = _currentStep > index;
    final isActive = _currentStep == index;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: isCompleted || isActive
                  ? const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                    )
                  : null,
              color: isCompleted || isActive ? null : Colors.grey.shade50,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive || isCompleted
                    ? AppColors.pengelolaMain
                    : Colors.grey.shade200,
                width: 2,
              ),
              boxShadow: (isCompleted || isActive)
                  ? [
                      BoxShadow(
                        color: AppColors.pengelolaMain.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : icon,
              size: 16,
              color: (isCompleted || isActive) ? Colors.white : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive || isCompleted ? FontWeight.w700 : FontWeight.w500,
              color: isActive
                  ? AppColors.pengelolaMain
                  : isCompleted
                      ? AppColors.textPrimary
                      : Colors.grey.shade400,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int index) {
    final isPassed = _currentStep > index;
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isPassed ? AppColors.pengelolaMain : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // ── Bottom Action Bar ─────────────────────────────────────────────────────

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep == 0) ...[
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: AppColors.pengelolaMain, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _GradientButton(
                  label: 'Selanjutnya',
                  icon: Icons.arrow_forward_rounded,
                  onTap: () {
                    if (_validateStep1(showSnackbar: true)) {
                      setState(() {
                        _currentStep = 1;
                      });
                    }
                  },
                ),
              ),
            ] else if (_currentStep == 1) ...[
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = 0;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: AppColors.pengelolaMain, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Kembali'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _GradientButton(
                  label: 'Selanjutnya',
                  icon: Icons.arrow_forward_rounded,
                  onTap: () {
                    if (_validateStep2(showSnackbar: true)) {
                      setState(() {
                        _currentStep = 2;
                      });
                    }
                  },
                ),
              ),
            ] else ...[
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = 1;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: AppColors.pengelolaMain, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Kembali'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Obx(() {
                  final isSaving = controller.isLoading.value;
                  return _GradientButton(
                    label: controller.isEditMode ? 'Simpan' : 'Simpan Data',
                    icon: Icons.check_circle_outline_rounded,
                    isLoading: isSaving,
                    onTap: isSaving ? null : controller.simpan,
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Harga Snapshot ────────────────────────────────────────────────────────

  Widget _buildHargaSnapshot() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border(
            top: BorderSide(color: AppColors.pengelolaMain, width: 2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.pengelolaMain.withValues(alpha: 0.06),
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
                  width: 36,
                  height: 36,
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
                    fontFamily: 'PlusJakartaSans',
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
                      fontWeight: FontWeight.w800,
                      color: AppColors.pengelolaMain,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ),
              ],
            ),
            if (controller.jumlahController.text.isNotEmpty) ...[
              const SizedBox(height: 14),
              Divider(height: 1, color: Colors.grey.shade100),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estimasi Nilai Transaksi',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontFamily: 'PlusJakartaSans',
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
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF00838F),
                      fontFamily: 'PlusJakartaSans',
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
}

// ── Gradient Button ───────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: onTap == null
              ? []
              : [
                  BoxShadow(
                    color: AppColors.pengelolaMain.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(icon, size: 16, color: Colors.white),
                ],
              ),
      ),
    );
  }
}

// ── Section Card ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color accentColor;

  const _SectionCard({
    required this.title,
    required this.child,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          top: BorderSide(color: accentColor, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
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
                  width: 36,
                  height: 36,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
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
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        fontFamily: 'PlusJakartaSans',
      ),
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
          borderSide:
              const BorderSide(color: AppColors.pengelolaMain, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
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
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(14),
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: Colors.grey.shade400),
    );
  }
}

// ── Summary Card ───────────────────────────────────────────────────────────────

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
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.pengelolaMain.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Ringkasan Pencatatan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Nama Nasabah', controller.nasabahController.text),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Jenis Sampah', controller.jenisSampahBreadcrumb),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Jumlah',
                    '${FormatHelper.number(controller.rxJumlah.value)} ${controller.selectedSatuanSingkatan}',
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Tanggal', controller.selectedTanggalFormat),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Harga/Satuan',
                    '${FormatHelper.currency(controller.rxHargaPerSatuan.value)} / ${controller.selectedSatuanSingkatan}',
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: Colors.white.withValues(alpha: 0.12)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Nilai',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                      Text(
                        FormatHelper.currency(
                          controller.rxJumlah.value * controller.rxHargaPerSatuan.value,
                        ),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.65),
              fontWeight: FontWeight.w500,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ),
      ],
    );
  }
}

// ── Collapsible Catatan Section ────────────────────────────────────────────────

class _CollapsibleCatatanSection extends StatelessWidget {
  final InputSampahController controller;

  const _CollapsibleCatatanSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.notes_rounded, color: Colors.grey.shade500, size: 18),
          ),
          title: const Text(
            'Tambah Catatan (Opsional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
          children: [
            Divider(height: 1, color: Colors.grey.shade100),
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppTextField(
                controller: controller.catatanController,
                label: 'Catatan',
                hint: 'Tambahkan keterangan tambahan pencatatan...',
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
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => false;
}