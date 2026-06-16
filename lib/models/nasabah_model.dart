import 'bank_sampah_model.dart';

class NasabahModel {
  final String id;
  final String nama;
  final String? noHp;
  final String? alamat;
  final String? bankSampahId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relasi
  final BankSampahModel? bankSampah;

  const NasabahModel({
    required this.id,
    required this.nama,
    this.noHp,
    this.alamat,
    this.bankSampahId,
    required this.createdAt,
    required this.updatedAt,
    this.bankSampah,
  });

  factory NasabahModel.fromJson(Map<String, dynamic> json) {
    return NasabahModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      noHp: json['no_hp'] as String?,
      alamat: json['alamat'] as String?,
      bankSampahId: json['bank_sampah_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      bankSampah: json['bank_sampah'] != null
          ? BankSampahModel.fromJson(json['bank_sampah'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'no_hp': noHp,
      'alamat': alamat,
      'bank_sampah_id': bankSampahId,
    };
  }

  NasabahModel copyWith({
    String? nama,
    String? noHp,
    String? alamat,
    String? bankSampahId,
    BankSampahModel? bankSampah,
  }) {
    return NasabahModel(
      id: id,
      nama: nama ?? this.nama,
      noHp: noHp ?? this.noHp,
      alamat: alamat ?? this.alamat,
      bankSampahId: bankSampahId ?? this.bankSampahId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      bankSampah: bankSampah ?? this.bankSampah,
    );
  }
}
