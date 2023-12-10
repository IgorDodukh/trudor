//date
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

//route
class RouteException implements Exception {
  final String message;
  const RouteException(this.message);
}