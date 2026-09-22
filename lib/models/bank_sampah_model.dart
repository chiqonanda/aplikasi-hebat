class BankSampahModel {
  final String id;
  final String nama;
  final String? alamat;
  final String? rt;
  final String? rw;
  final double? latitude;
  final double? longitude;
  final String? jamOperasional;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BankSampahModel({
    required this.id,
    required this.nama,
    this.alamat,
    this.rt,
    this.rw,
    this.latitude,
    this.longitude,
    this.jamOperasional,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// True jika lokasi (pin peta) sudah pernah disetel.
  bool get punyaLokasi => latitude != null && longitude != null;

  String get namaLengkap {
    if (rt != null && rw != null) return '$nama (RT $rt/RW $rw)';
    if (rt != null) return '$nama (RT $rt)';
    return nama;
  }

  factory BankSampahModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return BankSampahModel(
      id: json['id'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      alamat: json['alamat'] as String?,
      rt: json['rt'] as String?,
      rw: json['rw'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      jamOperasional: json['jam_operasional'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'alamat': alamat,
      'rt': rt,
      'rw': rw,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (jamOperasional != null) 'jam_operasional': jamOperasional,
      'is_active': isActive,
    };
  }

  BankSampahModel copyWith({
    String? nama,
    String? alamat,
    String? rt,
    String? rw,
    double? latitude,
    double? longitude,
    String? jamOperasional,
    bool? isActive,
  }) {
    return BankSampahModel(
      id: id,
      nama: nama ?? this.nama,
      alamat: alamat ?? this.alamat,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      jamOperasional: jamOperasional ?? this.jamOperasional,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
