import 'package:dio/dio.dart';
import 'api_endpoints.dart';

/// Configured Dio client for API calls
class DioClient {
  static Dio? _instance;

  static Dio get instance {
    if (_instance == null) {
      _instance = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Add interceptors
      _instance!.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => print('[DIO] $obj'),
        ),
      );

      // Add error handling interceptor
      _instance!.interceptors.add(
        InterceptorsWrapper(
          onError: (error, handler) {
            print('[DIO ERROR] ${error.message}');
            handler.next(error);
          },
        ),
      );
    }
    return _instance!;
  }

  /// Reset instance (useful for testing or changing base URL)
  static void reset() {
    _instance = null;
  }
}
