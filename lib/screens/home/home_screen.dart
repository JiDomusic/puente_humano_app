import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider_simple.dart';
import '../../core/models/user_profile.dart';
import '../../utils/app_localizations.dart';

/// 📚 PuenteHumano Home Screen
/// "Un puente humano para que los libros lleguen a donde más se necesitan"
/// 
/// Conecta donantes de libros con bibliotecas comunitarias, 
/// usando personas viajeras como canal humano para transportar los libros.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleAuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final isLoading = authProvider.isLoading;
        
        if (isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('Usuario no encontrado'),
            ),
          );
        }

        return _buildResponsiveHome(user);
      },
    );
  }

  Widget _buildResponsiveHome(UserProfile user) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      backgroundColor: const Color(0xE6D282),
      appBar: AppBar(
        title: Text(
          'Hola, ${user.fullName.split(' ').first}!',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _getRoleColor(user.role),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Simular refresh
            await Future.delayed(const Duration(seconds: 1));
          },
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjeta de bienvenida
                _buildWelcomeCard(user, isMobile),
                SizedBox(height: isMobile ? 16 : 24),
                
                // Acciones rápidas por rol
                _buildQuickActions(user, isMobile),
                SizedBox(height: isMobile ? 16 : 24),
                
                // Interacciones entre roles
                _buildRoleInteractions(user, isMobile),
                SizedBox(height: isMobile ? 16 : 24),
                
                // Estadísticas del usuario
                _buildUserStats(user, isMobile),
                SizedBox(height: isMobile ? 16 : 24),
                
                // Actividad reciente
                _buildRecentActivity(user, isMobile),
                SizedBox(height: isMobile ? 16 : 24),
                
                // Información del ecosistema
                _buildEcosystemInfo(isMobile),
                
                // Espaciado final para navegación
                const SizedBox(height: 100),
              ],
            ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(user),
    );
  }

  Widget _buildWelcomeCard(UserProfile user, bool isMobile) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getRoleColor(user.role),
              _getRoleColor(user.role).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getRoleIcon(user.role),
                size: isMobile ? 32 : 40,
                color: Colors.white,
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getRoleWelcome(user.role),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRoleDescription(user.role),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(UserProfile user, bool isMobile) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 18 : 22,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        _buildActionGrid(user, isMobile),
      ],
    );
  }

  Widget _buildRoleInteractions(UserProfile user, bool isMobile) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_alt, color: Colors.indigo[600], size: isMobile ? 24 : 28),
                SizedBox(width: isMobile ? 8 : 12),
                Text(
                  l10n.connectWithUsers,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 16 : 18,
                    color: Colors.indigo[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              _getRoleInteractionDescription(user.role),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isMobile ? 12 : 14,
              ),
            ),
            SizedBox(height: isMobile ? 16 : 20),
            _buildInteractionButtons(user.role, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionButtons(UserRole userRole, bool isMobile) {
    final buttons = _getInteractionButtons(userRole);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.5,
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        final button = buttons[index];
        return ElevatedButton.icon(
          onPressed: button['onTap'],
          icon: Icon(button['icon'], size: isMobile ? 16 : 18),
          label: Text(
            button['title'],
            style: TextStyle(fontSize: isMobile ? 11 : 13),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: button['color'].withOpacity(0.1),
            foregroundColor: button['color'],
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: button['color'].withOpacity(0.3)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionGrid(UserProfile user, bool isMobile) {
    List<Map<String, dynamic>> actions = _getActionsForRole(user.role);
    
    if (isMobile) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.2,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return _buildActionCard(
            action['title'],
            action['icon'],
            action['color'],
            action['onTap'],
            isMobile,
          );
        },
      );
    } else {
      return Row(
        children: actions.map((action) => 
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildActionCard(
                action['title'],
                action['icon'],
                action['color'],
                action['onTap'],
                isMobile,
              ),
            ),
          ),
        ).toList(),
      );
    }
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap, bool isMobile) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: isMobile ? 24 : 32),
            SizedBox(height: isMobile ? 6 : 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 11 : 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStats(UserProfile user, bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu Progreso',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 16 : 18,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Puntuación',
                    '${user.averageRating?.toStringAsFixed(1) ?? "5.0"} ⭐',
                    Icons.star,
                    Colors.amber,
                    isMobile,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Actividades',
                    '${user.ratingsCount}',
                    Icons.trending_up,
                    Colors.green,
                    isMobile,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Miembro desde',
                    '${user.createdAt.year}',
                    Icons.calendar_today,
                    Colors.blue,
                    isMobile,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, bool isMobile) {
    return Column(
      children: [
        Icon(icon, color: color, size: isMobile ? 24 : 28),
        SizedBox(height: isMobile ? 4 : 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 16 : 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isMobile ? 10 : 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentActivity(UserProfile user, bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Actividad Reciente',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 16 : 18,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/activity'),
                  child: Text(
                    'Ver todo',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 8 : 12),
            _buildActivityItem(
              'Bienvenido a PuenteHumano',
              'Tu cuenta ha sido creada exitosamente',
              Icons.celebration,
              Colors.green,
              DateTime.now(),
              isMobile,
            ),
            _buildActivityItem(
              'Rol asignado: ${_getRoleDisplayName(user.role)}',
              'Ya puedes empezar a usar la plataforma',
              _getRoleIcon(user.role),
              _getRoleColor(user.role),
              DateTime.now().subtract(const Duration(minutes: 5)),
              isMobile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon, Color color, DateTime date, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: isMobile ? 16 : 20,
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isMobile ? 10 : 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${date.day}/${date.month}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: isMobile ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcosystemInfo(bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.purple[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: isMobile ? 24 : 28,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    'Ecosistema PuenteHumano',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              '"Un puente humano para que los libros lleguen a donde más se necesitan"',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isMobile ? 12 : 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEcosystemStat('Donantes', '1,234', Icons.volunteer_activism, isMobile),
                _buildEcosystemStat('Transportistas', '567', Icons.local_shipping, isMobile),
                _buildEcosystemStat('Bibliotecas', '89', Icons.library_books, isMobile),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEcosystemStat(String label, String value, IconData icon, bool isMobile) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: isMobile ? 20 : 24,
        ),
        SizedBox(height: isMobile ? 4 : 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: isMobile ? 10 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(UserProfile user) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _getRoleColor(user.role),
      unselectedItemColor: Colors.grey,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(_getRoleIcon(user.role)),
          label: 'Mi Dashboard',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Explorar',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Ya estamos en home
            break;
          case 1:
            _navigateToDashboard(user.role);
            break;
          case 2:
            context.push('/explore');
            break;
          case 3:
            context.push('/profile');
            break;
        }
      },
    );
  }

  // Métodos auxiliares
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.donante:
        return Colors.blue[600]!;
      case UserRole.transportista:
        return Colors.green[600]!;
      case UserRole.biblioteca:
        return Colors.purple[600]!;
    }
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

  String _getRoleWelcome(UserRole role) {
    switch (role) {
      case UserRole.donante:
        return '📚 Panel del Donante';
      case UserRole.transportista:
        return '🚛 Panel del Transportista';
      case UserRole.biblioteca:
        return '📖 Panel de Biblioteca';
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.donante:
        return 'Comparte libros con quienes los necesitan';
      case UserRole.transportista:
        return 'Conecta donantes con bibliotecas';
      case UserRole.biblioteca:
        return 'Recibe donaciones para tu comunidad';
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.donante:
        return 'Donante';
      case UserRole.transportista:
        return 'Transportista';
      case UserRole.biblioteca:
        return 'Biblioteca';
    }
  }

  List<Map<String, dynamic>> _getActionsForRole(UserRole role) {
    final l10n = AppLocalizations.of(context);
    switch (role) {
      case UserRole.donante:
        return [
          {
            'title': l10n.donateBooks,
            'icon': Icons.add_circle,
            'color': Colors.green,
            'onTap': () => context.push('/donations/create'),
          },
          {
            'title': l10n.viewLibraries,
            'icon': Icons.library_books,
            'color': Colors.purple,
            'onTap': () => context.push('/users?role=biblioteca'),
          },
          {
            'title': l10n.viewTransporters,
            'icon': Icons.local_shipping,
            'color': Colors.green,
            'onTap': () => context.push('/users?role=transportista'),
          },
          {
            'title': l10n.myDonations,
            'icon': Icons.history,
            'color': Colors.blue,
            'onTap': () => context.push('/donations'),
          },
          {
            'title': l10n.users,
            'icon': Icons.people,
            'color': Colors.teal,
            'onTap': () => context.push('/users'),
          },
        ];
      case UserRole.transportista:
        return [
          {
            'title': l10n.createTrip,
            'icon': Icons.add_road,
            'color': Colors.green,
            'onTap': () => context.push('/trips/create'),
          },
          {
            'title': l10n.viewDonors,
            'icon': Icons.volunteer_activism,
            'color': Colors.blue,
            'onTap': () => context.push('/users?role=donante'),
          },
          {
            'title': l10n.routeMap,
            'icon': Icons.map,
            'color': Colors.purple,
            'onTap': () => context.push('/map'),
          },
          {
            'title': l10n.myTrips,
            'icon': Icons.history,
            'color': Colors.orange,
            'onTap': () => context.push('/trips'),
          },
          {
            'title': l10n.users,
            'icon': Icons.people,
            'color': Colors.teal,
            'onTap': () => context.push('/users'),
          },
        ];
      case UserRole.biblioteca:
        return [
          {
            'title': l10n.requestBooks,
            'icon': Icons.request_page,
            'color': Colors.purple,
            'onTap': () => context.push('/requests/create'),
          },
          {
            'title': l10n.viewDonors,
            'icon': Icons.volunteer_activism,
            'color': Colors.blue,
            'onTap': () => context.push('/users?role=donante'),
          },
          {
            'title': l10n.viewTransporters,
            'icon': Icons.local_shipping,
            'color': Colors.green,
            'onTap': () => context.push('/users?role=transportista'),
          },
          {
            'title': l10n.myInventory,
            'icon': Icons.inventory_2,
            'color': Colors.green,
            'onTap': () => context.push('/inventory'),
          },
          {
            'title': l10n.receivedDonations,
            'icon': Icons.inbox,
            'color': Colors.orange,
            'onTap': () => context.push('/donations/received'),
          },
          {
            'title': l10n.users,
            'icon': Icons.people,
            'color': Colors.teal,
            'onTap': () => context.push('/users'),
          },
        ];
    }
  }

  void _navigateToDashboard(UserRole role) {
    switch (role) {
      case UserRole.donante:
        context.push('/donor-dashboard');
        break;
      case UserRole.transportista:
        context.push('/transporter-dashboard');
        break;
      case UserRole.biblioteca:
        context.push('/library-dashboard');
        break;
    }
  }

  String _getRoleInteractionDescription(UserRole role) {
    final l10n = AppLocalizations.of(context);
    switch (role) {
      case UserRole.donante:
        return l10n.donorInteractionDesc;
      case UserRole.transportista:
        return l10n.transporterInteractionDesc;
      case UserRole.biblioteca:
        return l10n.libraryInteractionDesc;
    }
  }

  List<Map<String, dynamic>> _getInteractionButtons(UserRole role) {
    final l10n = AppLocalizations.of(context);
    switch (role) {
      case UserRole.donante:
        return [
          {
            'title': l10n.viewLibraries,
            'icon': Icons.library_books,
            'color': Colors.purple[600]!,
            'onTap': () => context.push('/users?role=biblioteca'),
          },
          {
            'title': l10n.viewTransporters,
            'icon': Icons.local_shipping,
            'color': Colors.green[600]!,
            'onTap': () => context.push('/users?role=transportista'),
          },
          {
            'title': l10n.allUsers,
            'icon': Icons.people,
            'color': Colors.indigo[600]!,
            'onTap': () => context.push('/users'),
          },
        ];
      case UserRole.transportista:
        return [
          {
            'title': l10n.viewDonors,
            'icon': Icons.volunteer_activism,
            'color': Colors.blue[600]!,
            'onTap': () => context.push('/users?role=donante'),
          },
          {
            'title': l10n.viewLibraries,
            'icon': Icons.library_books,
            'color': Colors.purple[600]!,
            'onTap': () => context.push('/users?role=biblioteca'),
          },
          {
            'title': l10n.allUsers,
            'icon': Icons.people,
            'color': Colors.indigo[600]!,
            'onTap': () => context.push('/users'),
          },
        ];
      case UserRole.biblioteca:
        return [
          {
            'title': l10n.viewDonors,
            'icon': Icons.volunteer_activism,
            'color': Colors.blue[600]!,
            'onTap': () => context.push('/users?role=donante'),
          },
          {
            'title': l10n.viewTransporters,
            'icon': Icons.local_shipping,
            'color': Colors.green[600]!,
            'onTap': () => context.push('/users?role=transportista'),
          },
          {
            'title': l10n.allUsers,
            'icon': Icons.people,
            'color': Colors.indigo[600]!,
            'onTap': () => context.push('/users'),
          },
        ];
    }
  }
}