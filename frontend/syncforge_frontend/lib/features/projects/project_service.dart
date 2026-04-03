import '../../core/api/api_client.dart';
import '../../core/storage/token_storage.dart';
import 'project_model.dart';

class ProjectService {

  static Future<List<Project>> getProjects() async {

    final token = await TokenStorage.getToken();

    final response = await ApiClient.get(
      "/projects",
      token: token,
    );

    return response
        .map<Project>((p) => Project.fromJson(p))
        .toList();
  }
}