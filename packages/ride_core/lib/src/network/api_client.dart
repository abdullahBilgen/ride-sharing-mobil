import 'package:dio/dio.dart';

typedef TokenReader = Future<String?> Function();
typedef TokenWriter = Future<void> Function(String access, String refresh);

class ApiClient {
  ApiClient({required String baseUrl, required TokenReader readAccessToken, required Future<String?> Function() readRefreshToken, required TokenWriter saveTokens})
    : dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 12), receiveTimeout: const Duration(seconds: 15))),
      readRefreshToken = readRefreshToken {
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      final token = options.extra['skipAuth'] == true ? null : await readAccessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    }, onError: (error, handler) async {
      final request = error.requestOptions;
      if (error.response?.statusCode == 401 && request.extra['retried'] != true && request.extra['skipAuth'] != true) {
        try {
          final refresh = await readRefreshToken();
          if (refresh != null) {
            final response = await dio.post('/auth/refresh', data: {'refreshToken': refresh}, options: Options(extra: {'skipAuth': true}));
            final access = response.data['accessToken'] as String;
            final nextRefresh = response.data['refreshToken'] as String;
            await saveTokens(access, nextRefresh);
            request.extra['retried'] = true;
            request.headers['Authorization'] = 'Bearer $access';
            handler.resolve(await dio.fetch(request));
            return;
          }
        } catch (_) { /* The application auth layer handles expired sessions. */ }
      }
      handler.next(error);
    }));
  }
  final Dio dio;
  final Future<String?> Function() readRefreshToken;
}
