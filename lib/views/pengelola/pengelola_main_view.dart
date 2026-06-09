import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pengelola/pengelola_main_controller.dart';
import 'dashboard_view.dart';
import 'histori_view.dart';
import 'harga_view.dart';
import 'profil_bank_sampah_view.dart';

class PengelolaMainView extends GetView<PengelolaMainController> {
  const PengelolaMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DashboardView(),
      const HistoriView(),
      const HargaView(),
      const ProfilBankSampahView(),
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: pages,
          )),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: BottomNavigationBar(
                currentIndex: controller.currentIndex.value,
                onTap: controller.changePage,
                backgroundColor: Colors.white,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: const Color(0xFF2E7D32),
                unselectedItemColor: Colors.grey.shade400,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
                items: const [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.dashboard_rounded, size: 22),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.dashboard_rounded, size: 24),
                    ),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.history_rounded, size: 22),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.history_rounded, size: 24),
                    ),
                    label: 'Histori',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.sell_rounded, size: 22),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.sell_rounded, size: 24),
                    ),
                    label: 'Harga',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.store_rounded, size: 22),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.store_rounded, size: 24),
                    ),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
