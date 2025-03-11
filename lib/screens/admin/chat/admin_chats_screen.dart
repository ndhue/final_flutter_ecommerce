import 'package:final_ecommerce/data/mock_chat_provider.dart';
import 'package:final_ecommerce/routes/route_constants.dart';
// import 'package:final_ecommerce/providers/chat_provider.dart';
// import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminChatsScreen extends StatelessWidget {
  const AdminChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<MockChatProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Customer Chats (Mock)")),
      body:
          chatProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: chatProvider.chats.length,
                itemBuilder: (context, index) {
                  final chat = chatProvider.chats[index];
                  return ListTile(
                    title: Text(chat.userName),
                    subtitle: Text(chat.lastMessage),
                    trailing: Text(chat.lastMessageTimestamp.toString()),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        customerChatRoute,
                        arguments: {"userId": chat.userId},
                      );
                    },
                  );
                },
              ),
    );
  }
}
