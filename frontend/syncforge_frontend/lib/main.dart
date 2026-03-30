import 'package:flutter/material.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(const SyncForgeApp());
}

class SyncForgeApp extends StatelessWidget {
  const SyncForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SyncForge",
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
