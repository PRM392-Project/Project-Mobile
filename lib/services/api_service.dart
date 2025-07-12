

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 100),
    receiveTimeout: const Duration(seconds: 100),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> _setAuthHeader() async {
    final token = await getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  static Future<dynamic> get(String endpoint, {Map<String, String>? params}) async {
    await _setAuthHeader();
    try {
      final response = await _dio.get(endpoint, queryParameters: params);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    await _setAuthHeader();
    try {
      final response = await _dio.post(endpoint, data: body);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static Future<dynamic> postWithQuery(String endpoint, {Map<String, String>? queryParams}) async {
    await _setAuthHeader();
    try {
      final response = await _dio.post(endpoint, queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static Future<dynamic> put(String endpoint, dynamic body) async {
    await _setAuthHeader();
    try {
      final response = await _dio.put(endpoint, data: body);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static Future<dynamic> putWithQuery(String endpoint, {Map<String, String>? queryParams}) async {
    await _setAuthHeader();
    try {
      final response = await _dio.put(endpoint, queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static Future<dynamic> delete(String endpoint, {Map<String, String>? params}) async {
    await _setAuthHeader();
    try {
      final response = await _dio.delete(endpoint, queryParameters: params);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static void _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode ?? 0;
      if (statusCode == 401) {
        Fluttertoast.showToast(msg: "Hết phiên đăng nhập. Vui lòng đăng nhập lại.");

      } else {
        // Fluttertoast.showToast(msg: "Lỗi ${statusCode}: ${e.response?.data['message'] ?? 'Đã xảy ra lỗi'}");
      }
    } else {
      Fluttertoast.showToast(msg: "Không thể kết nối đến máy chủ.");
    }
  }

  static Future<dynamic> putMultipart(
      String endpoint, {
        Map<String, String>? queryParams,
        Map<String, dynamic>? fields,
        Map<String, dynamic>? files,
      }) async {
    await _setAuthHeader();
    final formData = FormData();

    // Add fields (nếu có)
    if (fields != null) {
      fields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }

    // Add files (nếu có)
    if (files != null) {
      for (var entry in files.entries) {
        final value = entry.value;
        if (value != null && value is String && value.isNotEmpty) {
          formData.files.add(MapEntry(
            entry.key,
            await MultipartFile.fromFile(value, filename: value.split('/').last),
          ));
        }
      }
    }

    try {
      final response = await _dio.put(
        endpoint,
        queryParameters: queryParams,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }


}
