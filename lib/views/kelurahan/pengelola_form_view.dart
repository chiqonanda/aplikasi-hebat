import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/themes/app_theme.dart';
import '../../controllers/kelurahan/pengelola_controller.dart';
import '../../core/widgets/app_widgets.dart';

class PengelolaFormView extends GetView<PengelolaController> {
  const PengelolaFormView({super.key});

  // ── Theme Colors (Sama dengan Dashboard) ────────────────────────────────
  static const _blue900 = AppColors.kelurahanDark;
  static const _blue800 = AppColors.kelurahanDark;
  static const _blue600 = AppColors.kelurahanMain;
  static const _blue500 = AppColors.kelurahanMain;
  static const _blue400 = Color(0xFF42A5F5);
  static const _blue200 = AppColors.kelurahanLight;
  static const _blue50 = AppColors.kelurahanLight;
  static const _bg = AppColors.scaffoldBg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────
            AppPageHeader(
              title: 'Tambah Pengelola',
              subtitle: 'Buat akun pengelola baru',
              gradientColors: AppColors.kelurahanGradient,
              showBack: true,
            ),

            // ── Content ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Info Card ──────────────────────────────
                      _buildInfoCard(),

                      const SizedBox(height: 26),

                      // ── Section Akun ───────────────────────────
                      _buildSectionTitle(
                        'Data Akun',
                        Icons.person_outline_rounded,
                      ),

                      const SizedBox(height: 18),

                      _buildInputField(
                        controller: controller.namaController,
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama lengkap',
                        icon: Icons.person_outline_rounded,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Nama wajib diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildInputField(
                        controller: controller.emailController,
                        label: 'Email',
                        hint: 'contoh@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Email wajib diisi';
                          }
                          if (!GetUtils.isEmail(v)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      Obx(
                        () => _buildInputField(
                          controller: controller.passwordController,
                          label: 'Password',
                          hint: 'Minimal 8 karakter',
                          icon: Icons.lock_outline_rounded,
                          obscureText:
                              !controller.isPasswordVisible.value,
                          suffixIcon: IconButton(
                            onPressed: controller.togglePassword,
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password wajib diisi';
                            }
                            if (v.length < 8) {
                              return 'Password minimal 8 karakter';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildInputField(
                        controller: controller.noHpController,
                        label: 'No. HP',
                        hint: '08xxxxxxxxxx',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 30),

                      // ── Section Bank Sampah ────────────────────
                      _buildSectionTitle(
                        'Bank Sampah',
                        Icons.store_rounded,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Pilih satu atau lebih bank sampah yang akan dikelola.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── List Bank Sampah ──────────────────────
                      Obx(() {
                        if (controller.listBankSampah.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: EmptyState(
                              message: 'Belum Ada Bank Sampah',
                              subtitle: 'Silakan tambahkan bank sampah terlebih dahulu sebelum membuat akun pengelola.',
                              icon: Icons.store_mall_directory_outlined,
                            ),
                          );
                        }

                        return Column(
                          children:
                              controller.listBankSampah.map((bank) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Obx(
                                () {
                                  final selected = controller
                                      .selectedBankSampahIds
                                      .contains(bank.id);

                                  return GestureDetector(
                                    onTap: () {
                                      if (selected) {
                                        controller
                                            .selectedBankSampahIds
                                            .remove(bank.id);
                                      } else {
                                        controller
                                            .selectedBankSampahIds
                                            .add(bank.id);
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(22),
                                        border: Border.all(
                                          color: selected
                                              ? _blue500
                                              : const Color(0xFFE3F2FD),
                                          width: selected ? 2 : 1.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _blue500.withValues(
                                              alpha: selected ? 0.15 : 0.06,
                                            ),
                                            blurRadius: 14,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 250),
                                            width: 54,
                                            height: 54,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: selected
                                                    ? [
                                                        _blue500,
                                                        _blue400,
                                                      ]
                                                    : [
                                                        _blue50,
                                                        _blue200,
                                                      ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                16,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.store_rounded,
                                              color: selected
                                                  ? Colors.white
                                                  : _blue600,
                                              size: 28,
                                            ),
                                          ),

                                          const SizedBox(width: 14),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  bank.namaLengkap,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    color: _blue900,
                                                  ),
                                                ),

                                                if (bank.alamat != null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets
                                                            .only(top: 5),
                                                    child: Text(
                                                      bank.alamat!,
                                                      style: TextStyle(
                                                        fontSize: 12.5,
                                                        color: Colors
                                                            .grey.shade600,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 250),
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? _blue500
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                              border: Border.all(
                                                color: selected
                                                    ? _blue500
                                                    : Colors.grey.shade400,
                                                width: 2,
                                              ),
                                            ),
                                            child: selected
                                                ? const Icon(
                                                    Icons.check_rounded,
                                                    color: Colors.white,
                                                    size: 18,
                                                  )
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      }),

                      const SizedBox(height: 34),

                      // ── Button ────────────────────────────────
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: controller.isSaving.value
                                ? null
                                : controller.tambahPengelola,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue500,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              disabledBackgroundColor:
                                  _blue500.withValues(alpha: 0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(18),
                              ),
                            ),
                            child: controller.isSaving.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person_add_rounded,
                                        size: 22,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Buat Akun Pengelola',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // INFO CARD
  // ─────────────────────────────────────────────────────────────

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE3F2FD),
            Color(0xFFF5FAFF),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _blue200,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_blue500, _blue400],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              'Akun pengelola akan langsung aktif dan dapat digunakan untuk login aplikasi.',
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION TITLE
  // ─────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_blue500, _blue400],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _blue900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // INPUT FIELD
  // ─────────────────────────────────────────────────────────────

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _blue900,
          ),
        ),

        const SizedBox(height: 10),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _blue900,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(
              icon,
              color: _blue500,
            ),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFE3F2FD),
                width: 1.4,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: _blue500,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.4,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}