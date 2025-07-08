import 'package:flutter/material.dart';
import '../../widgets/designer/des_header.dart';
import '../../widgets/designer/des_chat_list.dart';
import '../../widgets/designer/des_menu.dart';

class DesignerChatList extends StatelessWidget {
  const DesignerChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: DesHeader(),
      ),
      body: const DesChatListContent(),
      bottomNavigationBar: const DesMenu(selectedIndex: 2),
    );
  }
}
