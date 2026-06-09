import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/session_controller.dart';
import '../../core/services/session_service.dart';
import '../../models/bank_sampah_model.dart';

class PilihBankSampahView extends GetView<SessionController> {
  const PilihBankSampahView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // ── Header gradient (sama seperti dashboard) ──
          _buildHeader(),

          // ── Konten scrollable ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2E7D32),
                    strokeWidth: 2.5,
                  ),
                );
              }

              if (controller.listBankSampah.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.fetchBankSampahSaya,
                color: const Color(0xFF2E7D32),
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
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
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
                    const Text(
                      'BISA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Basis Informasi Sampah',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.75),
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
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
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
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Obx(() {
            final nama =
                SessionService.to.profile.value?.namaLengkap ?? '';
            return Text(
              nama,
              style: const TextStyle(
                fontSize: 22,
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
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.store_outlined,
                  size: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 6),
                Text(
                  'Pilih bank sampah yang ingin dikelola',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.store_outlined,
                  color: Color(0xFF2E7D32),
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Belum Ada Bank Sampah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kamu belum terhubung ke bank sampah\nmanapun. Hubungi kelurahan untuk\nmendapat akses.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: controller.fetchBankSampahSaya,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Muat Ulang',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
              ? Border.all(color: const Color(0xFF2E7D32).withOpacity(0.25), width: 1.5)
              : Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? const Color(0xFF2E7D32).withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
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
                    ? const Color(0xFFE8F5E9)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.store_rounded,
                color: isActive
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade400,
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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? const Color(0xFF1A1A2E)
                          : Colors.grey.shade500,
                    ),
                  ),
                  if (bank.rt != null || bank.alamat != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            [
                              if (bank.rt != null) 'RT ${bank.rt}',
                              if (bank.rw != null) 'RW ${bank.rw}',
                              if (bank.alamat != null) bank.alamat!,
                            ].join(' • '),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
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
                        ? const Color(0xFFE8F5E9)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? const Color(0xFF2E7D32)
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isActive
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade300,
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