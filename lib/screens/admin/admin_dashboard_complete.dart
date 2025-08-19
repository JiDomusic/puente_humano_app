import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/admin_service.dart';

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
            onPressed: () => context.go('/login'),
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
                  // Estadísticas generales
                  _buildStatsSection(),
                  const SizedBox(height: 24),
                  
                  // Lista de usuarios para revisar
                  _buildUsersSection(),
                  const SizedBox(height: 24),
                  
                  // Herramientas de moderación
                  _buildModerationTools(),
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
                Icon(Icons.analytics, color: Colors.red[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Resumen del Sistema',
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
                    _stats['total_users']?.toString() ?? '0',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Nuevos (7 días)',
                    _stats['users_this_week']?.toString() ?? '0',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_stats['users_by_role'] != null)
              Wrap(
                spacing: 8,
                children: [
                  _buildRoleChip('Donantes', _stats['users_by_role']['donante'] ?? 0, Colors.blue),
                  _buildRoleChip('Transportistas', _stats['users_by_role']['transportista'] ?? 0, Colors.green),
                  _buildRoleChip('Bibliotecas', _stats['users_by_role']['biblioteca'] ?? 0, Colors.orange),
                ],
              ),
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
                  Text('Ver detalles completos'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Editar información'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'flag',
              child: Row(
                children: [
                  Icon(Icons.flag, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Marcar como sospechoso'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, size: 16, color: Colors.orange),
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
                  Text('Eliminar permanentemente'),
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
                Icon(Icons.admin_panel_settings, color: Colors.red[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Herramientas de Administración',
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
                  'Exportar Datos',
                  Icons.download,
                  Colors.blue,
                  () => _exportData(),
                ),
                _buildToolButton(
                  'Usuarios Sospechosos',
                  Icons.warning,
                  Colors.orange,
                  () => _showSuspiciousUsers(),
                ),
                _buildToolButton(
                  'Limpiar Datos',
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
      width: 160,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(
          title,
          style: const TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
      case 'edit':
        _editUser(user);
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
              _detailRow('ID del Sistema', user['id']),
              _detailRow('Email', user['email']),
              _detailRow('Rol', _getRoleDisplayName(user['role'])),
              _detailRow('Teléfono', user['phone'] ?? 'No especificado'),
              _detailRow('Ciudad', user['city'] ?? 'No especificada'),
              _detailRow('País', user['country'] ?? 'No especificado'),
              _detailRow('Idioma', user['language'] ?? 'No especificado'),
              _detailRow('Calificación', '${user['average_rating'] ?? 0} ⭐'),
              _detailRow('Registrado', _formatDate(user['created_at'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editUser(user);
            },
            child: const Text('Editar'),
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
            width: 100,
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

  void _editUser(Map<String, dynamic> user) {
    _showComingSoon('Editar usuario ${user['full_name']}');
  }

  void _flagUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚩 Marcar como Sospechoso'),
        content: Text('¿Marcar usuario ${user['full_name']} como sospechoso?\n\nEsto agregará una marca para revisión manual.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Usuario ${user['full_name']} marcado para revisión')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Marcar'),
          ),
        ],
      ),
    );
  }

  void _blockUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚫 Bloquear Usuario'),
        content: Text('¿Bloquear usuario ${user['full_name']}?\n\nNo podrá acceder al sistema hasta ser desbloqueado.'),
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
                  SnackBar(content: Text('Error bloqueando usuario: $e')),
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
        title: const Text('🗑️ ELIMINAR USUARIO'),
        content: Text(
          '⚠️ ¿ELIMINAR PERMANENTEMENTE usuario ${user['full_name']}?\n\n'
          '• Se eliminarán todos sus datos\n'
          '• Se eliminarán sus donaciones/viajes\n'
          '• Esta acción NO se puede deshacer\n\n'
          'Solo eliminar si es spam/abuso confirmado.',
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
                  SnackBar(content: Text('Usuario ${user['full_name']} eliminado permanentemente')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error eliminando usuario: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINAR DEFINITIVAMENTE'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    _showComingSoon('Exportar datos del sistema');
  }

  void _showSuspiciousUsers() {
    _showComingSoon('Ver usuarios marcados como sospechosos');
  }

  void _cleanupData() {
    _showComingSoon('Herramientas de limpieza de datos');
  }

  void _showSettings() {
    _showComingSoon('Configuración del sistema');
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature: Próximamente disponible'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}