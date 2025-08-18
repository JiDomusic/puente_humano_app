import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('es');
  
  Locale get locale => _locale;
  
  bool get isSpanish => _locale.languageCode == 'es';
  bool get isEnglish => _locale.languageCode == 'en';
  
  LanguageProvider() {
    _loadLanguagePreference();
  }
  
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'es';
    _locale = Locale(languageCode);
    notifyListeners();
  }
  
  Future<void> changeLanguage(String languageCode) async {
    if (languageCode == _locale.languageCode) return;
    
    _locale = Locale(languageCode);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    
    notifyListeners();
  }
  
  Future<void> toggleLanguage() async {
    final newLanguage = _locale.languageCode == 'es' ? 'en' : 'es';
    await changeLanguage(newLanguage);
  }
}