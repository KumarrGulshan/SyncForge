import '../../core/api/api_client.dart';
import '../../core/storage/token_storage.dart';

class AIService {

  static Future<String> generateDescription(
    String title,
  ) async {

    final token = await TokenStorage.getToken();

    final response = await ApiClient.post(
      "/ai/generate-description",
      {
        "title": title,
      },
      token: token,
    );

    return response["description"];
  }
}