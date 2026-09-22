import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/themes/app_colors.dart';
import 'motion.dart';
import 'app_widgets.dart';

/// Pusat peta default: Kelurahan Gunung Lingai, Samarinda.
const LatLng kDefaultMapCenter = LatLng(-0.4903, 117.1487);
const double kDefaultMapZoom = 14;

/// Buka petunjuk arah ke titik [lat],[lng] — coba Google Maps dulu,
/// lalu Waze, terakhir fallback web browser.
Future<void> bukaPetunjukArah({
  required double lat,
  required double lng,
  String? label,
}) async {
  HapticFeedback.lightImpact();
  final q = label != null ? Uri.encodeComponent(label) : '';
  final urls = [
    Uri.parse('geo:$lat,$lng?q=$lat,$lng${q.isEmpty ? '' : '($q)'}'),
    Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'),
    Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes'),
  ];
  for (final uri in urls) {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
  }
}

String koordinatText(double? lat, double? lng) {
  if (lat == null || lng == null) return 'Lokasi belum disetel';
  return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
}

/// Tile layer OSM standar + atribusi wajib.
TileLayer _osmTileLayer() {
  return TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'id.bisa.banksampah',
  );
}

/// Peta penuh dengan daftar marker bank sampah.
/// Tap marker → bottom sheet detail (nama, alamat, jam, aksi).
class BankSampahMapViewer extends StatefulWidget {
  final List<MapEntry<LatLng, MapPlace>> places;
  final LatLng initialCenter;
  final double initialZoom;
  final VoidCallback? onBack;

  const BankSampahMapViewer({
    super.key,
    required this.places,
    required this.initialCenter,
    this.initialZoom = kDefaultMapZoom,
    this.onBack,
  });

  @override
  State<BankSampahMapViewer> createState() => _BankSampahMapViewerState();
}

