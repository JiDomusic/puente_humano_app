import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/services/admin_service.dart';
import '../../providers/admin_auth_provider.dart';
import 'users_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    
    try {
      final stats = await _adminService.getAdminStats();
      final users = await _adminService.getAllUsers();
      
      setState(() {
        _stats = stats;
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading admin data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control - PuenteHumano'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadAdminData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar datos',
          ),
          IconButton(
            onPressed: () async {
              final adminAuthProvider = context.read<AdminAuthProvider>();
              await adminAuthProvider.adminLogout();
              if (mounted) {
                context.go('/');
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Salir del panel',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 24),
                  _buildStatsSection(),
                  const SizedBox(height: 24),
                  _buildUsersSection(),
                  const SizedBox(height: 24),
                  _buildModerationTools(),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.red[600], size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👑 Panel de Propietario',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Control total sobre PuenteHumano • Moderar usuarios • Detectar fraudes',
                    style: TextStyle(color: Colors.red[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Estadísticas del Sistema',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Usuarios',
                    (_stats['total_users'] ?? _users.length).toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Nuevos (7 días)',
                    _countRecentUsers().toString(),
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRoleStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
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
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleStats() {
    final roleCount = <String, int>{};
    for (final user in _users) {
      final role = user['role'] as String? ?? 'sin_rol';
      roleCount[role] = (roleCount[role] ?? 0) + 1;
    }

    return Wrap(
      spacing: 8,
      children: [
        _buildRoleChip('Donantes', roleCount['donante'] ?? 0, Colors.blue),
        _buildRoleChip('Transportistas', roleCount['transportista'] ?? 0, Colors.green),
        _buildRoleChip('Bibliotecas', roleCount['biblioteca'] ?? 0, Colors.orange),
      ],
    );
  }

  Widget _buildRoleChip(String role, int count, Color color) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(
          count.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      label: Text(role),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  int _countRecentUsers() {
    final now = DateTime.now();
    return _users.where((user) {
      try {
        final createdAt = DateTime.parse(user['created_at'] ?? '');
        return now.difference(createdAt).inDays <= 7;
      } catch (e) {
        return false;
      }
    }).length;
  }

  Widget _buildUsersSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.red[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Moderación de Usuarios (${_users.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_users.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No hay usuarios registrados'),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _users.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return _buildUserCard(user);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isRecent = _isRecentUser(user['created_at']);
    
    return Container(
      decoration: BoxDecoration(
        color: isRecent ? Colors.green[50] : null,
        borderRadius: BorderRadius.circular(8),
        border: isRecent ? Border.all(color: Colors.green[200]!) : null,
      ),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: _getRoleColor(user['role']),
              child: Text(
                user['full_name']?.toString().substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            if (isRecent)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user['full_name'] ?? 'Sin nombre',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (isRecent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'NUEVO',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user['email'] ?? 'Sin email',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '${_getRoleDisplayName(user['role'])} • ${user['city'] ?? 'Sin ciudad'}, ${user['country'] ?? 'Sin país'}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (user['phone'] != null && user['phone'].toString().isNotEmpty)
              Text(
                'Tel: ${user['phone']}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            Text(
              'Registrado: ${_formatDate(user['created_at'])}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Ver detalles'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'flag',
              child: Row(
                children: [
                  Icon(Icons.flag, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Marcar sospechoso'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Bloquear usuario'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_forever, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleUserAction(value, user),
        ),
      ),
    );
  }

  Widget _buildModerationTools() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.purple[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Herramientas de Propietario',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildToolButton(
                  'Gestión Usuarios',
                  Icons.manage_accounts,
                  Colors.indigo,
                  () => _openUsersManagement(),
                ),
                _buildToolButton(
                  'Chat & Mensajes',
                  Icons.chat,
                  Colors.teal,
                  () => _openChatManagement(),
                ),
                _buildToolButton(
                  'Interacciones',
                  Icons.star_rate,
                  Colors.amber,
                  () => _openInteractionsManagement(),
                ),
                _buildToolButton(
                  'Exportar Datos',
                  Icons.download,
                  Colors.blue,
                  () => _exportData(),
                ),
                _buildToolButton(
                  'Limpiar Sistema',
                  Icons.cleaning_services,
                  Colors.purple,
                  () => _cleanupData(),
                ),
                _buildToolButton(
                  'Configuración',
                  Icons.settings,
                  Colors.green,
                  () => _showSettings(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 150,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // Métodos de utilidad
  Color _getRoleColor(String? role) {
    switch (role) {
      case 'donante':
        return Colors.blue;
      case 'transportista':
        return Colors.green;
      case 'biblioteca':
        return Colors.orange;
      default:
        return Colors.grey;
    }
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
        return 'Sin rol';
    }
  }

  bool _isRecentUser(String? createdAt) {
    if (createdAt == null) return false;
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      return now.difference(date).inDays <= 7;
    } catch (e) {
      return false;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Fecha desconocida';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  // Métodos de acción
  void _handleUserAction(String action, Map<String, dynamic> user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'flag':
        _flagUser(user);
        break;
      case 'block':
        _blockUser(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('👤 ${user['full_name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('ID', user['id']),
              _detailRow('Email', user['email']),
              _detailRow('Rol', _getRoleDisplayName(user['role'])),
              _detailRow('Teléfono', user['phone'] ?? 'No especificado'),
              _detailRow('Ciudad', user['city'] ?? 'No especificada'),
              _detailRow('País', user['country'] ?? 'No especificado'),
              _detailRow('Registrado', _formatDate(user['created_at'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
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
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  void _flagUser(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Usuario ${user['full_name']} marcado como sospechoso')),
    );
  }

  void _blockUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚫 Bloquear Usuario'),
        content: Text('¿Bloquear usuario ${user['full_name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _adminService.deactivateUser(user['id']);
                _loadAdminData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Usuario ${user['full_name']} bloqueado')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ ELIMINAR USUARIO'),
        content: Text(
          'ELIMINAR PERMANENTEMENTE usuario ${user['full_name']}?\n\n'
          'Esta acción NO se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _adminService.deleteUser(user['id']);
                _loadAdminData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Usuario ${user['full_name']} eliminado')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }

  void _openUsersManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UsersManagementScreen(),
      ),
    );
  }

  void _openChatManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📱 Gestión de Chat: En desarrollo')),
    );
  }

  void _openInteractionsManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⭐ Gestión de Interacciones: En desarrollo')),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exportar datos: Próximamente')),
    );
  }

  void _cleanupData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Limpiar sistema: Próximamente')),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración: Próximamente')),
    );
  }
}