import 'kategori_model.dart';
import 'sub_kategori_model.dart';
import 'jenis_sampah_model.dart';
import 'satuan_model.dart';
import 'profile_model.dart';
import 'bank_sampah_model.dart';
import 'tipe_sampah_model.dart';

class PengelolaanSampahModel {
  final String id;
  final String bankSampahId;
  final String profileId;
  final String kategoriId;
  final String? subKategoriId;
  final String? tipeId;
  final String? jenisSampahId;
  final double jumlah;
  final String satuanId;
  final double? hargaPerSatuan;
  final double? totalHarga;
  final DateTime tanggalPengelolaan;
  final String? catatan;
  final String? namaNasabah;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relasi (opsional, ada bila di-join)
  final KategoriModel? kategori;
  final SubKategoriModel? subKategori;
  final TipeSampahModel? tipe;
  final JenisSampahModel? jenisSampah;
  final SatuanModel? satuan;
  final ProfileModel? profile;
  final BankSampahModel? bankSampah;

  const PengelolaanSampahModel({
    required this.id,
    required this.bankSampahId,
    required this.profileId,
    required this.kategoriId,
    this.subKategoriId,
    this.tipeId,
    this.jenisSampahId,
    required this.jumlah,
    required this.satuanId,
    this.hargaPerSatuan,
    this.totalHarga,
    required this.tanggalPengelolaan,
    this.catatan,
    this.namaNasabah,
    required this.createdAt,
    required this.updatedAt,
    this.kategori,
    this.subKategori,
    this.tipe,
    this.jenisSampah,
    this.satuan,
    this.profile,
    this.bankSampah,
  });

  // Label nama item berdasarkan level yang diisi
  String get namaItem {
    if (jenisSampah != null) return jenisSampah!.nama;
    if (tipe != null) return tipe!.nama;
    if (subKategori != null) return subKategori!.nama;
    if (kategori != null) return kategori!.nama;
    return '-';
  }

  // Breadcrumb: Anorganik > Plastik > PET > Botol air mineral
  String get breadcrumb {
    final parts = <String>[];
    if (kategori != null) parts.add(kategori!.nama);
    if (subKategori != null) parts.add(subKategori!.nama);
    if (tipe != null) parts.add(tipe!.nama);
    if (jenisSampah != null) parts.add(jenisSampah!.nama);
    return parts.join(' > ');
  }

  factory PengelolaanSampahModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return PengelolaanSampahModel(
      id: json['id'] as String? ?? '',
      bankSampahId: json['bank_sampah_id'] as String? ?? '',
      profileId: json['profile_id'] as String? ?? '',
      kategoriId: json['kategori_id'] as String? ?? '',
      subKategoriId: json['sub_kategori_id'] as String?,
      tipeId: json['tipe_id'] as String?,
      jenisSampahId: json['jenis_sampah_id'] as String?,
      jumlah: parseDouble(json['jumlah']),
      satuanId: json['satuan_id'] as String? ?? '',
      hargaPerSatuan: json['harga_per_satuan'] != null
          ? parseDouble(json['harga_per_satuan'])
          : null,
      totalHarga: json['total_harga'] != null
          ? parseDouble(json['total_harga'])
          : null,
      tanggalPengelolaan: parseDate(json['tanggal_pengelolaan']),
      catatan: json['catatan'] as String?,
      namaNasabah: json['nama_nasabah'] as String?,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      kategori: json['kategori_sampah'] != null && json['kategori_sampah'] is Map<String, dynamic>
          ? KategoriModel.fromJson(
              json['kategori_sampah'] as Map<String, dynamic>)
          : null,
      subKategori: json['sub_kategori_sampah'] != null && json['sub_kategori_sampah'] is Map<String, dynamic>
          ? SubKategoriModel.fromJson(
              json['sub_kategori_sampah'] as Map<String, dynamic>)
          : null,
      tipe: json['tipe_sampah'] != null && json['tipe_sampah'] is Map<String, dynamic>
          ? TipeSampahModel.fromJson(
              json['tipe_sampah'] as Map<String, dynamic>)
          : null,
      jenisSampah: json['jenis_sampah'] != null && json['jenis_sampah'] is Map<String, dynamic>
          ? JenisSampahModel.fromJson(
              json['jenis_sampah'] as Map<String, dynamic>)
          : null,
      satuan: json['satuan'] != null && json['satuan'] is Map<String, dynamic>
          ? SatuanModel.fromJson(json['satuan'] as Map<String, dynamic>)
          : null,
      profile: json['profiles'] != null && json['profiles'] is Map<String, dynamic>
          ? ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
      bankSampah: json['bank_sampah'] != null && json['bank_sampah'] is Map<String, dynamic>
          ? BankSampahModel.fromJson(
              json['bank_sampah'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'bank_sampah_id': bankSampahId,
        'profile_id': profileId,
        'kategori_id': kategoriId,
        'sub_kategori_id': subKategoriId,
        'tipe_id': tipeId,
        'jenis_sampah_id': jenisSampahId,
        'jumlah': jumlah,
        'satuan_id': satuanId,
        'harga_per_satuan': hargaPerSatuan,
        'tanggal_pengelolaan':
            tanggalPengelolaan.toIso8601String().split('T').first,
        'catatan': catatan,
        'nama_nasabah': namaNasabah,
      };
}