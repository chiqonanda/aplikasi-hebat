import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/session_controller.dart';
import '../../core/services/session_service.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/bank_sampah_model.dart';

class PilihBankSampahView extends GetView<SessionController> {
  const PilihBankSampahView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          // ── Header gradient (sama seperti dashboard) ──
          _buildHeader(),

          // ── Konten scrollable ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget();
              }

              if (controller.listBankSampah.isEmpty) {
                return EmptyState(
                  message: 'Belum Ada Bank Sampah',
                  subtitle: 'Kamu belum terhubung ke bank sampah manapun. Hubungi kelurahan untuk mendapat akses.',
                  icon: Icons.store_outlined,
                  actionLabel: 'Muat Ulang',
                  onAction: controller.fetchBankSampahSaya,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchBankSampahSaya,
                color: AppColors.pengelolaMain,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.listBankSampah.length,
                  itemBuilder: (context, index) {
                    final bank = controller.listBankSampah[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BankSampahCard(
                        bank: bank,
                        onTap: () => controller.pilihBankSampah(bank),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.pengelolaGradient,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar: logo + logout
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: Image.asset(
                  'assets/images/logo.png', // sesuaikan path dengan lokasi file logo
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BISA',
                      style: AppTextStyles.titleLg.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Basis Informasi Sampah',
                      style: AppTextStyles.bodySm.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Logout button
              Tooltip(
                message: 'Keluar',
                child: GestureDetector(
                  onTap: () => Get.find<AuthController>().logout(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.red.shade200,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Greeting
          Text(
            'Selamat Datang 👋',
            style: AppTextStyles.bodySm.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Obx(() {
            final nama =
                SessionService.to.profile.value?.namaLengkap ?? '';
            return Text(
              nama,
              style: AppTextStyles.headlineMd.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            );
          }),
          const SizedBox(height: 14),

          // Info pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.store_outlined,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 6),
                Text(
                  'Pilih bank sampah yang ingin dikelola',
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Bank Sampah Card
// ─────────────────────────────────────────

class _BankSampahCard extends StatelessWidget {
  final BankSampahModel bank;
  final VoidCallback onTap;

  const _BankSampahCard({required this.bank, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = bank.isActive;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(color: AppColors.pengelolaMain.withValues(alpha: 0.25), width: 1.5)
              : Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppColors.pengelolaMain.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.pengelolaLight
                    : AppColors.scaffoldBg,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.store_rounded,
                color: isActive
                    ? AppColors.pengelolaMain
                    : AppColors.textTertiary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bank.nama,
                    style: AppTextStyles.titleSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                  if (bank.rt != null || bank.alamat != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            [
                              if (bank.rt != null) 'RT ${bank.rt}',
                              if (bank.rw != null) 'RW ${bank.rw}',
                              if (bank.alamat != null) bank.alamat!,
                            ].join(' • '),
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Status + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.pengelolaLight
                        : AppColors.scaffoldBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'Aktif' : 'Nonaktif',
                    style: AppTextStyles.bodySm.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? AppColors.pengelolaMain
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isActive
                      ? AppColors.pengelolaMain
                      : AppColors.textTertiary,
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}