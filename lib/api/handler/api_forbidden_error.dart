import 'package:api_manager/api/handler/api_error.dart';

class ApiForbiddenError extends ApiError {
  @override
  String message;

  ApiForbiddenError({required this.message});
}
