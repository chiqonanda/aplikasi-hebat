import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import 'motion.dart';

/// Dialog konfirmasi "Apakah kamu ingin keluar?" saat user menekan back
/// di halaman utama. Dipanggil lewat [confirmExit] dalam PopScope.
Future<bool> confirmExit() async {
  final ok = await Get.dialog<bool>(
    PopIn(
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.dangerMid, AppColors.danger],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.exit_to_app_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(height: 18),
              const Text(
                'Keluar Aplikasi?',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.kelurahanDark,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah kamu ingin keluar dari aplikasi?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13.5,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: PressableScale(
                      onTap: () => Get.back(result: false),
                      pressedScale: 0.95,
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.kelurahanLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.blueLight, width: 1),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.kelurahanMain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PressableScale(
                      onTap: () => Get.back(result: true),
                      pressedScale: 0.95,
                      glowIntensity: 0.4,
                      glowColor: AppColors.danger,
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.dangerMid, AppColors.danger],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.danger.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Keluar',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return ok ?? false;
}

/// Bungkus Scaffold utama dengan ini agar tombol back sistem
/// (atau swipe-back) menampilkan dialog konfirmasi keluar.
class ExitConfirmScope extends StatelessWidget {
  final Widget child;

  const ExitConfirmScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        HapticFeedback.mediumImpact();
        final exit = await confirmExit();
        if (exit) SystemNavigator.pop();
      },
      child: child,
    );
  }
}
