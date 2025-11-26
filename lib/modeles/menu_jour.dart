import 'plat.dart';

class MenuJour {
  final String id;
  final DateTime date;
  final String jourSemaine;
  final List<Plat> plats;
  final bool estDisponible;

  const MenuJour({
    required this.id,
    required this.date,
    required this.jourSemaine,
    required this.plats,
    this.estDisponible = true,
  });

  bool get estAujourdhui {
    final maintenant = DateTime.now();
    return date.year == maintenant.year &&
           date.month == maintenant.month &&
           date.day == maintenant.day;
  }

  int get nombrePlatsDisponibles => plats.where((p) => p.estDisponible).length;


  MenuJour copyWith({
    String? id,
    DateTime? date,
    String? jourSemaine,
    List<Plat>? plats,
    bool? estDisponible,
  }) {
    return MenuJour(
      id: id ?? this.id,
      date: date ?? this.date,
      jourSemaine: jourSemaine ?? this.jourSemaine,
      plats: plats ?? this.plats,
      estDisponible: estDisponible ?? this.estDisponible,
    );
  }

  @override
  String toString() {
    return 'MenuJour(jour: $jourSemaine, plats: ${plats.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuJour && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}