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
  
  // Nuevas traducciones para usuarios
  String get users => _localizedStrings['users']!;
  String get usersList => _localizedStrings['usersList']!;
  String get searchUsers => _localizedStrings['searchUsers']!;
  String get sortBy => _localizedStrings['sortBy']!;
  String get sortByName => _localizedStrings['sortByName']!;
  String get sortByRating => _localizedStrings['sortByRating']!;
  String get sortByDate => _localizedStrings['sortByDate']!;
  String get mostRecent => _localizedStrings['mostRecent']!;
  String get backToHome => _localizedStrings['backToHome']!;
  String get logoutConfirm => _localizedStrings['logoutConfirm']!;
  String get logoutQuestion => _localizedStrings['logoutQuestion']!;
  String get quickActions => _localizedStrings['quickActions']!;
  String get connectWithUsers => _localizedStrings['connectWithUsers']!;
  String get allUsers => _localizedStrings['allUsers']!;
  String get viewDonors => _localizedStrings['viewDonors']!;
  String get viewTransporters => _localizedStrings['viewTransporters']!;
  String get viewLibraries => _localizedStrings['viewLibraries']!;
  String get donorInteractionDesc => _localizedStrings['donorInteractionDesc']!;
  String get transporterInteractionDesc => _localizedStrings['transporterInteractionDesc']!;
  String get libraryInteractionDesc => _localizedStrings['libraryInteractionDesc']!;
  String get noUsersFound => _localizedStrings['noUsersFound']!;
  String get donateBooks => _localizedStrings['donateBooks']!;
  String get createTrip => _localizedStrings['createTrip']!;
  String get requestBooks => _localizedStrings['requestBooks']!;
  String get myInventory => _localizedStrings['myInventory']!;
  String get receivedDonations => _localizedStrings['receivedDonations']!;
  String get routeMap => _localizedStrings['routeMap']!;
  
  // Notificaciones
  String get notifications => _localizedStrings['notifications']!;
  String get noNotifications => _localizedStrings['noNotifications']!;
  String get markAsRead => _localizedStrings['markAsRead']!;
  String get markAllAsRead => _localizedStrings['markAllAsRead']!;
  String get delete => _localizedStrings['delete']!;

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
      'users': 'Usuarios',
      'usersList': 'Usuarios de PuenteHumano',
      'searchUsers': 'Buscar por nombre, ciudad o país...',
      'sortBy': 'Ordenar por',
      'sortByName': 'Nombre',
      'sortByRating': 'Calificación',
      'sortByDate': 'Más recientes',
      'mostRecent': 'Más recientes',
      'backToHome': 'Volver al inicio',
      'logoutConfirm': 'Cerrar Sesión',
      'logoutQuestion': '¿Estás seguro de que deseas cerrar sesión?',
      'quickActions': 'Acciones Rápidas',
      'connectWithUsers': 'Conecta con otros usuarios',
      'allUsers': 'Todos los Usuarios',
      'viewDonors': 'Ver Donantes',
      'viewTransporters': 'Ver Transportistas',
      'viewLibraries': 'Ver Bibliotecas',
      'donorInteractionDesc': 'Como donante, puedes conectar con bibliotecas que necesitan libros y transportistas que pueden llevarlos.',
      'transporterInteractionDesc': 'Como transportista, puedes conectar donantes con bibliotecas, llevando libros en tus viajes.',
      'libraryInteractionDesc': 'Como biblioteca, puedes conectar con donantes para solicitar libros y transportistas para recibirlos.',
      'noUsersFound': 'No hay usuarios registrados',
      'donateBooks': 'Donar Libros',
      'createTrip': 'Crear Viaje',
      'requestBooks': 'Solicitar Libros',
      'myInventory': 'Mi Inventario',
      'receivedDonations': 'Donaciones Recibidas',
      'routeMap': 'Mapa de Rutas',
      'notifications': 'Notificaciones',
      'noNotifications': 'No tienes notificaciones',
      'markAsRead': 'Marcar como leída',
      'markAllAsRead': 'Marcar todas como leídas',
      'delete': 'Eliminar',
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
      'users': 'Users',
      'usersList': 'HumanBridge Users',
      'searchUsers': 'Search by name, city or country...',
      'sortBy': 'Sort by',
      'sortByName': 'Name',
      'sortByRating': 'Rating',
      'sortByDate': 'Most recent',
      'mostRecent': 'Most recent',
      'backToHome': 'Back to home',
      'logoutConfirm': 'Log Out',
      'logoutQuestion': 'Are you sure you want to log out?',
      'quickActions': 'Quick Actions',
      'connectWithUsers': 'Connect with other users',
      'allUsers': 'All Users',
      'viewDonors': 'View Donors',
      'viewTransporters': 'View Transporters',
      'viewLibraries': 'View Libraries',
      'donorInteractionDesc': 'As a donor, you can connect with libraries that need books and transporters who can deliver them.',
      'transporterInteractionDesc': 'As a transporter, you can connect donors with libraries, carrying books on your trips.',
      'libraryInteractionDesc': 'As a library, you can connect with donors to request books and transporters to receive them.',
      'noUsersFound': 'No registered users',
      'donateBooks': 'Donate Books',
      'createTrip': 'Create Trip',
      'requestBooks': 'Request Books',
      'myInventory': 'My Inventory',
      'receivedDonations': 'Received Donations',
      'routeMap': 'Route Map',
      'notifications': 'Notifications',
      'noNotifications': 'You have no notifications',
      'markAsRead': 'Mark as read',
      'markAllAsRead': 'Mark all as read',
      'delete': 'Delete',
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