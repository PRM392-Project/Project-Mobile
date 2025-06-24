// lib/services/user_service.dart
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import 'api_service.dart';

class UserService {
  static Future<dynamic> loginDesigner(String email, String password) async {
    return await ApiService.post("/api/auth/designer/login", {
      "email": email,
      "password": password,
    });
  }

  static Future<dynamic> loginCustomer(String email, String password) async {
    return await ApiService.post("/api/auth/customer/login", {
      "email": email,
      "password": password,
    });
  }

  static Future<dynamic> getAllFurnitures({int pageNumber = -1, int pageSize = -1}) async {
    return await ApiService.get("/api/furnitures", params: {
      "pageNumber": pageNumber.toString(),
      "pageSize": pageSize.toString(),
    });
  }

  static Future<dynamic> getAllDesigns({int pageNumber = -1, int pageSize = -1}) async {
    return await ApiService.get("/api/designs", params: {
      "pageNumber": pageNumber.toString(),
      "pageSize": pageSize.toString(),
    });
  }

  static Future<dynamic> getAllFurnituresByDes({int pageNumber = -1, int pageSize = -1}) async {
    return await ApiService.get("/api/designer/furnitures", params: {
      "pageNumber": pageNumber.toString(),
      "pageSize": pageSize.toString(),
    });
  }

  static Future<dynamic> getAllDesignsByDes({int pageNumber = -1, int pageSize = -1}) async {
    return await ApiService.get("/api/designer/designs", params: {
      "pageNumber": pageNumber.toString(),
      "pageSize": pageSize.toString(),
    });
  }

  static Future<dynamic> getAllOrdersByDes({int pageNumber = -1, int pageSize = -1}) async {
    return await ApiService.get("/api/designer/orders", params: {
      "pageNumber": pageNumber.toString(),
      "pageSize": pageSize.toString(),
    });
  }

  static Future<dynamic> getAllOrdersByCus({int pageNumber = -1, int pageSize = -1}) async {
    return await ApiService.get("/api/customer/orders", params: {
      "pageNumber": pageNumber.toString(),
      "pageSize": pageSize.toString(),
    });
  }

  static Future<dynamic> getAllCart() async {
    return await ApiService.get("/api/cart");
  }

  static Future<dynamic> addToCart(int quantity, String productId) async {
    return await ApiService.post("/api/cart", {
      "quantity": quantity,
      "productId": productId,
    });
  }

  static Future<dynamic> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await ApiService.postWithQuery(
      "/api/auth/update-password",
      queryParams: {
        "password": currentPassword,
        "newPassword": newPassword,
      },
    );
  }


  static Future<dynamic> getOrderById({required String id}) async {
    return await ApiService.get("/api/orders/$id");
  }

  static Future<dynamic> registerDesigner({
    required String name,
    required String email,
    required String password,
    required String applicationUrl,
  }) async {
    return await ApiService.post(
      "/api/auth/designer/register",
      {
        "name": name,
        "email": email,
        "password": password,
        "applicattionUrl": applicationUrl,
      },
    );
  }

  static Future<dynamic> registerCustomer({
    required String name,
    required String email,
    required String password,
  }) async {
    return await ApiService.post(
      "/api/auth/customer/register",
      {
        "name": name,
        "email": email,
        "password": password,
      },
    );
  }

  static Future<dynamic> getProductById(String id) async {
    return await ApiService.get("/api/products/$id");
  }

  static Future<dynamic> removeFromCart(String productId) async {
    return await ApiService.delete(
      "/api/cart",
      params: {
        "productId": productId,
      },
    );
  }

  static Future<dynamic> forgetPassword({
    required String email,
    required int role,
  }) async {
    return await ApiService.postWithQuery(
      "/api/auth/forget-password",
      queryParams: {
        "email": email,
        "role": role.toString(),
      },
    );
  }

  static Future<dynamic> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return await ApiService.postWithQuery(
      "/api/auth/reset-password",
      queryParams: {
        "token": token,
        "newPassword": newPassword,
      },
    );
  }

  static Future<dynamic> updateCart(List<Map<String, dynamic>> items) async {
    return await ApiService.put("/api/cart", items);
  }

  static Future<dynamic> getPaymentLink() async {
    return await ApiService.get("/api/payment");
  }

  static Future<dynamic> reviewProduct({
    required String productId,
    required String comment,
    required int star,
  }) async {
    return await ApiService.postWithQuery(
      "/api/products/review",
      queryParams: {
        "id": productId,
        "comment": comment,
        "star": star.toString(),
      },
    );
  }

  static Future<dynamic> updateCartInfo({
    required String address,
    required String phoneNumber,
    required int method,
  }) async {
    return await ApiService.put(
      "/api/cart-info",
      {
        "address": address,
        "phoneNumber": phoneNumber,
        "method": method,
      },
    );
  }

  static Future<List<dynamic>> getAllConversations() async {
    try {
      final response = await ApiService.get("/api/conversations");
      if (response is List) {
        return response;
      } else if (response is Map && response["data"] is List) {
        return response["data"];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<dynamic> getConversationById(String id) async {
    try {
      final response = await ApiService.get("/api/conversations/$id");
      return response;
    } catch (e) {
      return null;
    }
  }

}


