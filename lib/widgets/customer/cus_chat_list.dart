import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../../services/user_service.dart';

class CusChatListContent extends StatefulWidget {
  const CusChatListContent({Key? key}) : super(key: key);

  @override
  State<CusChatListContent> createState() => _CusChatListContentState();
}

class _CusChatListContentState extends State<CusChatListContent> {
  List<dynamic> conversations = [];
  List<dynamic> filteredConversations = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    String userId = '';
    if (token != null && token.isNotEmpty) {
      final decoded = JwtDecoder.decode(token);
      userId = decoded['Id'] ?? decoded['sub'] ?? '';
    }

    final data = await UserService.getAllConversations();
    final filtered = data.where((conv) {
      final senderId = conv['sender']?['id']?.toString();
      final receiverId = conv['receiver']?['id']?.toString();
      return !(senderId == userId && receiverId == userId);
    }).toList();

    setState(() {
      conversations = filtered;
      filteredConversations = filtered;
      isLoading = false;
    });
  }

  void filterConversations(String query) {
    setState(() {
      filteredConversations = conversations
          .where((item) => item['sender']['name']
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }

  String formatTime(String isoTime) {
    final dt = DateTime.parse(isoTime);
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: searchController,
              onChanged: filterConversations,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Tìm kiếm nhà thiết kế...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),

          // Danh sách hội thoại
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.separated(
              itemCount: filteredConversations.length,
              separatorBuilder: (_, __) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = filteredConversations[index];
                  final sender = item['sender'];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: sender['avatar'] != null
                          ? NetworkImage(sender['avatar'])
                          : AssetImage("assets/default_avatar.png") as ImageProvider,
                    ),
                    title: Text(sender['name']),
                      subtitle: Text(
                        item['lastMessage'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('HH:mm').format(DateTime.parse(item['lastMessageTime'])),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(DateTime.parse(item['lastMessageTime'])),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),

                      onTap: () {
                        final conversationId = item['id']?.toString();
                        final senderName = item['sender']?['name'] ?? 'Người dùng';
                        if (conversationId != null) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.chatDetail,
                            arguments: {
                              'conversationId': conversationId,
                              'senderName': senderName,
                              'onMessageSent': (String msg, String time) {
                                setState(() {
                                  final index = conversations.indexWhere((c) => c['id'].toString() == conversationId);
                                  if (index != -1) {
                                    conversations[index]['lastMessage'] = msg;
                                    conversations[index]['lastMessageTime'] = time;
                                    filteredConversations = [...conversations];
                                  }
                                });
                              },
                            },
                          );

                        } else {
                          print('Không có conversationId trong item');
                        }
                      }
                  );
                }
            ),
          ),
        ],
      ),
    );
  }
}
