import 'package:flutter/material.dart';

class LanguageViewModel extends ChangeNotifier {
  static const _langs = ['fr', 'ar', 'en'];
  int _index = 0;

  String get lang => _langs[_index];
  bool get isRtl => lang == 'ar';

  /// Plain-text label shown in language toggles — no emoji per design rules.
  String get flagLabel {
    switch (lang) {
      case 'ar':
        return 'AR';
      case 'en':
        return 'EN';
      default:
        return 'FR';
    }
  }

  /// Cycle through FR → AR → EN and back.
  void cycle() {
    _index = (_index + 1) % _langs.length;
    notifyListeners();
  }

  /// Set language by code ('fr' | 'ar' | 'en').
  void setLanguage(String langCode) {
    final idx = _langs.indexOf(langCode);
    if (idx != -1 && idx != _index) {
      _index = idx;
      notifyListeners();
    }
  }
}