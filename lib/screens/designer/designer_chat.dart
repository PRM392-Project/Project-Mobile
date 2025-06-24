import 'package:flutter/material.dart';
import '../../widgets/designer/des_chat_content.dart';

class DesignerChat extends StatelessWidget {
  final String conversationId;
  final String senderName;  // Thêm biến này

  const DesignerChat({
    super.key,
    required this.conversationId,
    required this.senderName,   // Thêm biến này
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: DesChatContent(
        conversationId: conversationId,
        senderName: senderName,
      ),
    );
  }
}
