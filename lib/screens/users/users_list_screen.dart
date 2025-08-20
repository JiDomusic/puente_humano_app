import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/user_service.dart';
import '../../providers/auth_provider_simple.dart';
import '../../widgets/star_rating.dart';
import '../../utils/app_localizations.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final UserService _userService = UserService();
  List<UserProfile> _donantes = [];
  List<UserProfile> _transportistas = [];
  List<UserProfile> _bibliotecas = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'name'; // 'name', 'rating', 'date'

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
        _userService.getUsersByRole(UserRole.transportista),
        _userService.getUsersByRole(UserRole.biblioteca),
      ]);
      
      setState(() {
        _donantes = futures[0];
        _transportistas = futures[1];
        _bibliotecas = futures[2];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando usuarios: $e')),
        );
      }
    }
  }

  List<UserProfile> _filterAndSortUsers(List<UserProfile> users) {
    // Filtrar por búsqueda
    List<UserProfile> filteredUsers = users;
    if (_searchQuery.isNotEmpty) {
      filteredUsers = users.where((user) =>
        user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        user.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        user.country.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Ordenar según el criterio seleccionado
    switch (_sortBy) {
      case 'rating':
        filteredUsers.sort((a, b) {
          final ratingA = a.averageRating ?? 0.0;
          final ratingB = b.averageRating ?? 0.0;
          return ratingB.compareTo(ratingA); // Descendente
        });
        break;
      case 'date':
        filteredUsers.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Más recientes primero
        break;
      case 'name':
      default:
        filteredUsers.sort((a, b) => a.fullName.compareTo(b.fullName)); // Alfabético
        break;
    }

    return filteredUsers;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xE6D282),
      appBar: AppBar(
        title: Text(l10n.usersList),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/home'),
            tooltip: l10n.backToHome,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => setState(() => _sortBy = value),
            tooltip: l10n.sortBy,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    const Icon(Icons.sort_by_alpha),
                    const SizedBox(width: 8),
                    Text(l10n.sortByName),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'rating',
                child: Row(
                  children: [
                    const Icon(Icons.star),
                    const SizedBox(width: 8),
                    Text(l10n.sortByRating),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    const Icon(Icons.schedule),
                    const SizedBox(width: 8),
                    Text(l10n.mostRecent),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(),
            tooltip: l10n.logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            color: Colors.blue[600],
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: l10n.searchUsers,
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          // Lista de usuarios
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      children: [
                        _buildRoleSection(
                          'Donantes',
                          _filterAndSortUsers(_donantes),
                          Colors.blue[600]!,
                          Icons.volunteer_activism,
                          isMobile,
                        ),
                        const SizedBox(height: 24),
                        _buildRoleSection(
                          'Transportistas',
                          _filterAndSortUsers(_transportistas),
                          Colors.green[600]!,
                          Icons.local_shipping,
                          isMobile,
                        ),
                        const SizedBox(height: 24),
                        _buildRoleSection(
                          'Bibliotecas',
                          _filterAndSortUsers(_bibliotecas),
                          Colors.purple[600]!,
                          Icons.library_books,
                          isMobile,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSection(String title, List<UserProfile> users, Color color, IconData icon, bool isMobile) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la sección
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: isMobile ? 24 : 28),
                SizedBox(width: isMobile ? 8 : 12),
                Text(
                  '$title (${users.length})',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Lista de usuarios
          if (users.isEmpty)
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Text(
                '${l10n.noUsersFound} $title',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildUserTile(user, color, isMobile);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildUserTile(UserProfile user, Color roleColor, bool isMobile) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 8 : 12,
      ),
      leading: CircleAvatar(
        backgroundColor: roleColor.withOpacity(0.1),
        radius: isMobile ? 20 : 24,
        backgroundImage: user.photo != null ? NetworkImage(user.photo!) : null,
        child: user.photo == null
            ? Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: roleColor,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 16 : 18,
                ),
              )
            : null,
      ),
      title: Text(
        user.fullName,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 14 : 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${user.city}, ${user.country}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isMobile ? 12 : 14,
            ),
          ),
          Row(
            children: [
              StarRating(
                rating: user.averageRating ?? 5.0,
                size: isMobile ? 14 : 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${(user.averageRating ?? 5.0).toStringAsFixed(1)} (${user.ratingsCount})',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 11 : 13,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey[400],
        size: isMobile ? 16 : 18,
      ),
      onTap: () => context.push('/profile/public/${user.id}'),
    );
  }

  void _showLogoutDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.logoutConfirm),
          content: Text(l10n.logoutQuestion),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
                await authProvider.signOut();
                if (mounted) {
                  context.go('/login');
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.logoutConfirm),
            ),
          ],
        );
      },
    );
  }
}