import 'package:flutter/material.dart';
import 'package:storage_management_app/app/my_app.dart';
import 'package:storage_management_app/app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}
