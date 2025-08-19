import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        }
      },
    );
  }
}