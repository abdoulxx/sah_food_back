
class Plat {
  final int idPlat;
  final int idMenu;
  final String nomPlat;
  final String? description;
  final String? allergenes;
  final String? photoUrl;
  final int? jourSemaine; // 1=Lundi, 2=Mardi, 3=Mercredi, 4=Jeudi, 5=Vendredi
  final DateTime createdAt;
  final int? createdBy;
  final DateTime? updatedAt;
  final int? updatedBy;
  final DateTime? deletedAt;
  final int? deletedBy;

  Plat({
    required this.idPlat,
    required this.idMenu,
    required this.nomPlat,
    this.description,
    this.allergenes,
    this.photoUrl,
    this.jourSemaine,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
  });

  bool get estDisponible => deletedAt == null;

  List<String> get listeAllergenes {
    if (allergenes == null || allergenes!.isEmpty) return [];
    return allergenes!.split(',').map((e) => e.trim()).toList();
  }

  String get nom => nomPlat;

  factory Plat.fromJson(Map<String, dynamic> json) {
    return Plat(
      idPlat: json['id_plat'],
      idMenu: json['id_menu'],
      nomPlat: json['nom_plat'],
      description: json['description'],
      allergenes: json['allergenes'],
      photoUrl: json['photo_url'],
      jourSemaine: json['jour_semaine'],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      updatedBy: json['updated_by'],
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      deletedBy: json['deleted_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_plat': idPlat,
      'id_menu': idMenu,
      'nom_plat': nomPlat,
      'description': description,
      'allergenes': allergenes,
      'photo_url': photoUrl,
      'jour_semaine': jourSemaine,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'updated_at': updatedAt?.toIso8601String(),
      'updated_by': updatedBy,
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_by': deletedBy,
    };
  }

  Plat copyWith({
    int? idPlat,
    int? idMenu,
    String? nomPlat,
    String? description,
    String? allergenes,
    String? photoUrl,
    int? jourSemaine,
    DateTime? createdAt,
    int? createdBy,
    DateTime? updatedAt,
    int? updatedBy,
    DateTime? deletedAt,
    int? deletedBy,
  }) {
    return Plat(
      idPlat: idPlat ?? this.idPlat,
      idMenu: idMenu ?? this.idMenu,
      nomPlat: nomPlat ?? this.nomPlat,
      description: description ?? this.description,
      allergenes: allergenes ?? this.allergenes,
      photoUrl: photoUrl ?? this.photoUrl,
      jourSemaine: jourSemaine ?? this.jourSemaine,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }

  @override
  String toString() {
    return 'Plat(idPlat: $idPlat, nomPlat: $nomPlat, idMenu: $idMenu)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Plat && other.idPlat == idPlat;
  }

  @override
  int get hashCode => idPlat.hashCode;
}