import 'package:api_manager/api/api_manager.dart';

String baseUrl = 'https://api.example.com';
String? token;

class ApiConfig {
  final ApiManager _apiManager = ApiManager();

  ApiConfig();

  String get url => baseUrl;

  Future<Map<String, dynamic>> _getheaders() async {
    final headers = <String, dynamic>{'Content-Type': 'application/json'};

    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<dynamic> get({required String path}) async {
    final response = await _apiManager.get(
      '$url$path',
      headers: await _getheaders(),
    );
    return response;
  }

  Future<dynamic> post({
    required String path,
    dynamic body,
    bool isformData = false,
  }) async {
    final response = await _apiManager.post(
      '$url$path',
      body: body ?? {},
      headers: await _getheaders(),
      isformData: isformData,
    );
    return response;
  }

  Future<dynamic> put({
    required String path,
    dynamic body,
    bool isformData = false,
  }) async {
    final response = await _apiManager.put(
      '$url$path',
      body: body ?? {},
      headers: await _getheaders(),
      isformData: isformData,
    );
    return response;
  }

  Future<dynamic> delete({required String path}) async {
    final response = await _apiManager.delete(
      '$url$path',
      headers: await _getheaders(),
    );
    return response;
  }

  Future<dynamic> patch({required String path, dynamic body}) async {
    final response = await _apiManager.patch(
      '$url$path',
      body: body ?? {},
      headers: await _getheaders(),
    );
    return response;
  }
}
