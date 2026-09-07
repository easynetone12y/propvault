import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static const String _base = 'https://api.propvault.in/api/v1';
  static const _storage = FlutterSecureStorage();

  static Dio get instance {
    final dio = Dio(BaseOptions(
      baseUrl: _base,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (opts, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) opts.headers['Authorization'] = 'Bearer $token';
        handler.next(opts);
      },
      onError: (err, handler) async {
        if (err.response?.statusCode == 401) {
          if (await _tryRefresh(dio)) {
            final token = await _storage.read(key: 'access_token');
            err.requestOptions.headers['Authorization'] = 'Bearer $token';
            return handler.resolve(await dio.fetch(err.requestOptions));
          }
        }
        handler.next(err);
      },
    ));
    if (kDebugMode) dio.interceptors.add(LogInterceptor(requestBody: true));
    return dio;
  }

  static Future<bool> _tryRefresh(Dio dio) async {
    try {
      final rt = await _storage.read(key: 'refresh_token');
      if (rt == null) return false;
      final r = await dio.post('/auth/refresh', options: Options(headers: {'X-Refresh-Token': rt}));
      await _storage.write(key: 'access_token',  value: r.data['accessToken']);
      await _storage.write(key: 'refresh_token', value: r.data['refreshToken']);
      return true;
    } catch (_) { return false; }
  }

  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'access_token',  value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }
}
