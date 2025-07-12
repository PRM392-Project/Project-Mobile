import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../routes/app_routes.dart';
import '../../services/user_service.dart';

class OrderCard extends StatefulWidget {
  final dynamic order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  late String currentStatus;

  final statusStringToNumber = {
    'Pending': 1,
    'Processing': 2,
    'Delivered': 3,
    'Cancelled': 4,
    'Refunded': 5,
  };

  final numberToStatusString = {
    1: 'Pending',
    2: 'Processing',
    3: 'Delivered',
    4: 'Cancelled',
    5: 'Refunded',
  };

  final allowedTransitions = {
    1: [2, 4], // Pending → Processing or Cancelled
    2: [3, 4], // Processing → Delivered or Cancelled
    3: [5], // Delivered → Refunded
  };

  final statusColorMap = {
    'Pending': Colors.grey,
    'Processing': Colors.orange,
    'Delivered': Colors.green,
    'Cancelled': Colors.red,
    'Refunded': Colors.purple,
  };

  final statusOptions = [
    'Pending',
    'Processing',
    'Delivered',
    'Cancelled',
    'Refunded',
  ];

  @override
  void initState() {
    super.initState();
    final rawStatus =
        widget.order['status']?.toString().toLowerCase() ?? 'pending';
    // Convert db lowercase to capitalized for dropdown
    currentStatus =
        numberToStatusString.entries
            .firstWhere(
              (e) => e.value.toLowerCase() == rawStatus,
              orElse: () => const MapEntry(1, 'Pending'),
            )
            .value;
  }

  Future<void> _onStatusChanged(String? newStatus) async {
    if (newStatus == null || newStatus == currentStatus) return;

    final currentNum = statusStringToNumber[currentStatus]!;
    final newNum = statusStringToNumber[newStatus]!;

    if (!(allowedTransitions[currentNum]?.contains(newNum) ?? false)) {
      Fluttertoast.showToast(msg: 'Trạng thái phải được cập nhật theo thứ tự');
      return;
    }

    try {
      await UserService.updateOrderStatus(
        widget.order['id'].toString(),
        newNum,
      );
      setState(() {
        currentStatus = newStatus;
      });
      Fluttertoast.showToast(msg: 'Cập nhật trạng thái thành công');
    } catch (e) {
      debugPrint('Status update error: $e');
      Fluttertoast.showToast(msg: 'Cập nhật trạng thái thất bại');
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    final id = order['id'] ?? 'N/A';
    final name = order['customer']?['name'] ?? 'Unknown';

    final rawPrice = order['orderPrice'];
    final price =
        (rawPrice is num) ? rawPrice : int.tryParse(rawPrice.toString()) ?? 0;
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
    );

    final rawDate = order['date'] as String?;
    DateTime? dateTime = rawDate != null ? DateTime.tryParse(rawDate) : null;
    final formattedDate =
        dateTime != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(dateTime.toLocal())
            : 'N/A';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.designerOrderDetail,
          arguments: id,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mã đơn: $id",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text("Người mua: $name"),
            const SizedBox(height: 4),
            Text("Tổng giá: ${currencyFormatter.format(price)}"),
            const SizedBox(height: 4),
            Text("Thời gian: $formattedDate"),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Trạng thái: "),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColorMap[currentStatus] ?? Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    currentStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value:
                  statusOptions.contains(currentStatus) ? currentStatus : null,
              onChanged: _onStatusChanged,
              decoration: InputDecoration(
                labelText: 'Cập nhật trạng thái',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items:
                  statusOptions.map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
