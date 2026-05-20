import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_theme.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/format_helper.dart';
import '../../controllers/auth_controller.dart';

class ProfilKelurahanView extends StatelessWidget {
  const ProfilKelurahanView({super.key});

  // ── Warna Utama (sama persis dengan DashboardKelurahanView) ──────────────
  static const _blue900 = Color(0xFF0A2540);
  static const _blue800 = Color(0xFF0D3461);
  static const _blue600 = Color(0xFF1565C0);
  static const _blue500 = Color(0xFF1E88E5);
  static const _blue400 = Color(0xFF42A5F5);
  static const _blue200 = Color(0xFFBBDEFB);
  static const _blue50  = Color(0xFFE3F2FD);
  static const _teal    = Color(0xFF00ACC1);
  static const _tealBg  = Color(0xFFE0F7FA);
  static const _bg      = Color(0xFFF0F6FF);

  @override
  Widget build(BuildContext context) {
    final session = SessionService.to;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header dengan Avatar ─────────────────────────────────────
              _buildHeader(session),

              // ── Informasi Akun ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: _buildInfoAkun(session),
              ),

              // ── Menu Kelola Sistem ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: _buildMenuKelola(),
              ),

              // ── Tombol Keluar ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 48),
                child: _buildLogoutButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(SessionService session) {
    return Stack(
      children: [
        // Background gradient (sama dengan dashboard)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_blue900, _blue800, Color(0xFF1040A0)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar: Judul + Tombol Kembali ──────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Profil Kelurahan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Avatar & Nama ─────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    // Avatar lingkaran dengan initial
                    Obx(() {
                      final nama =
                          session.profile.value?.namaLengkap ?? 'Kelurahan';
                      final initial =
                          nama.isNotEmpty ? nama[0].toUpperCase() : 'K';
                      return Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _blue600.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 14),

                    // Nama Lengkap
                    Obx(
                      () => Text(
                        session.profile.value?.namaLengkap ?? '-',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Badge Role
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: _blue200.withOpacity(0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pengelola Kelurahan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.95),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Decorative circles (sama dengan dashboard)
        Positioned(
          top: -30,
          right: -20,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: 60,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _blue400.withOpacity(0.08),
            ),
          ),
        ),
      ],
    );
  }

  // ── Informasi Akun ────────────────────────────────────────────────────────
  Widget _buildInfoAkun(SessionService session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header dengan accent bar (sama dengan dashboard)
        _SectionHeader(title: 'Informasi Akun'),
        const SizedBox(height: 16),

        // Card info
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _blue50, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: _blue600.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Obx(
                () => _InfoRow(
                  icon: Icons.badge_outlined,
                  label: 'Nama Lengkap',
                  value: session.profile.value?.namaLengkap ?? '-',
                  iconBg: const Color(0xFFE3F2FD),
                  iconColor: _blue600,
                ),
              ),
              _Divider(),
              _InfoRow(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Role',
                value: 'Pengelola Kelurahan',
                iconBg: _tealBg,
                iconColor: _teal,
              ),
              _Divider(),
              Obx(
                () => _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Bergabung Sejak',
                  value: session.profile.value?.createdAt != null
                      ? FormatHelper.date(session.profile.value!.createdAt)
                      : '-',
                  iconBg: const Color(0xFFF3E5F5),
                  iconColor: const Color(0xFF6A1B9A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// ── Menu Kelola Sistem ────────────────────────────────────────────────────
  Widget _buildMenuKelola() {
    final menus = [
      _MenuData(
        icon: Icons.store_rounded,
        label: 'Manajemen\nBank Sampah',
        iconColor: _blue600,
        iconBg: _blue50,
        onTap: () => Get.toNamed(AppRoutes.manajemenBankSampah),
      ),
      _MenuData(
        icon: Icons.people_rounded,
        label: 'Manajemen\nPengelola',
        iconColor: _teal,
        iconBg: _tealBg,
        onTap: () => Get.toNamed(AppRoutes.manajemenPengelola),
      ),
      _MenuData(
        icon: Icons.category_rounded,
        label: 'Master Data\nSampah',
        iconColor: const Color(0xFF6A1B9A),
        iconBg: const Color(0xFFF3E5F5),
        onTap: () => Get.toNamed(AppRoutes.masterSampah),
      ),
      _MenuData(
        icon: Icons.assessment_rounded,
        label: 'Generator\nLaporan',
        iconColor: const Color(0xFF00695C),
        iconBg: const Color(0xFFE0F2F1),
        onTap: () => Get.toNamed(AppRoutes.generatorLaporan),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Kelola Sistem'),
        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 14) / 2;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menus.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,

                // ✅ FIX OVERFLOW
                mainAxisExtent: itemWidth * 0.92,
              ),
              itemBuilder: (_, i) => _MenuCard(data: menus[i]),
            );
          },
        ),
      ],
    );
  }

  // ── Tombol Keluar ─────────────────────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmLogout(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.red.shade400,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Keluar dari Akun',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.red.shade500,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _blue600.withOpacity(0.12),
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
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade400,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Keluar dari Akun?',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: _blue900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda akan keluar dari sesi ini.\nApakah Anda yakin?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Tombol Batal
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: _blue50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _blue600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol Keluar
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade400,
                              Colors.red.shade300,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Keluar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
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
      Get.find<AuthController>().logout();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header  — accent bar biru, sama persis dengan dashboard
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0A2540),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Divider tipis
// ─────────────────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFFE3F2FD),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Row  — baris informasi dengan icon box berwarna
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconBg;
  final Color iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Icon box berwarna — konsisten dengan MenuCard dashboard
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A2540),
                    letterSpacing: -0.2,
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

// ─────────────────────────────────────────────────────────────────────────────
// Menu Data Model
// ─────────────────────────────────────────────────────────────────────────────

class _MenuData {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  const _MenuData({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Menu Card  — identik dengan _MenuCard di dashboard
// ─────────────────────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final _MenuData data;

  const _MenuCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFE3F2FD),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 4,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: data.iconBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  data.icon,
                  color: data.iconColor,
                  size: 28,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Flexible(
              flex: 2,
              child: Text(
                data.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A2540),
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}