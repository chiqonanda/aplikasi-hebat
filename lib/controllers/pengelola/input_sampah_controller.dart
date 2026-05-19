import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../core/services/session_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/utils/format_helper.dart';
import '../../models/kategori_model.dart';
import '../../models/sub_kategori_model.dart';
import '../../models/jenis_sampah_model.dart';
import '../../models/satuan_model.dart';
import '../../models/harga_sampah_model.dart';
import '../../models/pengelolaan_sampah_model.dart';

class InputSampahController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final jumlahController = TextEditingController();
  final catatanController = TextEditingController();
  final tanggalController = TextEditingController();

  // Data list
  final listKategori = <KategoriModel>[].obs;
  final listSubKategori = <SubKategoriModel>[].obs;
  final listJenisSampah = <JenisSampahModel>[].obs;
  final listSatuan = <SatuanModel>[].obs;

  // State dropdown — pakai String ID agar konsisten dengan view
  final selectedKategoriId = ''.obs;
  final selectedSubKategoriId = ''.obs;
  final selectedJenisId = ''.obs;
  final selectedSatuanId = ''.obs;

  // Tanggal
  final selectedTanggal = Rx<DateTime?>(DateTime.now());

  // Harga snapshot otomatis dari tabel harga_sampah
  final hargaSnapshot = Rx<HargaSampahModel?>(null);

  // Loading state
  final isLoading = false.obs;
  final isSaving = false.obs;

  // Edit mode
  PengelolaanSampahModel? editData;
  bool get isEditMode => editData != null;

  @override
  void onInit() {
    super.onInit();
    _checkEditMode();
    _fetchMasterData();

    // Listener cascade dropdown
    ever(selectedKategoriId, (_) => _onKategoriChanged());
    ever(selectedSubKategoriId, (_) => _onSubKategoriChanged());
    ever(selectedJenisId, (_) => _onJenisChanged());
  }

  void _checkEditMode() {
    if (Get.arguments != null && Get.arguments is PengelolaanSampahModel) {
      editData = Get.arguments as PengelolaanSampahModel;
    }
  }

  Future<void> _fetchMasterData() async {
    isLoading.value = true;
    try {
      await Future.wait([_fetchKategori(), _fetchSatuan()]);
      if (isEditMode) _populateEditData();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data master.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchKategori() async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableKategoriSampah)
        .select()
        .eq('is_active', true)
        .order('nama');
    listKategori.value =
        (data as List).map((e) => KategoriModel.fromJson(e)).toList();
  }

  Future<void> _fetchSubKategori(String kategoriId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableSubKategoriSampah)
        .select()
        .eq('kategori_id', kategoriId)
        .eq('is_active', true)
        .order('nama');
    listSubKategori.value =
        (data as List).map((e) => SubKategoriModel.fromJson(e)).toList();
  }

  Future<void> _fetchJenisSampah(String subKategoriId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableJenisSampah)
        .select('*, satuan(*)')
        .eq('sub_kategori_id', subKategoriId)
        .eq('is_active', true)
        .order('nama');
    listJenisSampah.value =
        (data as List).map((e) => JenisSampahModel.fromJson(e)).toList();
  }

  Future<void> _fetchSatuan() async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableSatuan)
        .select()
        .order('nama');
    listSatuan.value =
        (data as List).map((e) => SatuanModel.fromJson(e)).toList();
  }

  Future<void> _fetchHargaOtomatis() async {
    final bankSampahId = SessionService.to.activeBankSampahId;
    hargaSnapshot.value = null;

    try {
      dynamic data;

      // Cari dari yang paling spesifik ke paling umum
      if (selectedJenisId.value.isNotEmpty) {
        data = await SupabaseService.client
            .from(SupabaseConstants.tableHargaSampah)
            .select('*, satuan(*)')
            .eq('bank_sampah_id', bankSampahId)
            .eq('jenis_sampah_id', selectedJenisId.value)
            .maybeSingle();
      }

      if (data == null && selectedSubKategoriId.value.isNotEmpty) {
        data = await SupabaseService.client
            .from(SupabaseConstants.tableHargaSampah)
            .select('*, satuan(*)')
            .eq('bank_sampah_id', bankSampahId)
            .eq('sub_kategori_id', selectedSubKategoriId.value)
            .isFilter('jenis_sampah_id', null)
            .maybeSingle();
      }

      if (data == null && selectedKategoriId.value.isNotEmpty) {
        data = await SupabaseService.client
            .from(SupabaseConstants.tableHargaSampah)
            .select('*, satuan(*)')
            .eq('bank_sampah_id', bankSampahId)
            .eq('kategori_id', selectedKategoriId.value)
            .isFilter('sub_kategori_id', null)
            .isFilter('jenis_sampah_id', null)
            .maybeSingle();
      }

      if (data != null) {
        hargaSnapshot.value = HargaSampahModel.fromJson(data);
        // Auto-set satuan dari harga jika belum dipilih
        if (hargaSnapshot.value?.satuanId != null &&
            selectedSatuanId.value.isEmpty) {
          selectedSatuanId.value = hargaSnapshot.value!.satuanId;
        }
      }
    } catch (_) {
      // Harga tidak ditemukan, tidak masalah
    }
  }

  void _onKategoriChanged() {
    selectedSubKategoriId.value = '';
    selectedJenisId.value = '';
    listSubKategori.clear();
    listJenisSampah.clear();
    hargaSnapshot.value = null;

    if (selectedKategoriId.value.isNotEmpty) {
      _fetchSubKategori(selectedKategoriId.value);
      _fetchHargaOtomatis();
    }
  }

  void _onSubKategoriChanged() {
    selectedJenisId.value = '';
    listJenisSampah.clear();

    if (selectedSubKategoriId.value.isNotEmpty) {
      _fetchJenisSampah(selectedSubKategoriId.value);
    }
    _fetchHargaOtomatis();
  }

  void _onJenisChanged() {
    // Auto-set satuan default dari jenis sampah yang dipilih
    if (selectedJenisId.value.isNotEmpty) {
      final jenis = listJenisSampah.firstWhereOrNull(
        (j) => j.id == selectedJenisId.value,
      );
      if (jenis?.satuanDefaultId != null && selectedSatuanId.value.isEmpty) {
        selectedSatuanId.value = jenis!.satuanDefaultId!;
      }
    }
    _fetchHargaOtomatis();
  }

  // Callback untuk dropdown view
  void onKategoriChanged(String? id) {
    selectedKategoriId.value = id ?? '';
  }

  void onSubKategoriChanged(String? id) {
    selectedSubKategoriId.value = id ?? '';
  }

  void onJenisChanged(String? id) {
    selectedJenisId.value = id ?? '';
  }

  void _populateEditData() {
    final d = editData!;

    selectedTanggal.value = d.tanggalPengelolaan;
    tanggalController.text =
        FormatHelper.date(d.tanggalPengelolaan);
    jumlahController.text = d.jumlah.toString();
    catatanController.text = d.catatan ?? '';
    selectedSatuanId.value = d.satuanId;

    // Set kategori, lalu muat sub-kategori & jenis secara berantai
    if (d.kategoriId.isNotEmpty) {
      selectedKategoriId.value = d.kategoriId;
      _fetchSubKategori(d.kategoriId).then((_) {
        if (d.subKategoriId != null) {
          selectedSubKategoriId.value = d.subKategoriId!;
          _fetchJenisSampah(d.subKategoriId!).then((_) {
            if (d.jenisSampahId != null) {
              selectedJenisId.value = d.jenisSampahId!;
            }
          });
        }
      });
    }
  }

  Future<void> pickTanggal(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedTanggal.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedTanggal.value = picked;
      tanggalController.text = FormatHelper.date(picked);
    }
  }

  void clearTanggal() {
    selectedTanggal.value = null;
    tanggalController.clear();
  }

  Future<void> simpan() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedKategoriId.value.isEmpty) {
      Get.snackbar('Validasi', 'Kategori wajib dipilih.');
      return;
    }
    if (selectedSatuanId.value.isEmpty) {
      Get.snackbar('Validasi', 'Satuan wajib dipilih.');
      return;
    }
    if (selectedTanggal.value == null) {
      Get.snackbar('Validasi', 'Tanggal wajib diisi.');
      return;
    }

    isSaving.value = true;
    try {
      final payload = {
        'bank_sampah_id': SessionService.to.activeBankSampahId,
        'profile_id': SessionService.to.profile.value!.id,
        'kategori_id': selectedKategoriId.value,
        'sub_kategori_id': selectedSubKategoriId.value.isEmpty
            ? null
            : selectedSubKategoriId.value,
        'jenis_sampah_id':
            selectedJenisId.value.isEmpty ? null : selectedJenisId.value,
        'jumlah': double.parse(
            jumlahController.text.trim().replaceAll(',', '.')),
        'satuan_id': selectedSatuanId.value,
        'harga_per_satuan': hargaSnapshot.value?.hargaPerSatuan,
        'tanggal_pengelolaan':
            FormatHelper.dateToInput(selectedTanggal.value!),
        'catatan': catatanController.text.trim().isEmpty
            ? null
            : catatanController.text.trim(),
      };

      if (isEditMode) {
        await SupabaseService.client
            .from(SupabaseConstants.tablePengelolaanSampah)
            .update(payload)
            .eq('id', editData!.id);
        Get.back(result: true);
        Get.snackbar('Berhasil', 'Data sampah berhasil diperbarui.');
      } else {
        await SupabaseService.client
            .from(SupabaseConstants.tablePengelolaanSampah)
            .insert(payload);
        Get.back(result: true);
        Get.snackbar('Berhasil', 'Data sampah berhasil disimpan.');
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Data gagal disimpan. Coba lagi.');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    jumlahController.dispose();
    catatanController.dispose();
    tanggalController.dispose();
    super.onClose();
  }
}