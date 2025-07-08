import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_routes.dart';

class OrderCard extends StatelessWidget {
  final dynamic order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final id = order['id'] ?? 'N/A';
    final status = order['status'] ?? 'Unknown';
    final name = order['customer']?['name'] ?? 'Unknown';

    final rawPrice = order['orderPrice'];
    final price = (rawPrice is int || rawPrice is double)
        ? rawPrice
        : int.tryParse(rawPrice.toString()) ?? 0;

    final rawDate = order['date'] as String?;
    DateTime? dateTime = rawDate != null ? DateTime.tryParse(rawDate) : null;
    final formattedDate = dateTime != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(dateTime.toLocal())
        : 'N/A';

    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.designerOrderDetail,
          arguments: id,
        );
      },
      child: Container(
        // XÓA height cố định để tránh overflow
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
            Text("Mã đơn: $id", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Người mua: $name"),
            const SizedBox(height: 4),
            Text("Tổng giá: ${currencyFormatter.format(price)}"),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Trạng thái: "),
                Expanded(
                  child: Text(
                    status,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text("Thời gian: $formattedDate"),
          ],
        ),
      ),
    );
  }
}
