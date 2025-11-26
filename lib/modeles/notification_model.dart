/// Modèle représentant une notification Firebase
class NotificationModel {
  final String id;
  final String titre;
  final String corps;
  final DateTime dateReception;
  final bool estLue;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.titre,
    required this.corps,
    required this.dateReception,
    this.estLue = false,
    this.data,
  });

  /// Créer depuis JSON
  factory NotificationModel.depuisJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      titre: json['titre'] as String,
      corps: json['corps'] as String,
      dateReception: DateTime.parse(json['dateReception'] as String),
      estLue: json['estLue'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'titre': titre,
      'corps': corps,
      'dateReception': dateReception.toIso8601String(),
      'estLue': estLue,
      'data': data,
    };
  }

  /// Copier avec modifications
  NotificationModel copierAvec({
    String? id,
    String? titre,
    String? corps,
    DateTime? dateReception,
    bool? estLue,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      corps: corps ?? this.corps,
      dateReception: dateReception ?? this.dateReception,
      estLue: estLue ?? this.estLue,
      data: data ?? this.data,
    );
  }
}
