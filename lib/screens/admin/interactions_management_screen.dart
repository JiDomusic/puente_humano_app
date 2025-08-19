import 'package:flutter/material.dart';

class InteractionsManagementScreen extends StatefulWidget {
  const InteractionsManagementScreen({super.key});

  @override
  State<InteractionsManagementScreen> createState() => _InteractionsManagementScreenState();
}

class _InteractionsManagementScreenState extends State<InteractionsManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Datos de ejemplo para demostrar la estructura
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _ratings = [];
  List<Map<String, dynamic>> _donations = [];
  List<Map<String, dynamic>> _trips = [];
  List<Map<String, dynamic>> _reports = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadInteractionsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInteractionsData() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Implementar cuando tengas las tablas de interacciones
      // Por ahora simulamos datos para mostrar la estructura
      await _loadMockData();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error cargando datos: $e');
    }
  }

  Future<void> _loadMockData() async {
    // Simular delay de carga
    await Future.delayed(const Duration(milliseconds: 800));
    
    _messages = [
      {
        'id': '1',
        'from_user': 'Juan Pérez',
        'from_email': 'juan@email.com',
        'from_role': 'donante',
        'to_user': 'María García',
        'to_email': 'maria@email.com', 
        'to_role': 'biblioteca',
        'message': 'Hola, tengo libros de matemáticas para donar',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'status': 'sent',
        'is_flagged': false,
      },
      {
        'id': '2',
        'from_user': 'Carlos López',
        'from_email': 'carlos@email.com',
        'from_role': 'transportista',
        'to_user': 'Ana Rodríguez',
        'to_email': 'ana@email.com',
        'to_role': 'donante',
        'message': 'Puedo recoger los libros mañana a las 10am',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'status': 'delivered',
        'is_flagged': false,
      },
      {
        'id': '3',
        'from_user': 'Usuario Sospechoso',
        'from_email': 'spam@email.com',
        'from_role': 'donante',
        'to_user': 'Víctima',
        'to_email': 'victima@email.com',
        'to_role': 'biblioteca',
        'message': 'Haz click en este enlace malicioso: http://scam.com',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
        'status': 'flagged',
        'is_flagged': true,
      },
    ];

    _ratings = [
      {
        'id': '1',
        'from_user': 'María García',
        'from_email': 'maria@email.com',
        'to_user': 'Juan Pérez',
        'to_email': 'juan@email.com',
        'rating': 5,
        'comment': 'Excelente donante, libros en perfecto estado',
        'interaction_type': 'donation',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'is_verified': true,
      },
      {
        'id': '2',
        'from_user': 'Ana Rodríguez',
        'from_email': 'ana@email.com',
        'to_user': 'Carlos López',
        'to_email': 'carlos@email.com',
        'rating': 4,
        'comment': 'Buen transportista, llegó a tiempo',
        'interaction_type': 'transport',
        'timestamp': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        'is_verified': true,
      },
      {
        'id': '3',
        'from_user': 'Fake User',
        'from_email': 'fake@email.com',
        'to_user': 'Innocent User',
        'to_email': 'innocent@email.com',
        'rating': 1,
        'comment': 'Este comentario parece falso y spam',
        'interaction_type': 'donation',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
        'is_verified': false,
      },
    ];

    _donations = [
      {
        'id': '1',
        'donor': 'Juan Pérez',
        'donor_email': 'juan@email.com',
        'recipient': 'María García',
        'recipient_email': 'maria@email.com',
        'title': 'Libros de Matemáticas',
        'description': '20 libros de cálculo y álgebra',
        'status': 'completed',
        'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'completed_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'photos': ['https://example.com/math_books.jpg'],
      },
      {
        'id': '2',
        'donor': 'Ana Rodríguez',
        'donor_email': 'ana@email.com',
        'recipient': null,
        'recipient_email': null,
        'title': 'Novelas Clásicas',
        'description': '15 novelas en excelente estado',
        'status': 'pending',
        'created_at': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
        'completed_at': null,
        'photos': ['https://example.com/novels.jpg'],
      },
    ];

    _trips = [
      {
        'id': '1',
        'traveler': 'Carlos López',
        'traveler_email': 'carlos@email.com',
        'origin': 'Bogotá',
        'destination': 'Medellín',
        'date': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'capacity': 50,
        'available_space': 20,
        'donations_carried': ['1'],
        'status': 'active',
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];

    _reports = [
      {
        'id': '1',
        'reported_user': 'Usuario Sospechoso',
        'reported_email': 'spam@email.com',
        'reporter': 'Víctima',
        'reporter_email': 'victima@email.com',
        'reason': 'spam',
        'description': 'Enviando mensajes con enlaces maliciosos',
        'evidence': 'Mensaje ID: 3',
        'status': 'pending',
        'created_at': DateTime.now().subtract(const Duration(minutes: 20)).toIso8601String(),
        'severity': 'high',
      },
      {
        'id': '2',
        'reported_user': 'Fake User',
        'reported_email': 'fake@email.com',
        'reporter': 'Innocent User',
        'reporter_email': 'innocent@email.com',
        'reason': 'fake_review',
        'description': 'Calificaciones falsas',
        'evidence': 'Rating ID: 3',
        'status': 'under_review',
        'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'severity': 'medium',
      },
    ];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Interacciones'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInteractionsData,
            tooltip: 'Recargar datos',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: const Icon(Icons.chat),
              text: 'Mensajes (${_messages.length})',
            ),
            Tab(
              icon: const Icon(Icons.star_rate),
              text: 'Calificaciones (${_ratings.length})',
            ),
            Tab(
              icon: const Icon(Icons.volunteer_activism),
              text: 'Donaciones (${_donations.length})',
            ),
            Tab(
              icon: const Icon(Icons.flight),
              text: 'Viajes (${_trips.length})',
            ),
            Tab(
              icon: const Icon(Icons.report_problem),
              text: 'Reportes (${_reports.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMessagesTab(),
                _buildRatingsTab(),
                _buildDonationsTab(),
                _buildTripsTab(),
                _buildReportsTab(),
              ],
            ),
    );
  }

  Widget _buildMessagesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageCard(message);
      },
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> message) {
    final isFlagged = message['is_flagged'] ?? false;
    final timestamp = DateTime.parse(message['timestamp']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isFlagged ? 4 : 2,
      color: isFlagged ? Colors.red.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${message['from_user']} → ${message['to_user']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${_getRoleDisplayName(message['from_role'])} → ${_getRoleDisplayName(message['to_role'])}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isFlagged)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'FLAGGED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFlagged ? Colors.red.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message['message'],
                style: TextStyle(
                  color: isFlagged ? Colors.red.shade800 : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDateTime(timestamp),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    if (!isFlagged) ...[
                      TextButton.icon(
                        onPressed: () => _flagMessage(message),
                        icon: const Icon(Icons.flag, size: 16),
                        label: const Text('Flagear'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange,
                        ),
                      ),
                    ],
                    TextButton.icon(
                      onPressed: () => _deleteMessage(message),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Eliminar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _ratings.length,
      itemBuilder: (context, index) {
        final rating = _ratings[index];
        return _buildRatingCard(rating);
      },
    );
  }

  Widget _buildRatingCard(Map<String, dynamic> rating) {
    final isVerified = rating['is_verified'] ?? false;
    final stars = rating['rating'] ?? 0;
    final timestamp = DateTime.parse(rating['timestamp']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: !isVerified ? Colors.yellow.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${rating['from_user']} → ${rating['to_user']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Interacción: ${_getInteractionDisplayName(rating['interaction_type'])}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    ...List.generate(5, (index) => Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    )),
                    const SizedBox(width: 8),
                    if (!isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'NO VERIFICADO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (rating['comment'] != null && rating['comment'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: !isVerified ? Colors.orange.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rating['comment'],
                  style: TextStyle(
                    color: !isVerified ? Colors.orange.shade800 : Colors.black87,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDateTime(timestamp),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    if (!isVerified) ...[
                      TextButton.icon(
                        onPressed: () => _verifyRating(rating),
                        icon: const Icon(Icons.verified, size: 16),
                        label: const Text('Verificar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                      ),
                    ],
                    TextButton.icon(
                      onPressed: () => _deleteRating(rating),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Eliminar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _donations.length,
      itemBuilder: (context, index) {
        final donation = _donations[index];
        return _buildDonationCard(donation);
      },
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    final status = donation['status'];
    final createdAt = DateTime.parse(donation['created_at']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donation['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Por: ${donation['donor']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (donation['recipient'] != null)
                        Text(
                          'Para: ${donation['recipient']}',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              donation['description'],
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Creado: ${_formatDateTime(createdAt)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _viewDonationDetails(donation),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Ver Detalles'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trips.length,
      itemBuilder: (context, index) {
        final trip = _trips[index];
        return _buildTripCard(trip);
      },
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final date = DateTime.parse(trip['date']);
    final createdAt = DateTime.parse(trip['created_at']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trip['origin']} → ${trip['destination']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Viajero: ${trip['traveler']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(trip['status']),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.event, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Fecha: ${_formatDateTime(date)}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.inventory, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Capacidad: ${trip['available_space']}/${trip['capacity']} kg disponibles',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Creado: ${_formatDateTime(createdAt)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _viewTripDetails(trip),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Ver Detalles'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final createdAt = DateTime.parse(report['created_at']);
    final severity = report['severity'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      color: severity == 'high' ? Colors.red.shade50 : 
             severity == 'medium' ? Colors.orange.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usuario Reportado: ${report['reported_user']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Por: ${report['reporter']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _buildSeverityChip(severity),
                    const SizedBox(height: 4),
                    _buildStatusChip(report['status']),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Razón: ${_getReasonDisplayName(report['reason'])}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(report['description']),
                  if (report['evidence'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Evidencia: ${report['evidence']}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reportado: ${_formatDateTime(createdAt)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    if (report['status'] == 'pending') ...[
                      TextButton.icon(
                        onPressed: () => _reviewReport(report),
                        icon: const Icon(Icons.rate_review, size: 16),
                        label: const Text('Revisar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                    ],
                    TextButton.icon(
                      onPressed: () => _takeActionOnReport(report),
                      icon: const Icon(Icons.gavel, size: 16),
                      label: const Text('Acción'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'active':
      case 'completed':
        color = Colors.green;
        label = status == 'active' ? 'ACTIVO' : 'COMPLETADO';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'PENDIENTE';
        break;
      case 'under_review':
        color = Colors.blue;
        label = 'EN REVISIÓN';
        break;
      case 'flagged':
        color = Colors.red;
        label = 'MARCADO';
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSeverityChip(String severity) {
    Color color;
    String label;
    
    switch (severity) {
      case 'high':
        color = Colors.red;
        label = 'ALTA';
        break;
      case 'medium':
        color = Colors.orange;
        label = 'MEDIA';
        break;
      case 'low':
        color = Colors.yellow;
        label = 'BAJA';
        break;
      default:
        color = Colors.grey;
        label = severity.toUpperCase();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
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
        return role ?? 'Desconocido';
    }
  }

  String _getInteractionDisplayName(String? type) {
    switch (type) {
      case 'donation':
        return 'Donación';
      case 'transport':
        return 'Transporte';
      default:
        return type ?? 'Desconocida';
    }
  }

  String _getReasonDisplayName(String? reason) {
    switch (reason) {
      case 'spam':
        return 'Spam';
      case 'fake_review':
        return 'Calificación Falsa';
      case 'inappropriate_content':
        return 'Contenido Inapropiado';
      case 'harassment':
        return 'Acoso';
      default:
        return reason ?? 'Otro';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  // Métodos de acción
  void _flagMessage(Map<String, dynamic> message) {
    _showSuccessSnackBar('Mensaje marcado como sospechoso');
    setState(() {
      message['is_flagged'] = true;
      message['status'] = 'flagged';
    });
  }

  void _deleteMessage(Map<String, dynamic> message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Eliminar este mensaje permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _messages.remove(message));
              _showSuccessSnackBar('Mensaje eliminado');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _verifyRating(Map<String, dynamic> rating) {
    setState(() {
      rating['is_verified'] = true;
    });
    _showSuccessSnackBar('Calificación verificada');
  }

  void _deleteRating(Map<String, dynamic> rating) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Eliminar esta calificación permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _ratings.remove(rating));
              _showSuccessSnackBar('Calificación eliminada');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _viewDonationDetails(Map<String, dynamic> donation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(donation['title']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Donante: ${donation['donor']}'),
              Text('Email: ${donation['donor_email']}'),
              if (donation['recipient'] != null) ...[
                Text('Receptor: ${donation['recipient']}'),
                Text('Email receptor: ${donation['recipient_email']}'),
              ],
              const SizedBox(height: 8),
              Text('Descripción: ${donation['description']}'),
              Text('Estado: ${donation['status']}'),
              Text('Creado: ${_formatDateTime(DateTime.parse(donation['created_at']))}'),
              if (donation['completed_at'] != null)
                Text('Completado: ${_formatDateTime(DateTime.parse(donation['completed_at']))}'),
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

  void _viewTripDetails(Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${trip['origin']} → ${trip['destination']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Viajero: ${trip['traveler']}'),
              Text('Email: ${trip['traveler_email']}'),
              Text('Fecha: ${_formatDateTime(DateTime.parse(trip['date']))}'),
              Text('Capacidad total: ${trip['capacity']} kg'),
              Text('Espacio disponible: ${trip['available_space']} kg'),
              Text('Estado: ${trip['status']}'),
              Text('Donaciones transportadas: ${trip['donations_carried'].length}'),
              Text('Creado: ${_formatDateTime(DateTime.parse(trip['created_at']))}'),
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

  void _reviewReport(Map<String, dynamic> report) {
    setState(() {
      report['status'] = 'under_review';
    });
    _showSuccessSnackBar('Reporte marcado en revisión');
  }

  void _takeActionOnReport(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acción del Moderador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: const Text('Advertir Usuario'),
              onTap: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Advertencia enviada al usuario');
                setState(() => report['status'] = 'resolved');
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Suspender Usuario'),
              onTap: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Usuario suspendido');
                setState(() => report['status'] = 'resolved');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Eliminar Usuario'),
              onTap: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Usuario eliminado');
                setState(() => report['status'] = 'resolved');
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.grey),
              title: const Text('Cerrar Reporte'),
              onTap: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Reporte cerrado sin acción');
                setState(() => report['status'] = 'resolved');
              },
            ),
          ],
        ),
      ),
    );
  }
}