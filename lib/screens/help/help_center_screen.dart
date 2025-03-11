import 'package:final_ecommerce/data/mock_chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HelpCenterScreen extends StatefulWidget {
  final String userId;

  const HelpCenterScreen({super.key, required this.userId});

  @override
  State<HelpCenterScreen> createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<HelpCenterScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<MockChatProvider>(
      context,
      listen: false,
    ).fetchMockMessages(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<MockChatProvider>(context);
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text("Chat with Admin")),
      body: Column(
        children: [
          Expanded(
            child:
                chatProvider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      reverse: true,
                      itemCount: chatProvider.messages.length,
                      itemBuilder: (context, index) {
                        final message = chatProvider.messages[index];
                        bool isUser = message.senderId == widget.userId;
                        return Align(
                          alignment:
                              isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.all(8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isUser ? Colors.blue[200] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(message.message),
                          ),
                        );
                      },
                    ),
          ),
          _buildMessageInput(controller, chatProvider),
        ],
      ),
    );
  }

  Widget _buildMessageInput(
    TextEditingController controller,
    MockChatProvider chatProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "Type a message"),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              chatProvider.sendMockMessage(
                widget.userId,
                widget.userId,
                "User",
                controller.text,
              );
              controller.clear();
            },
          ),
        ],
      ),
    );
  }
}
