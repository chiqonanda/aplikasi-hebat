import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/format_helper.dart';
import '../../core/services/supabase_service.dart';
import '../../core/widgets/app_widgets.dart';

class ProfilBankSampahView extends StatelessWidget {
  const ProfilBankSampahView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionService.to;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppPageHeader replacing default header
            AppPageHeader(
              title: 'Profil Bank Sampah',
              subtitle: 'Informasi & pengaturan',
              gradientColors: AppColors.pengelolaGradient,
              showBack: ModalRoute.of(context)?.canPop ?? false,
            ),

            // Konten scrollable
            Expanded(
              child: ListView(
                padding: AppTheme.pagePaddingAll,
                physics: const BouncingScrollPhysics(),
                children: [
                  // Hero card bank sampah
                  Obx(() {
                    final bank = session.activeBankSampah.value;
                    if (bank == null) return const SizedBox.shrink();
                    return _buildBankHeroCard(bank);
                  }),
                  const SizedBox(height: 16),

                  // Profil pengelola
                  Obx(() {
                    final profil = session.profile.value;
                    if (profil == null) return const SizedBox.shrink();
                    return _buildPengelolaCard(profil);
                  }),
                  const SizedBox(height: 16),

                  // Menu navigasi
                  _buildMenuCard(),
                  const SizedBox(height: 16),

                  // Logout button
                  _buildLogoutButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bank Hero Card ────────────────────────────────────────────────────────

  Widget _buildBankHeroCard(bank) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.pengelolaGradient,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.pengelolaMain.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bank.nama,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (bank.rt != null || bank.rw != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        [
                          if (bank.rt != null) 'RT ${bank.rt}',
                          if (bank.rw != null) 'RW ${bank.rw}',
                        ].join(' / '),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bank.isActive
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  bank.isActive ? 'Aktif' : 'Nonaktif',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),

          // Alamat
          if (bank.alamat != null) ...[
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Colors.white.withValues(alpha: 0.75),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bank.alamat!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Bergabung sejak
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: Colors.white.withValues(alpha: 0.55),
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                'Bergabung ${FormatHelper.date(bank.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Pengelola Card ────────────────────────────────────────────────────────

  Widget _buildPengelolaCard(profil) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.pengelolaLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.pengelolaMain,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Data Pengelola',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),

          // Info rows
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Nama Lengkap',
            value: profil.namaLengkap,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: SupabaseService.currentUser?.email ?? '-',
          ),
          if (profil.noHp != null) ...[
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'No. HP',
              value: profil.noHp!,
            ),
          ],
        ],
      ),
    );
  }

  // ─── Menu Card ─────────────────────────────────────────────────────────────

  Widget _buildMenuCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.history_rounded,
            iconBg: AppColors.kelurahanLight,
            iconColor: AppColors.kelurahanMain,
            label: 'Histori Pengelolaan',
            sublabel: 'Lihat riwayat data sampah',
            onTap: () => Get.toNamed(AppRoutes.historiSampah),
            isFirst: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _MenuTile(
            icon: Icons.swap_horiz_rounded,
            iconBg: const Color(0xFFFBE9E7),
            iconColor: const Color(0xFFE65100),
            label: 'Ganti Bank Sampah',
            sublabel: 'Kelola bank sampah lain',
            onTap: () => Get.toNamed(AppRoutes.pilihBankSampah),
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ─── Logout Button ─────────────────────────────────────────────────────────

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => Get.find<AuthController>().logout(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            SizedBox(width: 8),
            Text(
              'Keluar dari Akun',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Info Row
// ─────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Menu Tile
// ─────────────────────────────────────────

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _MenuTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.sublabel,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(
          top: isFirst ? 6 : 0,
          bottom: isLast ? 6 : 0,
        ),
        child: ListTile(
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            sublabel,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          trailing: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.pengelolaMain,
              size: 18,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        ),
      ),
    );
  }
}