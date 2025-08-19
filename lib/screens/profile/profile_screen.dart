import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/models/user_profile.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/language_toggle_button.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        elevation: 0,
        actions: [
          const LanguageToggleButton(isIconOnly: true),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileEditScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (authProvider.currentUser == null) {
            return const Center(
              child: Text('No se pudo cargar el perfil'),
            );
          }

          final user = authProvider.currentUser!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 24),
                _buildInfoSection('Información Personal', [
                  _buildInfoItem('Nombre', user.fullName),
                  _buildInfoItem('Email', user.email),
                  _buildInfoItem('Teléfono', user.phone),
                  if (user.age != null) _buildInfoItem('Edad', '${user.age} años'),
                  _buildInfoItem('Rol', _getRoleDisplayName(user.role)),
                ]),
                const SizedBox(height: 24),
                _buildInfoSection('Ubicación', [
                  _buildInfoItem('Ciudad', user.city),
                  _buildInfoItem('País', user.country),
                ]),
                const SizedBox(height: 24),
                _buildInfoSection('Estadísticas', [
                  _buildInfoItem('Calificación Promedio', 
                    user.averageRating != null 
                      ? '${user.averageRating!.toStringAsFixed(1)} ⭐'
                      : 'Sin calificaciones'),
                  _buildInfoItem('Total de Calificaciones', 
                    '${user.ratingsCount}'),
                ]),
                const SizedBox(height: 24),
                _buildInfoSection('Preferencias', [
                  _buildInfoItem('Idioma', 
                    user.language == 'es' ? 'Español' : 'English'),
                  _buildInfoItem('Miembro desde', 
                    '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
                ]),
                const SizedBox(height: 24),
                // Panel de administración (solo para administradores)
                _buildAdminSection(context, user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: user.photo != null 
                ? CachedNetworkImageProvider(user.photo!)
                : null,
              child: user.photo == null 
                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getRoleDisplayName(user.role),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
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

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.donante:
        return Colors.green;
      case UserRole.transportista:
        return Colors.blue;
      case UserRole.biblioteca:
        return Colors.purple;
    }
  }

  Widget _buildAdminSection(BuildContext context, UserProfile user) {
    // Solo mostrar para administradores autorizados
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    
    if (!isAdmin) {
      return const SizedBox.shrink(); // No mostrar nada si no es admin
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Administración',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Panel de control y monitoreo del sistema',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/admin'),
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Abrir Panel de Administración'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}