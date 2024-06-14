import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:storage_management_app/app/providers/locale_provider.dart';

class LocaleSwitcherListWidget extends StatelessWidget {
  const LocaleSwitcherListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final locale = provider.locale;

    return ExpansionTile(
      title: Text(locale.languageCode == "en"
          ? AppLocalizations.of(context)!.language_english
          : AppLocalizations.of(context)!.language_polish),
      leading: const Icon(Icons.language),
      children: AppLocalizations.supportedLocales.map(
        (nextLocale) {
          return ListTile(
            title: Text(nextLocale.languageCode == "en"
                ? AppLocalizations.of(context)!.english
                : AppLocalizations.of(context)!.polish),
            onTap: () {
              final provider =
                  Provider.of<LocaleProvider>(context, listen: false);
              provider.setLocale(nextLocale);
            },
            trailing: locale == nextLocale ? const Icon(Icons.check) : null,
          );
        },
      ).toList(),
    );
  }
}
