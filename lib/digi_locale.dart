import 'package:flutter/material.dart';

enum LanguageCodeType { es, en, pt }

class DigiLocale {
  static final ValueNotifier<Locale> localeNotifier = ValueNotifier(
    _resolveInitialLocale(),
  );

  static Locale get currentLocale => localeNotifier.value;

  static String get currentLocaleCode => localeNotifier.value.languageCode;

  static const supportedLanguagesCode = LanguageCodeType.values;

  static final supportedLocales = supportedLanguagesCode
      .map((e) => Locale(e.name))
      .toList();

  static void setLocaleFromType(LanguageCodeType languageCodeType) {
    debugPrint('Setting locale from type: $languageCodeType');
    _updateLocale(Locale(languageCodeType.name));
  }

  static Locale _resolveInitialLocale() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;

    return supportedLocales.firstWhere(
      (l) => l.languageCode == systemLocale.languageCode,
      orElse: () => supportedLocales.first,
    );
  }

  static void _updateLocale(Locale newLocale) {
    final resolvedLocale = supportedLocales.firstWhere(
      (l) => l.languageCode == newLocale.languageCode,
      orElse: () => supportedLocales.first,
    );

    localeNotifier.value = resolvedLocale;
  }

  static void setLocaleFromCode(String code) {
    try {
      final locale = supportedLocales.firstWhere(
        (l) => l.languageCode == code,
        orElse: () => supportedLocales.first,
      );
      localeNotifier.value = locale;
      debugPrint('Setting locale from code: $code');
    } catch (e) {
      debugPrint('Error setting locale from code: $code');
    }
  }
}
