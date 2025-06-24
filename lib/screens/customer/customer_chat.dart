import 'package:flutter/material.dart';
import '../../widgets/customer/cus_chat_content.dart';

class CustomerChat extends StatelessWidget {
  final String conversationId;
  final String senderName;
  final Function(String, String)? onMessageSent;

  const CustomerChat({
    super.key,
    required this.conversationId,
    required this.senderName,
    this.onMessageSent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CusChatContent(
        conversationId: conversationId,
        senderName: senderName,
        onMessageSent: onMessageSent,
      ),
    );
  }
}
