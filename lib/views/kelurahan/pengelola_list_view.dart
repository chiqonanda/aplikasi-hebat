import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../controllers/kelurahan/pengelola_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/bank_sampah_model.dart';
import '../../models/profile_model.dart';

class PengelolaListView extends GetView<PengelolaController> {
  const PengelolaListView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        bottomNavigationBar: const KelurahanBottomNavBar(currentIndex: 2),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildTabBar(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: AppLoadingState(message: 'Memuat data pengelola...'),
                    );
                  }
                  return TabBarView(
                    children: [
                      _TabAktif(controller: controller),
                      _TabPending(controller: controller),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  // ── Header dengan wave & stats ───────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 185),
          painter: _HeaderWavePainter(),
        ),
        // Decorative circles
        Positioned(
          top: -25, right: -15,
          child: Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          top: 30, right: 65,
          child: Container(
            width: 55, height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Manajemen Pengelola',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Kelola akun pengelola bank sampah',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // People icon badge
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.people_rounded, color: Colors.white, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Stat pills row
              Obx(() => Row(
                children: [
                  _StatPill(
                    icon: Icons.verified_user_rounded,
                    label: 'Aktif',
                    value: '${controller.listPengelola.length}',
                    color: const Color(0xFF69F0AE),
                  ),
                  const SizedBox(width: 10),
                  _StatPill(
                    icon: Icons.hourglass_top_rounded,
                    label: 'Menunggu',
                    value: '${controller.listPending.length}',
                    color: const Color(0xFFFFD54F),
                  ),
                  const SizedBox(width: 10),
                  _StatPill(
                    icon: Icons.store_rounded,
                    label: 'Bank',
                    value: '${controller.listBankSampah.length}',
                    color: const Color(0xFF80D8FF),
                  ),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tab Bar ──────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Obx(() {
        final pendingCount = controller.listPending.length;
        return TabBar(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.kelurahanGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.kelurahanMain.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.w800),
          unselectedLabelStyle: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
          tabs: [
            const Tab(text: 'Pengelola Aktif'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Menunggu'),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF57F17),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$pendingCount',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── FAB ──────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return GestureDetector(
      onTap: () {
        controller.resetForm();
        Get.toNamed(AppRoutes.formPengelola);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.kelurahanGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.kelurahanMain.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text(
              'Tambah Pengelola',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Pill Widget ─────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB: AKTIF
// ─────────────────────────────────────────────────────────────────────────────
class _TabAktif extends StatelessWidget {
  final PengelolaController controller;
  const _TabAktif({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.listPengelola.isEmpty) {
        return const AppEmptyState(
          icon: Icons.people_outline_rounded,
          title: 'Belum Ada Pengelola Aktif',
          subtitle: 'Silakan tambah pengelola baru melalui tombol di bawah.',
        );
      }
      return RefreshIndicator(
        onRefresh: controller.fetchAll,
        color: AppColors.kelurahanMain,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
          itemCount: controller.listPengelola.length,
          itemBuilder: (context, i) {
            final pengelola = controller.listPengelola[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PengelolaCard(
                pengelola: pengelola,
                index: i,
                controller: controller,
                onHapus: () => _confirmHapus(context, pengelola, controller),
                onAturBankSampah: () =>
                    _showAturBankSampahSheet(context, pengelola, controller),
              ),
            );
          },
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB: PENDING
// ─────────────────────────────────────────────────────────────────────────────
class _TabPending extends StatelessWidget {
  final PengelolaController controller;
  const _TabPending({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.listPending.isEmpty) {
        return const AppEmptyState(
          icon: Icons.hourglass_empty_rounded,
          title: 'Tidak Ada Pendaftaran',
          subtitle: 'Tidak ada pendaftaran pengelola yang menunggu verifikasi.',
        );
      }
      return RefreshIndicator(
        onRefresh: controller.fetchAll,
        color: AppColors.kelurahanMain,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
          itemCount: controller.listPending.length,
          itemBuilder: (context, i) {
            final pengelola = controller.listPending[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _PendingCard(
                pengelola: pengelola,
                listBankSampah: controller.listBankSampah,
                controller: controller,
                onApprove: () =>
                    _showApproveSheet(context, pengelola, controller),
                onTolak: () => _confirmTolak(context, pengelola, controller),
              ),
            );
          },
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD: PENGELOLA AKTIF
// ─────────────────────────────────────────────────────────────────────────────
// warna avatar bergilir berdasarkan index
const _avatarGradients = [
  [Color(0xFF0A2540), Color(0xFF1E88E5)],
  [Color(0xFF00695C), Color(0xFF26A69A)],
  [Color(0xFF283593), Color(0xFF5C6BC0)],
  [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
  [Color(0xFF00838F), Color(0xFF26C6DA)],
];

class _PengelolaCard extends StatelessWidget {
  final ProfileModel pengelola;
  final int index;
  final PengelolaController controller;
  final VoidCallback onHapus;
  final VoidCallback onAturBankSampah;

  const _PengelolaCard({
    required this.pengelola,
    required this.index,
    required this.controller,
    required this.onHapus,
    required this.onAturBankSampah,
  });

  @override
  Widget build(BuildContext context) {
    final initial = pengelola.namaLengkap.isNotEmpty
        ? pengelola.namaLengkap[0].toUpperCase()
        : '?';
    final grad = _avatarGradients[index % _avatarGradients.length];

    return GestureDetector(
      onTap: () => _showInfoSheet(context, pengelola, controller),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border(
            left: BorderSide(color: grad[0], width: 3),
          ),
          boxShadow: [
            BoxShadow(
              color: grad[0].withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar dengan gradient bergilir
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: grad,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: grad[0].withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pengelola.namaLengkap,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.kelurahanDark,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (pengelola.noHp != null &&
                          pengelola.noHp!.isNotEmpty) ...[
                        Icon(Icons.phone_outlined,
                            size: 11, color: grad[1]),
                        const SizedBox(width: 4),
                        Text(
                          pengelola.noHp!,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11.5,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Icon(Icons.calendar_today_outlined,
                          size: 11, color: grad[1]),
                      const SizedBox(width: 4),
                      Text(
                        FormatHelper.date(pengelola.createdAt),
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  // "Aktif" badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: grad[0].withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5, height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFF69F0AE),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Pengelola Aktif',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: grad[0],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Action column: atur + hapus
            Column(
              children: [
                GestureDetector(
                  onTap: onAturBankSampah,
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: grad[0].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: grad[0].withValues(alpha: 0.2), width: 1),
                    ),
                    child: Icon(Icons.store_rounded, color: grad[0], size: 16),
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onHapus,
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFFFCDD2), width: 1),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFD32F2F), size: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD: PENDING
// ─────────────────────────────────────────────────────────────────────────────
class _PendingCard extends StatelessWidget {
  final ProfileModel pengelola;
  final List<BankSampahModel> listBankSampah;
  final PengelolaController controller;
  final VoidCallback onApprove;
  final VoidCallback onTolak;

  const _PendingCard({
    required this.pengelola,
    required this.listBankSampah,
    required this.controller,
    required this.onApprove,
    required this.onTolak,
  });

  @override
  Widget build(BuildContext context) {
    final initial = pengelola.namaLengkap.isNotEmpty
        ? pengelola.namaLengkap[0].toUpperCase()
        : '?';

    final namaPilihan = pengelola.bankSampahPilihan.isEmpty
        ? null
        : listBankSampah
            .where((b) => pengelola.bankSampahPilihan.contains(b.id))
            .map((b) => b.namaLengkap)
            .join(', ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: const Border(
          left: BorderSide(color: Color(0xFFF57F17), width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF57F17).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF57F17), Color(0xFFFFB300)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF57F17).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Dot animasi menunggu
                    Positioned(
                      top: 0, right: 0,
                      child: Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD54F),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pengelola.namaLengkap,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.kelurahanDark,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (pengelola.noHp != null && pengelola.noHp!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined,
                                size: 11, color: Color(0xFFF57F17)),
                            const SizedBox(width: 4),
                            Text(
                              pengelola.noHp!,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 11.5,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFFFD54F), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5, height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF57F17),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Menunggu Verifikasi',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFF57F17),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            FormatHelper.date(pengelola.createdAt),
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
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

          // Bank pilihan
          if (namaPilihan != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.kelurahanLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFBBDEFB), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.storefront_rounded,
                        size: 14, color: AppColors.kelurahanMain),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pengajuan: $namaPilihan',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11.5,
                          color: AppColors.kelurahanMain,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Divider
          const Divider(
              color: Color(0xFFF1F5F9), height: 1, thickness: 1,
              indent: 14, endIndent: 14),
          const SizedBox(height: 12),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Obx(() {
              final isProcessing =
                  controller.isApprovingId.value == pengelola.id;
              return Row(
                children: [
                  // Tolak
                  GestureDetector(
                    onTap: isProcessing ? null : onTolak,
                    child: Container(
                      height: 42,
                      width: 90,
                      decoration: BoxDecoration(
                        color: isProcessing
                            ? Colors.grey.shade100
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isProcessing
                              ? Colors.grey.shade300
                              : const Color(0xFFD32F2F).withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close_rounded,
                              size: 16,
                              color: isProcessing
                                  ? Colors.grey
                                  : const Color(0xFFD32F2F)),
                          const SizedBox(width: 4),
                          Text(
                            'Tolak',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: isProcessing
                                  ? Colors.grey
                                  : const Color(0xFFD32F2F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Setujui
                  Expanded(
                    child: GestureDetector(
                      onTap: isProcessing ? null : onApprove,
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: isProcessing
                              ? LinearGradient(colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade400,
                                ])
                              : const LinearGradient(
                                  colors: AppColors.kelurahanGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isProcessing
                              ? []
                              : [
                                  BoxShadow(
                                    color: AppColors.kelurahanMain
                                        .withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            isProcessing
                                ? const SizedBox(
                                    width: 15, height: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.check_rounded,
                                    size: 17, color: Colors.white),
                            const SizedBox(width: 7),
                            const Text(
                              'Setujui & Atur Bank',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM SHEET: Approve
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _showApproveSheet(
  BuildContext context,
  ProfileModel pengelola,
  PengelolaController controller,
) async {
  final selected = pengelola.bankSampahPilihan.obs;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _StyledSheet(
      title: 'Setujui Pendaftaran',
      subtitle: pengelola.namaLengkap,
      gradientColors: const [Color(0xFF00695C), Color(0xFF26A69A)],
      icon: Icons.how_to_reg_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih bank sampah yang akan dikelola:',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() => ListView.separated(
                  itemCount: controller.listBankSampah.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final bank = controller.listBankSampah[i];
                    return Obx(() => _BankCheckTile(
                          bank: bank,
                          isSelected: selected.contains(bank.id),
                          onChanged: (v) {
                            if (v == true) {
                              selected.add(bank.id);
                            } else {
                              selected.remove(bank.id);
                            }
                          },
                        ));
                  },
                )),
          ),
          const SizedBox(height: 14),
          Obx(() => _ActionButton(
                label: 'Setujui Pengelola',
                icon: Icons.check_circle_outline_rounded,
                isLoading:
                    controller.isApprovingId.value == pengelola.id,
                gradientColors: const [Color(0xFF00695C), Color(0xFF26A69A)],
                onPressed: () async {
                  await controller.approvePengelola(
                    pengelola.id,
                    selected.toList(),
                  );
                  if (!controller.listPending
                      .any((p) => p.id == pengelola.id)) {
                    Get.back();
                  }
                },
              )),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM SHEET: Atur Bank Sampah
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _showAturBankSampahSheet(
  BuildContext context,
  ProfileModel pengelola,
  PengelolaController controller,
) async {
  final existing = await controller.getBankSampahPengelola(pengelola.id);
  final selected = existing.obs;

  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _StyledSheet(
      title: 'Atur Bank Sampah',
      subtitle: pengelola.namaLengkap,
      gradientColors: AppColors.kelurahanGradient,
      icon: Icons.store_rounded,
      child: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.separated(
                  itemCount: controller.listBankSampah.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final bank = controller.listBankSampah[i];
                    return Obx(() => _BankCheckTile(
                          bank: bank,
                          isSelected: selected.contains(bank.id),
                          onChanged: (v) {
                            if (v == true) {
                              selected.add(bank.id);
                            } else {
                              selected.remove(bank.id);
                            }
                          },
                        ));
                  },
                )),
          ),
          const SizedBox(height: 14),
          Obx(() => _ActionButton(
                label: 'Simpan Relasi',
                icon: Icons.save_outlined,
                isLoading: controller.isSaving.value,
                gradientColors: AppColors.kelurahanGradient,
                onPressed: () async {
                  await controller.updateRelasiPengelola(
                    pengelola.id,
                    selected.toList(),
                  );
                  if (!controller.isSaving.value) Get.back();
                },
              )),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM SHEET: Info Pengelola
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _showInfoSheet(
  BuildContext context,
  ProfileModel pengelola,
  PengelolaController controller,
) async {
  final ids = await controller.getBankSampahPengelola(pengelola.id);
  final banks =
      controller.listBankSampah.where((b) => ids.contains(b.id)).toList();

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.kelurahanLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Profile row
            Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.kelurahanGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.kelurahanMain.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      pengelola.namaLengkap.isNotEmpty
                          ? pengelola.namaLengkap[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pengelola.namaLengkap,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.kelurahanDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (pengelola.noHp != null &&
                          pengelola.noHp!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined,
                                size: 12, color: AppColors.kelurahanMain),
                            const SizedBox(width: 5),
                            Text(
                              pengelola.noHp!,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12.5,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5, height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Pengelola Aktif',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2E7D32),
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

            const SizedBox(height: 18),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 16),

            // Section label
            Row(
              children: [
                Container(
                  width: 4, height: 18,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.kelurahanGradient,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Bank Sampah yang Dikelola',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.kelurahanDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (banks.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.kelurahanLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: AppColors.kelurahanMain),
                    SizedBox(width: 8),
                    Text(
                      'Belum ada bank sampah yang dikelola.',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: AppColors.kelurahanMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...banks.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFEBF2FA), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.kelurahanMain
                                .withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.kelurahanGradient,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.storefront_rounded,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.nama,
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.kelurahanDark,
                                  ),
                                ),
                                if ((b.rt?.isNotEmpty ?? false) ||
                                    (b.rw?.isNotEmpty ?? false)) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    [
                                      if (b.rt?.isNotEmpty ?? false) 'RT ${b.rt}',
                                      if (b.rw?.isNotEmpty ?? false) 'RW ${b.rw}',
                                    ].join(' / '),
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOGS
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _confirmHapus(
  BuildContext context,
  ProfileModel pengelola,
  PengelolaController controller,
) async {
  final ok = await ConfirmDialog.show(
    title: 'Hapus Pengelola',
    message:
        'Yakin ingin menghapus "${pengelola.namaLengkap}"? Akun dan semua relasinya akan dihapus.',
    confirmLabel: 'Hapus',
    isDanger: true,
  );
  if (ok) controller.hapusPengelola(pengelola.id);
}

Future<void> _confirmTolak(
  BuildContext context,
  ProfileModel pengelola,
  PengelolaController controller,
) async {
  final ok = await ConfirmDialog.show(
    title: 'Tolak Pendaftaran',
    message:
        'Yakin ingin menolak pendaftaran "${pengelola.namaLengkap}"? Akun akan dihapus permanen.',
    confirmLabel: 'Tolak',
    isDanger: true,
  );
  if (ok) controller.tolakPengelola(pengelola.id);
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// ── Styled Bottom Sheet ──────────────────────────────────────────────────────
class _StyledSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final IconData icon;
  final Widget child;

  const _StyledSheet({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 44, height: 4,
            margin: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Sheet header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.kelurahanDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12.5,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 17, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, bottomInset + 20),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bank Check Tile ──────────────────────────────────────────────────────────
class _BankCheckTile extends StatelessWidget {
  final BankSampahModel bank;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const _BankCheckTile({
    required this.bank,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.kelurahanLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF42A5F5)
              : const Color(0xFFEBF2FA),
          width: isSelected ? 1.5 : 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.kelurahanMain.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: onChanged,
        activeColor: AppColors.kelurahanMain,
        checkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          bank.namaLengkap,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: isSelected
                ? AppColors.kelurahanDark
                : Colors.grey.shade700,
          ),
        ),
        subtitle: bank.alamat != null
            ? Text(
                bank.alamat!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11.5,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      ),
    );
  }
}

// ── Action Button ────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final List<Color> gradientColors;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.gradientColors,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: isLoading
              ? LinearGradient(
                  colors: [Colors.grey.shade300, Colors.grey.shade400])
              : LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WAVE PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppColors.kelurahanGradient,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path1 = Path()
      ..lineTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.22, size.height * 0.96,
        size.width * 0.5, size.height * 0.80,
      )
      ..quadraticBezierTo(
        size.width * 0.78, size.height * 0.64,
        size.width, size.height * 0.78,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = const Color(0xFF42A5F5).withValues(alpha: 0.28);

    final path2 = Path()
      ..moveTo(0, size.height * 0.52)
      ..quadraticBezierTo(
        size.width * 0.32, size.height * 0.40,
        size.width * 0.58, size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.80, size.height * 0.72,
        size.width, size.height * 0.58,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path2, paint2);

    // Subtle dots
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07);

    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.28), 38, dotPaint);
    canvas.drawCircle(
        Offset(size.width * 0.88, size.height * 0.16), 24, dotPaint);
  }

  @override
  bool shouldRepaint(_HeaderWavePainter oldDelegate) => false;
}