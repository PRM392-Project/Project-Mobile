import 'package:flutter/material.dart';
import '../../widgets/customer/customer_header.dart';
import '../../widgets/customer/cus_des_content.dart';  

class CustomerDesign extends StatelessWidget {
  const CustomerDesign({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomerHeader(),
      ),
      body: const CusDesContent(),
    );
  }
}
