import 'package:dio/dio.dart';
import 'app_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
        validateStatus: (_) => true, // handle status codes ourselves
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.instance.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) => _send(() => _dio.get(path, queryParameters: _clean(query)));

  Future<Map<String, dynamic>> post(String path, {Object? body}) =>
      _send(() => _dio.post(path, data: body));

  Future<Map<String, dynamic>> put(String path, {Object? body}) =>
      _send(() => _dio.put(path, data: body));

  Future<Map<String, dynamic>> patch(String path, {Object? body}) =>
      _send(() => _dio.patch(path, data: body));

  Future<Map<String, dynamic>> delete(String path, {Object? body}) =>
      _send(() => _dio.delete(path, data: body));

  Map<String, dynamic>? _clean(Map<String, dynamic>? query) {
    if (query == null) return null;
    final cleaned = <String, dynamic>{};
    for (final entry in query.entries) {
      if (entry.value == null) continue;
      cleaned[entry.key] = entry.value;
    }
    return cleaned;
  }

  Future<Map<String, dynamic>> _send(
    Future<Response> Function() request,
  ) async {
    Response response;
    try {
      response = await request();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const ApiException(
          "Couldn't reach the server. Check your connection and try again.",
          isNetworkError: true,
        );
      }
      throw ApiException(e.message ?? 'Something went wrong. Please try again.');
    }

    final body = response.data;
    final Map<String, dynamic> json = body is Map<String, dynamic>
        ? body
        : <String, dynamic>{};

    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) {
      return json;
    }

    final message =
        (json['message'] as String?) ?? 'Something went wrong. Please try again.';
    final rawErrors = json['errors'];
    final fieldErrors = <ApiFieldError>[];
    if (rawErrors is List) {
      for (final e in rawErrors) {
        if (e is Map) {
          fieldErrors.add(
            ApiFieldError(
              field: (e['field'] ?? '').toString(),
              message: (e['message'] ?? '').toString(),
            ),
          );
        }
      }
    }

    throw ApiException(message, statusCode: status, fieldErrors: fieldErrors);
  }
}
