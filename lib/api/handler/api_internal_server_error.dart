import 'package:api_manager/api/handler/api_error.dart';

class ApiInternalServerError extends ApiError {
  @override
  String message;
  ApiInternalServerError({
    required this.message,
  });
}
