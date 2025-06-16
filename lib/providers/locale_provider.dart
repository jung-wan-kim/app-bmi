import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 현재 로케일 프로바이더
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('ko', 'KR')) {
    _loadLocale();
  }

  static const String _localeKey = 'app_locale';

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey) ?? 'ko';
    state = Locale(languageCode, languageCode == 'ko' ? 'KR' : 'US');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
  
  void toggleLocale() {
    final newLocale = state.languageCode == 'ko' 
        ? const Locale('en', 'US') 
        : const Locale('ko', 'KR');
    setLocale(newLocale);
  }
}