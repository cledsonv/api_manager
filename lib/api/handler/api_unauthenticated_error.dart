import 'package:api_manager/api/handler/api_error.dart';


class ApiUnauthenticatedError extends ApiError {
  @override
  String message;
  ApiUnauthenticatedError({required this.message});
}
