import 'package:api_manager/api/handler/api_error.dart';

class ApiNotFoundError extends ApiError {
  @override
  String message;
  ApiNotFoundError({
    required this.message,
  });
}
