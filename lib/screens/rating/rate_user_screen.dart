import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/user_service.dart';
import '../../providers/auth_provider_simple.dart';
import '../../widgets/star_rating.dart';
import '../../utils/app_localizations.dart';

class RateUserScreen extends StatefulWidget {
  final String userId;
  final String? interactionType; // 'donation', 'trip', 'general'
  final String? interactionId;
  
  const RateUserScreen({
    super.key,
    required this.userId,
    this.interactionType,
    this.interactionId,
  });

  @override
  State<RateUserScreen> createState() => _RateUserScreenState();
}

class _RateUserScreenState extends State<RateUserScreen> {
  final UserService _userService = UserService();
  final TextEditingController _commentController = TextEditingController();
  
  UserProfile? _userToRate;
  double _rating = 5.0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  
  final List<String> _predefinedComments = [
    'Excelente comunicación y puntualidad',
    'Muy confiable y profesional',
    'Gran colaboración en el transporte de libros',
    'Persona muy amable y servicial',
    'Cumplió con lo acordado perfectamente',
    'Recomiendo trabajar con esta persona',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _userService.getUserById(widget.userId);
      setState(() {
        _userToRate = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar usuario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitRating() async {
    if (_userToRate == null) return;

    final authProvider = context.read<SimpleAuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);

    try {
      await _userService.rateUser(
        ratedUserId: widget.userId,
        raterUserId: currentUser.id,
        rating: _rating,
        comment: _commentController.text.trim(),
        interactionType: widget.interactionType,
        interactionId: widget.interactionId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calificación enviada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar calificación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Calificar Usuario'),
        backgroundColor: Colors.amber[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userToRate == null
              ? const Center(child: Text('Usuario no encontrado'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información del usuario
                      _buildUserInfo(isMobile),
                      
                      SizedBox(height: isMobile ? 24 : 32),
                      
                      // Sección de calificación
                      _buildRatingSection(isMobile),
                      
                      SizedBox(height: isMobile ? 24 : 32),
                      
                      // Comentarios predefinidos
                      _buildPredefinedComments(isMobile),
                      
                      SizedBox(height: isMobile ? 16 : 24),
                      
                      // Comentario personalizado
                      _buildCustomComment(isMobile),
                      
                      SizedBox(height: isMobile ? 32 : 40),
                      
                      // Botones de acción
                      _buildActionButtons(isMobile),
                    ],
                  ),
                ),
    );
  }

  Widget _buildUserInfo(bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: isMobile ? 30 : 40,
              backgroundImage: _userToRate!.photo != null 
                  ? NetworkImage(_userToRate!.photo!) 
                  : null,
              backgroundColor: Colors.grey[300],
              child: _userToRate!.photo == null
                  ? Text(
                      _userToRate!.fullName.isNotEmpty 
                          ? _userToRate!.fullName[0].toUpperCase() 
                          : '?',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    )
                  : null,
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userToRate!.fullName,
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRoleDisplayName(_userToRate!.role),
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: _getRoleColor(_userToRate!.role),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_userToRate!.city}, ${_userToRate!.country}',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      StarRating(
                        rating: _userToRate!.averageRating ?? 5.0,
                        size: isMobile ? 16 : 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(_userToRate!.averageRating ?? 5.0).toStringAsFixed(1)} (${_userToRate!.ratingsCount} calificaciones)',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu Calificación',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.amber[800],
              ),
            ),
            SizedBox(height: isMobile ? 16 : 20),
            Center(
              child: Column(
                children: [
                  InteractiveStarRating(
                    initialRating: _rating,
                    size: isMobile ? 40 : 48,
                    onRatingChanged: (rating) {
                      setState(() => _rating = rating);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getRatingDescription(_rating),
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: _getRatingColor(_rating),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredefinedComments(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comentarios Sugeridos',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _predefinedComments.map((comment) {
            return ActionChip(
              label: Text(
                comment,
                style: TextStyle(fontSize: isMobile ? 12 : 14),
              ),
              onPressed: () {
                setState(() {
                  if (_commentController.text.isEmpty) {
                    _commentController.text = comment;
                  } else {
                    _commentController.text += '. $comment';
                  }
                });
              },
              backgroundColor: Colors.amber[50],
              side: BorderSide(color: Colors.amber[200]!),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomComment(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comentario (Opcional)',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        TextField(
          controller: _commentController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Comparte tu experiencia trabajando con ${_userToRate!.fullName}...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.amber[600]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[400]!),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(fontSize: isMobile ? 16 : 18),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitRating,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Enviar Calificación',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.donante:
        return 'Donante';
      case UserRole.transportista:
        return 'Transportista';
      case UserRole.biblioteca:
        return 'Biblioteca';
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.donante:
        return Colors.blue[600]!;
      case UserRole.transportista:
        return Colors.green[600]!;
      case UserRole.biblioteca:
        return Colors.purple[600]!;
    }
  }

  String _getRatingDescription(double rating) {
    if (rating >= 4.5) return 'Excelente';
    if (rating >= 3.5) return 'Muy Bueno';
    if (rating >= 2.5) return 'Bueno';
    if (rating >= 1.5) return 'Regular';
    return 'Necesita Mejorar';
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 3.5) return Colors.lightGreen;
    if (rating >= 2.5) return Colors.amber;
    if (rating >= 1.5) return Colors.orange;
    return Colors.red;
  }
}