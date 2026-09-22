import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/design_tokens.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/kelurahan/dashboard_kelurahan_controller.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/wave_painter.dart';

class ProfilKelurahanView extends StatelessWidget {
  const ProfilKelurahanView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionService.to;
    final hasDashboardCtrl = Get.isRegistered<DashboardKelurahanController>();
    final dashboardCtrl = hasDashboardCtrl ? Get.find<DashboardKelurahanController>() : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header & Avatar Profile Card (Sesuai Gambar Acuan) ───────
              _buildHeaderProfileCard(context, session),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // ── 3 Summary Metric Cards (BSU, Terkelola, Partisipasi) ─
                    _buildSummaryMetricsRow(dashboardCtrl),

                    const SizedBox(height: 20),

                    // ── Section 1: Informasi Akun & Wilayah ──────────────────
                    _buildInformasiAkunCard(session),

                    const SizedBox(height: 20),

                    // ── Section 2: Pengaturan & Keamanan ────────────────────
                    _buildPengaturanKeamananCard(context),

                    const SizedBox(height: 24),

                    // ── Tombol Keluar dari Akun dengan Konfirmasi ──────────
                    _buildLogoutButton(context),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header & Profile Card ────────────────────────────────────────────────
  Widget _buildHeaderProfileCard(BuildContext context, SessionService session) {
    return Stack(
      children: [
        // Wave Background
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 230),
          painter: WavePainter.blue(),
        ),

        // Back button top bar
        Positioned(
          top: 10,
          left: 8,
          right: 20,
          child: Row(
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
                  'Profil Kelurahan',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Floating Card Utama Profil
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 64, 20, 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.kelurahanMain.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar Overlapping Top Edge
                Transform.translate(
                  offset: const Offset(0, -38),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Obx(() {
                        final nama = session.profile.value?.namaLengkap ?? 'K';
                        final initial = nama.isNotEmpty ? nama[0].toUpperCase() : 'K';
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.kelurahanGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.kelurahanMain.withValues(alpha: 0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }),
                      // Checkmark badge hijau
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF00C853),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -22),
                  child: Column(
                    children: [
                      // Judul Nama Admin Kelurahan
                      Obx(() {
                        final nama = session.profile.value?.namaLengkap;
                        final displayTitle = (nama != null && nama.isNotEmpty)
                            ? 'Admin $nama'
                            : 'Admin Kelurahan Gunung Lingai';
                        return Text(
                          displayTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.kelurahanDark,
                            letterSpacing: -0.4,
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                      Text(
                        'Kecamatan Sungai Pinang • Kota Samarinda',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Pill Tag "Akun Pengelola Terverifikasi"
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            const Text(
                              'Akun Pengelola Terverifikasi',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Row 2 Badges (Wilayah Binaan & SK Aktif)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.location_city_rounded,
                                    size: 13, color: AppColors.textSecondary),
                                SizedBox(width: 5),
                                Text(
                                  'Wilayah Binaan: 14 RW',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 13, color: Color(0xFF00897B)),
                                SizedBox(width: 5),
                                Text(
                                  'SK Aktif s.d 2026',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF00897B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── 3 Summary Metric Cards ───────────────────────────────────────────────
  Widget _buildSummaryMetricsRow(DashboardKelurahanController? controller) {
    return Row(
      children: [
        // Card 1: BSU AKTIF
        Expanded(
          child: _SummaryMetricTile(
            title: 'BSU AKTIF',
            valueWidget: Obx(() {
              final count = controller?.totalBankSampahAktif.value ?? 11;
              return Text(
                '$count BSU',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E3A8A),
                ),
              );
            }),
            subTextWidget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C853),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '100% Sinkron',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00C853),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Card 2: TERKELOLA
        Expanded(
          child: _SummaryMetricTile(
            title: 'TERKELOLA',
            valueWidget: Obx(() {
              final ton = controller?.totalTimbulanTon.value ?? 24.8;
              return Text(
                '${ton.toStringAsFixed(1)} Ton',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E3A8A),
                ),
              );
            }),
            subTextWidget: Text(
              'Total Timbulan',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Card 3: PARTISIPASI
        Expanded(
          child: _SummaryMetricTile(
            title: 'PARTISIPASI',
            valueWidget: const Text(
              '85.7%',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E3A8A),
              ),
            ),
            subTextWidget: Text(
              '14 RW Terdata',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Section 1: Informasi Akun & Wilayah ──────────────────────────────────
  Widget _buildInformasiAkunCard(SessionService session) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: DesignTokens.shadowSm,
      ),
      child: Column(
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Informasi Akun & Wilayah',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.kelurahanDark,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Resmi SIPAS',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),

          // 1. Nama Lengkap & Gelar
          Obx(() => _ProfileDetailRow(
                icon: Icons.person_outline_rounded,
                iconBgColor: const Color(0xFFE3F2FD),
                iconColor: const Color(0xFF1976D2),
                label: 'Nama Lengkap & Gelar',
                value: session.profile.value?.namaLengkap ?? 'Budi Santoso, S.STP',
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary, size: 20),
              )),
          const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 64),

          // 2. NIP / ID Kedinasan
          const _ProfileDetailRow(
            icon: Icons.badge_outlined,
            iconBgColor: Color(0xFFE0F2F1),
            iconColor: Color(0xFF00897B),
            label: 'NIP / ID Kedinasan',
            value: '19880412 201101 1 003',
            trailing: _MiniBadge(text: 'PNS', color: Color(0xFF64748B)),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 64),

          // 3. Role Penugasan
          const _ProfileDetailRow(
            icon: Icons.verified_user_outlined,
            iconBgColor: Color(0xFFE0F7FA),
            iconColor: Color(0xFF00ACC1),
            label: 'Role Penugasan',
            value: 'Pengelola Wilayah Kelurahan',
            trailing: Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 20),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 64),

          // 4. Wilayah Kerja
          const _ProfileDetailRow(
            icon: Icons.location_on_outlined,
            iconBgColor: Color(0xFFFFF8E1),
            iconColor: Color(0xFFFFA000),
            label: 'Wilayah Kerja',
            value: 'Kel. Gunung Lingai, Kec. Sungai Pinang',
            trailing: Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 20),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 64),

          // 5. Terdaftar Sejak
          Obx(() => _ProfileDetailRow(
                icon: Icons.calendar_today_outlined,
                iconBgColor: const Color(0xFFF3E5F5),
                iconColor: const Color(0xFF8E24AA),
                label: 'Terdaftar Sejak',
                value: session.profile.value?.createdAt != null
                    ? FormatHelper.date(session.profile.value!.createdAt)
                    : '07 Juni 2024',
                trailing: const Text(
                  'Aktif',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00C853),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // ── Section 2: Pengaturan & Keamanan ────────────────────────────────────
  Widget _buildPengaturanKeamananCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: DesignTokens.shadowSm,
      ),
      child: Column(
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Pengaturan & Keamanan',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.kelurahanDark,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Sistem & Privasi',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),

          // 1. Ubah Kata Sandi & PIN Validasi
          InkWell(
            onTap: () {
              Get.snackbar(
                'Informasi',
                'Fitur ubah kata sandi dapat diakses via pengaturan akun.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
            ),
            child: const _ProfileDetailRow(
              icon: Icons.lock_outline_rounded,
              iconBgColor: Color(0xFFE8EAF6),
              iconColor: Color(0xFF3F51B5),
              label: '',
              value: 'Ubah Kata Sandi & PIN Validasi',
              trailing: Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary, size: 20),
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 64),

          // 2. Bantuan Teknis DLHK Kota
          InkWell(
            onTap: () {
              Get.snackbar(
                'Bantuan Teknis',
                'Hubungi layanan bantuan DLHK Kota di kantor kelurahan terdekat.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: const _ProfileDetailRow(
              icon: Icons.support_agent_rounded,
              iconBgColor: Color(0xFFE0F2F1),
              iconColor: Color(0xFF00897B),
              label: '',
              value: 'Bantuan Teknis DLHK Kota',
              trailing: Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tombol Keluar dari Akun Kelurahan ────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _confirmLogout(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 18),
            SizedBox(width: 8),
            Text(
              'Keluar dari Akun Kelurahan',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Modal Dialog Konfirmasi Verifikasi Keluar ─────────────────────────────
  void _confirmLogout(BuildContext context) async {
    final ok = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
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
              // Icon Container Keluar
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFDC2626),
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Keluar dari Akun?',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.kelurahanDark,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin keluar dari akun Kelurahan?\nSesi login Anda akan diakhiri.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(result: false),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Center(
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(result: true),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC2626)
                                  .withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Ya, Keluar',
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true) {
      Future.delayed(const Duration(milliseconds: 150), () {
        Get.find<AuthController>().logout();
      });
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET HELPERS LOKAL
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryMetricTile extends StatelessWidget {
  final String title;
  final Widget valueWidget;
  final Widget subTextWidget;

  const _SummaryMetricTile({
    required this.title,
    required this.valueWidget,
    required this.subTextWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: DesignTokens.shadowSm,
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          valueWidget,
          const SizedBox(height: 4),
          subTextWidget,
        ],
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String value;
  final Widget trailing;

  const _ProfileDetailRow({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label.isNotEmpty) ...[
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.kelurahanDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _MiniBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
