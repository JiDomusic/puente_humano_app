import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/config/app_config.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWide = screenSize.width > 600;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.all(isWide ? 48.0 : 24.0),
                child: Column(
                  children: [
                    SizedBox(height: isWide ? 40 : 20),
                    
                    // Logo y título
                    Container(
                      width: isWide ? 150 : 120,
                      height: isWide ? 150 : 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.book,
                        size: isWide ? 80 : 60,
                        color: const Color(AppConfig.primaryColorValue),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Text(
                      AppConfig.appName,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isWide ? 48 : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Container(
                      constraints: BoxConstraints(maxWidth: isWide ? 600 : double.infinity),
                      child: Text(
                        AppConfig.appSlogan,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isWide ? 24 : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    SizedBox(height: isWide ? 60 : 40),
                    
                    // Descripción
                    Container(
                      constraints: BoxConstraints(maxWidth: isWide ? 800 : double.infinity),
                      padding: EdgeInsets.all(isWide ? 32 : 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Conecta donantes, viajeros y bibliotecas',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: isWide ? 20 : null,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isWide ? 24 : 16),
                          if (isWide)
                            Row(
                              children: [
                                _buildFeature(context, Icons.volunteer_activism, 'Dona libros'),
                                _buildFeature(context, Icons.local_shipping, 'Transporta'),
                                _buildFeature(context, Icons.library_books, 'Recibe'),
                              ],
                            )
                          else
                            Column(
                              children: [
                                Row(
                                  children: [
                                    _buildFeature(context, Icons.volunteer_activism, 'Dona libros'),
                                    _buildFeature(context, Icons.local_shipping, 'Transporta'),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildFeature(context, Icons.library_books, 'Recibe'),
                              ],
                            ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: isWide ? 60 : 40),
                    
                    // Botones de acción
                    Container(
                      constraints: BoxConstraints(maxWidth: isWide ? 400 : double.infinity),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context.push('/login'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                padding: EdgeInsets.symmetric(vertical: isWide ? 20 : 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: isWide ? 20 : 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => context.push('/register'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white, width: 2),
                                padding: EdgeInsets.symmetric(vertical: isWide ? 20 : 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Registrarse',
                                style: TextStyle(
                                  fontSize: isWide ? 20 : 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Botón de test (temporal)
                    Center(
                      child: TextButton(
                        onPressed: () => context.push('/test'),
                        child: const Text(
                          '🧪 Test Sistema',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(BuildContext context, IconData icon, String text) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}