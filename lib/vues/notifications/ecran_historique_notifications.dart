import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constantes/couleurs_app.dart';
import '../../core/constantes/tailles_app.dart';
import '../../modeles/notification_model.dart';
import '../../services/service_historique_notifications.dart';

class EcranHistoriqueNotifications extends StatefulWidget {
  const EcranHistoriqueNotifications({super.key});

  @override
  State<EcranHistoriqueNotifications> createState() => _EcranHistoriqueNotificationsState();
}

class _EcranHistoriqueNotificationsState extends State<EcranHistoriqueNotifications> {
  List<NotificationModel> _notifications = [];
  bool _estEnChargement = true;

  @override
  void initState() {
    super.initState();
    _chargerNotifications();
  }

  Future<void> _chargerNotifications() async {
    setState(() => _estEnChargement = true);
    final notifications = await ServiceHistoriqueNotifications.obtenirNotifications();
    setState(() {
      _notifications = notifications;
      _estEnChargement = false;
    });

    // Marquer toutes comme lues après 2 secondes
    Future.delayed(const Duration(seconds: 2), () {
      ServiceHistoriqueNotifications.marquerToutesCommeLues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.grisClair,
      appBar: AppBar(
        backgroundColor: CouleursApp.bleuPrimaire,
        foregroundColor: CouleursApp.blanc,
        title: const Text('Notifications'),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Tout supprimer',
              onPressed: _confirmerSuppression,
            ),
        ],
      ),
      body: _estEnChargement
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _construireEcranVide()
              : RefreshIndicator(
                  onRefresh: _chargerNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _construireCarteNotification(notification);
                    },
                  ),
                ),
    );
  }

  Widget _construireEcranVide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: CouleursApp.gris.withValues(alpha: 0.5),
          ),
          const SizedBox(height: TaillesApp.espacementMoyen),
          Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: CouleursApp.gris.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: TaillesApp.espacementMin),
          Text(
            'Vos notifications apparaîtront ici',
            style: TextStyle(
              fontSize: 14,
              color: CouleursApp.gris.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireCarteNotification(NotificationModel notification) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final dateTexte = dateFormat.format(notification.dateReception);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: TaillesApp.espacementMin),
        padding: const EdgeInsets.symmetric(horizontal: TaillesApp.espacementMoyen),
        decoration: BoxDecoration(
          color: CouleursApp.erreur,
          borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete,
          color: CouleursApp.blanc,
        ),
      ),
      onDismissed: (direction) async {
        await ServiceHistoriqueNotifications.supprimerNotification(notification.id);
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification supprimée'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: TaillesApp.espacementMin),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
        ),
        elevation: notification.estLue ? 1 : 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
            border: Border.all(
              color: notification.estLue
                  ? Colors.transparent
                  : CouleursApp.bleuPrimaire.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: TaillesApp.espacementMoyen,
              vertical: TaillesApp.espacementMin,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: CouleursApp.bleuPrimaire.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.estLue
                    ? Icons.notifications_outlined
                    : Icons.notifications_active,
                color: CouleursApp.bleuPrimaire,
                size: 24,
              ),
            ),
            title: Text(
              notification.titre,
              style: TextStyle(
                fontSize: 16,
                fontWeight: notification.estLue ? FontWeight.w500 : FontWeight.bold,
                color: CouleursApp.bleuFonce,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notification.corps,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CouleursApp.grisFonce,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: CouleursApp.gris.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateTexte,
                      style: TextStyle(
                        fontSize: 12,
                        color: CouleursApp.gris.withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: !notification.estLue
                ? Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: CouleursApp.bleuPrimaire,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  void _confirmerSuppression() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer'),
        content: const Text('Voulez-vous supprimer toutes les notifications ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ServiceHistoriqueNotifications.supprimerToutesNotifications();
              Navigator.of(context).pop();
              _chargerNotifications();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.erreur,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
