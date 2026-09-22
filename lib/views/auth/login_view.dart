import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../core/utils/validator.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/wave_painter.dart';
import '../../app/themes/app_colors.dart';

class LoginView extends GetView<AuthController> {
  /// Deteksi keyboard via MediaQuery — sumber kebenaran tunggal untuk spacing.
  static const _keyboardThreshold = 120.0;
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardVisible =
        mediaQuery.viewInsets.bottom > _keyboardThreshold;
    final screenWidth = mediaQuery.size.width;
    // Gunakan tinggi total layar (termasuk keyboard bottom inset) agar layout tidak mengkerut saat keyboard muncul
    final screenHeight = mediaQuery.size.height + mediaQuery.viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background wave decoration ──────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedWave.green(
              size: Size(screenWidth, screenHeight * 0.42),
            ),
          ),
        const AmbientBlob(color: Color(0x14FFFFFF), size: 220),

          // ── Decorative circles ──────────────────────────────
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // ── Main content ────────────────────────────────────
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Tinggi konten = tinggi LAYAR + inset keyboard.
                // Saat keyboard terbuka, MediaQuery.of(...).size.height
                // menyusut otomatis — jadi konten selalu diratakan pada
                // area yang terlihat (tidak pernah ada bagian yang
                // "hilang di bawah" / overflow bawah).
                final double availableHeight =
                    mediaQuery.size.height + mediaQuery.viewInsets.bottom -
                        mediaQuery.padding.vertical;

                // Spacer adaptif: membesar mengikuti ruang tersisa di
                // atas baseline 710px, DIBATASI MAKSIMUM sehingga konten
                // tak pernah dipaksa lebih tinggi dari layar.
                final double extra =
                    (availableHeight - 710).clamp(0.0, double.infinity);

                // Keyboard terbuka → kompres semua spacer agar form tetap
                // terlihat penuh di area yang tersisa.
                double topSpacer = keyboardVisible
                    ? 8.0
                    : (16.0 + extra * 0.30).clamp(16.0, 64.0);
                double middleSpacer = keyboardVisible
                    ? 8.0
                    : (12.0 + extra * 0.22).clamp(12.0, 44.0);
                double bottomSpacer = keyboardVisible
                    ? 10.0
                    : (16.0 + extra * 0.18).clamp(16.0, 40.0);
                double footerSpacer = keyboardVisible ? 6.0 : 16.0;

                return PullToRefresh(
                  onRefresh: () async {},
                  color: AppColors.pengelolaMain,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                        width: screenWidth,
                        child: Column(
                          children: [
                            SizedBox(height: topSpacer),
                            
                            // ── Top section (logo + title) ──
                            StaggeredEntrance(
                              index: 0,
                              hapticOnEnter: false,
                              child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Double ring logo
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      width: 58,
                                      height: 58,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 58,
                                        height: 58,
                                        decoration: const BoxDecoration(
                                          color: AppColors.pengelolaLight,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.eco_rounded,
                                          color: AppColors.pengelolaMain,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Title
                                const Text(
                                  'BISA',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Basis Informasi Sampah',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            ),

                            SizedBox(height: middleSpacer),

                            // ── Login card ───────────────────────────────
                            StaggeredEntrance(
                              index: 1,
                              child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 420),
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    // Accent line hijau di atas card
                                    border: const Border(
                                      top: BorderSide(
                                        color: AppColors.pengelolaMain,
                                        width: 3,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.pengelolaMain
                                            .withValues(alpha: 0.08),
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Form(
                                    key: controller.loginFormKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Card header
                                        const Text(
                                          'Selamat Datang 👋',
                                          style: TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Masuk untuk mengelola bank sampah Anda',
                                          style: TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 13,
                                            color: Colors.grey.shade500,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 28),

                                        // Email label + field
                                        const _FieldLabel(label: 'Email'),
                                        const SizedBox(height: 8),
                                        AppTextField(
                                          controller: controller.emailController,
                                          label: '',
                                          hint: 'contoh@email.com',
                                          prefixIcon: Icons.email_outlined,
                                          keyboardType: TextInputType.emailAddress,
                                          validator: AppValidator.email,
                                        ),
                                        const SizedBox(height: 20),

                                        // Password label + field
                                        const _FieldLabel(label: 'Kata Sandi'),
                                        const SizedBox(height: 8),
                                        Obx(
                                          () => AppTextField(
                                            controller: controller.passwordController,
                                            label: '',
                                            hint: 'Masukkan kata sandi',
                                            prefixIcon: Icons.lock_outline_rounded,
                                            obscureText:
                                                !controller.isPasswordVisible.value,
                                            validator: AppValidator.password,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                controller.isPasswordVisible.value
                                                    ? Icons.visibility_outlined
                                                    : Icons.visibility_off_outlined,
                                                color: Colors.grey.shade400,
                                                size: 20,
                                              ),
                                              onPressed:
                                                  controller.togglePasswordVisibility,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),

                                        // Lupa sandi
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: controller.forgotPassword,
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: const Text(
                                              'Lupa sandi?',
                                              style: TextStyle(
                                                fontFamily: 'PlusJakartaSans',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.pengelolaMain,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 28),

                                        // Tombol masuk
                                        Obx(
                                          () => _GradientButton(
                                            label: 'Masuk Sistem',
                                            isLoading: controller.isLoading.value,
                                            onPressed: controller.login,
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        // Divider
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 1,
                                                color: Colors.grey.shade100,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12),
                                              child: Text(
                                                'atau',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade400,
                                                  fontFamily: 'PlusJakartaSans',
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                height: 1,
                                                color: Colors.grey.shade100,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),

                                        // Link daftar
                                        Center(
                                          child: Wrap(
                                            alignment: WrapAlignment.center,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              Text(
                                                'Belum punya akun? ',
                                                style: TextStyle(
                                                  fontFamily: 'PlusJakartaSans',
                                                  fontSize: 14,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () =>
                                                    Get.toNamed(AppRoutes.register),
                                                child: const Text(
                                                  'Daftar Sekarang',
                                                  style: TextStyle(
                                                    fontFamily: 'PlusJakartaSans',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.pengelolaMain,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ),

                            SizedBox(height: bottomSpacer),

                            // ── Tagline bawah ────────────────────────────
                            StaggeredEntrance(
                              index: 2,
                              child: Padding(
                              padding: EdgeInsets.only(bottom: footerSpacer),
                              child: Text(
                                'Kelola sampah, jaga lingkungan 🌿',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Field Label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ── Gradient Button ───────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _GradientButton({
    required this.label,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.pengelolaDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.pengelolaMain.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.pengelolaMain.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Shine effect
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 27,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Button content
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.zero,
              minimumSize: const Size(double.infinity, 54),
            ),
            onPressed: isLoading ? null : onPressed,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Masuk Sistem',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Wave Painter ──────────────────────────────────────────────────────────────

