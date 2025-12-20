import 'dart:convert';
import 'package:flutter/services.dart';

class TextService {
  static Map<String, dynamic>? _texts;
  static bool _isLoaded = false;

  static Future<void> loadTexts() async {
    if (_isLoaded) return;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/texts.json');
      _texts = json.decode(jsonString) as Map<String, dynamic>;
      _isLoaded = true;
    } catch (e) {
      print('Error loading texts.json: $e');
      _texts = {}; // Fallback to empty map
      _isLoaded = true;
    }
  }

  static String get(String path, {String defaultValue = ''}) {
    if (_texts == null) return defaultValue;
    
    final keys = path.split('.');
    dynamic value = _texts;
    
    for (final key in keys) {
      if (value is Map<String, dynamic> && value.containsKey(key)) {
        value = value[key];
      } else {
        return defaultValue;
      }
    }
    
    return value is String ? value : defaultValue;
  }

  static Map<String, dynamic>? getSection(String section) {
    if (_texts == null) return null;
    return _texts![section] as Map<String, dynamic>?;
  }

  static bool get isLoaded => _isLoaded;
}

