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
      backgroundColor: const Color(0xE6D282),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xE6D282),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: EdgeInsets.all(isWide ? 48.0 : 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: isWide ? 40 : 20),

                      // Logo
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

                      // Nombre app
                      Text(
                        AppConfig.appName,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: const Color(0xFF8B4513),
                          fontWeight: FontWeight.bold,
                          fontSize: isWide ? 48 : null,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Slogan
                      Container(
                        constraints: BoxConstraints(maxWidth: isWide ? 600 : double.infinity),
                        child: Text(
                          AppConfig.appSlogan,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF8B4513),
                            fontSize: isWide ? 24 : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: isWide ? 60 : 40),

                      // Bloque amarillo de features
                      Container(
                        constraints: BoxConstraints(maxWidth: isWide ? 800 : double.infinity),
                        padding: EdgeInsets.all(isWide ? 32 : 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8C807).withOpacity(0.8),
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
                            _buildFeaturesLayout(context, isWide),
                          ],
                        ),
                      ),

                      SizedBox(height: isWide ? 60 : 40),

                      // Botones
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
                                  foregroundColor: const Color(0xFF1976D2),
                                  elevation: 6,
                                  shadowColor: Colors.black26,
                                  padding: EdgeInsets.symmetric(vertical: isWide ? 20 : 16, horizontal: 24),
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
                                  foregroundColor: const Color(0xFF8B4513),
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white, width: 2),
                                  padding: EdgeInsets.symmetric(vertical: isWide ? 20 : 16, horizontal: 24),
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

                      // Botón test
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
      ),
    );
  }

  /// Layout de features sin duplicar código
  Widget _buildFeaturesLayout(BuildContext context, bool isWide) {
    if (isWide) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildFeature(context, Icons.volunteer_activism, 'Dona libros'),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildFeature(context, Icons.local_shipping, 'Transporta'),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildFeature(context, Icons.library_books, 'Recibe'),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: _buildFeature(context, Icons.local_shipping, 'Transporta'),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildFeature(context, Icons.volunteer_activism, 'Dona libros'),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildFeature(context, Icons.library_books, 'Recibe'),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  /// Widget de cada feature
  Widget _buildFeature(BuildContext context, IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
