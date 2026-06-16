import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/design_tokens.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/format_helper.dart';
import '../../controllers/auth_controller.dart';

class ProfilKelurahanView extends StatelessWidget {
  const ProfilKelurahanView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionService.to;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Wave Header ──────────────────────────────────────────────
              _buildWaveHeader(context, session),

              // ── Avatar overlapping header ────────────────────────────────
              Transform.translate(
                offset: const Offset(0, -48),
                child: _buildAvatar(session),
              ),

              // ── Nama & Badge ─────────────────────────────────────────────
              Transform.translate(
                offset: const Offset(0, -36),
                child: _buildNameBadge(session),
              ),

              // ── Cards ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Column(
                    children: [
                      _buildInfoCard(session),
                      const SizedBox(height: 20),
                      _buildMenuGrid(),
                      const SizedBox(height: 20),
                      _buildLogoutButton(context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Wave Header ─────────────────────────────────────────────────────────
  Widget _buildWaveHeader(BuildContext context, SessionService session) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 210),
          painter: _WavePainter(),
        ),

        // Decorative circles
        Positioned(
          top: -30,
          right: -20,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: 60,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: -20,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  const Expanded(
                    child: Text(
                      'Profil',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // Edit hint icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Kelurahan badge dengan dot hijau
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
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
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.verified_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Pengelola Kelurahan',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Avatar ───────────────────────────────────────────────────────────────
  Widget _buildAvatar(SessionService session) {
    return Center(
      child: Obx(() {
        final nama = session.profile.value?.namaLengkap ?? 'K';
        final initial = nama.isNotEmpty ? nama[0].toUpperCase() : 'K';
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.kelurahanGradient,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: AppColors.kelurahanMain.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Nama & Badge ─────────────────────────────────────────────────────────
  Widget _buildNameBadge(SessionService session) {
    return Center(
      child: Column(
        children: [
          Obx(() => Text(
                session.profile.value?.namaLengkap ?? '-',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.kelurahanDark,
                  letterSpacing: -0.5,
                ),
              )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.kelurahanLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFBBDEFB),
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
                    color: AppColors.kelurahanMain,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Akun Terverifikasi',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kelurahanMain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Card ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard(SessionService session) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEBF2FA), width: 1.2),
        boxShadow: DesignTokens.kelurahanShadowSm,
      ),
      child: Column(
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.kelurahanMain,
                        Color(0xFF42A5F5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Informasi Akun',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.kelurahanDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),

          // Rows
          Obx(() => _InfoRow(
                icon: Icons.badge_outlined,
                label: 'Nama Lengkap',
                value: session.profile.value?.namaLengkap ?? '-',
                iconGradient: const [
                  AppColors.kelurahanMain,
                  Color(0xFF42A5F5),
                ],
              )),
          const Divider(
              color: Color(0xFFF1F5F9), height: 1, thickness: 1,
              indent: 16, endIndent: 16),
          const _InfoRow(
            icon: Icons.admin_panel_settings_outlined,
            label: 'Role',
            value: 'Pengelola Kelurahan',
            iconGradient: [Color(0xFF00838F), Color(0xFF26C6DA)],
          ),
          const Divider(
              color: Color(0xFFF1F5F9), height: 1, thickness: 1,
              indent: 16, endIndent: 16),
          Obx(() => _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Bergabung Sejak',
                value: session.profile.value?.createdAt != null
                    ? FormatHelper.date(session.profile.value!.createdAt)
                    : '-',
                iconGradient: const [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
              )),
        ],
      ),
    );
  }

  // ── Menu Grid ─────────────────────────────────────────────────────────────
  Widget _buildMenuGrid() {
    final menus = [
      _MenuItem(
        icon: Icons.bar_chart_rounded,
        label: 'Monitoring',
        gradientColors: const [AppColors.kelurahanMain, Color(0xFF42A5F5)],
        bgColor: AppColors.kelurahanLight,
        onTap: () => Get.toNamed(AppRoutes.monitoringBankSampah),
      ),
      _MenuItem(
        icon: Icons.store_rounded,
        label: 'Bank Sampah',
        gradientColors: const [Color(0xFF00838F), Color(0xFF26C6DA)],
        bgColor: const Color(0xFFE0F7FA),
        onTap: () => Get.toNamed(AppRoutes.manajemenBankSampah),
      ),
      _MenuItem(
        icon: Icons.people_outline_rounded,
        label: 'Pengelola',
        gradientColors: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
        bgColor: const Color(0xFFE3F2FD),
        onTap: () => Get.toNamed(AppRoutes.manajemenPengelola),
      ),
      _MenuItem(
        icon: Icons.category_outlined,
        label: 'Jenis Sampah',
        gradientColors: const [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
        bgColor: const Color(0xFFF3E5F5),
        onTap: () => Get.toNamed(AppRoutes.masterSampah),
      ),
      _MenuItem(
        icon: Icons.assessment_outlined,
        label: 'Laporan',
        gradientColors: const [Color(0xFF00695C), Color(0xFF26A69A)],
        bgColor: const Color(0xFFE0F2F1),
        onTap: () => Get.toNamed(AppRoutes.generatorLaporan),
      ),
      _MenuItem(
        icon: Icons.manage_search_rounded,
        label: 'Aktivitas',
        gradientColors: const [Color(0xFF283593), Color(0xFF5C6BC0)],
        bgColor: const Color(0xFFE8EAF6),
        onTap: () => Get.toNamed(AppRoutes.monitoringBankSampah),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.kelurahanMain, Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Kelola Sistem',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.kelurahanDark,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 24) / 3;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menus.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: itemWidth + 16,
              ),
              itemBuilder: (context, index) {
                return _MenuCard(item: menus[index]);
              },
            );
          },
        ),
      ],
    );
  }

  // ── Logout Button ─────────────────────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmLogout(context),
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD32F2F).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Shine
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 27,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Keluar dari Akun',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) async {
    final ok = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.kelurahanMain.withValues(alpha: 0.12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD32F2F).withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Keluar dari Akun?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.kelurahanDark,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda akan keluar dari sesi ini.\nApakah Anda yakin?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  color: Colors.grey.shade500,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(result: false),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.kelurahanLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFBBDEFB),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.kelurahanMain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(result: true),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD32F2F)
                                  .withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Keluar',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
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
    );

