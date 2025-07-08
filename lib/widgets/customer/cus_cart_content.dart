import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../screens/customer/payment_webview.dart';
import 'CartCard.dart';
import '../../services/user_service.dart';
import '../../../routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class CusCartContent extends StatefulWidget {
  const CusCartContent({Key? key}) : super(key: key);

  @override
  State<CusCartContent> createState() => _CusCartContentState();
}

class _CusCartContentState extends State<CusCartContent> {
  bool _isShippingInfoExpanded = false;

  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  int selectedPaymentMethod = 0;
  bool hasInfoChanges = false;

  Map<String, dynamic>? cartData;
  bool isLoading = true;
  String? errorMsg;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  //ép kiểu cho giá, số lượng, method thanh toán
  int parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // get all cart
  Future<void> loadCart() async {
    try {
      final response = await UserService.getAllCart();
      if (response != null && response['data'] != null) {
        final data = response['data'];
        final cartItems = data['orderDetails'] ?? [];

        if (cartItems.isEmpty) {
          setState(() {
            cartData = data;
            isLoading = false;
            errorMsg = 'Giỏ hàng hiện đang trống';
          });
        } else {
          setState(() {
            cartData = data;
            addressController.text = data['address'] ?? '';
            phoneController.text = data['phoneNumber'] ?? '';
            selectedPaymentMethod = parseInt(data['method']);
            updateTotalPrice();
            isLoading = false;
            hasChanges = false;
          });

          //Cập nhật provider
          Provider.of<CartProvider>(context, listen: false)
              .setItemCount(cartItems.length);
        }
      } else {
        setState(() {
          errorMsg = 'Không có dữ liệu giỏ hàng';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Giỏ hàng hiện đang trống';
        isLoading = false;
      });
    }
  }

  //thay đổi tổng giá khi thay đổi số lượng
  void updateTotalPrice() {
    int total = 0;
    for (var detail in cartData!['orderDetails']) {
      final product = detail['product'];
      final price = parseInt(product['price']);
      final quantity = parseInt(detail['quantity']);
      detail['detailPrice'] = price * quantity;
      total += price * quantity;
    }
    cartData!['orderPrice'] = total;
  }

  //tăng số lượng
  void onIncreaseQuantity(int index) {
    setState(() {
      cartData!['orderDetails'][index]['quantity']++;
      hasChanges = true;
      updateTotalPrice();
    });
  }

  //method thanh toán
  String getPaymentMethodText(dynamic method) {
    int value = parseInt(method);
    switch (value) {
      case 1:
        return 'Chuyển khoản ngân hàng';
      case 2:
        return 'Thanh toán qua ví điện tử';
      default:
        return 'Thanh toán khi nhận hàng';
    }
  }

  //giảm số lượng
  void onDecreaseQuantity(int index) {
    setState(() {
      int current = parseInt(cartData!['orderDetails'][index]['quantity']);
      if (current > 1) {
        cartData!['orderDetails'][index]['quantity'] = current - 1;
        hasChanges = true;
        updateTotalPrice();
      }
    });
  }

  //xóa item khỏi cart
  void onRemoveItem(int index) async {
    final productId = cartData!['orderDetails'][index]['product']['id'];

    try {
      await UserService.removeFromCart(productId);
      setState(() {
        cartData!['orderDetails'].removeAt(index);
        updateTotalPrice();
      });

      final newCount = cartData!['orderDetails'].length;
      Provider.of<CartProvider>(context, listen: false).setItemCount(newCount);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Xóa sản phẩm thành công')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xóa sản phẩm thất bại: $e')));
    }
  }

  //lưu thông tin ship + method thanh toán
  Future<void> saveCartInfo() async {
    try {
      final response = await UserService.updateCartInfo(
        address: addressController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        method: selectedPaymentMethod,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Cập nhật thông tin giao hàng thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi cập nhật thông tin giao hàng: $e")),
      );
    }
  }

  //lưu khi thay đổi số lượng của 1 sản phẩm
  Future<void> saveCartChanges() async {
    try {
      List<Map<String, dynamic>> updatedItems =
          cartData!['orderDetails'].map<Map<String, dynamic>>((detail) {
            return {
              "productId": detail['product']['id'],
              "quantity": parseInt(detail['quantity']),
            };
          }).toList();

      var response = await UserService.updateCart(updatedItems);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Lưu giỏ hàng thành công'),
        ),
      );

      setState(() {
        hasChanges = false; // Reset lại trạng thái sau khi lưu thành công
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi lưu giỏ hàng: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    //chỉnh format tiền về vnd
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.customerHomepage);
          },
        ),
        actions: [
          //hiện nút lưu khi có thay đổi về số lượng
          if (hasChanges)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: saveCartChanges,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF3F5139),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Lưu"),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg != null
          ? Center(child: Text(errorMsg!))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Thông tin giao hàng",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3F5139),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isShippingInfoExpanded ? Icons.expand_less : Icons.expand_more,
                        color: const Color(0xFF3F5139),
                      ),
                      onPressed: () {
                        setState(() {
                          _isShippingInfoExpanded = !_isShippingInfoExpanded;
                        });
                      },
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _isShippingInfoExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Column(
                    children: [
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          hintText: 'Địa chỉ',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF3F5139)),
                          ),
                        ),
                        onChanged: (value) {
                          final original = cartData?['address'] ?? '';
                          setState(() {
                            hasInfoChanges = value.trim() != original.toString().trim();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          hintText: 'Số điện thoại',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF3F5139)),
                          ),
                        ),
                        onChanged: (value) {
                          final original = cartData?['phoneNumber'] ?? '';
                          setState(() {
                            hasInfoChanges = value.trim() != original.toString().trim();
                          });
                        },
                      ),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<int>(
                        value: selectedPaymentMethod,
                        decoration: const InputDecoration.collapsed(hintText: ''),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('Thanh toán khi nhận hàng')),
                          DropdownMenuItem(value: 1, child: Text('Chuyển khoản ngân hàng')),
                          DropdownMenuItem(value: 2, child: Text('Thanh toán qua ví điện tử')),
                        ],
                        onChanged: (value) {
                          if (value != null && value != parseInt(cartData?['method'])) {
                            setState(() {
                              selectedPaymentMethod = value;
                              hasInfoChanges = true;
                            });
                          }
                        },
                      ),

                      //hiện nút lưu khi có thay đổi thông tin ship + method thanh toán
                      if (hasInfoChanges)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextButton(
                              onPressed: () async {
                                await saveCartInfo();
                                setState(() => hasInfoChanges = false);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF3F5139),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text("Lưu", style: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ),
                    ],
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: cartData!['orderDetails'].length,
              itemBuilder: (context, index) {
                final detail = cartData!['orderDetails'][index];
                final product = detail['product'];
                final isDesign = product['isDesign'] == true;
                final imageUrl = product['primaryImage']?['imageSource'];

                //truyền thông tin qua widget giao diện của 1 sản phẩm
                return CartCard(
                  productName: product['name'],
                  productImageUrl: imageUrl,
                  price: parseInt(product['price']),
                  quantity: parseInt(detail['quantity']),
                  detailPrice: parseInt(detail['detailPrice']),
                  isDesign: isDesign,
                  onIncreaseQuantity: () => onIncreaseQuantity(index),
                  onDecreaseQuantity: () => onDecreaseQuantity(index),
                  onRemoveItem: () => onRemoveItem(index),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3F5139),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng tiền:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  formatCurrency.format(parseInt(cartData!['orderPrice'])),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          //payos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (cartData?['orderDetails']?.isEmpty ?? true)
                    ? null
                    : () async {
                  try {
                    final response = await UserService.getPaymentLink();
                    final paymentUrl = response['data'];
                    if (paymentUrl != null && paymentUrl is String) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentWebView(url: paymentUrl),
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint("Lỗi khi lấy đường link thanh toán: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Không thể lấy đường link thanh toán")),
                    );
                  }
                },
                icon: const Icon(Icons.payment, size: 20),
                label: const Text(
                  "Thanh toán",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  backgroundColor: const Color(0xFF3F5139),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

}
