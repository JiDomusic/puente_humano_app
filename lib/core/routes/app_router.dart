import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider_simple.dart';
import '../../providers/admin_auth_provider.dart';
import '../../screens/welcome_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/admin_login_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/dashboards/donor_dashboard_screen.dart';
import '../../screens/dashboards/transporter_dashboard_screen.dart';
import '../../screens/dashboards/library_dashboard_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/trips/trips_screen.dart';
import '../../screens/trips/trip_detail_screen.dart';
import '../../screens/donations/donations_screen.dart';
import '../../screens/donations/donation_detail_screen.dart';
import '../../screens/shipments/shipment_detail_screen.dart';
import '../../screens/libraries/libraries_screen.dart';
import '../../screens/libraries/library_detail_screen.dart';
import '../../screens/maps/map_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/profile/public_profile_screen.dart';
import '../../screens/test_registration_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authProvider = context.read<SimpleAuthProvider>();
      final adminAuthProvider = context.read<AdminAuthProvider>();
      final isLoggedIn = authProvider.isLoggedIn;
      final isLoading = authProvider.isLoading;
      final isAdmin = authProvider.isAdmin;
      final isAdminLoggedIn = adminAuthProvider.isLoggedIn;

      // Si está cargando, mantener en la ruta actual
      if (isLoading) return null;

      // Rutas públicas (no requieren autenticación)
      final publicRoutes = ['/', '/login', '/register', '/admin-login', '/test'];
      final isPublicRoute = publicRoutes.contains(state.fullPath);

      // Si no está logueado y trata de acceder a ruta privada
      if (!isLoggedIn && !isAdminLoggedIn && !isPublicRoute) {
        return '/';
      }

      // NUEVA LÓGICA: Si es admin y está logueado, redirigir al panel admin
      if (isLoggedIn && isAdmin && !state.fullPath!.startsWith('/admin')) {
        print('🔄 Admin detectado, redirigiendo al panel admin');
        return '/admin';
      }

      // NUEVA LÓGICA: Si admin está logueado via AdminAuthProvider, ir al panel
      if (isAdminLoggedIn && !state.fullPath!.startsWith('/admin')) {
        print('🔄 AdminAuthProvider activo, redirigiendo al panel admin');
        return '/admin';
      }

      // Si está logueado como usuario normal y trata de acceder a ruta pública
      if (isLoggedIn && !isAdmin && isPublicRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Ruta de bienvenida
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Rutas de autenticación
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/admin-login',
        name: 'admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),

      // Pantalla de test (temporal para debugging)
      GoRoute(
        path: '/test',
        name: 'test',
        builder: (context, state) => const TestRegistrationScreen(),
      ),

      // Ruta principal (home)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Dashboards específicos por rol
      GoRoute(
        path: '/donor-dashboard',
        name: 'donor-dashboard',
        builder: (context, state) => const DonorDashboardScreen(),
      ),
      GoRoute(
        path: '/transporter-dashboard',
        name: 'transporter-dashboard',
        builder: (context, state) => const TransporterDashboardScreen(),
      ),
      GoRoute(
        path: '/library-dashboard',
        name: 'library-dashboard',
        builder: (context, state) => const LibraryDashboardScreen(),
      ),

      // Perfil de usuario
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Perfil público de usuario
      GoRoute(
        path: '/user/:userId',
        name: 'public-profile',
        builder: (context, state) => PublicProfileScreen(
          userId: state.pathParameters['userId']!,
        ),
      ),

      // Viajes
      GoRoute(
        path: '/trips',
        name: 'trips',
        builder: (context, state) => const TripsScreen(),
      ),
      GoRoute(
        path: '/trips/:tripId',
        name: 'trip-detail',
        builder: (context, state) => TripDetailScreen(
          tripId: state.pathParameters['tripId']!,
        ),
      ),

      // Donaciones
      GoRoute(
        path: '/donations',
        name: 'donations',
        builder: (context, state) => const DonationsScreen(),
      ),
      GoRoute(
        path: '/donations/:donationId',
        name: 'donation-detail',
        builder: (context, state) => DonationDetailScreen(
          donationId: state.pathParameters['donationId']!,
        ),
      ),

      // Envíos
      GoRoute(
        path: '/shipments/:shipmentId',
        name: 'shipment-detail',
        builder: (context, state) => ShipmentDetailScreen(
          shipmentId: state.pathParameters['shipmentId']!,
        ),
      ),

      // Bibliotecas
      GoRoute(
        path: '/libraries',
        name: 'libraries',
        builder: (context, state) => const LibrariesScreen(),
      ),
      GoRoute(
        path: '/libraries/:libraryId',
        name: 'library-detail',
        builder: (context, state) => LibraryDetailScreen(
          libraryId: state.pathParameters['libraryId']!,
        ),
      ),

      // Mapa
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) => const MapScreen(),
      ),

      // Rutas adicionales para funcionalidades del home
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Notificaciones')),
          body: const Center(
            child: Text('Notificaciones - En desarrollo'),
          ),
        ),
      ),
      GoRoute(
        path: '/activity',
        name: 'activity',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Actividad')),
          body: const Center(
            child: Text('Historial de actividad - En desarrollo'),
          ),
        ),
      ),
      GoRoute(
        path: '/explore',
        name: 'explore',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Explorar')),
          body: const Center(
            child: Text('Explorar - En desarrollo'),
          ),
        ),
      ),
      GoRoute(
        path: '/donations/create',
        name: 'donations-create',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Donar Libros')),
          body: const Center(
            child: Text('Crear donación - En desarrollo'),
          ),
        ),
      ),
      GoRoute(
        path: '/trips/create',
        name: 'trips-create',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Crear Viaje')),
          body: const Center(
            child: Text('Crear viaje - En desarrollo'),
          ),
        ),
      ),
      GoRoute(
        path: '/requests/create',
        name: 'requests-create',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Solicitar Libros')),
          body: const Center(
            child: Text('Solicitar libros - En desarrollo'),
          ),
        ),
      ),
      GoRoute(
        path: '/inventory',
        name: 'inventory',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Inventario')),
          body: const Center(
            child: Text('Inventario - En desarrollo'),
          ),
        ),
      ),
      GoRoute(
        path: '/donors',
        name: 'donors',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Donantes')),
          body: const Center(
            child: Text('Lista de donantes - En desarrollo'),
          ),
        ),
      ),
      GoRoute(
        path: '/transporters',
        name: 'transporters',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Transportistas')),
          body: const Center(
            child: Text('Lista de transportistas - En desarrollo'),
          ),
        ),
      ),
      GoRoute(
        path: '/donations/received',
        name: 'donations-received',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Donaciones Recibidas')),
          body: const Center(
            child: Text('Donaciones recibidas - En desarrollo'),
          ),
        ),
      ),

      // Panel de Administración (solo para administradores autorizados)
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) {
          final adminAuthProvider = context.read<AdminAuthProvider>();
          
          // Verificar si el administrador está logueado
          if (!adminAuthProvider.isLoggedIn) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Acceso Denegado'),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.security,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Acceso Restringido',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Debe iniciar sesión como administrador para acceder.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/admin-login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Ir al Login de Admin'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return const AdminDashboardScreen();
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Ruta: ${state.fullPath}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
}