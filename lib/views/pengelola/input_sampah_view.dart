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
    // Jika dalam mode edit, mulai dengan data terisi penuh
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppPageHeader replacing default header
            AppPageHeader(
              title: controller.isEditMode ? 'Edit Data Sampah' : 'Input Data Sampah',
              subtitle: controller.isEditMode
                  ? 'Perbarui data pengelolaan bank sampah'
                  : 'Tambah pencatatan pengelolaan baru',
              gradientColors: AppColors.pengelolaGradient,
              showBack: true,
            ),

            // Step Progress Indicator
            _buildStepIndicator(),

            // Form scrollable
            Expanded(
              child: Form(
                key: controller.formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    if (_currentStep == 0) ...[
                      // STEP 1: Jenis Sampah
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
                    ] else if (_currentStep == 1) ...[
                      // STEP 2: Informasi Nasabah
                      _SectionCard(
                        icon: Icons.person_outline_rounded,
                        iconColor: const Color(0xFF0D47A1),
                        iconBg: const Color(0xFFE3F2FD),
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
                                color: AppColors.surfaceLowest,
                                child: Container(
                                  width: 320,
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.outlineVariant),
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

                      // STEP 2: Jumlah & Tanggal Detail
                      _SectionCard(
                        icon: Icons.scale_outlined,
                        iconColor: const Color(0xFF1565C0),
                        iconBg: const Color(0xFFE3F2FD),
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
                                                    'Kunci ltr (Jelantah)',
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
                                                    'Otomatis',
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
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: controller.hargaPerSatuanController,
                              label: 'Harga per Satuan (Rp) *',
                              hint: 'Masukkan harga per satuan...',
                              prefixIcon: Icons.attach_money_rounded,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: AppValidator.harga,
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

                      // Catatan Collapsible
                      _CollapsibleCatatanSection(controller: controller),
                    ] else ...[
                      // STEP 3: Konfirmasi Ringkasan
                      Obx(() {
                        if (controller.hargaSnapshot.value == null) {
                          return const SizedBox.shrink();
                        }
                        return _buildHargaSnapshot();
                      }),

                      // Summary Card
                      _SummaryCard(controller: controller),
                    ],
                  ],
                ),
              ),
            ),

            // Persistent bottom actions
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  // ─── Step Indicator ──────────────────────────────────────────────────────

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
              color: isCompleted
                  ? AppColors.pengelolaMain
                  : isActive
                      ? AppColors.pengelolaLight
                      : Colors.grey.shade50,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? AppColors.pengelolaMain
                    : isCompleted
                        ? AppColors.pengelolaMain
                        : Colors.grey.shade200,
                width: 2,
              ),
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : icon,
              size: 16,
              color: isCompleted
                  ? Colors.white
                  : isActive
                      ? AppColors.pengelolaMain
                      : Colors.grey.shade400,
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
                      : AppColors.textTertiary,
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
      color: isPassed ? AppColors.pengelolaMain : Colors.grey.shade200,
    );
  }

  // ─── Bottom Action Bar ────────────────────────────────────────────────────

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
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () {
                    if (_validateStep1(showSnackbar: true)) {
                      setState(() {
                        _currentStep = 1;
                      });
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Selanjutnya'),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
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
                  ),
                  child: const Text('Kembali'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () {
                    if (_validateStep2(showSnackbar: true)) {
                      setState(() {
                        _currentStep = 2;
                      });
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Selanjutnya'),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
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
                  ),
                  child: const Text('Kembali'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Obx(() {
                  final isSaving = controller.isLoading.value;
                  return ElevatedButton(
                    onPressed: isSaving ? null : controller.simpan,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSaving) ...[
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ] else ...[
                          const Icon(Icons.check_circle_outline_rounded, size: 16),
                          const SizedBox(width: 6),
                        ],
                        Text(controller.isEditMode ? 'Simpan' : 'Simpan Data'),
                      ],
                    ),
                  );
                }),
              ),
            ],
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.pengelolaMain.withValues(alpha: 0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.pengelolaMain.withValues(alpha: 0.04),
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
              const Divider(height: 1, color: AppColors.divider),
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
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
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
        fillColor: enabled ? AppColors.surfaceLowest : AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.pengelolaMain, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pengelolaMain.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.pengelolaMain.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.pengelolaLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.assignment_outlined, color: AppColors.pengelolaMain, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Ringkasan Pencatatan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.pengelolaDark,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.all(18),
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
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Nilai',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                  Text(
                    FormatHelper.currency(
                      controller.rxJumlah.value * controller.rxHargaPerSatuan.value,
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pengelolaMain,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ],
              ),
              ],
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
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
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
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontFamily: 'PlusJakartaSans',
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              fontFamily: 'PlusJakartaSans',
            ),
          ),
          children: [
            const Divider(height: 1, color: AppColors.divider),
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