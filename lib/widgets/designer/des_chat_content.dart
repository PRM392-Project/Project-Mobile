import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../services/user_service.dart';
import '../../services/signalr_service.dart';

class DesChatContent extends StatefulWidget {
  final String conversationId;
  final String senderName;
  final Function(String, String)? onMessageSent;

  const DesChatContent({
    Key? key,
    required this.conversationId,
    required this.senderName,
    this.onMessageSent,
  }) : super(key: key);

  @override
  State<DesChatContent> createState() => _DesChatContentState();
}

class _DesChatContentState extends State<DesChatContent> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> messages = [];
  String conversationId = '';
  String newMessage = '';
  bool isLoading = true;
  String userId = '';
  Function(String, String)? onMessageSent;

  @override
  void initState() {
    super.initState();
    conversationId = widget.conversationId;
    onMessageSent = widget.onMessageSent;
    _initUserAndSignalR();
    fetchConversation();
  }

  Future<void> _initUserAndSignalR() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      try {
        final decoded = JwtDecoder.decode(token);
        final extractedId = decoded['Id'] ?? decoded['sub'] ?? '';
        setState(() {
          userId = extractedId;
        });

        // Khởi tạo SignalR và lắng nghe tin nhắn realtime
        await SignalRService.startConnection(token, _onReceiveMessage);
        await SignalRService.joinConversation(widget.conversationId);
      } catch (e) {
        print("Error decoding token or starting SignalR: $e");
      }
    }
  }

  // Hàm gọi khi nhận tin nhắn realtime từ SignalR
  void _onReceiveMessage(Map<String, dynamic> message) {
    if (message['conversationId'] == conversationId) {
      // 👉 Gắn avatar nếu không có
      final senderId = message['senderId'];
      final existingMsg = messages.firstWhere(
            (m) => m['senderId'] == senderId && m['senderAvatar'] != null,
        orElse: () => null,
      );

      final enrichedMsg = Map<String, dynamic>.from(message);
      if (enrichedMsg['senderAvatar'] == null && existingMsg != null) {
        enrichedMsg['senderAvatar'] = existingMsg['senderAvatar'];
      }

      setState(() {
        messages.add(enrichedMsg);
      });
    }
  }

  Future<void> fetchConversation() async {
    setState(() => isLoading = true);
    final data = await UserService.getConversationById(conversationId);
    setState(() {
      messages = (data is Map && data['data'] is List) ? data['data'] : [];
      isLoading = false;
    });
  }

  String formatTime(String iso) {
    final dt = DateTime.parse(iso);
    return DateFormat.Hm().format(dt);
  }

  String formatDate(String iso) {
    final dt = DateTime.parse(iso);
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  Map<String, List<dynamic>> groupByDate(List<dynamic> msgs) {
    Map<String, List<dynamic>> grouped = {};
    for (var msg in msgs) {
      String date = formatDate(msg['createdTime']);
      grouped.putIfAbsent(date, () => []).add(msg);
    }
    return grouped;
  }

  @override
  void dispose() {
    // Ngắt kết nối SignalR khi màn hình bị hủy
    SignalRService.stopConnection();
    super.dispose();
  }

  void _sendMessage() async {
    final content = newMessage.trim();
    if (content.isEmpty) return;

    final receiverId =
    messages.firstWhere(
          (msg) => msg['senderId'] != userId,
      orElse: () => null,
    )?['senderId'];

    if (receiverId == null) {
      print("❌ Không tìm thấy receiverId từ message history");
      return;
    }

    setState(() => newMessage = '');
    _controller.clear();

    try {
      await SignalRService.sendMessage(userId, receiverId, content);
      print("📤 Tin nhắn đã gửi qua SignalR");
    } catch (e) {
      print("❌ Error sending message via SignalR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final modalArgs = ModalRoute.of(context)?.settings.arguments;
    if (onMessageSent == null && modalArgs != null && modalArgs is Map) {
      onMessageSent = modalArgs['onMessageSent'];
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF3F5139),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.senderName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                reverse: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children:
                groupByDate(
                  messages,
                ).entries.toList().reversed.map((entry) {
                  final date = entry.key;
                  final msgs = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          child: Text(
                            date,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      ...msgs.map((msg) {
                        final isOwn = msg['senderId'] == userId;
                        return Row(
                          mainAxisAlignment:
                          isOwn
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            if (!isOwn)
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 6,
                                ),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage:
                                  msg['senderAvatar'] != null
                                      ? NetworkImage(
                                    msg['senderAvatar'],
                                  )
                                      : null,
                                  child:
                                  msg['senderAvatar'] == null
                                      ? const Icon(
                                    Icons.person,
                                    size: 16,
                                  )
                                      : null,
                                ),
                              ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 6,
                              ),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                maxWidth:
                                MediaQuery.of(
                                  context,
                                ).size.width *
                                    0.7,
                              ),
                              decoration: BoxDecoration(
                                color:
                                isOwn
                                    ? const Color(0xFF3F5139)
                                    : const Color(0xFFF4F4F4),
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                isOwn
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg['content'],
                                    style: TextStyle(
                                      color:
                                      isOwn
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatTime(msg['createdTime']),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                      isOwn
                                          ? Colors.white70
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey)),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller, // ← Thêm dòng này
                      onChanged: (val) => setState(() => newMessage = val),
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Nhập tin nhắn...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF425A41)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
