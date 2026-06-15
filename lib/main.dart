import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const SingleGameApp());
}

class SingleGameApp extends StatelessWidget {
  const SingleGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Single Game',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const HomePage(),
    );
  }
}
