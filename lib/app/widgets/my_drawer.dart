import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storage_management_app/app/providers/theme_provider.dart';
import 'package:storage_management_app/app/widgets/locale_switcher_list_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                ),
                SizedBox(height: 20),
                Text(
                  'User Name',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 5),
                Text(
                  'user@gmail.com',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(localizations!.home),
            leading: const Icon(Icons.home),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          ListTile(
            title: Text(localizations.productList),
            leading: const Icon(Icons.list),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/product_list');
            },
          ),
          ExpansionTile(
            title: Text(localizations.settings),
            leading: const Icon(Icons.settings),
            children: [
              ListTile(
                title: Text(
                  themeProvider.isDarkMode ? localizations.darkTheme : localizations.lightTheme,
                  style: const TextStyle(fontSize: 16),
                ),
                leading: themeProvider.isDarkMode
                    ? const Icon(Icons.nightlight_round)
                    : const Icon(Icons.wb_sunny),
                onTap: () {
                  themeProvider.toggleTheme();
                  setState(() {
                    isDarkMode = themeProvider.isDarkMode;
                  });
                },
              ),
              const LocaleSwitcherListWidget(),
            ],
          ),
        ],
      ),
    );
  }
}
