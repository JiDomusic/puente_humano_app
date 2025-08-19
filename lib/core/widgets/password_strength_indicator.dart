import 'package:flutter/material.dart';
import '../utils/validators.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showTips;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showTips = true,
  });

  @override
  Widget build(BuildContext context) {
    final strength = SecurityValidators.getPasswordStrength(password);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de progreso de fuerza
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: _getProgressValue(strength),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(strength.colorValue),
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strength.text,
              style: TextStyle(
                color: Color(strength.colorValue),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        
        if (showTips && password.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildPasswordTips(),
        ],
      ],
    );
  }

  double _getProgressValue(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return 0.2;
      case PasswordStrength.weak:
        return 0.4;
      case PasswordStrength.medium:
        return 0.6;
      case PasswordStrength.strong:
        return 0.8;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }

  Widget _buildPasswordTips() {
    final tips = <String, bool>{
      'Al menos 8 caracteres': password.length >= 8,
      'Incluye minúscula (a-z)': password.contains(RegExp(r'[a-z]')),
      'Incluye mayúscula (A-Z)': password.contains(RegExp(r'[A-Z]')),
      'Incluye número (0-9)': password.contains(RegExp(r'[0-9]')),
      'Incluye carácter especial': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      'No contiene secuencias': !_hasSequentialChars(password),
      'Caracteres únicos': !_hasExcessiveRepetition(password),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requisitos de seguridad:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...tips.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  entry.value ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: entry.value ? Colors.green : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  entry.key,
                  style: TextStyle(
                    color: entry.value ? Colors.green[700] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // Métodos auxiliares (duplicados de validators.dart para este widget)
  bool _hasSequentialChars(String password) {
    final sequences = ['123', 'abc', 'qwe', 'asd', 'zxc'];
    final lowerPassword = password.toLowerCase();
    return sequences.any((seq) => lowerPassword.contains(seq));
  }
  
  bool _hasExcessiveRepetition(String password) {
    if (password.length < 3) return false;
    final chars = password.split('');
    final charCount = <String, int>{};
    
    for (final char in chars) {
      charCount[char] = (charCount[char] ?? 0) + 1;
    }
    
    final maxAllowed = (password.length * 0.3).ceil();
    return charCount.values.any((count) => count > maxAllowed);
  }
}