// ============================================
// SISTEMA DE VALIDACIONES DE SEGURIDAD
// ============================================

class SecurityValidators {
  // VALIDACIONES DE EMAIL
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'El email es requerido';
    }
    
    // Regex completo para email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
    );
    
    if (!emailRegex.hasMatch(email)) {
      return 'Formato de email inválido';
    }
    
    // Verificar longitud
    if (email.length > 254) {
      return 'Email demasiado largo';
    }
    
    // Verificar dominios sospechosos
    final suspiciousDomains = [
      '10minutemail.com',
      'tempmail.org',
      'guerrillamail.com',
      'mailinator.com',
      'throwaway.email',
    ];
    
    final domain = email.split('@').last.toLowerCase();
    if (suspiciousDomains.contains(domain)) {
      return 'No se permiten emails temporales';
    }
    
    return null;
  }

  // VALIDACIONES DE CONTRASEÑA ROBUSTAS
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    // Longitud mínima
    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    
    // Longitud máxima
    if (password.length > 128) {
      return 'La contraseña no puede exceder 128 caracteres';
    }
    
    // Debe contener al menos una minúscula
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Debe contener al menos una letra minúscula';
    }
    
    // Debe contener al menos una mayúscula
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener al menos una letra mayúscula';
    }
    
    // Debe contener al menos un número
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }
    
    // Debe contener al menos un carácter especial
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Debe contener al menos un carácter especial (!@#\$%^&*(),.?":{}|<>)';
    }
    
    // Verificar patrones comunes débiles
    final weakPatterns = [
      'password',
      '123456',
      'qwerty',
      'admin',
      'letmein',
      'welcome',
      'monkey',
      'dragon',
    ];
    
    final lowerPassword = password.toLowerCase();
    for (final pattern in weakPatterns) {
      if (lowerPassword.contains(pattern)) {
        return 'La contraseña contiene patrones comunes inseguros';
      }
    }
    
    // Verificar secuencias
    if (_hasSequentialChars(password)) {
      return 'La contraseña no puede contener secuencias obvias (123, abc, etc.)';
    }
    
    // Verificar repetición excesiva
    if (_hasExcessiveRepetition(password)) {
      return 'La contraseña no puede tener demasiados caracteres repetidos';
    }
    
    return null;
  }

  // CONFIRMACIÓN DE CONTRASEÑA
  static String? validatePasswordConfirmation(String? password, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'La confirmación de contraseña es requerida';
    }
    
    if (password != confirmation) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }

  // VALIDACIONES DE NOMBRE
  static String? validateFullName(String? name) {
    if (name == null || name.isEmpty) {
      return 'El nombre completo es requerido';
    }
    
    // Remover espacios extra
    name = name.trim();
    
    if (name.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    if (name.length > 100) {
      return 'El nombre no puede exceder 100 caracteres';
    }
    
    // Solo letras, espacios, acentos y algunos caracteres especiales
    final nameRegex = RegExp(r"^[a-zA-ZàáâäçéèêëíìîïñóòôöúùûüýÿÀÁÂÄÇÉÈÊËÍÌÎÏÑÓÒÔÖÚÙÛÜÝŸ\s\-\'\.]+$");
    if (!nameRegex.hasMatch(name)) {
      return 'El nombre solo puede contener letras, espacios y guiones';
    }
    
    // Verificar que no sean solo espacios
    if (name.replaceAll(' ', '').isEmpty) {
      return 'El nombre no puede ser solo espacios';
    }
    
    // Verificar patrones sospechosos
    final suspiciousPatterns = [
      'test',
      'prueba',
      'admin',
      'user',
      'usuario',
      '123',
      'xxx',
      'aaa',
    ];
    
    final lowerName = name.toLowerCase();
    for (final pattern in suspiciousPatterns) {
      if (lowerName.contains(pattern)) {
        return 'El nombre parece ser ficticio o de prueba';
      }
    }
    
    return null;
  }

  // VALIDACIONES DE TELÉFONO
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return null; // Teléfono es opcional
    }
    
    // Remover espacios y caracteres especiales excepto + y -
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d\+\-]'), '');
    
    if (cleanPhone.length < 10) {
      return 'El teléfono debe tener al menos 10 dígitos';
    }
    
    if (cleanPhone.length > 15) {
      return 'El teléfono no puede exceder 15 dígitos';
    }
    
    // Verificar formato internacional o nacional
    final phoneRegex = RegExp(r'^\+?[1-9]\d{9,14}$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Formato de teléfono inválido';
    }
    
    return null;
  }

  // VERIFICACIÓN DE FUERZA DE CONTRASEÑA
  static PasswordStrength getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.veryWeak;
    
    int score = 0;
    
    // Longitud
    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;
    if (password.length >= 16) score += 1;
    
    // Diversidad de caracteres
    if (password.contains(RegExp(r'[a-z]'))) score += 1;
    if (password.contains(RegExp(r'[A-Z]'))) score += 1;
    if (password.contains(RegExp(r'[0-9]'))) score += 1;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 2;
    
    // Penalizaciones
    if (_hasSequentialChars(password)) score -= 2;
    if (_hasExcessiveRepetition(password)) score -= 2;
    
    // Bonificaciones por complejidad
    final uniqueChars = password.split('').toSet().length;
    if (uniqueChars >= password.length * 0.7) score += 1;
    
    // Clasificar fuerza
    if (score <= 2) return PasswordStrength.veryWeak;
    if (score <= 4) return PasswordStrength.weak;
    if (score <= 6) return PasswordStrength.medium;
    if (score <= 8) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  // MÉTODOS AUXILIARES PRIVADOS
  static bool _hasSequentialChars(String password) {
    final sequences = [
      '012345',
      '123456',
      '234567',
      '345678',
      '456789',
      'abcdef',
      'bcdefg',
      'cdefgh',
      'defghi',
      'efghij',
      'fghijk',
      'qwerty',
      'asdfgh',
      'zxcvbn',
    ];
    
    final lowerPassword = password.toLowerCase();
    for (final seq in sequences) {
      if (lowerPassword.contains(seq)) return true;
    }
    
    return false;
  }
  
  static bool _hasExcessiveRepetition(String password) {
    final chars = password.split('');
    final charCount = <String, int>{};
    
    for (final char in chars) {
      charCount[char] = (charCount[char] ?? 0) + 1;
    }
    
    // Si algún carácter aparece más del 30% de las veces
    final maxAllowed = (password.length * 0.3).ceil();
    return charCount.values.any((count) => count > maxAllowed);
  }

  // VALIDACIÓN DE COORDENADAS
  static String? validateLatitude(double? lat) {
    if (lat == null) return null;
    if (lat < -90 || lat > 90) {
      return 'Latitud debe estar entre -90 y 90';
    }
    return null;
  }

  static String? validateLongitude(double? lng) {
    if (lng == null) return null;
    if (lng < -180 || lng > 180) {
      return 'Longitud debe estar entre -180 y 180';
    }
    return null;
  }

  // VALIDACIÓN DE CIUDAD/PAÍS
  static String? validateLocation(String? location, String fieldName) {
    if (location == null || location.isEmpty) {
      return '$fieldName es requerido';
    }
    
    location = location.trim();
    
    if (location.length < 2) {
      return '$fieldName debe tener al menos 2 caracteres';
    }
    
    if (location.length > 50) {
      return '$fieldName no puede exceder 50 caracteres';
    }
    
    // Solo letras, espacios y algunos caracteres especiales
    final locationRegex = RegExp(r"^[a-zA-ZàáâäçéèêëíìîïñóòôöúùûüýÿÀÁÂÄÇÉÈÊËÍÌÎÏÑÓÒÔÖÚÙÛÜÝŸ\s\-\'\.]+$");
    if (!locationRegex.hasMatch(location)) {
      return '$fieldName solo puede contener letras y espacios';
    }
    
    return null;
  }

  // VALIDACIÓN ANTI-SPAM
  static String? validateAntiSpam(String? input) {
    if (input == null || input.isEmpty) return null;
    
    // Detectar URLs
    final urlRegex = RegExp(r'https?://[^\s]+');
    if (urlRegex.hasMatch(input)) {
      return 'No se permiten enlaces web';
    }
    
    // Detectar texto repetitivo (spam)
    final words = input.toLowerCase().split(' ');
    final wordCount = <String, int>{};
    
    for (final word in words) {
      if (word.length > 3) {
        wordCount[word] = (wordCount[word] ?? 0) + 1;
      }
    }
    
    // Si alguna palabra se repite más de 3 veces
    if (wordCount.values.any((count) => count > 3)) {
      return 'El texto parece spam (demasiada repetición)';
    }
    
    return null;
  }
}

// ENUM PARA FUERZA DE CONTRASEÑA
enum PasswordStrength {
  veryWeak,
  weak,
  medium,
  strong,
  veryStrong,
}

// EXTENSIÓN PARA OBTENER COLOR Y TEXTO
extension PasswordStrengthExtension on PasswordStrength {
  String get text {
    switch (this) {
      case PasswordStrength.veryWeak:
        return 'Muy débil';
      case PasswordStrength.weak:
        return 'Débil';
      case PasswordStrength.medium:
        return 'Media';
      case PasswordStrength.strong:
        return 'Fuerte';
      case PasswordStrength.veryStrong:
        return 'Muy fuerte';
    }
  }
  
  int get colorValue {
    switch (this) {
      case PasswordStrength.veryWeak:
        return 0xFFD32F2F; // Rojo
      case PasswordStrength.weak:
        return 0xFFFF5722; // Naranja rojo
      case PasswordStrength.medium:
        return 0xFFFF9800; // Naranja
      case PasswordStrength.strong:
        return 0xFF4CAF50; // Verde claro
      case PasswordStrength.veryStrong:
        return 0xFF2E7D32; // Verde oscuro
    }
  }
}