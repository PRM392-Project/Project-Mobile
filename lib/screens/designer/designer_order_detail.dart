import 'package:flutter/material.dart';
import '../../widgets/designer/des_header.dart';
import '../../widgets/designer/des_order_detail_content.dart';  // import widget mới


class DesignerOrderDetail extends StatelessWidget {
  final String orderId;

  const DesignerOrderDetail({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: DesHeader(),
      ),
      body: DesOrderDetailContent(orderId: orderId),

    );
  }
}
