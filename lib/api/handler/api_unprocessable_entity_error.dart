import 'package:api_manager/api/handler/api_error.dart';

class ApiUnprocessableEntityError extends ApiError {
  @override
  String message;
  ApiUnprocessableEntityError({required this.message});
}
