<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# API Manager

Um gerenciador de API robusto e flexível para Flutter que simplifica requisições HTTP e oferece tratamento avançado de erros.

## Características

- ✅ Tratamento automático de erros HTTP
- ✅ Parser customizável de mensagens de erro
- ✅ Interceptadores para logging detalhado
- ✅ Suporte a FormData
- ✅ Timeouts configuráveis
- ✅ Cliente Dio customizável
- ✅ Tipagem forte com Dart

## Instalação

Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  api_manager:
    path: ../api_manager
```

## Uso Básico

### Configuração Simples

```dart
import 'package:api_manager/api/api_client.dart';

final apiClient = ApiClient();

// GET request
final response = await apiClient.get(
  'https://api.example.com/users',
  headers: {'Content-Type': 'application/json'},
);

// POST request
final postResponse = await apiClient.post(
  'https://api.example.com/users',
  body: {'name': 'João', 'email': 'joao@email.com'},
  headers: {'Content-Type': 'application/json'},
);
```

### Exemplo Prático Completo

Veja um exemplo completo de implementação em [example/example.dart](example/example.dart). Este exemplo demonstra:

- Configuração de headers automáticos
- Gerenciamento de token de autenticação
- Wrapper para todos os métodos HTTP
- Configuração de URL base

```dart
// Exemplo de uso do ApiManager
final apiManager = ApiManager();

// Definir token de autenticação
token = 'seu_token_aqui';

// Fazer requisições
final users = await apiManager.get(path: '/users');
final newUser = await apiManager.post(
  path: '/users',
  body: {'name': 'Maria', 'email': 'maria@email.com'},
);
```

## Configuração Avançada

### Cliente com Timeouts Customizados

```dart
final apiClient = ApiClient.withTimeout(
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 15),
);
```

### Cliente com Dio Customizado

```dart
final customDio = Dio();
// Configure seu Dio aqui...

final apiClient = ApiClient.withCustomDio(customDio);
```

### Parser de Erro Customizado

```dart
class MeuErrorParser implements ErrorMessageParser {
  @override
  String parseMessage(dynamic responseData, int statusCode) {
    // Sua lógica personalizada aqui
    return 'Erro customizado: $statusCode';
  }
}

final apiClient = ApiClient(
  errorMessageParser: MeuErrorParser(),
);
```

## Tratamento de Erros

O API Manager trata automaticamente diferentes tipos de erro:

| Status Code | Exceção | Descrição |
|-------------|---------|-----------|
| 400 | `ApiBadRequestError` | Requisição malformada |
| 401 | `ApiUnauthenticatedError` | Não autenticado |
| 403 | `ApiForbiddenError` | Acesso negado |
| 404 | `ApiNotFoundError` | Recurso não encontrado |
| 422 | `ApiUnprocessableEntityError` | Dados inválidos |
| 500/503 | `ApiInternalServerError` | Erro do servidor |
| Conexão | `ApiConnectionError` | Problemas de rede |

### Exemplo de Tratamento

```dart
try {
  final response = await apiManager.get(path: '/users');
  print('Sucesso: $response');
} on ApiUnauthenticatedError catch (e) {
  print('Não autenticado: ${e.message}');
  // Redirecionar para login
} on ApiConnectionError catch (e) {
  print('Erro de conexão: ${e.message}');
  // Mostrar mensagem de erro de rede
} on ApiError catch (e) {
  print('Erro da API: ${e.message}');
  // Tratamento genérico
}
```

## Logging

O API Manager inclui logging detalhado por padrão:

- 📤 Requisições (método, URL, headers, body)
- 📥 Respostas (status, body, tempo de resposta)
- ❌ Erros (detalhes completos)

## Métodos Disponíveis

### ApiClient

- `get(url, headers)`
- `post(url, body, headers, isFormData)`
- `put(url, body, headers, isFormData)`
- `patch(url, body, headers)`
- `delete(url, headers)`

### ApiManager (Exemplo)

- `get(path)`
- `post(path, body, isFormData)`
- `put(path, body, isFormData)`
- `patch(path, body)`
- `delete(path)`

## Estrutura do Projeto

```
lib/
├── api/
│   ├── api_client.dart              # Cliente principal
│   ├── api_response.dart            # Parser de respostas
│   ├── error_message_parser.dart    # Parser de erros
│   ├── response_request_entity.dart # Entidade de resposta
│   ├── response_request_mapper.dart # Mapper Dio
│   └── handler/                     # Exceções customizadas
│       ├── api_error.dart
│       ├── api_bad_request_error.dart
│       ├── api_connection_error.dart
│       └── ...
└── example/
    └── example.dart                 # Exemplo prático
```

## Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## Licença

Este projeto está licenciado sob a licença MIT.
