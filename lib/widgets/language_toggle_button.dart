import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LanguageToggleButton extends StatelessWidget {
  final bool isIconOnly;
  final Color? backgroundColor;
  final Color? textColor;
  
  const LanguageToggleButton({
    super.key,
    this.isIconOnly = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        if (isIconOnly) {
          return IconButton(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                languageProvider.isSpanish ? 'ES' : 'EN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: textColor ?? Colors.grey[700],
                ),
              ),
            ),
            onPressed: () => languageProvider.toggleLanguage(),
            tooltip: languageProvider.isSpanish ? 'Switch to English' : 'Cambiar a Español',
          );
        }
        
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                context,
                'ES',
                '🇪🇸',
                languageProvider.isSpanish,
                () => languageProvider.changeLanguage('es'),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey[300],
              ),
              _buildLanguageOption(
                context,
                'EN',
                '🇺🇸',
                languageProvider.isEnglish,
                () => languageProvider.changeLanguage('en'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildLanguageOption(
    BuildContext context,
    String code,
    String flag,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              code,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected 
                  ? Colors.white 
                  : (textColor ?? Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}