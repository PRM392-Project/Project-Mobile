import 'package:flutter/material.dart';
import '../../widgets/customer/customer_menu.dart';
import '../../widgets/customer/cus_profile_content.dart';

class CustomerProfile extends StatelessWidget {
  const CustomerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: CusProfileContent(),
      bottomNavigationBar: CustomerMenu(selectedIndex: 3),
    );
  }
}
