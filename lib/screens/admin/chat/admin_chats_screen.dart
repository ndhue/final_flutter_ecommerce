import 'package:final_ecommerce/data/mock_chat_provider.dart';
import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/widgets/widgets_export.dart';
import 'package:flutter/material.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<MockChatProvider>();
      chatProvider.fetchChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Customer Chats"),
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: borderColor, width: 0.5)),
        ),
        child: Consumer<MockChatProvider>(
          builder: (context, chatProvider, _) {
            if (chatProvider.isLoading) {
              return AdminChatSkeleton();
            }

            if (chatProvider.chats.isEmpty) {
              return const Center(child: Text("No chats available"));
            }

            return ListView.builder(
              itemCount: chatProvider.chats.length,
              itemBuilder: (context, index) {
                final chat = chatProvider.chats[index];
                int unreadCount = chatProvider.getUnreadMessages(chat.userId);

                return ListTile(
                  title: Text(chat.userName),
                  subtitle: Text(chat.lastMessage),
                  trailing:
                      unreadCount > 0
                          ? CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                          : const SizedBox.shrink(),
                  onTap: () {
                    chatProvider.markChatAsRead(chat.userId);
                    Navigator.pushNamed(
                      context,
                      chatScreenRoute,
                      arguments: {
                        "userId": chat.userId,
                        "userName": chat.userName,
                        "isAdmin": true,
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
