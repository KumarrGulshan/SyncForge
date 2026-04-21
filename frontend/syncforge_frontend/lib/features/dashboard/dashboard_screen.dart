import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/storage/token_storage.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  Map<String, dynamic>? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {

    try {

      final token = await TokenStorage.getToken();

      final response = await http.get(
        Uri.parse("http://192.168.1.138:8080/api/dashboard"),
        headers: {
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {

        setState(() {
          data = jsonDecode(response.body);
          loading = false;
        });

      } else {

        setState(() {
          loading = false;
        });

      }

    } catch (e) {

      print("Dashboard error: $e");

      setState(() {
        loading = false;
      });

    }
  }

  Widget statCard(String title, int value, IconData icon, Color color) {

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(icon, size: 36, color: color),

            const SizedBox(height: 10),

            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            )

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Dashboard"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data == null
              ? const Center(child: Text("Failed to load dashboard"))
              : GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,

                  children: [

                    statCard(
                      "Projects",
                      data!["projects"] ?? 0,
                      Icons.folder,
                      Colors.blue,
                    ),

                    statCard(
                      "Tasks",
                      data!["tasks"] ?? 0,
                      Icons.task,
                      Colors.orange,
                    ),

                    statCard(
                      "Completed",
                      data!["completed"] ?? 0,
                      Icons.check_circle,
                      Colors.green,
                    ),

                    statCard(
                      "Pending",
                      data!["pending"] ?? 0,
                      Icons.pending,
                      Colors.red,
                    ),

                  ],
                ),
    );
  }
}