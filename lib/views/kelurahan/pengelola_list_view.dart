import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/kelurahan/pengelola_controller.dart';
import '../../core/utils/format_helper.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/bank_sampah_model.dart';
import '../../models/profile_model.dart';

// ── Palet Warna (sama dengan dashboard & monitoring) ─────────────────────────
class _C {
  static const blue900 = Color(0xFF0A2540);
  static const blue800 = Color(0xFF0D3461);
  static const blue600 = Color(0xFF1565C0);
  static const blue500 = Color(0xFF1E88E5);
  static const blue400 = Color(0xFF42A5F5);
  static const blue200 = Color(0xFFBBDEFB);
  static const blue50  = Color(0xFFE3F2FD);
  static const bg      = Color(0xFFF0F6FF);
  static const warning = Color(0xFFF57F17);
  static const warnBg  = Color(0xFFFFF8E1);
  static const red     = Color(0xFFD32F2F);
  static const redBg   = Color(0xFFFFEBEE);
}

// ─────────────────────────────────────────────────────────────────────────────
// Main View
// ─────────────────────────────────────────────────────────────────────────────

class PengelolaListView extends GetView<PengelolaController> {
  const PengelolaListView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Custom Header ───────────────────────────────────────────
              _buildHeader(context),

              // ── Tab Content ─────────────────────────────────────────────
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: _C.blue500,
                        strokeWidth: 2.5,
                      ),
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

        // ── FAB ────────────────────────────────────────────────────────────
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            controller.resetForm();
            Get.toNamed(AppRoutes.formPengelola);
          },
          backgroundColor: _C.blue600,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.person_add_rounded, size: 22),
          label: const Text(
            'Tambah',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_C.blue900, _C.blue800, Color(0xFF1040A0)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  children: [
                    // Back
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.2),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manajemen',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Pengelola Bank Sampah',
                            style: TextStyle(
                              fontSize: 13,
                              color: _C.blue200,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ── Tab Bar ───────────────────────────────────────────────────
              Obx(() {
                final pendingCount = controller.listPending.length;
                return TabBar(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  indicator: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.5),
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    const Tab(text: 'Pengelola Aktif'),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Menunggu'),
                          if (pendingCount > 0) ...[
                            const SizedBox(width: 7),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: _C.warning,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$pendingCount',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
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

              const SizedBox(height: 16),
            ],
          ),
        ),

        // Decorative circle
        Positioned(
          top: -20,
          right: -10,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab Aktif
// ─────────────────────────────────────────────────────────────────────────────

class _TabAktif extends StatelessWidget {
  final PengelolaController controller;
  const _TabAktif({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.listPengelola.isEmpty) {
        return _EmptyState(
          icon: Icons.people_outline_rounded,
          message: 'Belum ada pengelola aktif.',
          actionLabel: 'Tambah Pengelola',
          onAction: () {
            controller.resetForm();
            Get.toNamed(AppRoutes.formPengelola);
          },
        );
      }
      return RefreshIndicator(
        onRefresh: controller.fetchAll,
        color: _C.blue500,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: controller.listPengelola.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final pengelola = controller.listPengelola[i];
            return _PengelolaCard(
              pengelola: pengelola,
              controller: controller,
              onHapus: () => _confirmHapus(context, pengelola, controller),
              onAturBankSampah: () =>
                  _showAturBankSampahSheet(context, pengelola, controller),
            );
          },
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab Pending
// ─────────────────────────────────────────────────────────────────────────────

class _TabPending extends StatelessWidget {
  final PengelolaController controller;
  const _TabPending({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.listPending.isEmpty) {
        return const _EmptyState(
          icon: Icons.hourglass_empty_rounded,
          message: 'Tidak ada pendaftaran\nyang menunggu verifikasi.',
        );
      }
      return RefreshIndicator(
        onRefresh: controller.fetchAll,
        color: _C.blue500,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          itemCount: controller.listPending.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final pengelola = controller.listPending[i];
            return _PendingCard(
              pengelola: pengelola,
              listBankSampah: controller.listBankSampah,
              controller: controller,
              onApprove: () =>
                  _showApproveSheet(context, pengelola, controller),
              onTolak: () => _confirmTolak(context, pengelola, controller),
            );
          },
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card Pengelola Aktif
// ─────────────────────────────────────────────────────────────────────────────

class _PengelolaCard extends StatelessWidget {
  final ProfileModel pengelola;
  final VoidCallback onHapus;
  final VoidCallback onAturBankSampah;
  final PengelolaController controller;

  const _PengelolaCard({
    required this.pengelola,
    required this.onHapus,
    required this.onAturBankSampah,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final initial = pengelola.namaLengkap.isNotEmpty
        ? pengelola.namaLengkap[0].toUpperCase()
        : '?';

    return GestureDetector(
      onTap: () => _showInfoSheet(context, pengelola, controller),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _C.blue50, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _C.blue600.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_C.blue600, _C.blue400],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: _C.blue600.withOpacity(0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _C.blue900,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (pengelola.noHp != null &&
                      pengelola.noHp!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 13, color: _C.blue400),
                        const SizedBox(width: 5),
                        Text(
                          pengelola.noHp!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _C.blue50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 11, color: _C.blue500),
                        const SizedBox(width: 4),
                        Text(
                          'Bergabung ${FormatHelper.date(pengelola.createdAt)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _C.blue600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            // Hapus button
            GestureDetector(
              onTap: onHapus,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _C.redBg,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                      color: _C.red.withOpacity(0.2), width: 1),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: _C.red, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card Pending
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _C.warnBg, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _C.warning.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ────────────────────────────────────────────────────
          Row(
            children: [
              // Avatar (warning style)
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _C.warning,
                      _C.warning.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: _C.warning.withOpacity(0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pengelola.namaLengkap,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _C.blue900,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge "Menunggu"
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: _C.warnBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _C.warning.withOpacity(0.3),
                                width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: _C.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Menunggu',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _C.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (pengelola.noHp != null &&
                        pengelola.noHp!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 13, color: _C.blue400),
                          const SizedBox(width: 5),
                          Text(
                            pengelola.noHp!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _C.blue50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 11, color: _C.blue500),
                          const SizedBox(width: 4),
                          Text(
                            'Daftar ${FormatHelper.date(pengelola.createdAt)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _C.blue600,
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

          // ── Pilihan Bank Sampah ─────────────────────────────────────────
          if (namaPilihan != null) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _C.blue50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.blue200, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.store_outlined,
                      size: 15, color: _C.blue500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pilihan: $namaPilihan',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _C.blue600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ── Divider ────────────────────────────────────────────────────
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _C.blue200.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Action Buttons ─────────────────────────────────────────────
          Obx(() {
            final isProcessing =
                controller.isApprovingId.value == pengelola.id;
            return Row(
              children: [
                // Tolak
                Expanded(
                  child: GestureDetector(
                    onTap: isProcessing ? null : onTolak,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isProcessing ? Colors.grey.shade100 : _C.redBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isProcessing
                              ? Colors.grey.shade300
                              : _C.red.withOpacity(0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close_rounded,
                              size: 18,
                              color: isProcessing
                                  ? Colors.grey
                                  : _C.red),
                          const SizedBox(width: 6),
                          Text(
                            'Tolak',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isProcessing
                                  ? Colors.grey
                                  : _C.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Setujui
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: isProcessing ? null : onApprove,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isProcessing
                            ? LinearGradient(colors: [
                                Colors.grey.shade300,
                                Colors.grey.shade400,
                              ])
                            : const LinearGradient(
                                colors: [_C.blue600, _C.blue400],
                              ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isProcessing
                            ? []
                            : [
                                BoxShadow(
                                  color: _C.blue600.withOpacity(0.3),
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
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_rounded,
                                  size: 18, color: Colors.white),
                          const SizedBox(width: 6),
                          const Text(
                            'Setujui & Atur',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _C.blue50, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _C.blue600.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_C.blue50, _C.blue200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: _C.blue600, size: 36),
              ),
              const SizedBox(height: 18),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _C.blue900,
                  letterSpacing: -0.2,
                  height: 1.5,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_C.blue600, _C.blue400]),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _C.blue600.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      actionLabel!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Sheet: Approve + Pilih Bank Sampah
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
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: _C.blue200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            _SheetTitle(
              title: 'Setujui Pendaftaran',
              subtitle: pengelola.namaLengkap,
            ),
            const SizedBox(height: 6),
            const Text(
              'Pilih bank sampah yang akan dikelola:',
              style: TextStyle(
                fontSize: 14,
                color: _C.blue600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),

            // List checkbox
            Expanded(
              child: Obx(() => ListView.separated(
                    controller: scrollCtrl,
                    itemCount: controller.listBankSampah.length,
                    separatorBuilder: (_, __) => Container(
                      height: 1,
                      color: _C.blue50,
                    ),
                    itemBuilder: (_, i) {
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

            // Submit button
            Obx(() => _GradientButton(
                  label: 'Setujui Pengelola',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading:
                      controller.isApprovingId.value == pengelola.id,
                  onPressed: () async {
                    await controller.approvePengelola(
                      pengelola.id,
                      selected.toList(),
                    );
                    if (!controller.listPending
                        .any((p) => p.id == pengelola.id)) {
                      Navigator.of(ctx).pop();
                    }
                  },
                )),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Sheet: Atur Bank Sampah (pengelola aktif)
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _showAturBankSampahSheet(
  BuildContext context,
  ProfileModel pengelola,
  PengelolaController controller,
) async {
  final existing = await controller.getBankSampahPengelola(pengelola.id);
  final selected = existing.obs;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      builder: (_, scrollCtrl) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: _C.blue200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _SheetTitle(
              title: 'Atur Bank Sampah',
              subtitle: pengelola.namaLengkap,
            ),
            const SizedBox(height: 14),

            Expanded(
              child: Obx(() => ListView.separated(
                    controller: scrollCtrl,
                    itemCount: controller.listBankSampah.length,
                    separatorBuilder: (_, __) => Container(
                      height: 1,
                      color: _C.blue50,
                    ),
                    itemBuilder: (_, i) {
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

            Obx(() => _GradientButton(
                  label: 'Simpan Relasi',
                  icon: Icons.save_outlined,
                  isLoading: controller.isSaving.value,
                  onPressed: () async {
                    await controller.updateRelasiPengelola(
                      pengelola.id,
                      selected.toList(),
                    );
                    if (!controller.isSaving.value) {
                      Navigator.of(ctx).pop();
                    }
                  },
                )),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Sheet Pengelola
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: _C.blue200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Profile row
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_C.blue600, _C.blue400],
                  ),
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: _C.blue600.withOpacity(0.28),
                      blurRadius: 8,
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
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
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
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _C.blue900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (pengelola.noHp != null &&
                        pengelola.noHp!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 14, color: _C.blue400),
                          const SizedBox(width: 5),
                          Text(
                            pengelola.noHp!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _C.blue200.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Section label
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_C.blue500, _C.blue400],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Bank Sampah yang Dikelola',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _C.blue900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (banks.isEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _C.blue50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: _C.blue400),
                  SizedBox(width: 8),
                  Text(
                    'Belum ada bank sampah yang dikelola.',
                    style: TextStyle(
                      fontSize: 13,
                      color: _C.blue600,
                      fontWeight: FontWeight.w500,
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
                      color: _C.blue50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _C.blue200, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_C.blue600, _C.blue400],
                            ),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(Icons.store_rounded,
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _C.blue900,
                                ),
                              ),
                              if ((b.rt?.isNotEmpty ?? false) ||
                                  (b.rw?.isNotEmpty ?? false)) ...[
                                const SizedBox(height: 2),
                                Text(
                                  [
                                    if (b.rt?.isNotEmpty ?? false)
                                      'RT ${b.rt}',
                                    if (b.rw?.isNotEmpty ?? false)
                                      'RW ${b.rw}',
                                  ].join(' / '),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
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
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog Konfirmasi
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
// Helper Widgets (Sheet)
// ─────────────────────────────────────────────────────────────────────────────

class _SheetTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SheetTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_C.blue500, _C.blue400],
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
                color: _C.blue900,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? _C.blue50 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? _C.blue400 : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: onChanged,
        activeColor: _C.blue600,
        checkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          bank.namaLengkap,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? _C.blue900 : Colors.grey.shade700,
          ),
        ),
        subtitle: bank.alamat != null
            ? Text(
                bank.alamat!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              )
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isLoading
              ? LinearGradient(
                  colors: [Colors.grey.shade300, Colors.grey.shade400])
              : const LinearGradient(colors: [_C.blue600, _C.blue400]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: _C.blue600.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}