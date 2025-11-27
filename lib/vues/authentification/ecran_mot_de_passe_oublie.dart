import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constantes/couleurs_app.dart';
import '../../core/constantes/tailles_app.dart';
import '../../modeles_vues/authentification_model_vue.dart';
import '../../services/service_authentification.dart';

class EcranMotDePasseOublie extends StatefulWidget {
  const EcranMotDePasseOublie({super.key});

  @override
  State<EcranMotDePasseOublie> createState() => _EtatEcranMotDePasseOublie();
}

class _EtatEcranMotDePasseOublie extends State<EcranMotDePasseOublie> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _controleurEmail = TextEditingController();
  bool _estEnChargement = false;
  bool _emailEnvoye = false;

  @override
  void dispose() {
    _controleurEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.blanc,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CouleursApp.grisFonce),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'mot de passe oublié',
          style: TextStyle(
            color: CouleursApp.grisFonce,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
        child: Form(
          key: _cleFormulaire,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: TaillesApp.espacementMoyen),

              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: CouleursApp.bleuPrimaire,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'assets/images/sah.webp',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: TaillesApp.espacementMoyen),

              const Text(
                'SAH FOOD',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CouleursApp.orangePrimaire,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: TaillesApp.espacementTresGrand),

              if (!_emailEnvoye) ...[
                const Column(
                  children: [
                    Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.bleuPrimaire,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Entrez votre email pour recevoir un lien de réinitialisation',
                      style: TextStyle(
                        fontSize: 14,
                        color: CouleursApp.grisFonce,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: TaillesApp.espacementTresGrand),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: CouleursApp.gris),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: _controleurEmail,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validerEmail,
                    decoration: const InputDecoration(
                      hintText: 'exemple.test@sahanalytics.com',
                      hintStyle: TextStyle(color: CouleursApp.gris),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),

                const SizedBox(height: TaillesApp.espacementTresGrand),

                // Bouton d'envoi
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _estEnChargement ? null : _envoyerLienReinitialisation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CouleursApp.bleuPrimaire,
                      foregroundColor: CouleursApp.blanc,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _estEnChargement
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                CouleursApp.blanc,
                              ),
                            ),
                          )
                        : const Text(
                            'Envoyer le lien',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ] else ...[
                // Message de confirmation
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: CouleursApp.succes.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CouleursApp.succes),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        size: 60,
                        color: CouleursApp.succes,
                      ),
                    ),

                    const SizedBox(height: TaillesApp.espacementMoyen),

                    const Text(
                      'Email envoyé !',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.succes,
                      ),
                    ),

                    const SizedBox(height: TaillesApp.espacementMin),

                    Text(
                      'Un lien de réinitialisation a été envoyé à ${_controleurEmail.text}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CouleursApp.grisFonce,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: TaillesApp.espacementMoyen),

                    const Text(
                      'Vérifiez votre boîte de réception et suivez les instructions.',
                      style: TextStyle(
                        fontSize: 12,
                        color: CouleursApp.gris,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: TaillesApp.espacementTresGrand),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CouleursApp.bleuPrimaire,
                          foregroundColor: CouleursApp.blanc,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Retour à la connexion',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: TaillesApp.espacementMoyen),

              if (!_emailEnvoye)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Retour à la connexion',
                    style: TextStyle(
                      color: CouleursApp.bleuPrimaire,
                      fontSize: 14,
                    ),
                  ),
                ),

              const SizedBox(height: TaillesApp.espacementMoyen),

              if (_emailEnvoye) ...[
                TextButton(
                  onPressed: _renvoyerEmail,
                  child: const Text(
                    'Renvoyer l\'email',
                    style: TextStyle(
                      color: CouleursApp.bleuPrimaire,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _validerEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'L\'email est requis';
    }
    if (!email.contains('@sahanalytics.com') || !email.contains('.')) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  Future<void> _envoyerLienReinitialisation() async {
    if (_cleFormulaire.currentState!.validate()) {
      setState(() {
        _estEnChargement = true;
      });

      try {
        // Appeler le service Supabase pour envoyer l'email de réinitialisation
        await ServiceAuthentification.reinitialiserMotDePasse(
          _controleurEmail.text.trim(),
        );

        setState(() {
          _estEnChargement = false;
          _emailEnvoye = true;
        });
      } catch (erreur) {
        setState(() {
          _estEnChargement = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(erreur.toString().replaceAll('Exception: ', '')),
              backgroundColor: CouleursApp.erreur,
            ),
          );
        }
      }
    }
  }

  Future<void> _renvoyerEmail() async {
    setState(() {
      _emailEnvoye = false;
    });

    // on attend un peu avant de permettre un nouvel envoi
    await Future.delayed(const Duration(milliseconds: 500));
  }
}