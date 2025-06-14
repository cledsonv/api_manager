import 'package:api_manager/api/error_message_parser.dart';
import 'package:api_manager/api/handler/api_bad_request_error.dart';
import 'package:api_manager/api/handler/api_forbidden_error.dart';
import 'package:api_manager/api/handler/api_internal_server_error.dart';
import 'package:api_manager/api/handler/api_not_found_error.dart';
import 'package:api_manager/api/handler/api_unauthenticated_error.dart';
import 'package:api_manager/api/handler/api_unprocessable_entity_error.dart';
import 'package:api_manager/api/response_request_entity.dart';

class ApiResponseParser {
  final ErrorMessageParser _errorMessageParser;

  ApiResponseParser({ErrorMessageParser? errorMessageParser})
      : _errorMessageParser = errorMessageParser ?? DefaultErrorMessageParser();
  
  dynamic handleResponse(ResponseRequestEntity response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.data;
    }

    final errorMessage = _errorMessageParser.parseMessage(
      response.data, 
      response.statusCode,
    );

    switch (response.statusCode) {
      case 400:
        throw ApiBadRequestError(message: errorMessage);
      case 401:
        throw ApiUnauthenticatedError(message: errorMessage);
      case 403:
        throw ApiForbiddenError(message: errorMessage);
      case 404:
        throw ApiNotFoundError(message: errorMessage);
      case 422:
        throw ApiUnprocessableEntityError(message: errorMessage);
      case 500:
        throw ApiInternalServerError(message: errorMessage);
      case 503:
        throw ApiInternalServerError(message: errorMessage);
      default:
        throw ApiInternalServerError(message: errorMessage);
    }
  }
}
