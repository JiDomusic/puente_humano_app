import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class TwoFactorService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // CONFIGURACIÓN 2FA
  static const int codeLength = 6;
  static const int codeExpiryMinutes = 10;
  static const int maxAttempts = 3;
  static const int cooldownMinutes = 30;

  // GENERAR CÓDIGO DE VERIFICACIÓN
  String generateVerificationCode() {
    final random = Random.secure();
    String code = '';
    
    for (int i = 0; i < codeLength; i++) {
      code += random.nextInt(10).toString();
    }
    
    return code;
  }

  // HASHEAR CÓDIGO PARA ALMACENAMIENTO SEGURO
  String hashCodeWithSalt(String code, String salt) {
    final bytes = utf8.encode(code + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // GENERAR SALT ÚNICO
  String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  // ENVIAR CÓDIGO POR EMAIL
  Future<bool> sendVerificationCode(String email, String purpose) async {
    try {
      // Verificar cooldown
      final canSend = await _checkCooldown(email, purpose);
      if (!canSend) {
        throw Exception('Debe esperar antes de solicitar otro código');
      }

      // Generar código y salt
      final code = generateVerificationCode();
      final salt = generateSalt();
      final hashedCode = hashCodeWithSalt(code, salt);
      
      // Guardar en base de datos
      await _supabase.from('verification_codes').insert({
        'email': email,
        'purpose': purpose,
        'code_hash': hashedCode,
        'salt': salt,
        'expires_at': DateTime.now().add(const Duration(minutes: codeExpiryMinutes)).toIso8601String(),
        'attempts': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Enviar email (simulado por ahora)
      print('📧 Código 2FA para $email: $code (expires in $codeExpiryMinutes min)');
      
      // TODO: Integrar con servicio de email real
      // await _sendEmailWithCode(email, code, purpose);
      
      return true;
    } catch (e) {
      print('Error enviando código 2FA: $e');
      return false;
    }
  }

  // VERIFICAR CÓDIGO
  Future<TwoFactorResult> verifyCode(String email, String code, String purpose) async {
    try {
      // Buscar código activo
      final result = await _supabase
          .from('verification_codes')
          .select('*')
          .eq('email', email)
          .eq('purpose', purpose)
          .gte('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (result == null) {
        return TwoFactorResult.expired;
      }

      // Verificar intentos máximos
      final attempts = result['attempts'] ?? 0;
      if (attempts >= maxAttempts) {
        await _lockCode(result['id']);
        return TwoFactorResult.maxAttemptsReached;
      }

      // Verificar código
      final salt = result['salt'];
      final storedHash = result['code_hash'];
      final inputHash = hashCodeWithSalt(code, salt);

      // Incrementar intentos
      await _supabase
          .from('verification_codes')
          .update({'attempts': attempts + 1})
          .eq('id', result['id']);

      if (inputHash == storedHash) {
        // Código correcto - marcar como usado
        await _markCodeAsUsed(result['id']);
        return TwoFactorResult.success;
      } else {
        return TwoFactorResult.invalid;
      }
    } catch (e) {
      print('Error verificando código 2FA: $e');
      return TwoFactorResult.error;
    }
  }

  // VERIFICAR COOLDOWN
  Future<bool> _checkCooldown(String email, String purpose) async {
    try {
      final cooldownEnd = DateTime.now().subtract(const Duration(minutes: cooldownMinutes));
      
      final recentCode = await _supabase
          .from('verification_codes')
          .select('created_at')
          .eq('email', email)
          .eq('purpose', purpose)
          .gte('created_at', cooldownEnd.toIso8601String())
          .limit(1)
          .maybeSingle();

      return recentCode == null;
    } catch (e) {
      print('Error verificando cooldown: $e');
      return false;
    }
  }

  // MARCAR CÓDIGO COMO USADO
  Future<void> _markCodeAsUsed(String codeId) async {
    await _supabase
        .from('verification_codes')
        .update({
          'used_at': DateTime.now().toIso8601String(),
          'is_used': true,
        })
        .eq('id', codeId);
  }

  // BLOQUEAR CÓDIGO POR EXCESO DE INTENTOS
  Future<void> _lockCode(String codeId) async {
    await _supabase
        .from('verification_codes')
        .update({
          'is_locked': true,
          'locked_at': DateTime.now().toIso8601String(),
        })
        .eq('id', codeId);
  }

  // LIMPIAR CÓDIGOS EXPIRADOS
  Future<void> cleanupExpiredCodes() async {
    try {
      await _supabase
          .from('verification_codes')
          .delete()
          .lt('expires_at', DateTime.now().toIso8601String());
      
      print('✅ Códigos expirados limpiados');
    } catch (e) {
      print('Error limpiando códigos expirados: $e');
    }
  }

  // OBTENER ESTADÍSTICAS DE SEGURIDAD
  Future<Map<String, dynamic>> getSecurityStats(String email) async {
    try {
      final stats = await _supabase
          .from('verification_codes')
          .select('purpose, created_at, attempts, is_used')
          .eq('email', email)
          .gte('created_at', DateTime.now().subtract(const Duration(days: 30)).toIso8601String());

      final totalCodes = stats.length;
      final successfulVerifications = stats.where((s) => s['is_used'] == true).length;
      final failedAttempts = stats.fold<int>(0, (sum, s) => sum + ((s['attempts'] ?? 0) as int)) - successfulVerifications;

      return {
        'total_codes_sent': totalCodes,
        'successful_verifications': successfulVerifications,
        'failed_attempts': failedAttempts,
        'success_rate': totalCodes > 0 ? (successfulVerifications / totalCodes) : 0,
        'last_verification': stats.isNotEmpty 
            ? stats.where((s) => s['is_used'] == true).isNotEmpty
                ? stats.where((s) => s['is_used'] == true).last['created_at']
                : null
            : null,
      };
    } catch (e) {
      print('Error obteniendo estadísticas de seguridad: $e');
      return {};
    }
  }

  // VERIFICAR SI EL USUARIO TIENE 2FA HABILITADO
  Future<bool> isTwoFactorEnabled(String userId) async {
    try {
      final user = await _supabase
          .from('users')
          .select('two_factor_enabled')
          .eq('id', userId)
          .single();
      
      return user['two_factor_enabled'] ?? false;
    } catch (e) {
      print('Error verificando 2FA habilitado: $e');
      return false;
    }
  }

  // HABILITAR/DESHABILITAR 2FA
  Future<bool> setTwoFactorEnabled(String userId, bool enabled) async {
    try {
      await _supabase
          .from('users')
          .update({'two_factor_enabled': enabled})
          .eq('id', userId);
      
      return true;
    } catch (e) {
      print('Error configurando 2FA: $e');
      return false;
    }
  }

  // GENERAR CÓDIGOS DE RESPALDO
  List<String> generateBackupCodes() {
    final codes = <String>[];
    final random = Random.secure();
    
    for (int i = 0; i < 10; i++) {
      String code = '';
      for (int j = 0; j < 8; j++) {
        code += random.nextInt(10).toString();
      }
      // Formatear como XXXX-XXXX
      code = '${code.substring(0, 4)}-${code.substring(4, 8)}';
      codes.add(code);
    }
    
    return codes;
  }

  // GUARDAR CÓDIGOS DE RESPALDO
  Future<bool> saveBackupCodes(String userId, List<String> codes) async {
    try {
      // Hashear códigos antes de guardar
      final hashedCodes = codes.map((code) {
        final salt = generateSalt();
        return {
          'user_id': userId,
          'code_hash': hashCodeWithSalt(code.replaceAll('-', ''), salt),
          'salt': salt,
          'is_used': false,
          'created_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      // Eliminar códigos anteriores
      await _supabase
          .from('backup_codes')
          .delete()
          .eq('user_id', userId);

      // Insertar nuevos códigos
      await _supabase
          .from('backup_codes')
          .insert(hashedCodes);

      return true;
    } catch (e) {
      print('Error guardando códigos de respaldo: $e');
      return false;
    }
  }

  // VERIFICAR CÓDIGO DE RESPALDO
  Future<bool> verifyBackupCode(String userId, String code) async {
    try {
      final cleanCode = code.replaceAll('-', '');
      
      final backupCodes = await _supabase
          .from('backup_codes')
          .select('*')
          .eq('user_id', userId)
          .eq('is_used', false);

      for (final backupCode in backupCodes) {
        final salt = backupCode['salt'];
        final storedHash = backupCode['code_hash'];
        final inputHash = hashCodeWithSalt(cleanCode, salt);

        if (inputHash == storedHash) {
          // Marcar código como usado
          await _supabase
              .from('backup_codes')
              .update({
                'is_used': true,
                'used_at': DateTime.now().toIso8601String(),
              })
              .eq('id', backupCode['id']);

          return true;
        }
      }

      return false;
    } catch (e) {
      print('Error verificando código de respaldo: $e');
      return false;
    }
  }
}

// ENUM PARA RESULTADOS DE VERIFICACIÓN
enum TwoFactorResult {
  success,
  invalid,
  expired,
  maxAttemptsReached,
  error,
}

// EXTENSIÓN PARA MENSAJES
extension TwoFactorResultExtension on TwoFactorResult {
  String get message {
    switch (this) {
      case TwoFactorResult.success:
        return 'Código verificado correctamente';
      case TwoFactorResult.invalid:
        return 'Código incorrecto';
      case TwoFactorResult.expired:
        return 'Código expirado o no encontrado';
      case TwoFactorResult.maxAttemptsReached:
        return 'Máximo de intentos alcanzado';
      case TwoFactorResult.error:
        return 'Error del sistema';
    }
  }

  bool get isSuccess => this == TwoFactorResult.success;
}