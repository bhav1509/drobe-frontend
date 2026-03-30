import 'package:flutter/material.dart';
import 'screens/app_shell.dart';

void main() {
  runApp(const DrobeApp());
}

class DrobeApp extends StatelessWidget {
  const DrobeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DROBE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AppShell(),
    );
  }
}
