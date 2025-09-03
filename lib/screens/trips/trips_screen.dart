import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider_simple.dart';
import '../../core/services/trip_service.dart';
import '../../core/models/trip.dart';
import '../../utils/app_localizations.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final TripService _tripService = TripService();
  List<Trip> _trips = [];
  bool _isLoading = true;
  String _selectedFilter = 'active';

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    try {
      final trips = await _tripService.getAllTrips();
      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar viajes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Trip> get _filteredTrips {
    switch (_selectedFilter) {
      case 'active':
        return _trips.where((t) => t.isActive).toList();
      case 'all':
        return _trips;
      default:
        return _trips;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final authProvider = context.watch<SimpleAuthProvider>();
    final isTransporter = authProvider.currentUser?.role.toString() == 'UserRole.transportista';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trips),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isTransporter)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/trips/create'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          _buildFilterSection(isMobile),
          
          // Lista de viajes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTrips.isEmpty
                    ? _buildEmptyState(isTransporter)
                    : RefreshIndicator(
                        onRefresh: _loadTrips,
                        child: ListView.builder(
                          padding: EdgeInsets.all(isMobile ? 8 : 16),
                          itemCount: _filteredTrips.length,
                          itemBuilder: (context, index) {
                            final trip = _filteredTrips[index];
                            return _buildTripCard(trip, isMobile);
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
            'Filtrar viajes:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Row(
            children: [
              _buildFilterChip('active', 'Activos', Colors.green),
              const SizedBox(width: 8),
              _buildFilterChip('all', 'Todos', Colors.grey),
            ],
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

  Widget _buildEmptyState(bool isTransporter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay viajes disponibles',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTransporter 
              ? 'Crea tu primer viaje para ayudar a la comunidad'
              : 'Aún no hay transportistas disponibles',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          if (isTransporter) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/trips/create'),
              icon: const Icon(Icons.add),
              label: const Text('Crear Viaje'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTripCard(Trip trip, bool isMobile) {
    final authProvider = context.read<SimpleAuthProvider>();
    final currentUserId = authProvider.currentUser?.id;
    final isOwnTrip = currentUserId == trip.travelerId;
    
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.push('/trips/${trip.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ruta y estado
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.route,
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${trip.originCountry} → ${trip.destCountry}',
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOwnTrip)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Mi viaje',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: isMobile ? 10 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              SizedBox(height: isMobile ? 8 : 12),
              
              // Información del transportista
              if (trip.traveler != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: isMobile ? 16 : 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Transportista: ${trip.traveler!.fullName}',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    // Botón de chat
                    if (!isOwnTrip)
                      InkWell(
                        onTap: () => context.push('/chat/${trip.travelerId}'),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.message,
                            size: isMobile ? 16 : 18,
                            color: Colors.green[600],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              
              // Fechas del viaje
              Row(
                children: [
                  Icon(
                    Icons.flight_takeoff,
                    size: isMobile ? 16 : 18,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${trip.departDate.day}/${trip.departDate.month}/${trip.departDate.year}',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.flight_land,
                    size: isMobile ? 16 : 18,
                    color: Colors.orange[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${trip.arriveDate.day}/${trip.arriveDate.month}/${trip.arriveDate.year}',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isMobile ? 8 : 12),
              
              // Capacidad disponible
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: trip.hasCapacity 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory,
                      size: isMobile ? 16 : 18,
                      color: trip.hasCapacity ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Capacidad disponible',
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${trip.availableKg.toStringAsFixed(1)} kg de ${trip.capacityKg} kg',
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 15,
                              fontWeight: FontWeight.bold,
                              color: trip.hasCapacity ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: isMobile ? 60 : 80,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (trip.usedKg / trip.capacityKg).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: trip.hasCapacity ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Notas si existen
              if (trip.notes != null && trip.notes!.isNotEmpty) ...[
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
                          trip.notes!,
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
}