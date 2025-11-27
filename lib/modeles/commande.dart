import 'plat.dart';

enum StatutCommande {
  enAttente('EN_ATTENTE'),
  validee('VALIDEE'),
  annulee('ANNULEE');

  final String valeur;
  const StatutCommande(this.valeur);

  static StatutCommande fromString(String statut) {
    switch (statut) {
      case 'EN_ATTENTE':
        return StatutCommande.enAttente;
      case 'VALIDEE':
        return StatutCommande.validee;
      case 'ANNULEE':
        return StatutCommande.annulee;
      default:
        return StatutCommande.enAttente;
    }
  }
}

class Commande {
  final int idCommande;
  final int idUser;
  final int idPlat;
  final StatutCommande statut;
  final String? siteLivraison; // DANGA ou CAMPUS
  final String? notesSpeciales; // Notes du collaborateur (ex: "Je veux du piment svp")
  final DateTime createdAt;
  final int? createdBy;
  final DateTime? updatedAt;
  final int? updatedBy;
  final DateTime? deletedAt;
  final int? deletedBy;

  // Champs optionnels pour les jointures
  final Plat? plat;

  const Commande({
    required this.idCommande,
    required this.idUser,
    required this.idPlat,
    required this.statut,
    this.siteLivraison,
    this.notesSpeciales,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
    this.plat,
  });

  bool get estActif => deletedAt == null;

  DateTime get dateLivraison => createdAt; // À adapter selon votre logique

  String get jourSemaine {
    const jours = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];

    // Si on a un plat avec un jour_semaine défini, on l'utilise
    if (plat?.jourSemaine != null) {
      return jours[plat!.jourSemaine! - 1];
    }

    // Sinon, on utilise le jour de création
    return jours[dateLivraison.weekday - 1];
  }

  bool get estAujourdhui {
    final maintenant = DateTime.now();
    return dateLivraison.year == maintenant.year &&
           dateLivraison.month == maintenant.month &&
           dateLivraison.day == maintenant.day;
  }

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      idCommande: json['id_commande'],
      idUser: json['id_user'],
      idPlat: json['id_plat'],
      statut: StatutCommande.fromString(json['statut']),
      siteLivraison: json['site_livraison'],
      notesSpeciales: json['notes_speciales'],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      updatedBy: json['updated_by'],
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      deletedBy: json['deleted_by'],
      plat: json['plats'] != null ? Plat.fromJson(json['plats']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_commande': idCommande,
      'id_user': idUser,
      'id_plat': idPlat,
      'statut': statut.valeur,
      'site_livraison': siteLivraison,
      'notes_speciales': notesSpeciales,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'updated_at': updatedAt?.toIso8601String(),
      'updated_by': updatedBy,
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_by': deletedBy,
    };
  }

  Commande copyWith({
    int? idCommande,
    int? idUser,
    int? idPlat,
    StatutCommande? statut,
    String? siteLivraison,
    String? notesSpeciales,
    DateTime? createdAt,
    int? createdBy,
    DateTime? updatedAt,
    int? updatedBy,
    DateTime? deletedAt,
    int? deletedBy,
    Plat? plat,
  }) {
    return Commande(
      idCommande: idCommande ?? this.idCommande,
      idUser: idUser ?? this.idUser,
      idPlat: idPlat ?? this.idPlat,
      statut: statut ?? this.statut,
      siteLivraison: siteLivraison ?? this.siteLivraison,
      notesSpeciales: notesSpeciales ?? this.notesSpeciales,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      plat: plat ?? this.plat,
    );
  }

  @override
  String toString() {
    return 'Commande(idCommande: $idCommande, idPlat: $idPlat, statut: ${statut.valeur})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Commande && other.idCommande == idCommande;
  }

  @override
  int get hashCode => idCommande.hashCode;
}