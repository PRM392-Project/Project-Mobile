import 'package:flutter/material.dart';
import '../../widgets/customer/customer_header.dart';
import '../../widgets/customer/cus_chat_list.dart';
import '../../widgets/customer/customer_menu.dart';

class CustomerChatList extends StatelessWidget {
  const CustomerChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomerHeader(),
      ),
      body: const CusChatListContent(),
      bottomNavigationBar: const CustomerMenu(selectedIndex: 2),
    );
  }
}
