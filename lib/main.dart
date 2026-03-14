import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/ui/main_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SalarySwiftApp(),
    ),
  );
}

class SalarySwiftApp extends StatelessWidget {
  const SalarySwiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '工资结算',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          surface: const Color(0xFFF4F7FB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 48,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A2340),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xFF1A2340)),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
