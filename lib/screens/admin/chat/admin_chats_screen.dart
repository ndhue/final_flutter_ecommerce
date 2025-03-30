import 'package:final_ecommerce/providers/chat_provider.dart';
import 'package:final_ecommerce/providers/user_provider.dart';
import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/widgets/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminChatsScreen extends StatefulWidget {
  const AdminChatsScreen({super.key});

  @override
  State<AdminChatsScreen> createState() => _AdminChatsScreenState();
}

class _AdminChatsScreenState extends State<AdminChatsScreen> {
  @override
  void initState() {
    super.initState();
    final chatProvider = context.read<ChatProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatProvider.fetchChats();
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (timestamp.isAfter(today)) {
      return DateFormat.Hm().format(timestamp); // Show only time (HH:mm)
    } else if (timestamp.isAfter(yesterday)) {
      return "Yesterday";
    } else {
      return DateFormat('dd/MM/yyyy').format(timestamp); // Show date format
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          "Customer Chats",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: borderColor, width: 0.5)),
        ),
        child: Consumer<ChatProvider>(
          builder: (context, chatProvider, _) {
            if (chatProvider.isLoading) {
              return const AdminChatSkeleton();
            }

            if (chatProvider.chats.isEmpty) {
              return const Center(child: Text("No chats available"));
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: chatProvider.chats.length,
              itemBuilder: (context, index) {
                final chat = chatProvider.chats[index];
                int unreadCount = chatProvider.unreadMessages;

                // Check if the last message is sent by the admin
                final isLastMessageFromAdmin = chat.userId == user?.id;

                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        chat.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        spacing: 16.0,
                        children: [
                          Text(
                            (isLastMessageFromAdmin ? "You: " : "") +
                                (chat.lastMessage.length > 30
                                    ? '${chat.lastMessage.substring(0, 30)}...'
                                    : chat.lastMessage),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _formatTimestamp(chat.lastMessageTimestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (unreadCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 12,
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        chatProvider.markChatAsRead(chat.userId);
                        Navigator.pushNamed(
                          context,
                          adminSingleChat,
                          arguments: {
                            "userId": chat.userId,
                            "userName": chat.userName,
                            "isAdmin": true,
                          },
                        );
                      },
                    ),
                    Divider(height: 1, thickness: 0.2, color: Colors.grey[400]),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
