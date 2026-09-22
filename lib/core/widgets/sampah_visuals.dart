import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import 'motion.dart';

/// Visual identitas satu jenis sampah: ikon + pasangan warna gradient.
/// Dipakai bersama oleh master sampah dan halaman lain yang menampilkan
/// item sampah, supaya satu kategori selalu punya "wajah" yang sama.
class SampahVisual {
  final IconData icon;
  final List<Color> gradient;

  const SampahVisual(this.icon, this.gradient);

  Color get accent => gradient.last;
}

/// Konstanta keyword — tulis sekali, dipakai di [resolveSampahVisual]
/// dan bisa diimpor tempat lain untuk pencocokan.
const kResidu = 'residu';
const kDaurUlang = 'daur ulang';
const kAnorganik = 'anorganik';
const kOrganik = 'organik';

/// Resolusi visual berdasarkan nama kategori / satuan.
/// Keyword dicocokkan case-insensitive & urutan penting:
/// yang lebih spesifik diperiksa lebih dulu.
SampahVisual resolveSampahVisual({
  String? kategori,
  String? satuan,
  IconData? fallbackIcon,
}) {
  final String q;
  if (kategori != null && kategori.trim().isNotEmpty) {
    q = kategori.toLowerCase();
  } else if (satuan != null && satuan.trim().isNotEmpty) {
    return _satuanVisual(satuan.toLowerCase());
  } else {
    return SampahVisual(
      fallbackIcon ?? Icons.label_outline_rounded,
      const [AppColors.kelurahanDark, AppColors.kelurahanMain],
    );
  }

  if (q.contains('residu')) {
    return const SampahVisual(Icons.delete_forever_rounded, [
      AppColors.grey,
      AppColors.textSecondary,
    ]);
  }
  if (q.contains('daur ulang') || q.contains('recycle') || q.contains('anorganik')) {
    return const SampahVisual(Icons.recycling_rounded, [
      AppColors.blueDeep,
      AppColors.kelurahanMain,
    ]);
  }
  if (q.contains('organik') || q.contains('basah') || q.contains('hijau')) {
    return const SampahVisual(Icons.compost_rounded, [
      AppColors.pengelolaDark,
      AppColors.secondary,
    ]);
  }
  if (q.contains('plastik')) {
    return const SampahVisual(Icons.water_drop_rounded, [
      AppColors.tealDark,
      AppColors.cyan,
    ]);
  }
  if (q.contains('kertas') || q.contains('karton')) {
    return const SampahVisual(Icons.description_rounded, [
      AppColors.amber,
      AppColors.amberLight,
    ]);
  }
  if (q.contains('logam') || q.contains('besi') || q.contains('alumunium') || q.contains('kaleng')) {
    return const SampahVisual(Icons.hardware_rounded, [
      AppColors.indigoDark,
      AppColors.indigo,
    ]);
  }
  if (q.contains('kaca') || q.contains('gelas')) {
    return const SampahVisual(Icons.emoji_food_beverage_rounded, [
      AppColors.teal,
      AppColors.tealMid,
    ]);
  }
  if (q.contains('elektronik') || q.contains('e-waste') || q.contains('baterai')) {
    return const SampahVisual(Icons.electrical_services_rounded, [
      AppColors.dangerDeep,
      AppColors.dangerMid,
    ]);
  }
  if (q.contains('kain') || q.contains('tekstil') || q.contains('pakaian')) {
    return const SampahVisual(Icons.checkroom_rounded, [
      AppColors.purple,
      AppColors.purpleMid,
    ]);
  }
  if (q.contains('minyak') || q.contains('cair')) {
    return const SampahVisual(Icons.opacity_rounded, [
      AppColors.orange,
      AppColors.amber,
    ]);
  }
  if (q.contains('b3') || q.contains('medis') || q.contains('deterjen')) {
    return const SampahVisual(Icons.warning_amber_rounded, [
      AppColors.dangerDeep,
      AppColors.orange,
    ]);
  }

  // Fallback: gradient role kelurahan + ikon generik
  return SampahVisual(
    fallbackIcon ?? Icons.label_outline_rounded,
    const [AppColors.kelurahanDark, AppColors.kelurahanMain],
  );
}

SampahVisual _satuanVisual(String q) {
  if (q.contains('kg') || q.contains('kilo')) {
    return const SampahVisual(Icons.scale_rounded, [
      AppColors.tealDark,
      AppColors.tealMid,
    ]);
  }
  if (q.contains('liter') || q == 'ltr' || q == 'l') {
    return const SampahVisual(Icons.water_drop_rounded, [
      AppColors.blueDeep,
      AppColors.kelurahanMain,
    ]);
  }
  if (q.contains('pcs') || q.contains('bh') || q.contains('buah')) {
    return const SampahVisual(Icons.inventory_2_rounded, [
      AppColors.indigoDark,
      AppColors.indigo,
    ]);
  }
  if (q.contains('unit')) {
    return const SampahVisual(Icons.devices_other_rounded, [
      AppColors.purple,
      AppColors.purpleMid,
    ]);
  }
  if (q.contains('pack') || q.contains('pak')) {
    return const SampahVisual(Icons.all_inbox_rounded, [
      AppColors.amber,
      AppColors.amberLight,
    ]);
  }
  return const SampahVisual(Icons.straighten_rounded, [
    AppColors.kelurahanDark,
    AppColors.kelurahanMain,
  ]);
}

/// Detail ringkas satu kategori — dipanggil saat card di-tap.
void showKategoriDetailSheet(
  BuildContext context, {
  required String nama,
  String? deskripsi,
}) {
  HapticFeedback.selectionClick();
  final resolved = resolveSampahVisual(kategori: nama);

  Get.bottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    PopIn(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: resolved.gradient,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: resolved.accent.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child:
                    Icon(resolved.icon, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                nama,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.kelurahanDark,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                (deskripsi == null || deskripsi.isEmpty)
                    ? 'Kategori sampah — ikut melindungi lingkungan 🌿'
                    : deskripsi,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13.5,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PressableScale(
                onTap: Get.back,
                pressedScale: 0.97,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.kelurahanLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.blueLight, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.kelurahanMain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
