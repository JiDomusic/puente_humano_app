import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/donation_service.dart';
import '../../core/models/donation.dart';
import '../../providers/auth_provider_simple.dart';

class DonationDetailScreen extends StatefulWidget {
  final String donationId;
  
  const DonationDetailScreen({super.key, required this.donationId});

  @override
  State<DonationDetailScreen> createState() => _DonationDetailScreenState();
}

class _DonationDetailScreenState extends State<DonationDetailScreen> {
  final DonationService _donationService = DonationService();
  Donation? _donation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDonationDetail();
  }

  Future<void> _loadDonationDetail() async {
    setState(() => _isLoading = true);
    
    try {
      final donation = await _donationService.getDonationById(widget.donationId);
      setState(() {
        _donation = donation;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar donación: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (_donation == null) return;
    
    try {
      await _donationService.updateDonationStatus(widget.donationId, newStatus);
      await _loadDonationDetail(); // Recargar datos
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado actualizado a: $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cargando...'),
          backgroundColor: Colors.orange[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDonationDetail,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_donation == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('No encontrado'),
          backgroundColor: Colors.grey[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Donación no encontrada'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Donación ${_donation!.donationCode}'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        actions: [
          if (_canUpdateStatus())
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: _updateStatus,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'pendiente',
                  child: Text('Marcar como Pendiente'),
                ),
                const PopupMenuItem(
                  value: 'en_transito',
                  child: Text('En Tránsito'),
                ),
                const PopupMenuItem(
                  value: 'entregado',
                  child: Text('Entregado'),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDonationDetail,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(),
              const SizedBox(height: 16),
              _buildBookInfoCard(),
              const SizedBox(height: 16),
              _buildDonorInfoCard(),
              const SizedBox(height: 16),
              _buildLibraryInfoCard(),
              const SizedBox(height: 16),
              if (_donation!.notes != null && _donation!.notes!.isNotEmpty)
                _buildNotesCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getStatusIcon(), color: _getStatusColor()),
                const SizedBox(width: 8),
                Text(
                  'Estado de la Donación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getStatusColor()),
              ),
              child: Text(
                _getStatusDisplayName(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Código: ${_donation!.donationCode}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Creado: ${_formatDate(_donation!.createdAt)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.book, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Información del Libro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Título', _donation!.title, Icons.title),
            const SizedBox(height: 8),
            _buildInfoRow('Autor', _donation!.author, Icons.person),
            const SizedBox(height: 8),
            _buildInfoRow('Peso', '${_donation!.weightKg} kg', Icons.scale),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorInfoCard() {
    final donor = _donation!.donor;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.volunteer_activism, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Donante',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (donor != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.green[100],
                    backgroundImage: donor.photo != null ? NetworkImage(donor.photo!) : null,
                    child: donor.photo == null
                        ? Icon(Icons.person, color: Colors.green[600])
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donor.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${donor.city}, ${donor.country}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chat, color: Colors.indigo[600]),
                    onPressed: () => context.go('/chat/${donor.id}'),
                    tooltip: 'Enviar mensaje',
                  ),
                ],
              ),
            ] else ...[
              const Text('Información del donante no disponible'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryInfoCard() {
    final library = _donation!.targetLibrary;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.library_books, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  'Biblioteca Destino',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (library != null) ...[
              _buildInfoRow('Nombre', library.name, Icons.library_books),
              const SizedBox(height: 8),
              _buildInfoRow('Ubicación', '${library.city}, ${library.country}', Icons.location_on),
              const SizedBox(height: 8),
              _buildInfoRow('Email', library.contactEmail, Icons.email),
              if (library.contactPhone != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow('Teléfono', library.contactPhone!, Icons.phone),
              ],
            ] else ...[
              const Text('Información de biblioteca no disponible'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_alt, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Notas Adicionales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _donation!.notes!,
              style: const TextStyle(fontSize: 14),
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

  Color _getStatusColor() {
    switch (_donation!.status) {
      case 'pendiente':
        return Colors.orange;
      case 'en_transito':
        return Colors.blue;
      case 'entregado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (_donation!.status) {
      case 'pendiente':
        return Icons.schedule;
      case 'en_transito':
        return Icons.local_shipping;
      case 'entregado':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  String _getStatusDisplayName() {
    switch (_donation!.status) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_transito':
        return 'En Tránsito';
      case 'entregado':
        return 'Entregado';
      default:
        return _donation!.status;
    }
  }

  bool _canUpdateStatus() {
    final authProvider = context.read<SimpleAuthProvider>();
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null) return false;
    
    // Solo el donante o admin pueden actualizar el estado
    return currentUser.id == _donation!.donorId || authProvider.isAdmin;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}