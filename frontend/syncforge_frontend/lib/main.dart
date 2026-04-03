import 'package:flutter/material.dart';
import 'features/auth/login_screen.dart';
import 'features/projects/project_list_screen.dart';
import 'core/theme/app_theme.dart';

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
      theme: AppTheme.lightTheme,
      initialRoute: "/",
      routes: {
        "/": (context) => LoginScreen(),
        "/projects": (context) => ProjectListScreen(),
      },
    );
  }
}
