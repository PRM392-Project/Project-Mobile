import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../routes/app_routes.dart';
import '../../services/user_service.dart';

class DesChatListContent extends StatefulWidget {
  const DesChatListContent({Key? key}) : super(key: key);

  @override
  State<DesChatListContent> createState() => _DesChatListContentState();
}

class _DesChatListContentState extends State<DesChatListContent> {
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
    final data = await UserService.getAllConversations();
    setState(() {
      conversations = data;
      filteredConversations = data;
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
                hintText: 'Tìm kiếm khách hàng...',
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
                            AppRoutes.desChatDetail,
                            arguments: {
                              'conversationId': conversationId,
                              'senderName': senderName,
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
