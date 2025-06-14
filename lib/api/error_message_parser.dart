abstract class ErrorMessageParser {
  String parseMessage(dynamic responseData, int statusCode);
}

/// Parser padrão que procura por campos comuns de mensagem de erro
class DefaultErrorMessageParser implements ErrorMessageParser {
  @override
  String parseMessage(dynamic responseData, int statusCode) {
    if (responseData == null) {
      return _getDefaultMessage(statusCode);
    }

    if (responseData is Map<String, dynamic>) {
      // Tenta encontrar a mensagem em campos comuns
      for (String key in ['message', 'error', 'msg', 'detail', 'description']) {
        if (responseData.containsKey(key) && responseData[key] != null) {
          final value = responseData[key];
          if (value is String && value.isNotEmpty) {
            return value;
          }
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
        }
      }
      
      // Tenta encontrar em estruturas aninhadas
      if (responseData.containsKey('errors') && responseData['errors'] != null) {
        final errors = responseData['errors'];
        if (errors is Map<String, dynamic>) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
          return firstError.toString();
        }
        if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }
      }
    }

    if (responseData is String && responseData.isNotEmpty) {
      return responseData;
    }

    return _getDefaultMessage(statusCode);
  }

  String _getDefaultMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Requisição inválida';
      case 401:
        return 'Não autorizado';
      case 403:
        return 'Acesso negado';
      case 404:
        return 'Recurso não encontrado';
      case 422:
        return 'Dados inválidos';
      case 500:
        return 'Erro interno do servidor';
      case 503:
        return 'Serviço indisponível';
      default:
        return 'Erro na requisição';
    }
  }
}

/// Parser para APIs que retornam erro em formato simples: { "message": "erro" }
class SimpleErrorMessageParser implements ErrorMessageParser {
  final String messageField;

  const SimpleErrorMessageParser({this.messageField = 'message'});

  @override
  String parseMessage(dynamic responseData, int statusCode) {
    if (responseData is Map<String, dynamic> && 
        responseData.containsKey(messageField)) {
      return responseData[messageField]?.toString() ?? 'Erro na requisição';
    }
    return 'Erro na requisição';
  }
}

/// Parser para APIs que retornam erro em formato Laravel: { "message": "erro", "errors": {...} }
class LaravelErrorMessageParser implements ErrorMessageParser {
  @override
  String parseMessage(dynamic responseData, int statusCode) {
    if (responseData is Map<String, dynamic>) {
      // Primeiro tenta a mensagem principal
      if (responseData.containsKey('message') && 
          responseData['message'] != null) {
        return responseData['message'].toString();
      }
      
      // Se não encontrar, tenta o primeiro erro de validação
      if (responseData.containsKey('errors') && 
          responseData['errors'] is Map<String, dynamic>) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
      }
    }
    return 'Erro na requisição';
  }
}

/// Parser customizável que permite definir uma função de extração
class CustomErrorMessageParser implements ErrorMessageParser {
  final String Function(dynamic responseData, int statusCode) _parseFunction;

  const CustomErrorMessageParser(this._parseFunction);

  @override
  String parseMessage(dynamic responseData, int statusCode) {
    return _parseFunction(responseData, statusCode);
  }
}
