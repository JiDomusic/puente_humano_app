import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider_simple.dart';
import '../../core/services/trip_service.dart';
import '../../core/models/trip.dart';
import '../../utils/app_localizations.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tripService = TripService();
  bool _isLoading = false;

  // Controladores del formulario
  final _originCityController = TextEditingController();
  final _originCountryController = TextEditingController();
  final _destCityController = TextEditingController();
  final _destCountryController = TextEditingController();
  final _capacityController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _departDate;
  DateTime? _arriveDate;

  @override
  void dispose() {
    _originCityController.dispose();
    _originCountryController.dispose();
    _destCityController.dispose();
    _destCountryController.dispose();
    _capacityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDepartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDepartDate 
          ? (_departDate ?? DateTime.now().add(const Duration(days: 1)))
          : (_arriveDate ?? DateTime.now().add(const Duration(days: 2))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isDepartDate) {
          _departDate = picked;
          // Si la fecha de llegada es antes que la de salida, ajustarla
          if (_arriveDate != null && _arriveDate!.isBefore(_departDate!)) {
            _arriveDate = _departDate!.add(const Duration(days: 1));
          }
        } else {
          _arriveDate = picked;
        }
      });
    }
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_departDate == null || _arriveDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona las fechas de salida y llegada'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = context.read<SimpleAuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Usuario no encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final trip = Trip(
        id: '',
        tripCode: '',
        travelerId: currentUser.id,
        originCity: _originCityController.text.trim(),
        originCountry: _originCountryController.text.trim(),
        originLat: 0.0, // TODO: Implementar geocoding
        originLng: 0.0,
        destCity: _destCityController.text.trim(),
        destCountry: _destCountryController.text.trim(),
        destLat: 0.0, // TODO: Implementar geocoding
        destLng: 0.0,
        departDate: _departDate!,
        arriveDate: _arriveDate!,
        capacityKg: double.parse(_capacityController.text),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      final success = await _tripService.createTrip(trip);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Viaje creado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // Volver a la pantalla anterior
      } else {
        throw Exception('Error al crear el viaje');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear viaje: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createTrip),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información del transportista
                    _buildInfoSection(),
                    const SizedBox(height: 24),

                    // Origen
                    _buildOriginSection(),
                    const SizedBox(height: 24),

                    // Destino
                    _buildDestinationSection(),
                    const SizedBox(height: 24),

                    // Fechas
                    _buildDatesSection(),
                    const SizedBox(height: 24),

                    // Capacidad
                    _buildCapacitySection(),
                    const SizedBox(height: 24),

                    // Notas opcionales
                    _buildNotesSection(),
                    const SizedBox(height: 32),

                    // Botón de crear
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createTrip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.createTrip,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Información del Viaje',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Como transportista, puedes ayudar a conectar donantes con bibliotecas llevando libros en tus viajes.',
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

  Widget _buildOriginSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flight_takeoff, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Origen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _originCityController,
              decoration: InputDecoration(
                labelText: 'Ciudad de origen',
                hintText: 'Ej: Madrid',
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa la ciudad de origen';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _originCountryController,
              decoration: InputDecoration(
                labelText: 'País de origen',
                hintText: 'Ej: España',
                prefixIcon: const Icon(Icons.flag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa el país de origen';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flight_land, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  'Destino',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _destCityController,
              decoration: InputDecoration(
                labelText: 'Ciudad de destino',
                hintText: 'Ej: Quito',
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa la ciudad de destino';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _destCountryController,
              decoration: InputDecoration(
                labelText: 'País de destino',
                hintText: 'Ej: Ecuador',
                prefixIcon: const Icon(Icons.flag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa el país de destino';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.date_range, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  'Fechas del Viaje',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha de salida',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _departDate != null 
                                ? '${_departDate!.day}/${_departDate!.month}/${_departDate!.year}'
                                : 'Seleccionar fecha',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _departDate != null ? FontWeight.bold : FontWeight.normal,
                              color: _departDate != null ? Colors.black : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha de llegada',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _arriveDate != null 
                                ? '${_arriveDate!.day}/${_arriveDate!.month}/${_arriveDate!.year}'
                                : 'Seleccionar fecha',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _arriveDate != null ? FontWeight.bold : FontWeight.normal,
                              color: _arriveDate != null ? Colors.black : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacitySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Capacidad de Carga',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              decoration: InputDecoration(
                labelText: 'Capacidad disponible (kg)',
                hintText: 'Ej: 10',
                suffixText: 'kg',
                prefixIcon: const Icon(Icons.scale),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: 'Peso máximo de libros que puedes transportar',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa la capacidad';
                }
                final capacity = double.tryParse(value);
                if (capacity == null || capacity <= 0) {
                  return 'Por favor ingresa una capacidad válida mayor a 0';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  'Notas Adicionales (Opcional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notas o condiciones especiales',
                hintText: 'Ej: Solo libros en español, condiciones de entrega, etc.',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}