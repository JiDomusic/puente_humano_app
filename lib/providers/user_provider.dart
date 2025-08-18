import 'package:flutter/material.dart';
import '../core/services/database_service.dart';
import '../core/models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<UserProfile> _users = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<UserProfile> get users => _users;
  List<UserProfile> get donantes => _users.where((u) => u.role == UserRole.donante).toList();
  List<UserProfile> get transportistas => _users.where((u) => u.role == UserRole.transportista).toList();
  List<UserProfile> get bibliotecas => _users.where((u) => u.role == UserRole.biblioteca).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsers() async {
    _setLoading(true);
    _clearError();

    try {
      _users = await _databaseService.getUsers();
      notifyListeners();
    } catch (e) {
      _setError('Error cargando usuarios: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<UserProfile?> getUserById(String userId) async {
    try {
      return await _databaseService.getUserById(userId);
    } catch (e) {
      _setError('Error obteniendo usuario: $e');
      return null;
    }
  }

  List<UserProfile> getUsersByRole(UserRole role) {
    return _users.where((user) => user.role == role).toList();
  }

  List<UserProfile> searchUsers(String query) {
    if (query.isEmpty) return _users;
    
    return _users.where((user) =>
      user.fullName.toLowerCase().contains(query.toLowerCase()) ||
      user.city.toLowerCase().contains(query.toLowerCase()) ||
      user.country.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}