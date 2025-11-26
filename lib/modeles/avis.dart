
class Avis {
  final int idAvis;
  final int idUser;
  final int idPlat;
  final int? note;
  final String? commentaire;
  final DateTime createdAt;
  final int? createdBy;
  final DateTime? updatedAt;
  final int? updatedBy;
  final DateTime? deletedAt;
  final int? deletedBy;

  const Avis({
    required this.idAvis,
    required this.idUser,
    required this.idPlat,
    this.note,
    this.commentaire,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
  });

  bool get estActif => deletedAt == null;

  bool get aUneNote => note != null && note! >= 1 && note! <= 5;

  bool get aUnCommentaire => commentaire != null && commentaire!.isNotEmpty;

  String get affichageEtoiles {
    if (!aUneNote) return '☆☆☆☆☆';

    String etoiles = '';
    for (int i = 1; i <= 5; i++) {
      etoiles += i <= note! ? '★' : '☆';
    }
    return etoiles;
  }

  factory Avis.fromJson(Map<String, dynamic> json) {
    return Avis(
      idAvis: json['id_avis'],
      idUser: json['id_user'],
      idPlat: json['id_plat'],
      note: json['note'],
      commentaire: json['commentaire'],
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
      'id_avis': idAvis,
      'id_user': idUser,
      'id_plat': idPlat,
      'note': note,
      'commentaire': commentaire,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'updated_at': updatedAt?.toIso8601String(),
      'updated_by': updatedBy,
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_by': deletedBy,
    };
  }

  Avis copyWith({
    int? idAvis,
    int? idUser,
    int? idPlat,
    int? note,
    String? commentaire,
    DateTime? createdAt,
    int? createdBy,
    DateTime? updatedAt,
    int? updatedBy,
    DateTime? deletedAt,
    int? deletedBy,
  }) {
    return Avis(
      idAvis: idAvis ?? this.idAvis,
      idUser: idUser ?? this.idUser,
      idPlat: idPlat ?? this.idPlat,
      note: note ?? this.note,
      commentaire: commentaire ?? this.commentaire,
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
    return 'Avis(idAvis: $idAvis, idPlat: $idPlat, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Avis && other.idAvis == idAvis;
  }

  @override
  int get hashCode => idAvis.hashCode;
}