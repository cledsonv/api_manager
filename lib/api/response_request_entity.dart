class ResponseRequestEntity {
  final dynamic data;
  final int statusCode;
  final String statusMessage;

  ResponseRequestEntity({
    required this.data,
    required this.statusCode,
    required this.statusMessage,
  });

  @override
  String toString() {
    return 'ResponseRequestEntity(statusCode: $statusCode, statusMessage: $statusMessage, data: $data)';
  }
}
