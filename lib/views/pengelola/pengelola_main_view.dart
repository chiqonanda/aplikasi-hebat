import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/design_tokens.dart';
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
      bottomNavigationBar: _buildCustomBottomNav(context),
    );
  }

  Widget _buildCustomBottomNav(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'icon': Icons.dashboard_outlined,
        'activeIcon': Icons.dashboard_rounded,
        'label': 'Dashboard',
      },
      {
        'icon': Icons.history_outlined,
        'activeIcon': Icons.history_rounded,
        'label': 'Histori',
      },
      {
        'icon': Icons.sell_outlined,
        'activeIcon': Icons.sell_rounded,
        'label': 'Harga',
      },
      {
        'icon': Icons.store_outlined,
        'activeIcon': Icons.store_rounded,
        'label': 'Profil',
      },
    ];

    return Obx(() {
      final selectedIndex = controller.currentIndex.value;
      final bottomPadding = MediaQuery.of(context).padding.bottom;

      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.noScaling,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLowest,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final isSelected = selectedIndex == index;
                  final item = items[index];

                  return Expanded(
                    flex: isSelected ? 3 : 2,
                    child: GestureDetector(
                      onTap: () => controller.changePage(index),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.pengelolaLight
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected ? item['activeIcon'] : item['icon'],
                                color: isSelected
                                    ? AppColors.pengelolaDark
                                    : AppColors.textSecondary,
                                size: 20,
                              ),
                              Flexible(
                                child: AnimatedSize(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: isSelected
                                      ? Padding(
                                          padding: const EdgeInsets.only(left: 6.0),
                                          child: Text(
                                            item['label'],
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.pengelolaDark,
                                              fontFamily: 'PlusJakartaSans',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      );
    });
  }
}
