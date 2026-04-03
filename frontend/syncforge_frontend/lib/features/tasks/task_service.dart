import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/storage/token_storage.dart';
import 'task_model.dart';

class TaskService {

  static const String baseUrl = "http://192.168.1.144:8080/api";


  static Future<List<Task>> getTasks(String projectId) async {

    final token = await TokenStorage.getToken();

    final response = await ApiClient.get(
      "/projects/$projectId/tasks",
      token: token,
    );

    return response
        .map<Task>((t) => Task.fromJson(t))
        .toList();
  }

  static Future<void> updateStatus(
      String projectId,
      String taskId,
      String status,
      ) async {

    final token = await TokenStorage.getToken();

    await http.patch(
      Uri.parse("$baseUrl/projects/$projectId/tasks/$taskId/status"),

      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },

      body: jsonEncode({
        "status": status
      }),
    );
  }

  static Future<void> createTask(
      String projectId,
      String title,
      String description,
      ) async {

    final token = await TokenStorage.getToken();

    await http.post(
      Uri.parse("$baseUrl/projects/$projectId/tasks"),

      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },

      body: jsonEncode({
        "title": title,
        "description": description
      }),
    );
  }
}