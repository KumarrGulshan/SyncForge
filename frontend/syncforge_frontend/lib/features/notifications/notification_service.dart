import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/storage/token_storage.dart';
import 'notification_model.dart';

class NotificationService {

  static const String baseUrl = "http://192.168.1.101:8080";

  static Future<List<AppNotification>> getNotifications() async {

    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/api/notifications"),
      headers: {
        "Authorization": "Bearer $token"
      },
    );
    print("Notification response: ${response.body}");

    if (response.statusCode == 200) {

      final List data = jsonDecode(response.body);

      return data
          .map((json) => AppNotification.fromJson(json))
          .toList();

    } else {

      throw Exception("Failed to load notifications");

    }
  }
}