class Utilisateur {
  final int idUser;
  final String qid;
  final String prenom;
  final String nom;
  final String email;
  final String role;
  final String? departement;
  final String site;
  final String? photo; // URL de la photo de profil
  final DateTime createdAt;
  final int? createdBy;
  final DateTime? updatedAt;
  final int? updatedBy;
  final DateTime? deletedAt;
  final int? deletedBy;
  final String? fcmToken;

  const Utilisateur({
    required this.idUser,
    required this.qid,
    required this.prenom,
    required this.nom,
    required this.email,
    required this.role,
    this.departement,
    required this.site,
    this.photo,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
    this.fcmToken,
  });

  String get nomComplet => '$prenom $nom';
  bool get estActif => deletedAt == null;

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      idUser: json['id_user'],
      qid: json['qid'],
      prenom: json['prenom'],
      nom: json['nom'],
      email: json['email'],
      role: json['role'],
      departement: json['departement'],
      site: json['site'],
      photo: json['photo'],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      updatedBy: json['updated_by'],
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      deletedBy: json['deleted_by'],
      fcmToken: json['fcm_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'qid': qid,
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'role': role,
      'departement': departement,
      'site': site,
      'photo': photo,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'updated_at': updatedAt?.toIso8601String(),
      'updated_by': updatedBy,
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_by': deletedBy,
      'fcm_token': fcmToken,
    };
  }

  Utilisateur copyWith({
    int? idUser,
    String? qid,
    String? prenom,
    String? nom,
    String? email,
    String? role,
    String? departement,
    String? site,
    String? photo,
    DateTime? createdAt,
    int? createdBy,
    DateTime? updatedAt,
    int? updatedBy,
    DateTime? deletedAt,
    int? deletedBy,
    String? fcmToken,
  }) {
    return Utilisateur(
      idUser: idUser ?? this.idUser,
      qid: qid ?? this.qid,
      prenom: prenom ?? this.prenom,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      role: role ?? this.role,
      departement: departement ?? this.departement,
      site: site ?? this.site,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  String toString() {
    return 'Utilisateur(idUser: $idUser, nom: $nom, prenom: $prenom, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Utilisateur && other.idUser == idUser;
  }

  @override
  int get hashCode => idUser.hashCode;
}