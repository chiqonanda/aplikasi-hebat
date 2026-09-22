class ProfileModel {
  final String id;
  final String authUserId;
  final String namaLengkap;
  final String? noHp;
  final String role;
  final bool isVerified;
  final List<String> bankSampahPilihan; // pilihan saat registrasi
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.authUserId,
    required this.namaLengkap,
    this.noHp,
    required this.role,
    this.isVerified = false,
    this.bankSampahPilihan = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isKelurahan => role == 'kelurahan';
  bool get isPengelola => role == 'pengelola';

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return ProfileModel(
      id: json['id'] as String? ?? '',
      authUserId: json['auth_user_id'] as String? ?? '',
      namaLengkap: json['nama_lengkap'] as String? ?? '',
      noHp: json['no_hp'] as String?,
      role: json['role'] as String? ?? 'pengelola',
      isVerified: json['is_verified'] as bool? ?? false,
      bankSampahPilihan: json['bank_sampah_pilihan'] is List
          ? (json['bank_sampah_pilihan'] as List).map((e) => e.toString()).toList()
          : [],
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auth_user_id': authUserId,
      'nama_lengkap': namaLengkap,
      'no_hp': noHp,
      'role': role,
      'is_verified': isVerified,
      'bank_sampah_pilihan': bankSampahPilihan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProfileModel copyWith({String? namaLengkap, String? noHp}) {
    return ProfileModel(
      id: id,
      authUserId: authUserId,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      noHp: noHp ?? this.noHp,
      role: role,
      isVerified: isVerified,
      bankSampahPilihan: bankSampahPilihan,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