class _BankSampahMapViewerState extends State<BankSampahMapViewer> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.initialCenter,
            initialZoom: widget.initialZoom,
            onTap: (_, _) => Get.back(),
          ),
          children: [
            _osmTileLayer(),
            MarkerLayer(
              markers: widget.places.map((entry) {
                final place = entry.value;
                return Marker(
                  point: entry.key,
                  width: 120,
                  height: 76,
                  alignment: Alignment.topCenter,
                  child: PressableScale(
                    onTap: () => place.onTap(),
                    pressedScale: 0.9,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.storefront_rounded,
                                  size: 13, color: AppColors.primary),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  place.nama,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Pin + shadow tanah
                        const Icon(
                          Icons.location_on_rounded,
                          size: 34,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('© OpenStreetMap'),
              ],
            ),
          ],
        ),

        // Tombol kembali
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                PressableScale(
                  onTap: widget.onBack ?? Get.back,
                  pressedScale: 0.9,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        size: 20, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 10),
                if (widget.places.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      '${widget.places.length} bank sampah',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Data ringkas satu titik peta.
class MapPlace {
  final String nama;
  final VoidCallback onTap;
  const MapPlace({required this.nama, required this.onTap});
}

// ═══════════════════════════════════════════════════════════════════════════
// SHEET: peta semua bank sampah (sisi kelurahan)
// ═══════════════════════════════════════════════════════════════════════════

/// Tampilkan peta full-screen berisi semua bank sampah.
/// [items] = daftar (nama, alamat, jam, lat, lng, onTapDetail).
void showPetaSemuaBankSampah(
  BuildContext context, {
  required List<BankSampahPetaItem> items,
}) {
  HapticFeedback.mediumImpact();
  final withLokasi =
      items.where((e) => e.lat != null && e.lng != null).toList();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => PopIn(
      child: SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.92,
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: withLokasi.isEmpty
                    ? const AppEmptyState(
                        icon: Icons.map_outlined,
                        title: 'Belum Ada Lokasi',
                        subtitle:
                            'Belum ada bank sampah yang menyetel pin lokasinya di peta.',
                      )
                    : BankSampahMapViewer(
                        places: withLokasi
                            .map((e) => MapEntry(
                                LatLng(e.lat!, e.lng!),
                                MapPlace(
                                  nama: e.nama,
                                  onTap: () =>
                                      _showDetailBankSampah(ctx, e),
                                )))
                            .toList(),
                        initialCenter: LatLng(withLokasi.first.lat!,
                            withLokasi.first.lng!),
                        initialZoom: 14,
                        onBack: () => Navigator.of(ctx).pop(),
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Satu item peta bank sampah — diterima dari view, tidak terikat model.
class BankSampahPetaItem {
  final String nama;
  final String? alamat;
  final String? jamOperasional;
  final double? lat;
  final double? lng;

  /// Aksi tombol "Lihat Profil" di detail sheet (mis. buka halaman detail).
  final VoidCallback? onLihatProfil;

  const BankSampahPetaItem({
    required this.nama,
    this.alamat,
    this.jamOperasional,
    this.lat,
    this.lng,
    this.onLihatProfil,
  });
}

/// Detail ringkas satu bank sampah dari peta.
void _showDetailBankSampah(BuildContext ctx, BankSampahPetaItem item) {
  HapticFeedback.selectionClick();
  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    PopIn(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
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
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.pengelolaDark, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.nama,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.kelurahanDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (item.alamat != null && item.alamat!.isNotEmpty)
              _detailRow(Icons.location_on_outlined, item.alamat!),
            if (item.jamOperasional != null &&
                item.jamOperasional!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _detailRow(Icons.access_time_rounded, item.jamOperasional!),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: PressableScale(
                    onTap: () {
                      Get.back();
                      item.onLihatProfil?.call();
                    },
                    pressedScale: 0.95,
                    splashColor: AppColors.kelurahanLight,
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
                        'Lihat Profil',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.kelurahanMain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PressableScale(
                    onTap: () {
                      bukaPetunjukArah(
                          lat: item.lat!, lng: item.lng!, label: item.nama);
                    },
                    pressedScale: 0.95,
                    glowIntensity: 0.4,
                    glowColor: AppColors.primary,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.secondary,
                            AppColors.pengelolaDark
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.navigation_rounded,
                              color: Colors.white, size: 17),
                          SizedBox(width: 7),
                          Text(
                            'Petunjuk Arah',
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
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _detailRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 17, color: AppColors.textSecondary),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// PICKER: pengelola menyetel pin lokasinya (drag pin → Simpan)
// ═══════════════════════════════════════════════════════════════════════════

/// Buka map picker. User geser peta; pin tetap di tengah layar.
/// Simpan → return [LatLng]; batal → null.
Future<LatLng?> showMapPicker(
  BuildContext context, {
  LatLng? initial,
  String title = 'Setel Lokasi',
}) {
  LatLng center = initial ?? kDefaultMapCenter;
  final controller = MapController();

  return showModalBottomSheet<LatLng>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.92,
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
          child: Stack(
            children: [
              FlutterMap(
                mapController: controller,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 16,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                  onMapEvent: (e) {
                    if (e.camera.center != center) {
                      setState(() => center = e.camera.center);
                    }
                  },
                ),
                children: [
                  _osmTileLayer(),
                  const RichAttributionWidget(
                    attributions: [TextSourceAttribution('© OpenStreetMap')],
                  ),
                ],
              ),

              // Pin tetap di tengah + shadow tanah
              IgnorePointer(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -17),
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Header + koordinat + tombol
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        children: [
                          PressableScale(
                            onTap: () => Navigator.of(ctx).pop(),
                            pressedScale: 0.9,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.close_rounded,
                                  size: 20, color: AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Kartu koordinat live
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location_rounded,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            koordinatText(center.latitude, center.longitude),
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tombol Simpan
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: PressableScale(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(ctx).pop(center);
                        },
                        pressedScale: 0.97,
                        glowIntensity: 0.45,
                        glowColor: AppColors.primary,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.secondary,
                                AppColors.pengelolaDark
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Simpan Lokasi',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 15,
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
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
