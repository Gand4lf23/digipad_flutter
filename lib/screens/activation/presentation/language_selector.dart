import 'package:digipad_flutter/main.dart';
import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final Color color;

  const LanguageSelector({super.key, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    // Get current locale or default to English if null
    final currentLocale = Localizations.localeOf(context);

    return DropdownButton<Locale>(
      value: currentLocale,
      menuWidth: 140,
      dropdownColor: Colors.grey[900],
      icon: Icon(Icons.language, color: color),
      underline: Container(), // Remove underline
      style: TextStyle(color: color, fontSize: 16),
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          MyApp.setLocale(context, newLocale);
        }
      },
      items: const [
        DropdownMenuItem(value: Locale('en'), child: Text('English')),
        DropdownMenuItem(value: Locale('es'), child: Text('Español')),
        DropdownMenuItem(value: Locale('pt'), child: Text('Português')),
      ],
      selectedItemBuilder: (context) {
        return const [Locale('en'), Locale('es'), Locale('pt')].map((locale) {
          // Show short code in the button itself to save space
          return Center(
            child: Text(
              locale.languageCode.toUpperCase(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          );
        }).toList();
      },
    );
  }
}
