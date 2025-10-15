import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});
  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    
    final languageData = [
      {'code': 'en', 'name': 'english', 'flag': '🇺🇸'},
      {'code': 'hi', 'name': 'hindi', 'flag': '🇮🇳'},
      {'code': 'mr', 'name': 'marathi', 'flag': '🇮🇳'},
      {'code': 'ta', 'name': 'tamil', 'flag': '🇮🇳'},
      {'code': 'te', 'name': 'telugu', 'flag': '🇮🇳'},
      {'code': 'kn', 'name': 'kannada', 'flag': '🇮🇳'},
      {'code': 'ml', 'name': 'malayalam', 'flag': '🇮🇳'},
    ];

    return PopupMenuButton<String>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            currentLocale.languageCode.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      onSelected: (String languageCode) async {
        await context.setLocale(Locale(languageCode));
        if (context.mounted) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      },
      itemBuilder: (BuildContext context) {
        return languageData.map((language) {
          final isSelected = currentLocale.languageCode == language['code'];
          return PopupMenuItem<String>(
            value: language['code'],
            child: Row(
              children: [
                Text(language['flag']!, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(
                  language['name']!.tr(),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.teal : null,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  const Icon(Icons.check, color: Colors.teal, size: 20),
                ],
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

// Alternative dropdown widget for use within forms
class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});
  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    
    final languageData = [
      {'code': 'en', 'name': 'english', 'flag': '🇺🇸'},
      {'code': 'hi', 'name': 'hindi', 'flag': '🇮🇳'},
      {'code': 'mr', 'name': 'marathi', 'flag': '🇮🇳'},
      {'code': 'ta', 'name': 'tamil', 'flag': '🇮🇳'},
      {'code': 'te', 'name': 'telugu', 'flag': '🇮🇳'},
      {'code': 'kn', 'name': 'kannada', 'flag': '🇮🇳'},
      {'code': 'ml', 'name': 'malayalam', 'flag': '🇮🇳'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLocale.languageCode,
          hint: Text('select_language'.tr()),
          isExpanded: true,
          items: languageData.map((language) {
            return DropdownMenuItem<String>(
              value: language['code'],
              child: Row(
                children: [
                  Text(language['flag']!, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(language['name']!.tr()),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              context.setLocale(Locale(newValue));
            }
          },
        ),
      ),
    );
  }
}