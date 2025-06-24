import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CartCard extends StatelessWidget {
  final String? productImageUrl;
  final String productName;
  final int price;
  final int quantity;
  final int detailPrice;
  final bool isDesign;
  final VoidCallback onIncreaseQuantity;
  final VoidCallback onDecreaseQuantity;
  final VoidCallback onRemoveItem;

  const CartCard({
    Key? key,
    this.productImageUrl,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.detailPrice,
    required this.isDesign,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    required this.onRemoveItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            color: const Color(0xFFBCD4B5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: productImageUrl != null
                  ? Image.network(
                productImageUrl!,
                width: 130,
                height: 130,
                fit: BoxFit.contain,
              )
                  : Container(
                width: 70,
                height: 70,
                color: const Color(0xFFBCD4B5),
                child: const Icon(Icons.image_not_supported, size: 40, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text('Đơn giá: ${formatCurrency.format(price)}'),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tăng/giảm hoặc khoảng trống chiếm chỗ
                    isDesign
                        ? const SizedBox(width: 120) // giữ kích thước đều
                        : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: onDecreaseQuantity,
                            splashRadius: 20,
                            padding: const EdgeInsets.all(2),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: onIncreaseQuantity,
                            splashRadius: 20,
                            padding: const EdgeInsets.all(2),
                          ),
                        ],
                      ),
                    ),
                    // Nút xóa luôn hiển thị ở vị trí này
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: onRemoveItem,
                      splashRadius: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Tổng: ${formatCurrency.format(detailPrice)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
