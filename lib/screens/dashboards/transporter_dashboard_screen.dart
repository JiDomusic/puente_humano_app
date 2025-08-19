import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class TransporterDashboardScreen extends StatefulWidget {
  const TransporterDashboardScreen({super.key});

  @override
  State<TransporterDashboardScreen> createState() => _TransporterDashboardScreenState();
}

class _TransporterDashboardScreenState extends State<TransporterDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Scaffold(
          appBar: AppBar(
            title: Text('¡Hola ${user?.fullName ?? 'Transportista'}!'),
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => context.push('/notifications'),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _showLogoutDialog(context),
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
                  
                  // Acciones rápidas para transportistas
                  _buildQuickActions(),
                  SizedBox(height: MediaQuery.of(context).size.width < 600 ? 16 : 24),
                  
                  // Mis viajes activos
                  _buildActiveTrips(),
                  SizedBox(height: MediaQuery.of(context).size.width < 600 ? 16 : 24),
                  
                  // Donaciones disponibles
                  _buildAvailableDonations(),
                  SizedBox(height: MediaQuery.of(context).size.width < 600 ? 16 : 24),
                  
                  // Estadísticas de transporte
                  _buildTransportStats(),
                  
                  // Espaciado final para navegación
                  const SizedBox(height: 100),
                ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: _buildTransporterNavigation(),
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.local_shipping, color: Colors.green[600], size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🚛 Panel del Transportista',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Conecta donantes con bibliotecas llevando libros donde se necesitan',
                    style: TextStyle(color: Colors.green[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
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
                          'Crear Viaje',
                          Icons.add_road,
                          Colors.green,
                          () => context.push('/trips/create'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionCard(
                          'Ver Donaciones',
                          Icons.inventory,
                          Colors.blue,
                          () => context.push('/donations'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          'Mapa de Rutas',
                          Icons.map,
                          Colors.purple,
                          () => context.push('/map'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionCard(
                          'Mi Perfil',
                          Icons.person,
                          Colors.orange,
                          () => context.push('/profile'),
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
                      'Crear Viaje',
                      Icons.add_road,
                      Colors.green,
                      () => context.push('/trips/create'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      'Ver Donaciones',
                      Icons.inventory,
                      Colors.blue,
                      () => context.push('/donations'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      'Mapa de Rutas',
                      Icons.map,
                      Colors.purple,
                      () => context.push('/map'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      'Mi Perfil',
                      Icons.person,
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

  Widget _buildActiveTrips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mis Viajes Activos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/trips'),
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Icon(Icons.flight_takeoff, color: Colors.green[600]),
            ),
            title: const Text('Buenos Aires → Mendoza'),
            subtitle: const Text('Salida: 25 Ago • Capacidad: 45/50 kg'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: const Text('Activo'),
                  backgroundColor: Colors.green[100],
                ),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.flight_land, color: Colors.blue[600]),
            ),
            title: const Text('Córdoba → Salta'),
            subtitle: const Text('Salida: 28 Ago • Capacidad: 20/35 kg'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: const Text('Planificado'),
                  backgroundColor: Colors.orange[100],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableDonations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Donaciones Disponibles',
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
        SizedBox(
          height: MediaQuery.of(context).size.width < 600 ? 120 : 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            children: [
              _buildDonationCard(
                'Libros Infantiles',
                'Buenos Aires',
                'Mendoza',
                '15 kg',
                Colors.blue,
              ),
              _buildDonationCard(
                'Enciclopedias',
                'Córdoba',
                'Salta',
                '25 kg',
                Colors.green,
              ),
              _buildDonationCard(
                'Novelas',
                'Rosario',
                'Tucumán',
                '8 kg',
                Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDonationCard(String title, String origin, String destination, String weight, Color color) {
    final isMobile = MediaQuery.of(context).size.width < 600;
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
                  Icon(Icons.book, color: color, size: isMobile ? 16 : 20),
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
              Row(
                children: [
                  Icon(Icons.location_on, size: isMobile ? 12 : 14, color: Colors.grey[600]),
                  SizedBox(width: isMobile ? 2 : 4),
                  Expanded(
                    child: Text(
                      origin,
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 11, 
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Row(
                children: [
                  Icon(Icons.flag, size: isMobile ? 12 : 14, color: Colors.grey[600]),
                  SizedBox(width: isMobile ? 2 : 4),
                  Expanded(
                    child: Text(
                      destination,
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 11, 
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
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
                  weight,
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

  Widget _buildTransportStats() {
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
                  child: _buildStatItem('Viajes', '23', Icons.local_shipping, Colors.green),
                ),
                Expanded(
                  child: _buildStatItem('Libros', '456', Icons.book, Colors.blue),
                ),
                Expanded(
                  child: _buildStatItem('Rating', '4.9', Icons.star, Colors.amber),
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

  Widget _buildTransporterNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green[600],
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping),
          label: 'Viajes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Donaciones',
        ),
        BottomNavigationBarItem(
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
            context.push('/trips');
            break;
          case 2:
            context.push('/donations');
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
              context.read<AuthProvider>().signOut();
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