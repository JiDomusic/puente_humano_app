import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('es'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  // Traducciones
  Map<String, String> get _localizedStrings => _translations[locale.languageCode] ?? _translations['es']!;

  // Métodos de acceso a traducciones
  String get appTitle => _localizedStrings['appTitle']!;
  String get appSlogan => _localizedStrings['appSlogan']!;
  String get welcome => _localizedStrings['welcome']!;
  String get login => _localizedStrings['login']!;
  String get register => _localizedStrings['register']!;
  String get email => _localizedStrings['email']!;
  String get password => _localizedStrings['password']!;
  String get confirmPassword => _localizedStrings['confirmPassword']!;
  String get fullName => _localizedStrings['fullName']!;
  String get phone => _localizedStrings['phone']!;
  String get city => _localizedStrings['city']!;
  String get country => _localizedStrings['country']!;
  String get role => _localizedStrings['role']!;
  String get language => _localizedStrings['language']!;
  String get spanish => _localizedStrings['spanish']!;
  String get english => _localizedStrings['english']!;
  String get donor => _localizedStrings['donor']!;
  String get transporter => _localizedStrings['transporter']!;
  String get library => _localizedStrings['library']!;
  String get home => _localizedStrings['home']!;
  String get myDonations => _localizedStrings['myDonations']!;
  String get myTrips => _localizedStrings['myTrips']!;
  String get profile => _localizedStrings['profile']!;
  String get settings => _localizedStrings['settings']!;
  String get logout => _localizedStrings['logout']!;
  String get save => _localizedStrings['save']!;
  String get cancel => _localizedStrings['cancel']!;
  String get edit => _localizedStrings['edit']!;
  String get personalInfo => _localizedStrings['personalInfo']!;
  String get location => _localizedStrings['location']!;
  String get statistics => _localizedStrings['statistics']!;
  String get preferences => _localizedStrings['preferences']!;
  String get ratingAverage => _localizedStrings['ratingAverage']!;
  String get totalRatings => _localizedStrings['totalRatings']!;
  String get memberSince => _localizedStrings['memberSince']!;
  String get notSpecified => _localizedStrings['notSpecified']!;
  String get noRatings => _localizedStrings['noRatings']!;
  String get profileUpdated => _localizedStrings['profileUpdated']!;

  // Diccionario de traducciones
  static const Map<String, Map<String, String>> _translations = {
    'es': {
      'appTitle': 'PuenteHumano',
      'appSlogan': 'Un puente humano para que los libros lleguen a donde más se necesitan',
      'welcome': 'Bienvenido',
      'login': 'Iniciar Sesión',
      'register': 'Registrarse',
      'email': 'Correo Electrónico',
      'password': 'Contraseña',
      'confirmPassword': 'Confirmar Contraseña',
      'fullName': 'Nombre Completo',
      'phone': 'Teléfono',
      'city': 'Ciudad',
      'country': 'País',
      'role': 'Rol',
      'language': 'Idioma',
      'spanish': 'Español',
      'english': 'English',
      'donor': 'Donante',
      'transporter': 'Transportista',
      'library': 'Biblioteca',
      'home': 'Inicio',
      'myDonations': 'Mis Donaciones',
      'myTrips': 'Mis Viajes',
      'profile': 'Mi Perfil',
      'settings': 'Configuración',
      'logout': 'Cerrar Sesión',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'edit': 'Editar',
      'personalInfo': 'Información Personal',
      'location': 'Ubicación',
      'statistics': 'Estadísticas',
      'preferences': 'Preferencias',
      'ratingAverage': 'Calificación Promedio',
      'totalRatings': 'Total de Calificaciones',
      'memberSince': 'Miembro desde',
      'notSpecified': 'No especificado',
      'noRatings': 'Sin calificaciones',
      'profileUpdated': 'Perfil actualizado exitosamente',
    },
    'en': {
      'appTitle': 'HumanBridge',
      'appSlogan': 'A human bridge so books reach where they\'re needed most',
      'welcome': 'Welcome',
      'login': 'Log In',
      'register': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'fullName': 'Full Name',
      'phone': 'Phone',
      'city': 'City',
      'country': 'Country',
      'role': 'Role',
      'language': 'Language',
      'spanish': 'Español',
      'english': 'English',
      'donor': 'Donor',
      'transporter': 'Transporter',
      'library': 'Library',
      'home': 'Home',
      'myDonations': 'My Donations',
      'myTrips': 'My Trips',
      'profile': 'My Profile',
      'settings': 'Settings',
      'logout': 'Log Out',
      'save': 'Save',
      'cancel': 'Cancel',
      'edit': 'Edit',
      'personalInfo': 'Personal Information',
      'location': 'Location',
      'statistics': 'Statistics',
      'preferences': 'Preferences',
      'ratingAverage': 'Average Rating',
      'totalRatings': 'Total Ratings',
      'memberSince': 'Member since',
      'notSpecified': 'Not specified',
      'noRatings': 'No ratings',
      'profileUpdated': 'Profile updated successfully',
    },
  };
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}