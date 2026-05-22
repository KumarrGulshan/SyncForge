import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {

  static const String baseUrl = "http://192.168.1.124:8080/api";

  // =========================
  // POST REQUEST
  // =========================
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
    {String? token}
  ) async {

    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),

      headers: {
        "Content-Type": "application/json",
        if (token != null)
          "Authorization": "Bearer $token"
      },

      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  // =========================
  // GET REQUEST
  // =========================
  static Future<dynamic> get(
    String endpoint,
    {String? token}
  ) async {

    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),

      headers: {
        if (token != null)
          "Authorization": "Bearer $token"
      },
    );

    return jsonDecode(response.body);
  }
  static Future<void> delete(
  String endpoint,
  {String? token}
  ) async {

    final response = await http.delete(

      Uri.parse("$baseUrl$endpoint"),

      headers: {

        if (token != null)
          "Authorization":
              "Bearer $token"
      },
    );

    if (response.statusCode >= 400) {
 
      throw Exception(
        "Delete request failed",
      );
   }
  }
}