import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/user_service.dart';
import '../../routes/app_routes.dart'; // nhớ import AppRoutes

class CusOrderDetailContent extends StatefulWidget {
  final String orderId;


  const CusOrderDetailContent({Key? key, required this.orderId}) : super(key: key);

  @override
  State<CusOrderDetailContent> createState() => _CusOrderDetailContentState();
}

class _CusOrderDetailContentState extends State<CusOrderDetailContent> {
  dynamic orderData;
  bool isLoading = true;

  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    final response = await UserService.getOrderById(id: widget.orderId);
    if (response != null && response['data'] != null) {
      setState(() {
        orderData = response['data'];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          splashColor: Colors.grey.withOpacity(0.3),
          highlightColor: Colors.transparent,
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.customerOrder);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderData == null
          ? const Center(child: Text('Không tải được chi tiết đơn hàng'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã đơn: ${orderData['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Khách hàng: ${orderData['customer']?['name'] ?? 'N/A'}'),
            const SizedBox(height: 4),
            Text('Nhà thiết kế: ${orderData['designer']?['name'] ?? 'N/A'}'),
            const SizedBox(height: 4),
            Text('Trạng thái: ${orderData['status'] ?? 'N/A'}'),
            const SizedBox(height: 4),
            Text('Tổng giá: ${currencyFormatter.format(orderData['orderPrice'] ?? 0)}'),
            const SizedBox(height: 16),
            const Divider(),
            const Text('Chi tiết sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...((orderData['orderDetails'] as List<dynamic>?) ?? []).map((detail) {
              final product = detail['product'] ?? {};
              final productName = product['name'] ?? 'N/A';
              final quantity = detail['quantity'] ?? 0;
              final detailPrice = detail['detailPrice'] ?? 0;
              final imageUrl = product['primaryImage']?['imageSource'];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Hình ảnh sản phẩm
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Image.network(
                          imageUrl ?? '',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80),
                        ),
                      ),

                      // Thông tin sản phẩm
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text('Số lượng: $quantity'),
                              const SizedBox(height: 4),
                              Text('Giá: ${currencyFormatter.format(detailPrice)}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 16),
            const Divider(),
            const Text('Lịch sử trạng thái:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...((orderData['statuses'] as List<dynamic>?) ?? []).map((statusItem) {
              final name = statusItem['name'] ?? 'N/A';
              final timeRaw = statusItem['time'] ?? '';
              DateTime? time = DateTime.tryParse(timeRaw);
              final formattedTime = time != null ? dateFormat.format(time.toLocal()) : 'N/A';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name),
                    Text(formattedTime, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
