import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider_simple.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/user_service.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/star_rating.dart';

class DonorDashboardScreen extends StatefulWidget {
  const DonorDashboardScreen({super.key});

  @override
  State<DonorDashboardScreen> createState() => _DonorDashboardScreenState();
}

class _DonorDashboardScreenState extends State<DonorDashboardScreen> {
  final UserService _userService = UserService();
  List<UserProfile> _donantes = [];
  List<UserProfile> _bibliotecas = [];
  List<UserProfile> _transportistas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    try {
      final futures = await Future.wait([
        _userService.getUsersByRole(UserRole.donante),
        _userService.getUsersByRole(UserRole.biblioteca),
        _userService.getUsersByRole(UserRole.transportista),
      ]);
      
      setState(() {
        _donantes = futures[0];
        _bibliotecas = futures[1];
        _transportistas = futures[2];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleAuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final l10n = AppLocalizations.of(context);
        final isMobile = MediaQuery.of(context).size.width < 600;
        
        return Scaffold(
          appBar: AppBar(
            title: Text('¡Hola ${user?.fullName ?? l10n.donor}!'),
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => context.go('/home'),
                tooltip: l10n.backToHome,
              ),
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => context.push('/notifications'),
                tooltip: l10n.notifications,
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _showLogoutDialog(context),
                tooltip: l10n.logout,
              ),
            ],
          ),
          body: SafeArea(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Bienvenida personalizada
                  _buildWelcomeCard(),
                  SizedBox(height: MediaQuery.of(context).size.width < 600 ? 16 : 24),
                  
                  // Acciones rápidas para donantes
                  _buildQuickActions(l10n, isMobile),
                  SizedBox(height: isMobile ? 16 : 24),
                  
                  // Todos los usuarios y sus rutas
                  _buildAllUsersSection(l10n, isMobile),
                  SizedBox(height: isMobile ? 16 : 24),
                  
                  // Mis donaciones
                  _buildMyDonations(l10n, isMobile),
                  SizedBox(height: isMobile ? 16 : 24),
                  
                  // Bibliotecas cercanas
                  _buildNearbyLibraries(l10n, isMobile),
                  SizedBox(height: isMobile ? 16 : 24),
                  
                  // Estadísticas personales
                  _buildPersonalStats(l10n, isMobile),
                  
                  // Espaciado final para navegación
                  const SizedBox(height: 100),
                ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: _buildDonorNavigation(),
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.volunteer_activism, color: Colors.blue[600], size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📚 Panel del Donante',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Comparte libros y conocimiento con bibliotecas que lo necesitan',
                    style: TextStyle(color: Colors.blue[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(AppLocalizations l10n, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          l10n.donateBooks,
                          Icons.add_circle,
                          Colors.green,
                          () => context.push('/donations/create'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionCard(
                          l10n.viewLibraries,
                          Icons.library_books,
                          Colors.purple,
                          () => context.push('/users?role=biblioteca'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          l10n.viewTransporters,
                          Icons.local_shipping,
                          Colors.green,
                          () => context.push('/users?role=transportista'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionCard(
                          l10n.users,
                          Icons.people,
                          Colors.teal,
                          () => context.push('/users'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      'Donar Libros',
                      Icons.add_circle,
                      Colors.green,
                      () => context.push('/donations/create'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      'Buscar Bibliotecas',
                      Icons.search,
                      Colors.orange,
                      () => context.push('/libraries'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      'Ver Transportistas',
                      Icons.local_shipping,
                      Colors.purple,
                      () => context.push('/trips'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      'Mi Perfil',
                      Icons.person,
                      Colors.blue,
                      () => context.push('/profile'),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = MediaQuery.of(context).size.width < 600;
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: isMobile ? 24 : 32),
                SizedBox(height: isMobile ? 4 : 8),
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 10 : 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllUsersSection(AppLocalizations l10n, bool isMobile) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🌍 Red de Usuarios y Rutas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Bibliotecas
        _buildUserRoleCard(
          title: '📖 ${l10n.viewLibraries} (${_bibliotecas.length})',
          users: _bibliotecas.take(3).toList(),
          color: Colors.purple[600]!,
          onViewAll: () => context.push('/users?role=biblioteca'),
          l10n: l10n,
          isMobile: isMobile,
        ),
        const SizedBox(height: 12),
        
        // Transportistas
        _buildUserRoleCard(
          title: '🚛 ${l10n.viewTransporters} (${_transportistas.length})',
          users: _transportistas.take(3).toList(),
          color: Colors.green[600]!,
          onViewAll: () => context.push('/users?role=transportista'),
          l10n: l10n,
          isMobile: isMobile,
        ),
        const SizedBox(height: 12),
        
        // Otros Donantes
        _buildUserRoleCard(
          title: '📚 Otros ${l10n.viewDonors} (${_donantes.length})',
          users: _donantes.take(3).toList(),
          color: Colors.blue[600]!,
          onViewAll: () => context.push('/users?role=donante'),
          l10n: l10n,
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _buildUserRoleCard({
    required String title,
    required List<UserProfile> users,
    required Color color,
    required VoidCallback onViewAll,
    required AppLocalizations l10n,
    required bool isMobile,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 14 : 16,
                      color: color,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    'Ver todos',
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 8 : 12),
            if (users.isEmpty)
              Text(
                'No hay usuarios registrados en este rol',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 12 : 14,
                ),
              )
            else
              ...users.map((user) => _buildUserRouteItem(user, color, isMobile)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRouteItem(UserProfile user, Color color, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 6 : 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: isMobile ? 14 : 18,
            backgroundColor: color.withOpacity(0.1),
            child: user.photo != null
                ? ClipOval(child: Image.network(user.photo!, width: isMobile ? 28 : 36, height: isMobile ? 28 : 36, fit: BoxFit.cover))
                : Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14),
                  ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.location_on, size: isMobile ? 10 : 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${user.city}, ${user.country}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isMobile ? 10 : 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          StarRating(
            rating: user.averageRating ?? 5.0,
            size: isMobile ? 10 : 12,
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            size: isMobile ? 10 : 12,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildMyDonations(AppLocalizations l10n, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mis Donaciones',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/donations'),
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Icon(Icons.book, color: Colors.green[600]),
            ),
            title: const Text('Libros de Matemáticas'),
            subtitle: const Text('Estado: En camino • Destino: Biblioteca Sol'),
            trailing: Chip(
              label: const Text('Activa'),
              backgroundColor: Colors.green[100],
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.book, color: Colors.blue[600]),
            ),
            title: const Text('Novelas Clásicas'),
            subtitle: const Text('Estado: Pendiente • Esperando transportista'),
            trailing: Chip(
              label: const Text('Pendiente'),
              backgroundColor: Colors.orange[100],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyLibraries(AppLocalizations l10n, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bibliotecas Cercanas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/libraries'),
              child: const Text('Ver mapa'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: isMobile ? 100 : 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            children: [
              _buildLibraryCard('Biblioteca Sol', 'Mendoza', '2.3 km', Icons.school, isMobile),
              _buildLibraryCard('Centro Norte', 'Mar del Plata', '5.1 km', Icons.local_library, isMobile),
              _buildLibraryCard('Escuela Esperanza', 'Salta', '8.7 km', Icons.school, isMobile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLibraryCard(String name, String location, String distance, IconData icon, bool isMobile) {
    return Container(
      width: isMobile ? 120 : 140,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 8 : 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.purple[600], size: isMobile ? 20 : 24),
              SizedBox(height: isMobile ? 4 : 8),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: isMobile ? 10 : 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                location,
                style: TextStyle(
                  color: Colors.grey[600], 
                  fontSize: isMobile ? 8 : 10,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                distance,
                style: TextStyle(
                  color: Colors.green[600], 
                  fontSize: isMobile ? 8 : 10, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalStats(AppLocalizations l10n, bool isMobile) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mis Estadísticas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Donaciones', '12', Icons.volunteer_activism, Colors.blue),
                ),
                Expanded(
                  child: _buildStatItem('Libros', '156', Icons.book, Colors.green),
                ),
                Expanded(
                  child: _buildStatItem('Rating', '4.8', Icons.star, Colors.amber),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDonorNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue[600],
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.volunteer_activism),
          label: 'Donaciones',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_library),
          label: 'Bibliotecas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home'); // Ir al home principal con todos los usuarios
            break;
          case 1:
            context.push('/donations');
            break;
          case 2:
            context.push('/libraries');
            break;
          case 3:
            context.push('/profile');
            break;
        }
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SimpleAuthProvider>().signOut();
              context.go('/');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}