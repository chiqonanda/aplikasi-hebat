import 'package:get/get.dart';

/// Tab-tab di shell utama pengelola.
/// Urutan enum harus sama dengan urutan halaman di [PengelolaMainView].
enum PengelolaTab { dashboard, histori, laporan, profil }

class PengelolaMainController extends GetxController {
  final currentTab = PengelolaTab.dashboard.obs;

  PengelolaTab get currentIndex => currentTab.value;

  void changePage(PengelolaTab tab) {
    currentTab.value = tab;
  }
}
