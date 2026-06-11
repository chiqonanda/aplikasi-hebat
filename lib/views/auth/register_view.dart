import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../core/utils/validator.dart';
import '../../core/widgets/app_widgets.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final AuthController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AuthController>();
    controller.fetchBankSampahUntukRegister();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background wave (sama dengan login) ─────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 200),
              painter: _WavePainter(),
            ),
          ),

          // ── Decorative circles ──────────────────────────────
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Custom AppBar ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Daftar Akun',
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Scrollable form ────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Form(
                        key: controller.registerFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Info card ────────────────────
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.2),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.info_outline_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Setelah mendaftar, akun kamu akan diverifikasi oleh kelurahan sebelum bisa digunakan.',
                                      style: AppTextStyles.bodySm.copyWith(
                                        color: Colors.white,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Section: Data Diri & Akun ────
                            _SectionCard(
                              icon: Icons.person_add_rounded,
                              title: 'Data Diri & Akun',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _FieldLabel(label: 'Nama Lengkap'),
                                  const SizedBox(height: 8),
                                  AppTextField(
                                    controller:
                                        controller.regNamaController,
                                    label: '',
                                    hint: 'Masukkan nama lengkap',
                                    prefixIcon: Icons.badge_outlined,
                                    validator: (v) => AppValidator.required(
                                        v,
                                        fieldName: 'Nama lengkap'),
                                  ),
                                  const SizedBox(height: 16),
                                  const _FieldLabel(
                                      label: 'No. HP (opsional)'),
                                  const SizedBox(height: 8),
                                  AppTextField(
                                    controller:
                                        controller.regNoHpController,
                                    label: '',
                                    hint: 'Contoh: 08123456789',
                                    prefixIcon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    validator: AppValidator.phone,
                                  ),
                                  const SizedBox(height: 16),
                                  const _FieldLabel(label: 'Email'),
                                  const SizedBox(height: 8),
                                  AppTextField(
                                    controller:
                                        controller.regEmailController,
                                    label: '',
                                    hint: 'contoh@email.com',
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType:
                                        TextInputType.emailAddress,
                                    validator: AppValidator.email,
                                  ),
                                  const SizedBox(height: 16),
                                  const _FieldLabel(label: 'Kata Sandi'),
                                  const SizedBox(height: 8),
                                  Obx(
                                    () => AppTextField(
                                      controller: controller
                                          .regPasswordController,
                                      label: '',
                                      hint: 'Minimal 8 karakter',
                                      prefixIcon:
                                          Icons.lock_outline_rounded,
                                      obscureText: !controller
                                          .isPasswordVisible.value,
                                      validator: AppValidator.password,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          controller.isPasswordVisible
                                                  .value
                                              ? Icons.visibility_outlined
                                              : Icons
                                                  .visibility_off_outlined,
                                          color: Colors.grey.shade400,
                                          size: 20,
                                        ),
                                        onPressed: controller
                                            .togglePasswordVisibility,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const _FieldLabel(
                                      label: 'Konfirmasi Kata Sandi'),
                                  const SizedBox(height: 8),
                                  Obx(
                                    () => AppTextField(
                                      controller: controller
                                          .regConfirmPasswordController,
                                      label: '',
                                      hint: 'Ulangi kata sandi',
                                      prefixIcon:
                                          Icons.lock_outline_rounded,
                                      obscureText: !controller
                                          .isConfirmPasswordVisible
                                          .value,
                                      validator: (v) =>
                                          AppValidator.confirmPassword(
                                        v,
                                        controller
                                            .regPasswordController.text,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          controller
                                                  .isConfirmPasswordVisible
                                                  .value
                                              ? Icons.visibility_outlined
                                              : Icons
                                                  .visibility_off_outlined,
                                          color: Colors.grey.shade400,
                                          size: 20,
                                        ),
                                        onPressed: controller
                                            .toggleConfirmPasswordVisibility,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ── Section: Bank Sampah ─────────
                            _SectionCard(
                              icon: Icons.store_rounded,
                              title: 'Bank Sampah',
                              subtitle:
                                  'Pilih bank sampah tempat kamu bertugas',
                              child: Obx(() {
                                if (controller
                                    .isLoadingBankSampah.value) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  );
                                }

                                if (controller
                                    .listBankSampahRegister.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius:
                                          BorderRadius.circular(AppTheme.radiusMd),
                                      border: Border.all(
                                          color: AppColors.divider),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.store_outlined,
                                            size: 16,
                                            color: AppColors.textTertiary),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Belum ada bank sampah tersedia.',
                                          style: AppTextStyles.bodyMd.copyWith(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return Column(
                                  children: controller
                                      .listBankSampahRegister
                                      .map((bank) {
                                    return Obx(() {
                                      final isSelected = controller
                                          .selectedBankSampahRegister
                                          .contains(bank.id);
                                      return GestureDetector(
                                        onTap: () {
                                          if (isSelected) {
                                            controller
                                                .selectedBankSampahRegister
                                                .remove(bank.id);
                                          } else {
                                            controller
                                                .selectedBankSampahRegister
                                                .add(bank.id);
                                          }
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 200),
                                          margin: const EdgeInsets.only(
                                              bottom: 10),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.pengelolaLight
                                                : AppColors.background,
                                            borderRadius:
                                                BorderRadius.circular(AppTheme.radiusLg),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.divider,
                                              width:
                                                  isSelected ? 1.5 : 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                width: 42,
                                                height: 42,
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : AppColors.divider,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppTheme.radiusMd),
                                                ),
                                                child: Icon(
                                                  Icons.store_rounded,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : AppColors.textSecondary,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Text(
                                                      bank.namaLengkap,
                                                      style: AppTextStyles.bodyLg.copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: isSelected
                                                            ? AppColors.pengelolaDark
                                                            : AppColors.textPrimary,
                                                      ),
                                                    ),
                                                    if (bank.alamat !=
                                                        null) ...[
                                                      const SizedBox(
                                                          height: 3),
                                                      Text(
                                                        bank.alamat!,
                                                        style: AppTextStyles.bodySm.copyWith(
                                                          color: AppColors.textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          7),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? AppColors.primary
                                                        : AppColors.textTertiary,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: isSelected
                                                    ? const Icon(
                                                        Icons.check_rounded,
                                                        color: Colors.white,
                                                        size: 15,
                                                      )
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                                  }).toList(),
                                );
                              }),
                            ),

                            const SizedBox(height: 28),

                            // ── Tombol Daftar ────────────────
                            Obx(
                              () => _GradientButton(
                                label: 'Daftar Sekarang',
                                isLoading: controller.isLoading.value,
                                onPressed: controller.register,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Link login ───────────────────
                            Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Sudah punya akun? ',
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Get.back(),
                                    child: Text(
                                      'Masuk',
                                      style: AppTextStyles.bodyMd.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Tagline
                            Center(
                              child: Text(
                                'Kelola sampah, jaga lingkungan 🌿',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),

                            SizedBox(
                              height:
                                  MediaQuery.of(context).viewInsets.bottom,
                            ),
                          ],
                        ),
                      ),
                    ),
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

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: const Border(
          top: BorderSide(color: AppColors.primary, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.pengelolaLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySm.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Divider
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            height: 1,
            color: AppColors.divider,
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: child,
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
      style: AppTextStyles.labelMd.copyWith(
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
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
                  topLeft: Radius.circular(AppTheme.radiusLg),
                  topRight: Radius.circular(AppTheme.radiusLg),
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              minimumSize: const Size(double.infinity, 54),
              padding: EdgeInsets.zero,
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.labelLg.copyWith(
                          fontSize: 15,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
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

// ── Wave Painter (sama dengan LoginView) ──────────────────────────────────────

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.pengelolaDark, AppColors.primary],
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
      ..color = AppColors.secondary.withValues(alpha: 0.35);

    final path2 = Path()
      ..moveTo(0, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.55,
        size.width * 0.55,
        size.height * 0.70,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.82,
        size.width,
        size.height * 0.68,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path2, paint2);

    final paintDot = Paint()
      ..color = Colors.white.withValues(alpha: 0.08);

    canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.3), 40, paintDot);
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.2), 25, paintDot);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => false;
}