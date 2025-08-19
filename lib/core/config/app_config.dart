class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://svnuaodvrpeuaenrcruc.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN2bnVhb2R2cnBldWFlbnJjcnVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1NDU0MDIsImV4cCI6MjA3MTEyMTQwMn0.aKPREuJ9DoxMS2I832sQ_r0VGUhJMjxadTDgiYv2-Ww';
  
  // App Configuration
  static const String appName = 'PuenteHumano';
  static const String appSlogan = 'Un puente humano para que los libros lleguen a donde más se necesitan';
  
  // Features
  static const bool enableMaps = true;
  static const bool enableChat = true;
  static const bool enableNotifications = true;
  
  // Colors - Simple Black & White Theme
  static const int primaryColorValue = 0xFF000000;
  static const int secondaryColorValue = 0xFF424242;
  static const int accentColorValue = 0xFF757575;
}