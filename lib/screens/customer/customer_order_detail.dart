import 'package:flutter/material.dart';
import '../../widgets/customer/customer_header.dart';
import '../../widgets/customer/cus_order_detail_content.dart';  // import widget mới


class CustomerOrderDetail extends StatelessWidget {
  final String orderId;

  const CustomerOrderDetail({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomerHeader(),
      ),
      body: CusOrderDetailContent(orderId: orderId),

    );
  }
}
