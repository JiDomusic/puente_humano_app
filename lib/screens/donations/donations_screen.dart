import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/donation_service.dart';
import '../../core/models/donation.dart';
import '../../utils/app_localizations.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  final DonationService _donationService = DonationService();
  List<Donation> _donations = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() => _isLoading = true);
    try {
      final donations = await _donationService.getAllDonations();
      setState(() {
        _donations = donations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar donaciones: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Donation> get _filteredDonations {
    switch (_selectedFilter) {
      case 'pending':
        return _donations.where((d) => d.isPending).toList();
      case 'in_transit':
        return _donations.where((d) => d.isInTransit).toList();
      case 'delivered':
        return _donations.where((d) => d.isDelivered).toList();
      default:
        return _donations;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.donations),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/donations/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          _buildFilterSection(isMobile),
          
          // Lista de donaciones
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDonations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadDonations,
                        child: ListView.builder(
                          padding: EdgeInsets.all(isMobile ? 8 : 16),
                          itemCount: _filteredDonations.length,
                          itemBuilder: (context, index) {
                            final donation = _filteredDonations[index];
                            return _buildDonationCard(donation, isMobile);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por estado:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'Todas', Colors.grey),
                const SizedBox(width: 8),
                _buildFilterChip('pending', 'Pendientes', Colors.orange),
                const SizedBox(width: 8),
                _buildFilterChip('in_transit', 'En camino', Colors.blue),
                const SizedBox(width: 8),
                _buildFilterChip('delivered', 'Entregadas', Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, Color color) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.volunteer_activism,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay donaciones disponibles',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sé el primero en donar libros a la comunidad',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/donations/create'),
            icon: const Icon(Icons.add),
            label: const Text('Crear Donación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(Donation donation, bool isMobile) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.push('/donations/${donation.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y estado
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donation.title,
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'por ${donation.author}',
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(donation.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(donation.status).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      donation.statusText,
                      style: TextStyle(
                        color: _getStatusColor(donation.status),
                        fontSize: isMobile ? 10 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isMobile ? 8 : 12),
              
              // Información del donante
              if (donation.donor != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: isMobile ? 16 : 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Donante: ${donation.donor!.fullName}',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              
              // Biblioteca destino
              if (donation.targetLibrary != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.library_books,
                      size: isMobile ? 16 : 18,
                      color: Colors.purple[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Para: ${donation.targetLibrary!.name}',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: Colors.purple[600],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              
              // Peso y fecha
              Row(
                children: [
                  Icon(
                    Icons.scale,
                    size: isMobile ? 16 : 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${donation.weightKg} kg',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.calendar_today,
                    size: isMobile ? 16 : 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${donation.createdAt.day}/${donation.createdAt.month}/${donation.createdAt.year}',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              // Notas si existen
              if (donation.notes != null && donation.notes!.isNotEmpty) ...[
                SizedBox(height: isMobile ? 8 : 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note,
                        size: isMobile ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          donation.notes!,
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 13,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pendiente':
        return Colors.orange;
      case 'en_camino':
        return Colors.blue;
      case 'entregado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}