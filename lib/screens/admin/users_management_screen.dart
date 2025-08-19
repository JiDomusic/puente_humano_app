import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/admin_service.dart';
import '../../core/models/user_profile.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedRole = 'all';

  final List<String> _roles = ['all', 'donante', 'transportista', 'biblioteca'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _adminService.getAllUsers();
      
      // Ordenar alfabéticamente por nombre
      users.sort((a, b) => 
        (a['full_name'] ?? '').toString().toLowerCase()
        .compareTo((b['full_name'] ?? '').toString().toLowerCase())
      );

      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error cargando usuarios: $e');
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers = _users.where((user) {
        final nameMatch = (user['full_name'] ?? '')
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        
        final emailMatch = (user['email'] ?? '')
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());

        final roleMatch = _selectedRole == 'all' || 
            user['role'] == _selectedRole;

        return (nameMatch || emailMatch) && roleMatch;
      }).toList();

      // Mantener orden alfabético después del filtro
      _filteredUsers.sort((a, b) => 
        (a['full_name'] ?? '').toString().toLowerCase()
        .compareTo((b['full_name'] ?? '').toString().toLowerCase())
      );
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _deactivateUser(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Desactivación'),
        content: Text(
          '¿Está seguro que desea desactivar al usuario "$userName"?\n\n'
          'El usuario no podrá acceder a la aplicación hasta ser reactivado.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _adminService.deactivateUser(userId);
        if (success) {
          _showSuccessSnackBar('Usuario desactivado exitosamente');
          _loadUsers(); // Recargar lista
        } else {
          _showErrorSnackBar('Error desactivando usuario');
        }
      } catch (e) {
        _showErrorSnackBar('Error: $e');
      }
    }
  }

  Future<void> _deleteUser(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ ELIMINAR USUARIO'),
        content: Text(
          '¿Está COMPLETAMENTE SEGURO que desea ELIMINAR permanentemente al usuario "$userName"?\n\n'
          '⚠️ ESTA ACCIÓN NO SE PUEDE DESHACER ⚠️\n\n'
          'Se eliminarán:\n'
          '• Su cuenta de autenticación\n'
          '• Su perfil y datos\n'
          '• Todas sus donaciones y viajes\n'
          '• Su historial completo'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINAR PERMANENTEMENTE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _adminService.deleteUser(userId);
        if (success) {
          _showSuccessSnackBar('Usuario eliminado permanentemente');
          _loadUsers(); // Recargar lista
        } else {
          _showErrorSnackBar('Error eliminando usuario');
        }
      } catch (e) {
        _showErrorSnackBar('Error: $e');
      }
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['full_name'] ?? 'Usuario'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Foto de perfil
              if (user['photo'] != null)
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: CachedNetworkImage(
                        imageUrl: user['photo'],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => 
                          const Icon(Icons.person, size: 60),
                      ),
                    ),
                  ),
                ),
              
              _buildDetailRow('Email', user['email']),
              _buildDetailRow('Rol', _getRoleDisplayName(user['role'])),
              _buildDetailRow('Teléfono', user['phone']),
              _buildDetailRow('Ciudad', user['city']),
              _buildDetailRow('País', user['country']),
              _buildDetailRow('Calificación Promedio', 
                '${user['average_rating']?.toStringAsFixed(1) ?? '0.0'} ⭐'),
              _buildDetailRow('Número de Calificaciones', 
                '${user['ratings_count'] ?? 0}'),
              _buildDetailRow('Fecha de Registro', 
                _formatDate(user['created_at'])),
              _buildDetailRow('Estado', 
                user['is_active'] == true ? '✅ Activo' : '❌ Inactivo'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'No especificado'),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(String? role) {
    switch (role) {
      case 'donante':
        return 'Donante';
      case 'transportista':
        return 'Transportista';
      case 'biblioteca':
        return 'Biblioteca';
      default:
        return role ?? 'No especificado';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No especificado';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'donante':
        return Colors.blue;
      case 'transportista':
        return Colors.green;
      case 'biblioteca':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Recargar usuarios',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                // Barra de búsqueda
                TextField(
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterUsers();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Buscar por nombre o email',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filtro por rol
                Row(
                  children: [
                    const Text('Filtrar por rol: '),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        onChanged: (value) {
                          setState(() => _selectedRole = value!);
                          _filterUsers();
                        },
                        items: _roles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role == 'all' ? 'Todos' : _getRoleDisplayName(role)),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Estadísticas
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', _filteredUsers.length, Colors.blue),
                _buildStatCard('Donantes', 
                  _filteredUsers.where((u) => u['role'] == 'donante').length, 
                  Colors.green),
                _buildStatCard('Transportistas', 
                  _filteredUsers.where((u) => u['role'] == 'transportista').length, 
                  Colors.orange),
                _buildStatCard('Bibliotecas', 
                  _filteredUsers.where((u) => u['role'] == 'biblioteca').length, 
                  Colors.purple),
              ],
            ),
          ),

          // Lista de usuarios
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No se encontraron usuarios',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return _buildUserCard(user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isActive = user['is_active'] ?? true;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: _getRoleColor(user['role']),
          backgroundImage: user['photo'] != null 
              ? CachedNetworkImageProvider(user['photo'])
              : null,
          child: user['photo'] == null 
              ? Text(
                  (user['full_name'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(
          user['full_name'] ?? 'Sin nombre',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email'] ?? 'Sin email'),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user['role']),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getRoleDisplayName(user['role']),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                if (!isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'INACTIVO',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            if (user['city'] != null || user['country'] != null)
              Text(
                '${user['city'] ?? ''} ${user['country'] ?? ''}'.trim(),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'details':
                _showUserDetails(user);
                break;
              case 'deactivate':
                _deactivateUser(user['id'], user['full_name'] ?? 'Usuario');
                break;
              case 'delete':
                _deleteUser(user['id'], user['full_name'] ?? 'Usuario');
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('Ver Detalles'),
                ],
              ),
            ),
            if (isActive)
              const PopupMenuItem(
                value: 'deactivate',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Desactivar'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_forever, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showUserDetails(user),
      ),
    );
  }
}