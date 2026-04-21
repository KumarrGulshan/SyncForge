import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/storage/token_storage.dart';

class AuthService {

  static const String baseUrl = "http://192.168.1.138:8080";

  static Future<bool> login(String email, String password) async {

    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/login"),

      headers: {
        "Content-Type": "application/json"
      },

      body: jsonEncode({
        "email": email,
        "password": password
      }),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      await TokenStorage.saveToken(data["accessToken"]);

      return true;

    } else {
      return false;
    }
  }

  static Future<void> register(
    String name,
    String email,
    String password,
  ) async {

    await http.post(
      Uri.parse("$baseUrl/api/auth/register"),

      headers: {
        "Content-Type": "application/json"
      },

      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password
      }),
    );
  }
}