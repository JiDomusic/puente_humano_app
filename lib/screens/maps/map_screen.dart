import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/services/trip_service.dart';
import '../../core/services/donation_service.dart';
import '../../core/models/trip.dart';
import '../../core/models/donation.dart';
import '../../utils/app_localizations.dart';

class MapScreen extends StatefulWidget {
  final String? tripId;
  
  const MapScreen({
    super.key,
    this.tripId,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final TripService _tripService = TripService();
  final DonationService _donationService = DonationService();
  
  List<Trip> _trips = [];
  List<Donation> _donations = [];
  Trip? _selectedTrip;
  bool _isLoading = true;
  
  String _selectedLayer = 'all'; // all, trips, donations, libraries
  late TabController _tabController;
  
  Position? _currentPosition;
  bool _isLocationLoading = false;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMapData();
    
    if (widget.tripId != null) {
      _loadSpecificTrip();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMapData() async {
    setState(() => _isLoading = true);
    try {
      final trips = await _tripService.getAllTrips();
      final donations = await _donationService.getAllDonations();
      
      setState(() {
        _trips = trips;
        _donations = donations;
        _isLoading = false;
      });
      _updateMapMarkers();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos del mapa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadSpecificTrip() async {
    if (widget.tripId == null) return;
    
    try {
      final trip = await _tripService.getTripById(widget.tripId!);
      if (trip != null) {
        setState(() => _selectedTrip = trip);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar viaje: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true);
    
    try {
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('El servicio de ubicación está deshabilitado');
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permisos de ubicación denegados permanentemente');
      }

      // Obtener ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
      });

      // Mover cámara del mapa a la ubicación actual
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '📍 Ubicación: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error obteniendo ubicación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLocationLoading = false);
    }
  }

  void _updateMapMarkers() {
    Set<Marker> markers = {};

    // Agregar marcadores de viajes
    if (_selectedLayer == 'all' || _selectedLayer == 'trips') {
      for (int i = 0; i < _trips.length; i++) {
        final trip = _trips[i];
        // Usar coordenadas simuladas basadas en el índice
        final lat = 40.7128 + (i * 2.0); // Nueva York base + offset
        final lng = -74.0060 + (i * 3.0);
        
        markers.add(
          Marker(
            markerId: MarkerId('trip_${trip.id}'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: trip.route,
              snippet: '${trip.availableKg}kg disponible',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            onTap: () => context.push('/trips/${trip.id}'),
          ),
        );
      }
    }

    // Agregar marcadores de donaciones
    if (_selectedLayer == 'all' || _selectedLayer == 'donations') {
      for (int i = 0; i < _donations.length; i++) {
        final donation = _donations[i];
        // Usar coordenadas simuladas basadas en el índice
        final lat = 34.0522 + (i * 1.5); // Los Ángeles base + offset
        final lng = -118.2437 + (i * 2.0);
        
        markers.add(
          Marker(
            markerId: MarkerId('donation_${donation.id}'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: donation.title,
              snippet: '${donation.weightKg}kg - ${donation.statusText}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            onTap: () => context.push('/donations/${donation.id}'),
          ),
        );
      }
    }

    // Agregar marcador de ubicación actual
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(
            title: 'Mi Ubicación',
            snippet: 'Tu ubicación actual',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedTrip != null 
            ? 'Ruta: ${_selectedTrip!.route}'
            : l10n.routeMap),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: _selectedTrip == null 
            ? TabBar(
                controller: _tabController,
                onTap: (index) {
                  setState(() {
                    switch (index) {
                      case 0: _selectedLayer = 'all'; break;
                      case 1: _selectedLayer = 'trips'; break;
                      case 2: _selectedLayer = 'donations'; break;
                      case 3: _selectedLayer = 'libraries'; break;
                    }
                  });
                  _updateMapMarkers();
                },
                tabs: const [
                  Tab(icon: Icon(Icons.map), text: 'Todo'),
                  Tab(icon: Icon(Icons.local_shipping), text: 'Viajes'),
                  Tab(icon: Icon(Icons.volunteer_activism), text: 'Donaciones'),
                  Tab(icon: Icon(Icons.library_books), text: 'Bibliotecas'),
                ],
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedTrip != null
              ? _buildTripRouteView(_selectedTrip!, isMobile)
              : _buildGeneralMapView(isMobile),
    );
  }

  Widget _buildTripRouteView(Trip trip, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Stack(
        children: [
          // Simulación de mapa con ruta
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[100]!, Colors.green[100]!],
              ),
            ),
          ),
          
          // Marcador de origen
          Positioned(
            top: 100,
            left: 100,
            child: _buildLocationMarker(
              trip.originCity,
              trip.originCountry,
              Icons.flight_takeoff,
              Colors.green,
              isMobile,
            ),
          ),
          
          // Marcador de destino
          Positioned(
            bottom: 100,
            right: 100,
            child: _buildLocationMarker(
              trip.destCity,
              trip.destCountry,
              Icons.flight_land,
              Colors.red,
              isMobile,
            ),
          ),
          
          // Información del viaje
          Center(
            child: Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trip.route,
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, color: Colors.grey[600], size: isMobile ? 16 : 20),
                      const SizedBox(width: 8),
                      Text(
                        trip.traveler?.fullName ?? 'Transportista',
                        style: TextStyle(fontSize: isMobile ? 14 : 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.scale, color: Colors.green[600], size: isMobile ? 16 : 20),
                      const SizedBox(width: 8),
                      Text(
                        '${trip.availableKg} kg disponible',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${trip.departDate.day}/${trip.departDate.month}/${trip.departDate.year} - ${trip.arriveDate.day}/${trip.arriveDate.month}/${trip.arriveDate.year}',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralMapView(bool isMobile) {
    return Stack(
      children: [
        // Google Maps real
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            _updateMapMarkers();
          },
          initialCameraPosition: const CameraPosition(
            target: LatLng(40.7128, -74.0060), // Nueva York por defecto
            zoom: 5.0,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false, // Usamos nuestro botón personalizado
          zoomControlsEnabled: true,
          mapToolbarEnabled: true,
          onTap: (LatLng position) {
            // Opcional: manejar toques en el mapa
          },
        ),
        
        // Botón de geolocalización
        Positioned(
          top: 20,
          right: 20,
          child: FloatingActionButton(
            mini: true,
            onPressed: _isLocationLoading ? null : _getCurrentLocation,
            backgroundColor: _currentPosition != null ? Colors.green[600] : Colors.blue[600],
            child: _isLocationLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.my_location, color: Colors.white),
          ),
        ),
        
        // Estadísticas
        Positioned(
          bottom: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de la Red',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.purple[800],
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatRow(Icons.local_shipping, '${_trips.where((t) => t.isActive).length} Viajes Activos', Colors.green, isMobile),
                _buildStatRow(Icons.volunteer_activism, '${_donations.where((d) => d.isPending).length} Donaciones', Colors.blue, isMobile),
                _buildStatRow(Icons.route, '${_trips.map((t) => "${t.originCountry}-${t.destCountry}").toSet().length} Rutas', Colors.purple, isMobile),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationMarker(String city, String country, IconData icon, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: isMobile ? 20 : 24),
          const SizedBox(height: 4),
          Text(
            city,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            country,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatRow(IconData icon, String text, Color color, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isMobile ? 14 : 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}