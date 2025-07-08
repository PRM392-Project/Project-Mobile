import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/user_service.dart';
import 'buy_menu.dart';
import 'package:intl/intl.dart';
import 'review_content.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';


class CusFurDetailContent extends StatefulWidget {
  final Map<String, dynamic> product;

  const CusFurDetailContent({Key? key, required this.product})
    : super(key: key);

  @override
  State<CusFurDetailContent> createState() => _CusFurDetailContentState();
}

class _CusFurDetailContentState extends State<CusFurDetailContent> {
  List<dynamic> _furs = [];
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _fetchFurnitures();
    _loadProduct(widget.product);
  }

  List<Map<String, dynamic>> _reviews = [];
  void _loadProduct(Map<String, dynamic> productData) {
    setState(() {
      _reviews = List<Map<String, dynamic>>.from(productData['reviews'] ?? []);
    });
  }

  Future<void> _fetchFurnitures() async {
    final response = await UserService.getAllFurnitures();
    if (response != null && response['data'] != null) {
      setState(() {
        _furs = response['data']['items'];
      });
    }
  }

  String formatCurrency(double amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatCurrency.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final name = product['name'] ?? '';
    final price = product['price'] ?? 0;
    final rating = product['rating'] ?? 0;
    final imageSource = product['primaryImage']?['imageSource'];
    final description = product['description'] ?? '';
    final designerName = product['designer']?['name'] ?? 'Không rõ';

    const mainTextColor = Color(0xFF3F5139);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.customerFurniture,
            );
          },
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80), // padding đủ cho BuyMenu
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: mainTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    color: const Color(0xFFBCD4B5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child:
                          imageSource != null
                              ? Image.network(
                                imageSource,
                                width: double.infinity,
                                height: 270,
                                fit: BoxFit.contain,
                              )
                              : Container(
                                width: double.infinity,
                                height: 220,
                                color: const Color(0xFFBCD4B5),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Giá:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  formatCurrency(price),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (product['style']?['name'] != null)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        product['style']['name'],
                                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                                      ),
                                    ),
                                  ...((product['categories'] ?? []) as List<dynamic>).map<Widget>((cat) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        cat['name'] ?? '',
                                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                        const Text(
                          'Mô tả sản phẩm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description.isNotEmpty
                              ? description
                              : 'Chưa có mô tả.',
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Số lượng',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Nút -
                                  InkWell(
                                    onTap: () {
                                      if (_quantity > 1) {
                                        setState(() {
                                          _quantity--;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: const Icon(Icons.remove, size: 20),
                                    ),
                                  ),

                                  // Số lượng hiển thị
                                  Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    child: Text(
                                      _quantity.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),

                                  // Nút +
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      setState(() {
                                        _quantity++;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: const Icon(Icons.add, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$rating / 5.0',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Ngăn cách
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.zero,
              color: const Color(0xFFF4F4F4),
              height: 10,
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: product['designer']?['avatarSource'] != null
                        ? NetworkImage(product['designer']['avatarSource'])
                        : null,
                    child: product['designer']?['avatarSource'] == null
                        ? const Icon(Icons.person, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Tên và chữ "Nhà thiết kế"
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['designer']?['name'] ?? 'Không rõ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Nhà thiết kế',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Icon chat
                  IconButton(
                    icon: const Icon(Icons.chat, color: Color(0xFF3F5139)),
                    onPressed: () {
                      final designer = product['designer'];
                      final designerId = designer?['id'];
                      final designerName = designer?['name'] ?? 'Không rõ';

                      if (designerId == null) return;

                      Navigator.pushNamed(
                        context,
                        AppRoutes.chatDetail,
                        arguments: {
                          'conversationId': '',
                          'senderName': designerName,
                          'designerId': designerId,
                        },
                      );

                    },
                  ),

                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.zero,
              color: const Color(0xFFF4F4F4),
              height: 10,
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Sản phẩm khác',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mainTextColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _furs.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = _furs[index];
                    final id = item['id'];
                    final name = item['name'] ?? '';
                    final price = item['price'] ?? 0;
                    final rating = item['rating'] ?? 0;
                    final imageSource = item['primaryImage']?['imageSource'];

                    return GestureDetector(
                      onTap: () async {
                        final response = await UserService.getProductById(id);
                        if (response != null && response['data'] != null) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.customerFurDetail,
                            arguments: response['data'],
                          );
                        }
                      },

                      child: SizedBox(
                        width: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Container(
                                height: 170,
                                color: const Color(0xFFBCD4B5),
                                child:
                                    imageSource != null &&
                                            imageSource.isNotEmpty
                                        ? Image.network(
                                          imageSource,
                                          fit: BoxFit.contain,
                                        )
                                        : const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 40,
                                            color: Colors.white54,
                                          ),
                                        ),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(12),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Giá: ${formatCurrency(price)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$rating',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.zero,
              color: const Color(0xFFF4F4F4),
              height: 10,
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Đánh giá',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mainTextColor,
                ),
              ),
            ),

            const SizedBox(height: 12),
            ReviewContent(
              productId: widget.product['id'],
              reviews: _reviews,
              onSubmitted: () async {
                final res = await UserService.getProductById(widget.product['id']);
                if (res != null && res['data'] != null) {
                  _loadProduct(res['data']);
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SizedBox(
          height: 70,
          child: BuyMenu(
            onAddToCart: () async {
              final productDetail = widget.product;
              final isActive = productDetail['active'] ?? false;

              if (!isActive) {
                // Không cho thêm nếu sản phẩm hết hàng
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Sản phẩm đã hết hàng")),
                );
                return;
              }

              try {
                final response = await UserService.addToCart(
                  _quantity,
                  widget.product['id'].toString(),
                );

                if (response != null && response['statusCode'] == 200) {
                  // ✅ Tăng số lượng trên badge giỏ hàng
                  Provider.of<CartProvider>(context, listen: false).increment();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã thêm vào giỏ hàng!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Thêm vào giỏ thất bại: ${response['message'] ?? 'Không rõ lỗi'}",
                      ),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Vui lòng chọn các sản phẩm có cùng nhà thiết kế",
                    ),
                  ),
                );
              }
            },

            onBuyNow: () {
              print('Mua ngay');
            },
          ),
        ),
      ),
    );
  }
}
