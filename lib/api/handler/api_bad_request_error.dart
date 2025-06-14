import 'package:api_manager/api/handler/api_error.dart'; 

class ApiBadRequestError extends ApiError {
  @override
  String message;
  ApiBadRequestError({required this.message});
}
