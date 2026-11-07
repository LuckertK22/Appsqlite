import 'package:flutter/material.dart';

import 'routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InventarioApp());
}

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0F766E);
    return MaterialApp(
      title: 'StockFácil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF4F7F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        snackBarTheme:
            const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      ),
      initialRoute: Routes.dashboard,
      routes: Routes.table,
    );
  }
}
