  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:jwt_decoder/jwt_decoder.dart';
  import '../../services/user_service.dart';
  import '../../services/signalr_service.dart';

  class CusChatContent extends StatefulWidget {
    final String conversationId;
    final String senderName;
    final String? designerId;
    final Function(String, String)? onMessageSent;

    const CusChatContent({
      Key? key,
      required this.conversationId,
      required this.senderName,
      this.designerId,
      this.onMessageSent,
    }) : super(key: key);

    @override
    State<CusChatContent> createState() => _CusChatContentState();
  }

  class _CusChatContentState extends State<CusChatContent> {
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

      if (conversationId.isEmpty && widget.designerId != null) {
        _createOrGetConversation(widget.designerId!);
      } else {
        _initUserAndSignalR();
        fetchConversation();
      }

      onMessageSent = widget.onMessageSent;
    }

    //lấy nếu đã có + tạo nếu chưa có
    Future<void> _createOrGetConversation(String designerId) async {
      try {
        print("Gọi API tạo/lấy conversation với designerId: $designerId");
        final response = await UserService.getConversationWithReceiver(designerId);
        print("Response trả về: $response");

        final newId = response['data']?.toString();

        if (newId != null && newId.isNotEmpty) {
          setState(() {
            conversationId = newId;
          });

          await _initUserAndSignalR();
          await fetchConversation();
        } else {
          print("Không thể lấy được conversation từ designerId: $designerId");
        }
      } catch (e) {
        print("Lỗi khi tạo/lấy conversation: $e");
      }
    }

    //decode id để xác định người gửi + người nhận
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

          await SignalRService.startConnection(token, _onReceiveMessage);
          await SignalRService.joinConversation(conversationId);
        } catch (e) {
          print("Error decoding token or starting SignalR: $e");
        }
      }
    }

    //xác định người nhận với người gửi để chia tin nhắn ra 2 bên trái phải
    void _onReceiveMessage(Map<String, dynamic> message) {
      if (message['conversationId'] == conversationId) {
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

    //lấy thông tin cuộc trò chuyện (nếu đã có lịch sử chat)
    Future<void> fetchConversation() async {
      if (conversationId.isEmpty) return;
      setState(() => isLoading = true);
      final data = await UserService.getConversationById(conversationId);
      setState(() {
        messages = (data is Map && data['data'] is List) ? data['data'] : [];
        isLoading = false;
      });
    }

    //thời gian gửi của từng tin nhắn
    String formatTime(String iso) {
      final dt = DateTime.parse(iso);
      return DateFormat.Hm().format(dt);
    }

    //ngày tháng gửi của từng tin nhắn
    String formatDate(String iso) {
      final dt = DateTime.parse(iso);
      return DateFormat('dd/MM/yyyy').format(dt);
    }

    //group các tin nhắn theo ngày tháng để hiện ngày tháng duy nhất 1 lần
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
      //ngắt kết nối SignalR khi màn hình bị hủy
      SignalRService.stopConnection();
      super.dispose();
    }

    void _sendMessage() async {
      final content = newMessage.trim();
      if (content.isEmpty) return;

      Map<String, dynamic>? receiverMsg = messages.cast<Map<String, dynamic>>().firstWhere(
            (msg) => msg['senderId'] != userId,
        orElse: () => {},
      );

      final receiverId = receiverMsg['senderId']?.toString();
      if (receiverId == null || receiverId.isEmpty) {
        print("Không tìm thấy receiverId từ message history");
        return;
      }

      if (receiverId == null) {
        print("Không tìm thấy receiverId từ message history");
        return;
      }

      setState(() => newMessage = '');
      _controller.clear();

      try {
        await SignalRService.sendMessage(userId, receiverId, content);
        print("Tin nhắn đã gửi qua SignalR");
      } catch (e) {
        print("Error sending message via SignalR: $e");
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
                        controller: _controller,
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
