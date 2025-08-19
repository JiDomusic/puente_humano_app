import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/models/user_profile.dart';
import '../dashboards/donor_dashboard_screen.dart';
import '../dashboards/transporter_dashboard_screen.dart';
import '../dashboards/library_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

        // REDIRIGIR AUTOMÁTICAMENTE SEGÚN EL ROL DEL USUARIO
        switch (user.role) {
          case UserRole.donante:
            return const DonorDashboardScreen();
          case UserRole.transportista:
            return const TransporterDashboardScreen();
          case UserRole.biblioteca:
            return const LibraryDashboardScreen();
          default:
            // Fallback para roles no reconocidos
            return _buildGenericHome(user);
        }
      },
    );
  }

  // Dashboard genérico de fallback
  Widget _buildGenericHome(UserProfile user) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido ${user.fullName}'),
        backgroundColor: Colors.grey[600],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'Rol no reconocido: ${user.role}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Contacta al administrador para configurar tu cuenta.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<AuthProvider>().signOut(),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}