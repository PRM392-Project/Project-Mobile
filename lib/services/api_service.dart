// // lib/services/api_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../config.dart';
// import 'package:flutter/material.dart';
//
// class ApiService {
//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }
//
//   static Future<dynamic> get(String endpoint, {Map<String, String>? params}) async {
//     final uri = Uri.parse('$apiBaseUrl$endpoint').replace(queryParameters: params);
//     final token = await getToken();
//
//     final response = await http.get(uri, headers: {
//       'Content-Type': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     });
//
//     return _handleResponse(response);
//   }
//
//   static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
//     final uri = Uri.parse('$apiBaseUrl$endpoint');
//     final token = await getToken();
//
//     final response = await http.post(uri,
//         headers: {
//           'Content-Type': 'application/json',
//           if (token != null) 'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode(body));
//
//     return _handleResponse(response);
//   }
//
//   // Thêm phương thức delete
//   static Future<dynamic> delete(String endpoint, {Map<String, String>? params}) async {
//     final uri = Uri.parse('$apiBaseUrl$endpoint').replace(queryParameters: params);
//     final token = await getToken();
//
//     final response = await http.delete(uri, headers: {
//       'Content-Type': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     });
//
//     return _handleResponse(response);
//   }
//
//   static dynamic _handleResponse(http.Response response) {
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       return jsonDecode(response.body);
//     } else if (response.statusCode == 401) {
//       Fluttertoast.showToast(msg: "Hết phiên đăng nhập. Vui lòng đăng nhập lại.");
//       // TODO: Chuyển hướng về login nếu cần
//     }
//     // else {
//     //   debugPrint("API Error: ${response.statusCode} - ${response.body}");
//     //   Fluttertoast.showToast(msg: "Đã có lỗi xảy ra. Vui lòng thử lại.");
//     // }
//
//     throw Exception("Failed request: ${response.statusCode}");
//   }
// }


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
        // TODO: chuyển hướng về login nếu cần
      } else {
        Fluttertoast.showToast(msg: "Lỗi ${statusCode}: ${e.response?.data['message'] ?? 'Đã xảy ra lỗi'}");
      }
    } else {
      Fluttertoast.showToast(msg: "Không thể kết nối đến máy chủ.");
    }
  }
}