    if (ok == true) {
      // Tunggu hingga dialog tertutup sepenuhnya sebelum memicu transisi logout
      Future.delayed(const Duration(milliseconds: 150), () {
        Get.find<AuthController>().logout();
      });
    }
  }
}

// ── Info Row Widget ──────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> iconGradient;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: iconGradient,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: iconGradient.first.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kelurahanDark,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.shade300,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ── Menu Item Data ───────────────────────────────────────────────────────────
class _MenuItem {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final Color bgColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.bgColor,
    required this.onTap,
  });
}

// ── Menu Card Widget ─────────────────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final _MenuItem item;

  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border(
            top: BorderSide(color: item.gradientColors.first, width: 2),
          ),
          boxShadow: [
            BoxShadow(
              color: item.gradientColors.first.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: item.gradientColors,
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: item.gradientColors.first.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(item.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.kelurahanDark,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Wave Painter ─────────────────────────────────────────────────────────────
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppColors.kelurahanGradient,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path1 = Path()
      ..lineTo(0, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.95,
        size.width * 0.5,
        size.height * 0.82,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.68,
        size.width,
        size.height * 0.80,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = const Color(0xFF42A5F5).withValues(alpha: 0.3);

    final path2 = Path()
      ..moveTo(0, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.50,
        size.width * 0.55,
        size.height * 0.66,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.78,
        size.width,
        size.height * 0.64,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path2, paint2);

    final paintDot = Paint()
      ..color = Colors.white.withValues(alpha: 0.06);

    canvas.drawCircle(
        Offset(size.width * 0.12, size.height * 0.35), 45, paintDot);
    canvas.drawCircle(
        Offset(size.width * 0.88, size.height * 0.18), 28, paintDot);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => false;
}
