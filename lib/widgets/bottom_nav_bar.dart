import 'package:flutter/material.dart';
import '../core/models/user_profile.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final UserRole userRole;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final items = _getBottomNavItems();
    
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey[600],
      items: items,
    );
  }

  List<BottomNavigationBarItem> _getBottomNavItems() {
    switch (userRole) {
      case UserRole.donante:
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Mis Donaciones',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ];
        
      case UserRole.transportista:
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Mis Viajes',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ];
        
      case UserRole.biblioteca:
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Biblioteca',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ];
    }
  }
}