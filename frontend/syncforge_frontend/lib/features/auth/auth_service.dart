import '../../core/api/api_client.dart';
import '../../core/storage/token_storage.dart';

class AuthService {

  static Future<bool> login(String email, String password) async {

    final response = await ApiClient.post(
      "/auth/login",
      {
        "email": email,
        "password": password
      },
    );

    final token = response["accessToken"];

    if (token != null) {
      await TokenStorage.saveToken(token);
      return true;
    }

    return false;
  }
}
