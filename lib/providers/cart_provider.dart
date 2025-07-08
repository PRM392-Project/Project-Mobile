import 'package:flutter/material.dart';
import '../services/user_service.dart';

class CartProvider with ChangeNotifier {
  int _itemCount = 0;

  int get itemCount => _itemCount;

  void setItemCount(int count) {
    _itemCount = count;
    notifyListeners();
  }

  void increment() {
    _itemCount++;
    notifyListeners();
  }

  void decrement() {
    if (_itemCount > 0) {
      _itemCount--;
      notifyListeners();
    }
  }

  Future<void> loadCartCountFromAPI() async {
    try {
      final response = await UserService.getAllOrdersByCus();
      if (response != null && response['data'] != null) {
        final items = response['data']['items'] as List<dynamic>;
        _itemCount = items.length;
        notifyListeners();
      }
    } catch (e) {

    }
  }
}
