import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/constantes/couleurs_app.dart';
import 'core/config/supabase_config.dart';
import 'modeles_vues/splash_model_vue.dart';
import 'modeles_vues/authentification_model_vue.dart';
import 'modeles_vues/accueil_model_vue.dart';
import 'modeles_vues/navigation_model_vue.dart';
import 'modeles_vues/menu_model_vue.dart';
import 'modeles_vues/profil_model_vue.dart';
import 'modeles_vues/historique_model_vue.dart';
import 'modeles_vues/avis_model_vue.dart';
import 'services/service_notifications.dart';
import 'vues/ecran_splash/ecran_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase (uniquement sur mobile)
  if (!kIsWeb) {
    await Firebase.initializeApp();

    // Enregistrer le handler pour les notifications en arrière-plan
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Initialisation de Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Initialisation du service de notifications (uniquement sur mobile)
  if (!kIsWeb) {
    await ServiceNotifications.initialiser();
  }

  runApp(const ApplicationSahFood());
}

class ApplicationSahFood extends StatelessWidget {
  const ApplicationSahFood({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashModelVue()),
        ChangeNotifierProvider(create: (_) => AuthentificationModelVue()),
        ChangeNotifierProxyProvider<AuthentificationModelVue, MenuModelVue>(
          create: (context) => MenuModelVue(
            Provider.of<AuthentificationModelVue>(context, listen: false),
          ),
          update: (context, auth, previous) => previous ?? MenuModelVue(auth),
        ),
        ChangeNotifierProxyProvider<AuthentificationModelVue, AccueilModelVue>(
          create: (context) => AccueilModelVue(
            Provider.of<AuthentificationModelVue>(context, listen: false),
          ),
          update: (context, auth, previous) => previous ?? AccueilModelVue(auth),
        ),
        ChangeNotifierProxyProvider<AuthentificationModelVue, HistoriqueModelVue>(
          create: (context) => HistoriqueModelVue(
            Provider.of<AuthentificationModelVue>(context, listen: false),
          ),
          update: (context, auth, previous) => previous ?? HistoriqueModelVue(auth),
        ),
        ChangeNotifierProxyProvider<AuthentificationModelVue, AvisModelVue>(
          create: (context) => AvisModelVue(
            Provider.of<AuthentificationModelVue>(context, listen: false),
          ),
          update: (context, auth, previous) => previous ?? AvisModelVue(auth),
        ),
        ChangeNotifierProvider(create: (_) => NavigationModelVue()),
        ChangeNotifierProxyProvider<AuthentificationModelVue, ProfilModelVue>(
          create: (context) => ProfilModelVue(
            Provider.of<AuthentificationModelVue>(context, listen: false),
          ),
          update: (context, auth, previous) => previous ?? ProfilModelVue(auth),
        ),
      ],
      child: MaterialApp(
        title: 'SAH Food',
        debugShowCheckedModeBanner: false,
        navigatorKey: ServiceNotifications.navigatorKey,
        theme: ThemeData(
          primaryColor: CouleursApp.bleuPrimaire,
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(
            seedColor: CouleursApp.bleuPrimaire,
            primary: CouleursApp.bleuPrimaire,
            secondary: CouleursApp.orangePrimaire,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: CouleursApp.bleuPrimaire,
            foregroundColor: CouleursApp.blanc,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.orangePrimaire,
              foregroundColor: CouleursApp.blanc,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: CouleursApp.gris),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: CouleursApp.bleuPrimaire),
            ),
            filled: true,
            fillColor: CouleursApp.blanc,
          ),
        ),
        home: const EcranSplash(),
      ),
    );
  }
}