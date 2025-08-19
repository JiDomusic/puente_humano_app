import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Bienvenido de vuelta!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Esperar un momento para que se vea el mensaje
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Navegar a home
      context.go('/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Error al iniciar sesión'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 16.0 : 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                
                // Icono y título responsivos
                Icon(
                  Icons.library_books,
                  size: MediaQuery.of(context).size.width < 600 ? 60 : 80,
                  color: Colors.blue[600],
                ),
                
                SizedBox(height: MediaQuery.of(context).size.width < 600 ? 16 : 24),
                
                Text(
                  'PuenteHumano',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                    fontSize: MediaQuery.of(context).size.width < 600 ? 24 : 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Un puente humano para que los libros\nlleguen donde más se necesitan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: MediaQuery.of(context).size.width < 600 ? 32 : 48),
                
                // Campo email responsivo
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                    ),
                    prefixIcon: const Icon(Icons.email),
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width < 600 ? 12 : 16,
                      vertical: MediaQuery.of(context).size.width < 600 ? 12 : 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    if (!value.contains('@')) {
                      return 'Por favor ingresa un email válido';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: MediaQuery.of(context).size.width < 600 ? 16 : 24),
                
                // Campo contraseña responsivo
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width < 600 ? 12 : 16,
                      vertical: MediaQuery.of(context).size.width < 600 ? 12 : 16,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),

                SizedBox(height: MediaQuery.of(context).size.width < 600 ? 24 : 32),
                
                // Botón de login responsivo
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.width < 600 ? 12 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? SizedBox(
                              height: MediaQuery.of(context).size.width < 600 ? 16 : 20,
                              width: MediaQuery.of(context).size.width < 600 ? 16 : 20,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),

                SizedBox(height: MediaQuery.of(context).size.width < 600 ? 16 : 24),
                
                // Link a registro responsivo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: Text(
                        'Regístrate',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: MediaQuery.of(context).size.width < 600 ? 12 : 16),
                
                // Botón para admins responsivo
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/admin-login'),
                    icon: Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: MediaQuery.of(context).size.width < 600 ? 18 : 20,
                    ),
                    label: Text(
                      '👑 ACCESO DE ADMINISTRADOR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width < 600 ? 12 : 16,
                      ),
                      elevation: 8,
                      shadowColor: Colors.red[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: MediaQuery.of(context).size.width < 600 ? 12 : 16),
                
                // Link recuperar contraseña responsivo
                TextButton(
                  onPressed: () {
                    _showPasswordResetDialog();
                  },
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
                    ),
                  ),
                ),
                
                // Espaciado final flexible
                Flexible(
                  child: SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  void _showPasswordResetDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa tu email para recibir un enlace de recuperación'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                final authProvider = context.read<AuthProvider>();
                final success = await authProvider.resetPassword(emailController.text);
                
                if (mounted && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success 
                          ? 'Revisa tu email para el enlace de recuperación'
                          : authProvider.error ?? 'Error enviando email'
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}