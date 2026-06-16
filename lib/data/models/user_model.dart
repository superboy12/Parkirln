class UserModel {
  final String uid;
  final String nama;
  final String npm;
  final String email;
  final String noPlat;
  final String jenisKendaraan;
  final String? fotoUrl;

  const UserModel({
    required this.uid,
    required this.nama,
    required this.npm,
    required this.email,
    required this.noPlat,
    required this.jenisKendaraan,
    this.fotoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid: map['uid'] ?? '',
    nama: map['nama'] ?? '',
    npm: map['npm'] ?? '',
    email: map['email'] ?? '',
    noPlat: map['no_plat'] ?? '',
    jenisKendaraan: map['jenis_kendaraan'] ?? 'Motor',
    fotoUrl: map['foto'],
  );

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'nama': nama,
    'npm': npm,
    'email': email,
    'no_plat': noPlat,
    'jenis_kendaraan': jenisKendaraan,
    'foto': fotoUrl,
  };

  UserModel copyWith({String? nama, String? noPlat, String? jenisKendaraan, String? fotoUrl}) => UserModel(
    uid: uid, npm: npm, email: email,
    nama: nama ?? this.nama,
    noPlat: noPlat ?? this.noPlat,
    jenisKendaraan: jenisKendaraan ?? this.jenisKendaraan,
    fotoUrl: fotoUrl ?? this.fotoUrl,
  );
}
