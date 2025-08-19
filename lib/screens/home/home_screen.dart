import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/models/user_profile.dart';
import '../../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          body: _buildBody(user),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              // Si hace click en el botón Admin (último índice cuando isAdmin = true)
              if (authProvider.isAdmin && index == _getMaxIndex(user.role)) {
                context.go('/admin');
              }
            },
            userRole: user.role,
            isAdmin: authProvider.isAdmin,
          ),
        );
      },
    );
  }

  Widget _buildBody(UserProfile user) {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard(user);
      case 1:
        return _buildSecondaryView(user);
      case 2:
        return _buildMapView();
      case 3:
        return _buildProfileView(user);
      case 4:
        // El caso Admin se maneja en onTap navegando a '/admin'
        // pero por si acaso, volvemos al dashboard
        return _buildDashboard(user);
      default:
        return _buildDashboard(user);
    }
  }

  Widget _buildDashboard(UserProfile user) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          actions: [
            // Botón de administrador (solo para administradores autorizados)
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                print('🔍 AppBar Admin check: isAdmin=${authProvider.isAdmin}');
                
                if (authProvider.isAdmin) {
                  print('✅ Mostrando botón admin en AppBar');
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        print('🔴 Botón Admin presionado');
                        context.go('/admin');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.admin_panel_settings, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'ADMIN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                print('❌ No es admin, no se muestra botón');
                return const SizedBox.shrink();
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text('Hola, ${user.fullName.split(' ').first}'),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      _getRoleIcon(user.role),
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.role.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildWelcomeCard(user),
              const SizedBox(height: 16),
              
              // DEBUG INFO
              Consumer<AuthProvider>(
                builder: (context, debugAuthProvider, child) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DEBUG INFO:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Email: ${user.email}'),
                        Text('IsAdmin: ${debugAuthProvider.isAdmin}'),
                        Text('User ID: ${user.id}'),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Botón de Admin prominente
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  print('🔍 Verificando admin: isAdmin=${authProvider.isAdmin}, email=${authProvider.currentUser?.email}');
                  
                  if (authProvider.isAdmin) {
                    print('✅ Mostrando botón de admin');
                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton.icon(
                            onPressed: () => context.go('/admin'),
                            icon: const Icon(
                              Icons.admin_panel_settings,
                              size: 24,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'ACCEDER AL PANEL DE ADMINISTRACIÓN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              _buildQuickActions(user),
              const SizedBox(height: 16),
              _buildStatsCard(user),
              const SizedBox(height: 16),
              _buildRecentActivity(user),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(UserProfile user) {
    String message;
    String action;
    VoidCallback onTap;

    switch (user.role) {
      case UserRole.donante:
        message = '¿Tienes libros para donar? Encuentra transportistas que viajen hacia bibliotecas.';
        action = 'Ver viajes disponibles';
        onTap = () => context.push('/trips');
        break;
      case UserRole.transportista:
        message = '¿Viajas próximamente? Ayuda transportando libros hacia bibliotecas.';
        action = 'Ver donaciones pendientes';
        onTap = () => context.push('/donations');
        break;
      case UserRole.biblioteca:
        message = 'Gestiona las donaciones que llegan a tu biblioteca y confirma entregas.';
        action = 'Ver bibliotecas';
        onTap = () => context.push('/libraries');
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenido a PuenteHumano!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                child: Text(action),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(UserProfile user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones rápidas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: _getQuickActions(user),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getQuickActions(UserProfile user) {
    switch (user.role) {
      case UserRole.donante:
        return [
          _buildQuickAction(
            Icons.add_box,
            'Donar libro',
            () => _showDonateDialog(),
          ),
          _buildQuickAction(
            Icons.local_shipping,
            'Mis donaciones',
            () => context.push('/donations'),
          ),
          _buildQuickAction(
            Icons.map,
            'Ver mapa',
            () => context.push('/map'),
          ),
        ];
      case UserRole.transportista:
        return [
          _buildQuickAction(
            Icons.add_road,
            'Publicar viaje',
            () => _showTripDialog(),
          ),
          _buildQuickAction(
            Icons.inbox,
            'Mis envíos',
            () => context.push('/shipments'),
          ),
          _buildQuickAction(
            Icons.star,
            'Mis calificaciones',
            () => context.push('/profile'),
          ),
        ];
      case UserRole.biblioteca:
        return [
          _buildQuickAction(
            Icons.qr_code_scanner,
            'Confirmar entrega',
            () => _showScanDialog(),
          ),
          _buildQuickAction(
            Icons.library_books,
            'Libros recibidos',
            () => context.push('/libraries'),
          ),
          _buildQuickAction(
            Icons.notifications,
            'Notificaciones',
            () => context.push('/notifications'),
          ),
        ];
    }
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(UserProfile user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStat('Calificación', '${user.averageRating?.toStringAsFixed(1) ?? "0.0"} ⭐'),
                _buildStat('Actividad', '${user.ratingsCount} envíos'),
                _buildStat('Desde', '${user.createdAt.year}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(UserProfile user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Actividad reciente',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Ver toda la actividad
                  },
                  child: const Text('Ver todo'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              Icons.book_online,
              'Bienvenido a PuenteHumano',
              'Completa tu perfil para empezar',
              DateTime.now(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String subtitle, DateTime date) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        '${date.day}/${date.month}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSecondaryView(UserProfile user) {
    switch (user.role) {
      case UserRole.donante:
        return _buildDonationsView();
      case UserRole.transportista:
        return _buildTripsView();
      case UserRole.biblioteca:
        return _buildLibrariesView();
    }
  }

  Widget _buildDonationsView() {
    return const Center(
      child: Text('Mis Donaciones - En desarrollo'),
    );
  }

  Widget _buildTripsView() {
    return const Center(
      child: Text('Mis Viajes - En desarrollo'),
    );
  }

  Widget _buildLibrariesView() {
    return const Center(
      child: Text('Gestión Biblioteca - En desarrollo'),
    );
  }

  Widget _buildMapView() {
    return const Center(
      child: Text('Mapa - En desarrollo'),
    );
  }

  Widget _buildProfileView(UserProfile user) {
    return const Center(
      child: Text('Perfil - En desarrollo'),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.donante:
        return Icons.volunteer_activism;
      case UserRole.transportista:
        return Icons.local_shipping;
      case UserRole.biblioteca:
        return Icons.library_books;
    }
  }

  void _showDonateDialog() {
    // TODO: Implementar diálogo de donación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de donación en desarrollo')),
    );
  }

  void _showTripDialog() {
    // TODO: Implementar diálogo de viaje
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de viaje en desarrollo')),
    );
  }

  void _showScanDialog() {
    // TODO: Implementar escáner QR
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Escáner QR en desarrollo')),
    );
  }

  int _getMaxIndex(UserRole role) {
    // Los roles base tienen 4 tabs (0-3), si es admin agrega uno más (4)
    return 4; // Admin siempre será el índice 4
  }
}