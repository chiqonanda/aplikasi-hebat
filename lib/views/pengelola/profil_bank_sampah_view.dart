import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/format_helper.dart';
import '../../core/services/supabase_service.dart';
import '../../models/bank_sampah_model.dart';
import '../../models/profile_model.dart';

class ProfilBankSampahView extends StatelessWidget {
  const ProfilBankSampahView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionService.to;
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: () async {},
        color: AppColors.pengelolaMain,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ───────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(context, canPop)),

            // ── Content ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
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
                    const SizedBox(height: 24),

                    // Logout button
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, bool canPop) {
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
        Positioned(
          top: 30,
          right: 60,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
            child: Row(
              children: [
                if (canPop)
                  GestureDetector(
                    onTap: () => Get.back(),
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
                      const Text(
                        'Profil Bank Sampah',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Informasi bank sampah & akun pengelola',
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
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Bank Hero Card ────────────────────────────────────────────────────────

  Widget _buildBankHeroCard(BankSampahModel bank) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(22),
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
                  Icons.storefront_rounded,
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
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (bank.rt != null || bank.rw != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (bank.rt != null) 'RT ${bank.rt}',
                          if (bank.rw != null) 'RW ${bank.rw}',
                        ].join(' / '),
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Status badge dengan dot
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF69F0AE),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Aktif',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.12),
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
                      fontFamily: 'PlusJakartaSans',
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
                  fontFamily: 'PlusJakartaSans',
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

  // ── Pengelola Card ────────────────────────────────────────────────────────

  Widget _buildPengelolaCard(ProfileModel profil) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: const Border(
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 14),

          _InfoRow(
            icon: Icons.assignment_ind_outlined,
            label: 'Nama Lengkap',
            value: profil.namaLengkap,
            accent: const Color(0xFF2E7D32),
            accentBg: const Color(0xFFE8F5E9),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Email Terdaftar',
            value: SupabaseService.currentUser?.email ?? '-',
            accent: const Color(0xFF1565C0),
            accentBg: const Color(0xFFE3F2FD),
          ),
          if (profil.noHp != null && profil.noHp!.isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.phone_android_outlined,
              label: 'Nomor WhatsApp',
              value: profil.noHp!,
              accent: const Color(0xFFE65100),
              accentBg: const Color(0xFFFFF3E0),
            ),
          ],
        ],
      ),
    );
  }

  // ── Menu Card ─────────────────────────────────────────────────────────────

  Widget _buildMenuCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.history_rounded,
            iconBg: const Color(0xFFE3F2FD),
            iconColor: const Color(0xFF1565C0),
            label: 'Histori Pengelolaan',
            sublabel: 'Lihat data riwayat timbangan sampah',
            onTap: () => Get.toNamed(AppRoutes.historiSampah),
            isFirst: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade100),
          ),
          _MenuTile(
            icon: Icons.swap_horiz_rounded,
            iconBg: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFE65100),
            label: 'Ganti Bank Sampah',
            sublabel: 'Beralih ke kelola bank sampah lain',
            onTap: () => Get.toNamed(AppRoutes.pilihBankSampah),
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ── Logout Button ─────────────────────────────────────────────────────────

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => Get.find<AuthController>().logout(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFFFCDD2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFC62828), size: 20),
            SizedBox(width: 8),
            Text(
              'Keluar dari Akun',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFC62828),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final Color accentBg;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.accentBg,
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
            color: accentBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
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

// ── Menu Tile ─────────────────────────────────────────────────────────────────

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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            sublabel,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
          trailing: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.pengelolaMain,
              size: 20,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
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

    final paintDot = Paint()
      ..color = Colors.white.withValues(alpha: 0.06);

    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.3),
      40,
      paintDot,
    );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.15),
      25,
      paintDot,
    );
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => false;
}