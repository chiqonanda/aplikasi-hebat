import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../core/services/session_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../models/pengelolaan_sampah_model.dart';
import '../../app/routes/app_routes.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;
  final aktivitasTerbaru = <PengelolaanSampahModel>[].obs;

  // Statistik
  final totalJumlahBulanIni = 0.0.obs;
  final totalTransaksiBulanIni = 0.obs;
  final totalNilaiBulanIni = 0.0.obs;
  final totalKgBulanIni = 0.0.obs;
  final totalLiterBulanIni = 0.0.obs;
  final totalSatuanBulanIni = 0.0.obs;
  final totalJumlahHariIni = 0.0.obs;
  final totalTransaksiHariIni = 0.obs;

  String get bankSampahNama => SessionService.to.activeBankSampahNama;
  String get penggunaNama =>
      SessionService.to.profile.value?.namaLengkap ?? '-';

  @override
  void onInit() {
    super.onInit();
    // Defer navigasi dan fetch agar tidak dipanggil saat build berlangsung
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (SessionService.to.activeBankSampahIdOrNull == null) {
        Get.offAllNamed(AppRoutes.pilihBankSampah);
        return;
      }
      fetchDashboardData();
    });
  }

  Future<void> fetchDashboardData() async {
    final bankSampahId = SessionService.to.activeBankSampahIdOrNull;
    if (bankSampahId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.pilihBankSampah);
      });
      return;
    }

    isLoading.value = true;
    try {
      await Future.wait([
        _fetchAktivitasTerbaru(bankSampahId),
        _fetchStatistikBulanIni(bankSampahId),
        _fetchStatistikHariIni(bankSampahId),
      ]);
    } catch (e) {
      debugPrint('ERROR FETCH DASHBOARD: $e');
      Get.snackbar('Error', 'Gagal memuat data dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchAktivitasTerbaru(String bankSampahId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tablePengelolaanSampah)
        .select('''
          *,
          kategori_sampah(*),
          sub_kategori_sampah(*),
          tipe_sampah(*),
          jenis_sampah(*, tipe_sampah(*)),
          satuan(*)
        ''')
        .eq('bank_sampah_id', bankSampahId)
        .order('tanggal_pengelolaan', ascending: false)
        .limit(5);

    aktivitasTerbaru.value = (data as List)
        .map((e) => PengelolaanSampahModel.fromJson(e))
        .toList();
  }

  Future<void> _fetchStatistikBulanIni(String bankSampahId) async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    final data = await SupabaseService.client
        .from(SupabaseConstants.tablePengelolaanSampah)
        .select('jumlah, total_harga, satuan(singkatan)')
        .eq('bank_sampah_id', bankSampahId)
        .gte('tanggal_pengelolaan',
            firstDay.toIso8601String().split('T').first)
        .lte('tanggal_pengelolaan',
            lastDay.toIso8601String().split('T').first);

    final list = data as List;
    totalTransaksiBulanIni.value = list.length;

    double kgSum = 0.0;
    double literSum = 0.0;
    double satuanSum = 0.0;
    double nilaiSum = 0.0;

    for (final e in list) {
      final jumlah = (e['jumlah'] as num).toDouble();
      final totalHarga = (e['total_harga'] as num?)?.toDouble() ?? 0.0;
      nilaiSum += totalHarga;

      final satuanMap = e['satuan'] as Map?;
      final singkatan = (satuanMap?['singkatan'] as String? ?? '').toLowerCase();

      if (singkatan == 'kg') {
        kgSum += jumlah;
      } else if (singkatan == 'liter' || singkatan == 'lt' || singkatan == 'l' || singkatan == 'ltr') {
        literSum += jumlah;
      } else {
        satuanSum += jumlah;
      }
    }

    totalJumlahBulanIni.value = kgSum + literSum + satuanSum;
    totalKgBulanIni.value = kgSum;
    totalLiterBulanIni.value = literSum;
    totalSatuanBulanIni.value = satuanSum;
    totalNilaiBulanIni.value = nilaiSum;
  }

  Future<void> _fetchStatistikHariIni(String bankSampahId) async {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final data = await SupabaseService.client
        .from(SupabaseConstants.tablePengelolaanSampah)
        .select('jumlah')
        .eq('bank_sampah_id', bankSampahId)
        .eq('tanggal_pengelolaan', todayStr);

    final list = data as List;
    totalTransaksiHariIni.value = list.length;
    totalJumlahHariIni.value = list.fold(
      0.0,
      (sum, e) => sum + (e['jumlah'] as num).toDouble(),
    );
  }

  Future<void> goToInputSampah() async {
    final result = await Get.toNamed(AppRoutes.inputSampah);
    // Refresh dashboard otomatis setelah kembali dari input (baik simpan maupun batal)
    if (result == true) fetchDashboardData();
  }
  void goToHistori() => Get.toNamed(AppRoutes.historiSampah);
  void goToLaporan() => Get.toNamed(AppRoutes.laporanPengelola);
  void goToProfil() => Get.toNamed(AppRoutes.profilBankSampah);
  void goToPilihBankSampah() => Get.toNamed(AppRoutes.pilihBankSampah);

  Future<void> refresh() => fetchDashboardData();
}