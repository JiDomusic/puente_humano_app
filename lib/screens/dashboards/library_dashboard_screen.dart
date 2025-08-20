import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider_simple.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/user_service.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/star_rating.dart';

class LibraryDashboardScreen extends StatefulWidget {
  const LibraryDashboardScreen({super.key});

  @override
  State<LibraryDashboardScreen> createState() => _LibraryDashboardScreenState();
}

class _LibraryDashboardScreenState extends State<LibraryDashboardScreen> {
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
            title: Text('¡Hola ${user?.fullName ?? l10n.library}!'),
            backgroundColor: Colors.purple[600],
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
                  
                  // Acciones rápidas para bibliotecas
                  _buildQuickActions(l10n, isMobile),
                  SizedBox(height: isMobile ? 16 : 24),
                  
                  // Todos los usuarios y sus rutas
                  _buildAllUsersSection(l10n, isMobile),
                  SizedBox(height: isMobile ? 16 : 24),
                  
                  // Donaciones recibidas
                  _buildReceivedDonations(l10n, isMobile),
                  SizedBox(height: isMobile ? 16 : 24),
                  
                  // Donaciones en camino
                  _buildIncomingDonations(l10n, isMobile),
                  SizedBox(height: isMobile ? 16 : 24),
                  
                  // Estadísticas de la biblioteca
                  _buildLibraryStats(l10n, isMobile),
                  
                  // Espaciado final para navegación
                  const SizedBox(height: 100),
                ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: _buildLibraryNavigation(),
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      color: Colors.purple[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.local_library, color: Colors.purple[600], size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📖 Panel de Biblioteca',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recibe donaciones de libros y amplía tu colección para la comunidad',
                    style: TextStyle(color: Colors.purple[600]),
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
                          l10n.requestBooks,
                          Icons.request_page,
                          Colors.purple,
                          () => context.push('/requests/create'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionCard(
                          l10n.viewDonors,
                          Icons.volunteer_activism,
                          Colors.blue,
                          () => context.push('/users?role=donante'),
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
                      'Solicitar Libros',
                      Icons.request_page,
                      Colors.purple,
                      () => context.push('/requests/create'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      'Ver Donantes',
                      Icons.people,
                      Colors.blue,
                      () => context.push('/donors'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      'Mi Inventario',
                      Icons.inventory_2,
                      Colors.green,
                      () => context.push('/inventory'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      'Mi Perfil',
                      Icons.account_balance,
                      Colors.orange,
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
        
        // Donantes
        _buildUserRoleCard(
          title: '📚 ${l10n.viewDonors} (${_donantes.length})',
          users: _donantes.take(3).toList(),
          color: Colors.blue[600]!,
          onViewAll: () => context.push('/users?role=donante'),
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
        
        // Otras Bibliotecas
        _buildUserRoleCard(
          title: '📖 Otras ${l10n.viewLibraries} (${_bibliotecas.length})',
          users: _bibliotecas.take(3).toList(),
          color: Colors.purple[600]!,
          onViewAll: () => context.push('/users?role=biblioteca'),
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

  Widget _buildReceivedDonations(AppLocalizations l10n, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Donaciones Recibidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/donations/received'),
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Icon(Icons.check_circle, color: Colors.green[600]),
            ),
            title: const Text('Libros de Ciencias'),
            subtitle: const Text('De: María González • Entregado: 15 Ago'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('25 libros', style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.bold)),
                Text('12.5 kg', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.check_circle, color: Colors.blue[600]),
            ),
            title: const Text('Literatura Universal'),
            subtitle: const Text('De: Carlos Mendoza • Entregado: 18 Ago'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('15 libros', style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold)),
                Text('8.2 kg', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncomingDonations(AppLocalizations l10n, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Donaciones en Camino',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/donations/incoming'),
              child: const Text('Rastrear'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: isMobile ? 120 : 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            children: [
              _buildIncomingCard(
                'Enciclopedias',
                'Ana Pérez',
                'En ruta',
                '22 Ago',
                Colors.orange,
                isMobile,
              ),
              _buildIncomingCard(
                'Libros Infantiles',
                'Pedro Silva',
                'Recogido',
                '24 Ago',
                Colors.blue,
                isMobile,
              ),
              _buildIncomingCard(
                'Diccionarios',
                'Laura García',
                'Programado',
                '26 Ago',
                Colors.purple,
                isMobile,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncomingCard(String title, String donor, String status, String date, Color color, bool isMobile) {
    return Container(
      width: isMobile ? 140 : 160,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 8 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_shipping, color: color, size: isMobile ? 16 : 20),
                  SizedBox(width: isMobile ? 4 : 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: isMobile ? 10 : 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 4 : 8),
              Text(
                'Donante: $donor',
                style: TextStyle(
                  fontSize: isMobile ? 9 : 11, 
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Text(
                'Llegada: $date',
                style: TextStyle(
                  fontSize: isMobile ? 9 : 11, 
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: isMobile ? 4 : 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8, 
                  vertical: isMobile ? 2 : 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 9 : 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryStats(AppLocalizations l10n, bool isMobile) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas de la Biblioteca',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Recibidas', '47', Icons.inbox, Colors.green),
                ),
                Expanded(
                  child: _buildStatItem('Libros', '892', Icons.book, Colors.purple),
                ),
                Expanded(
                  child: _buildStatItem('Usuarios', '234', Icons.people, Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.73,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[600]!),
            ),
            const SizedBox(height: 8),
            Text(
              'Capacidad utilizada: 73% (2,340/3,200 libros)',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

  Widget _buildLibraryNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.purple[600],
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inbox),
          label: 'Donaciones',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2),
          label: 'Inventario',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance),
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
            context.push('/inventory');
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
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}