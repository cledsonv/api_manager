import 'package:api_manager/api/handler/api_error.dart';

class ApiConnectionError extends ApiError {
  @override
  String message;

  ApiConnectionError({required this.message});
}
