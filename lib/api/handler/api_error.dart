abstract class ApiError implements Exception {
  abstract String message;
  
  @override
  String toString() => message;
}
