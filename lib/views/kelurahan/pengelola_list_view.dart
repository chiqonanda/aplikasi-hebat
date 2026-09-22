import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../controllers/kelurahan/pengelola_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/add_fab.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/motion.dart';
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
          child: Obx(() {
            if (controller.isLoading.value) {
              return Column(
                children: [
                  _buildHeader(context),
                  const Expanded(
                    child: AppLoadingState(message: 'Memuat data pengelola...'),
                  ),
                ],
              );
            }
            return Column(
              children: [
                _buildHeader(context),
                _buildTabPills(),
                Expanded(
                  child: TabBarView(
                    children: [
                      _TabAktif(controller: controller),
                      _TabPending(controller: controller),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  // ── Header gradient + 3 stat tiles ───────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.kelurahanGradient,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manajemen Pengelola',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Otorisasi SK pengurus, verifikasi akun timbangan, dan\nkontrol akses kader BSU se-kelurahan.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11.5,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() => Row(
                      children: [
                        _HeaderStatTile(
                          icon: Icons.verified_user_rounded,
                          iconColor: AppColors.mintAccent,
                          value: '${controller.listPengelola.length}',
                          label: 'Pengelola Aktif',
                        ),
                        const SizedBox(width: 10),
                        _HeaderStatTile(
                          icon: Icons.assignment_outlined,
                          iconColor: AppColors.amberLight,
                          value: '${controller.listPending.length}',
                          label: 'Menunggu SK',
                        ),
                        const SizedBox(width: 10),
                        _HeaderStatTile(
                          icon: Icons.account_balance_rounded,
                          iconColor: const Color(0xFF80D8FF),
                          value: '${controller.listBankSampah.length}',
                          label: 'Bank Unit BSU',
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab pill Aktif / Verifikasi Berkas SK ────────────────────────────────
  Widget _buildTabPills() {
    return Container(
      color: Colors.transparent,
      child: Obx(() {
        final pendingCount = controller.listPending.length;
        return TabBar(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.kelurahanGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.kelurahanMain.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(
              height: 44,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pengelola Aktif'),                    if (controller.listPengelola.isNotEmpty) ...[
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${controller.listPengelola.length}',
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
            Tab(
              height: 44,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Verifikasi Berkas SK'),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.amber,
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
    return AddFab(
      label: 'Tambah Pengelola',
      icon: Icons.person_add_alt_1_rounded,
      gradientColors: AppColors.kelurahanGradient,
      onTap: () {
        controller.resetForm();
        Get.toNamed(AppRoutes.formPengelola);
      },
    );
  }
}

// ── Stat tile kecil di header ────────────────────────────────────────────────
class _HeaderStatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _HeaderStatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(height: 7),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.75),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
      final list = controller.listPengelolaFiltered;
      return PullToRefresh(
        onRefresh: controller.fetchAll,
        color: AppColors.kelurahanMain,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // ── Banner peringatan (hanya jika ada pending) ──────────────
            if (controller.listPending.isNotEmpty) ...[
              _buildBannerVerifikasi(context, controller),
              const SizedBox(height: 14),
            ],

            // ── Search bar ──────────────────────────────────────────────
            _buildSearchField(controller),
            const SizedBox(height: 14),

            // ── Daftar pengelola ────────────────────────────────────────
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: AppEmptyState(
                  icon: Icons.person_search_rounded,
                  title: 'Tidak Ditemukan',
                  subtitle:
                      'Tidak ada pengelola yang cocok dengan pencarian Anda.',
                ),
              )
            else
              ...list.asMap().entries.map((entry) {
                final i = entry.key;
                final pengelola = entry.value;
                return StaggeredEntrance(
                  index: i,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PengelolaCard(
                      pengelola: pengelola,
                      controller: controller,
                      onHapus: () =>
                          _confirmHapus(context, pengelola, controller),
                      onAturBankSampah: () => _showAturBankSampahSheet(
                          context, pengelola, controller),
                    ),
                  ),
                );
              }),
          ],
        ),
      );
    });
  }

  Widget _buildBannerVerifikasi(
      BuildContext context, PengelolaController controller) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.amberLight, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.campaign_outlined,
                size: 18, color: AppColors.amber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perlu Verifikasi SK Kelurahan',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.kelurahanDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${controller.listPending.length} kader pengelola menunggu validasi SK lurah untuk otorisasi akses aplikasi penimbangan sampah.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    height: 1.35,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => DefaultTabController.maybeOf(context)?.animateTo(1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.amber.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'Tinjau',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(PengelolaController controller) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded,
              size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: controller.setSearchQuery,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Cari nama pengurus, NIK, RW, atau BSU...',
                hintStyle: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Icon(Icons.tune_rounded, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
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
      return PullToRefresh(
        onRefresh: controller.fetchAll,
        color: AppColors.kelurahanMain,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.listPending.length,
          itemBuilder: (context, i) {
            final pengelola = controller.listPending[i];
            return StaggeredEntrance(
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _PendingCard(
                  pengelola: pengelola,
                  listBankSampah: controller.listBankSampah,
                  controller: controller,
                  onApprove: () =>
                      _showApproveSheet(context, pengelola, controller),
                  onTolak: () => _confirmTolak(context, pengelola, controller),
                ),
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
const _avatarGradients = [
  [AppColors.kelurahanDark, AppColors.kelurahanMain],
  [AppColors.tealDark, AppColors.tealMid],
  [AppColors.indigoDark, AppColors.indigo],
  [AppColors.purple, AppColors.purpleMid],
  [AppColors.teal, AppColors.cyan],
];

class _PengelolaCard extends StatelessWidget {
  final ProfileModel pengelola;
  final PengelolaController controller;
  final VoidCallback onHapus;
  final VoidCallback onAturBankSampah;

  const _PengelolaCard({
    required this.pengelola,
    required this.controller,
    required this.onHapus,
    required this.onAturBankSampah,
  });

  @override
  Widget build(BuildContext context) {
    final grad = _avatarGradients[pengelola.id.hashCode % _avatarGradients.length];

    return PressableScale(
      onTap: () => _showInfoSheet(context, pengelola, controller),
      onLongPress: onHapus,
      pressedScale: 0.965,
      splashColor: grad[0].withValues(alpha: 0.06),
      glowIntensity: 0.3,
      glowColor: grad[0],
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar inisial dengan gradient + dot aktif
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: grad,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
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
                      pengelola.namaLengkap.isNotEmpty
                          ? pengelola.namaLengkap[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.mintAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Info utama
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama + badge SK Aktif
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pengelola.namaLengkap,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.kelurahanDark,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.mintAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.mintAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'SK Aktif',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF00A878),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Jabatan + BSU
                  Text(
                    'Ketua Pengurus • ${controller.namaBsuPengelola(pengelola.id).isEmpty ? 'BSU belum diatur' : controller.namaBsuPengelola(pengelola.id)}',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      height: 1.3,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 7),

                  // Baris SK s.d. tanggal + tonase
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundKelurahan,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.description_outlined,
                                size: 11, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              'SK s.d. ${FormatHelper.date(pengelola.updatedAt)}',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.kelurahanLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.scale_outlined,
                                size: 11, color: AppColors.kelurahanMain),
                            const SizedBox(width: 4),
                            Obx(() => Text(
                                  controller.tonaseLabel(pengelola.id),
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.kelurahanMain,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Kolom aksi
            Column(
              children: [
                PressableScale(
                  onTap: onAturBankSampah,
                  pressedScale: 0.85,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.kelurahanLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.kelurahanMain.withValues(alpha: 0.2),
                          width: 1),
                    ),
                    child: const Icon(Icons.store_rounded,
                        color: AppColors.kelurahanMain, size: 16),
                  ),
                ),
                const SizedBox(height: 6),
                PressableScale(
                  onTap: onHapus,
                  pressedScale: 0.85,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: AppColors.dangerLighter, width: 1),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.danger, size: 16),
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
          left: BorderSide(color: AppColors.amber, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.amber.withValues(alpha: 0.08),
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
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.amber, Color(0xFFFFB300)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.amber.withValues(alpha: 0.3),
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
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.amberLight,
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
                                size: 11, color: AppColors.amber),
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
                                  color: AppColors.amberLight, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: AppColors.amber,
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
                                    color: AppColors.amber,
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
                  border: Border.all(color: AppColors.blueLight, width: 1),
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
              color: AppColors.dividerLight,
              height: 1,
              thickness: 1,
              indent: 14,
              endIndent: 14),
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
                            : AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isProcessing
                              ? Colors.grey.shade300
                              : AppColors.danger.withValues(alpha: 0.3),
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
                                  : AppColors.danger),
                          const SizedBox(width: 4),
                          Text(
                            'Tolak',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color:
                                  isProcessing ? Colors.grey : AppColors.danger,
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
                                    width: 15,
                                    height: 15,
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
      gradientColors: const [AppColors.tealDark, AppColors.tealMid],
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
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
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
                gradientColors: const [AppColors.tealDark, AppColors.tealMid],
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
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
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
                width: 44,
                height: 4,
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
                  width: 60,
                  height: 60,
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
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () async {
                                final phone = pengelola.noHp!;
                                String clean = phone.replaceAll(RegExp(r'\D'), '');
                                if (clean.startsWith('0')) {
                                  clean = '62${clean.substring(1)}';
                                }
                                final url = Uri.parse('https://wa.me/$clean');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  Get.snackbar('Gagal',
                                      'Tidak dapat membuka WhatsApp');
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.pengelolaLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFC8E6C9),
                                      width: 0.8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_rounded,
                                      size: 13,
                                      color: AppColors.pengelolaMain,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'WhatsApp',
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.pengelolaMain,
                                      ),
                                    ),
                                  ],
                                ),
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
                          color: AppColors.pengelolaLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.pengelolaMain,
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
                                color: AppColors.pengelolaMain,
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
            const Divider(color: AppColors.dividerLight, height: 1),
            const SizedBox(height: 16),

            // Section label
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
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
                            color: AppColors.kelurahanSurface, width: 1.2),
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
                            width: 40,
                            height: 40,
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
            width: 44,
            height: 4,
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
                  width: 48,
                  height: 48,
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
                    width: 32,
                    height: 32,
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
          const Divider(color: AppColors.dividerLight, height: 1),
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
              ? AppColors.kelurahanAccent
              : AppColors.kelurahanSurface,
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
                  width: 20,
                  height: 20,
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
