/// Configuration Supabase pour SAH Food
class SupabaseConfig {

  static const String supabaseUrl = 'https://zqycudphoyconosopagi.supabase.co/';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpxeWN1ZHBob3ljb25vc29wYWdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkyMjE1MDksImV4cCI6MjA3NDc5NzUwOX0.TZXmJhCRD0LsrnpxLKdihcGPZu9Lc9rUk501McSDuK8';

  // Configuration des tables
  static const String tableUsers = 'utilisateurs';
  static const String tableMenus = 'menus';
  static const String tablePlats = 'plats';
  static const String tableCommandes = 'commandes';
  static const String tableAvis = 'avis';

  // Configuration du storage pour les images
  static const String bucketImages = 'plats-images';
}