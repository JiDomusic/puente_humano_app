import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/user_service.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  
  const PublicProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final UserService _userService = UserService();
  UserProfile? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _userService.getUserProfile(widget.userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando perfil: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Público'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Volver'),
                      ),
                    ],
                  ),
                )
              : _user == null
                  ? const Center(child: Text('Usuario no encontrado'))
                  : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildRoleSpecificInfo(),
          const SizedBox(height: 24),
          _buildLocationInfo(),
          const SizedBox(height: 24),
          _buildRatingsInfo(),
          const SizedBox(height: 24),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: _user!.photo != null 
                ? CachedNetworkImageProvider(_user!.photo!)
                : null,
              child: _user!.photo == null 
                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user!.fullName,
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
                      color: _getRoleColor(_user!.role),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _user!.role.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_user!.city}, ${_user!.country}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (_user!.age != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${_user!.age} años',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSpecificInfo() {
    switch (_user!.role) {
      case UserRole.donante:
        return _buildDonanteInfo();
      case UserRole.transportista:
        return _buildTransportistaInfo();
      case UserRole.biblioteca:
        return _buildBibliotecaInfo();
    }
  }

  Widget _buildDonanteInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.volunteer_activism, color: _getRoleColor(_user!.role)),
                const SizedBox(width: 8),
                const Text(
                  'Información del Donante',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Libros donados', '45 libros', Icons.book),
            const SizedBox(height: 8),
            _buildInfoRow('Bibliotecas beneficiadas', '12 bibliotecas', Icons.library_books),
            const SizedBox(height: 8),
            _buildInfoRow('Última donación', 'Hace 3 días', Icons.calendar_today),
            const SizedBox(height: 16),
            const Text(
              'Tipos de libros que suele donar:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildCategoryChip('Educativos'),
                _buildCategoryChip('Literatura'),
                _buildCategoryChip('Infantiles'),
                _buildCategoryChip('Técnicos'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportistaInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: _getRoleColor(_user!.role)),
                const SizedBox(width: 8),
                const Text(
                  'Información del Transportista',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Entregas realizadas', '23 entregas', Icons.local_shipping),
            const SizedBox(height: 8),
            _buildInfoRow('Distancia recorrida', '1,250 km', Icons.route),
            const SizedBox(height: 8),
            _buildInfoRow('Último viaje', 'Hace 1 semana', Icons.calendar_today),
            const SizedBox(height: 16),
            const Text(
              'Rutas frecuentes:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildRouteChip('Bogotá - Medellín'),
                _buildRouteChip('Medellín - Cali'),
                _buildRouteChip('Cali - Pasto'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBibliotecaInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.library_books, color: _getRoleColor(_user!.role)),
                const SizedBox(width: 8),
                const Text(
                  'Información de la Biblioteca',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Libros recibidos', '156 libros', Icons.book),
            const SizedBox(height: 8),
            _buildInfoRow('Donantes conectados', '8 donantes', Icons.people),
            const SizedBox(height: 8),
            _buildInfoRow('Última recepción', 'Hace 5 días', Icons.calendar_today),
            const SizedBox(height: 16),
            const Text(
              'Especialidades:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildCategoryChip('Biblioteca Comunitaria'),
                _buildCategoryChip('Educación Primaria'),
                _buildCategoryChip('Programas de Lectura'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Descripción:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Biblioteca comunitaria que sirve a 500 familias en la zona rural. Enfocada en educación infantil y programas de alfabetización para adultos.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Ubicación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Ciudad', _user!.city, Icons.location_city),
            const SizedBox(height: 8),
            _buildInfoRow('País', _user!.country, Icons.flag),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Calificaciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_user!.averageRating != null) ...[
              Row(
                children: [
                  Text(
                    _user!.averageRating!.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < _user!.averageRating!.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      Text(
                        '${_user!.ratingsCount} calificaciones',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ] else ...[
              const Text(
                'Sin calificaciones aún',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.contact_phone, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Contacto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Implementar lógica de contacto (WhatsApp, mensaje, etc.)
                  _showContactOptions();
                },
                icon: const Icon(Icons.message),
                label: const Text('Contactar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildRouteChip(String route) {
    return Chip(
      label: Text(
        route,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.blue[100],
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
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

  void _showContactOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Opciones de Contacto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('WhatsApp'),
              subtitle: Text(_user!.phone),
              onTap: () {
                // Implementar apertura de WhatsApp
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.blue),
              title: const Text('Enviar Mensaje'),
              subtitle: const Text('Mensaje interno de la app'),
              onTap: () {
                // Implementar sistema de mensajería interna
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}