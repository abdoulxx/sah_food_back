
class Menu {
  final int idMenu;
  final int semaine;
  final DateTime dateDebut;
  final DateTime dateFin;
  final DateTime createdAt;
  final int? createdBy;
  final DateTime? updatedAt;
  final int? updatedBy;
  final DateTime? deletedAt;
  final int? deletedBy;

  const Menu({
    required this.idMenu,
    required this.semaine,
    required this.dateDebut,
    required this.dateFin,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
  });

  bool get estActif => deletedAt == null;

  bool get estSemaineCourante {
    final maintenant = DateTime.now();
    return maintenant.isAfter(dateDebut) && maintenant.isBefore(dateFin);
  }

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      idMenu: json['id_menu'],
      semaine: json['semaine'],
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
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
      'id_menu': idMenu,
      'semaine': semaine,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'updated_at': updatedAt?.toIso8601String(),
      'updated_by': updatedBy,
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_by': deletedBy,
    };
  }

  Menu copyWith({
    int? idMenu,
    int? semaine,
    DateTime? dateDebut,
    DateTime? dateFin,
    DateTime? createdAt,
    int? createdBy,
    DateTime? updatedAt,
    int? updatedBy,
    DateTime? deletedAt,
    int? deletedBy,
  }) {
    return Menu(
      idMenu: idMenu ?? this.idMenu,
      semaine: semaine ?? this.semaine,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
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
    return 'Menu(idMenu: $idMenu, semaine: $semaine, dateDebut: $dateDebut, dateFin: $dateFin)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Menu && other.idMenu == idMenu;
  }

  @override
  int get hashCode => idMenu.hashCode;
}