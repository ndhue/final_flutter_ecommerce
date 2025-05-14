import 'dart:async';

import 'package:final_ecommerce/models/models_export.dart';
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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map<String, UserModel?> _userCache = {};
  bool _initialLoadDone = false;
  StreamSubscription? _chatSubscription;

  bool _isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200;
  }

  bool _isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 800 && width <= 1200;
  }

  @override
  void initState() {
    super.initState();
    context.read<ChatProvider>();

    if (!_initialLoadDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _subscribeToChatUpdates();
        _initialLoadDone = true;
      });
    }
  }

  void _subscribeToChatUpdates() {
    final chatProvider = context.read<ChatProvider>();
    _chatSubscription = chatProvider.listenToChats().listen(
      (chats) {},
      onError: (error) {
        debugPrint("Error listening to chats: $error");
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (timestamp.isAfter(today)) {
      return DateFormat.Hm().format(timestamp);
    } else if (timestamp.isAfter(yesterday)) {
      return "Yesterday";
    } else {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }

  void _navigateToChat(String userId) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.markChatAsRead(userId);

    Navigator.pushNamed(
      context,
      adminSingleChat,
      arguments: {"userId": userId},
    ).then((_) {
      chatProvider.fetchChats();
    });
  }

  Future<UserModel?> _getCachedUserById(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = await userProvider.getUserById(userId);
    _userCache[userId] = user;
    return user;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final isLargeScreen = _isLargeScreen(context);
    final isMediumScreen = _isMediumScreen(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          "Customer Chats",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false);
              _chatSubscription?.cancel();
              _subscribeToChatUpdates();
            },
            tooltip: "Refresh chats",
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: borderColor, width: 0.5)),
        ),
        child: Consumer<ChatProvider>(
          builder: (context, chatProvider, _) {
            if (chatProvider.isLoading) {
              return isLargeScreen
                  ? _buildLargeScreenSkeleton()
                  : const AdminChatSkeleton();
            }

            if (chatProvider.chats.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No chats available",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final filteredChats =
                _searchQuery.isEmpty
                    ? chatProvider.chats
                    : chatProvider.chats
                        .where(
                          (chat) =>
                              chat.userName.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ) ||
                              chat.lastMessage.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ),
                        )
                        .toList();

            if (isLargeScreen) {
              return Row(
                children: [
                  // Chat list panel (left)
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildSearchBar(),
                        Expanded(
                          child: _buildChatList(
                            filteredChats,
                            user,
                            isLargeScreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Dashboard info panel (right)
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: borderColor, width: 0.5),
                        ),
                      ),
                      child: _buildDashboardInfoPanel(),
                    ),
                  ),
                ],
              );
            } else if (isMediumScreen) {
              return Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child: _buildChatList(filteredChats, user, isMediumScreen),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildSearchBar(),
                  Expanded(child: _buildChatList(filteredChats, user, false)),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search chats...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildLargeScreenSkeleton() {
    return Row(
      children: [
        // Left panel skeleton
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Search bar skeleton
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Skeleton(height: 50, width: double.infinity),
              ),
              // Chat list skeleton
              const Expanded(child: AdminChatSkeleton()),
            ],
          ),
        ),
        // Right panel skeleton
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: borderColor, width: 0.5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // User avatar skeleton
                const AvatarSkeletonLoader(radius: 30),
                const SizedBox(height: 16),
                // Username skeleton
                const Skeleton(height: 24, width: 150),
                const SizedBox(height: 8),
                // Status skeleton
                const Skeleton(height: 16, width: 100),
                const SizedBox(height: 32),
                // Chat messages skeleton
                Container(
                  padding: const EdgeInsets.all(16),
                  height: 300,
                  width: 500,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const ChatSkeletonLoader(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Customer Support Dashboard",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),

          // Quick Stats Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Stats",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            Icons.chat,
                            chatProvider.chats.length.toString(),
                            "Active Chats",
                          ),
                          _buildStatItem(
                            Icons.notification_important,
                            chatProvider.chats
                                .where((chat) => chat.unreadCount > 0)
                                .length
                                .toString(),
                            "Unread",
                          ),
                          _buildStatItem(
                            Icons.people,
                            chatProvider.chats
                                .map((chat) => chat.userId)
                                .toSet()
                                .length
                                .toString(),
                            "Customers",
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Quick Actions Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Actions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(Icons.refresh, "Refresh Chats", () {
                        final chatProvider = Provider.of<ChatProvider>(
                          context,
                          listen: false,
                        );
                        chatProvider.fetchChats();
                      }),
                      _buildActionButton(
                        Icons.mark_chat_read,
                        "Mark All Read",
                        () {
                          final chatProvider = Provider.of<ChatProvider>(
                            context,
                            listen: false,
                          );

                          // Mark all chats as read
                          for (final chat in chatProvider.chats) {
                            chatProvider.markChatAsRead(chat.userId);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("All chats marked as read"),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Announcements or Notes
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Support Team Announcements",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: const [
                          _AnnouncementItem(
                            title: "Welcome to the Support Dashboard",
                            content:
                                "Use this panel to manage all customer communications. Select a chat from the left to open the conversation.",
                            date: "Today",
                            isPinned: true,
                          ),
                          _AnnouncementItem(
                            title: "Customer Response Guidelines",
                            content:
                                "Remember to respond to all customer inquiries within 2 hours during business hours.",
                            date: "Yesterday",
                          ),
                          _AnnouncementItem(
                            title: "New Feature: Image Attachments",
                            content:
                                "You can now send images in chat responses. Try it out with our customers!",
                            date: "Feb 15, 2023",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildChatList(List<Chat> chatList, dynamic user, bool isWideScreen) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: chatList.length,
      itemBuilder: (context, index) {
        final chat = chatList[index];

        final isLastMessageFromAdmin = chat.userId == user?.id;

        return Column(
          children: [
            ListTile(
              selectedTileColor: primaryColor.withAlpha(10),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: isWideScreen ? 8.0 : 4.0,
              ),
              leading: FutureBuilder<UserModel?>(
                future: _getCachedUserById(chat.userId),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.avatar != null &&
                      snapshot.data!.avatar!.isNotEmpty) {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(snapshot.data!.avatar!),
                      radius: 20,
                    );
                  }

                  return CircleAvatar(
                    radius: 20,
                    child: Text(
                      chat.userName.isNotEmpty
                          ? chat.userName[0].toUpperCase()
                          : "?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
              title: Text(
                chat.userName,
                style: TextStyle(
                  fontWeight:
                      chat.unreadCount > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    (isLastMessageFromAdmin ? "You: " : "") +
                        (chat.lastMessage.length > 30
                            ? '${chat.lastMessage.substring(0, 30)}...'
                            : chat.lastMessage),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          chat.unreadCount > 0 ? Colors.black : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(chat.lastMessageTimestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing:
                  chat.unreadCount > 0
                      ? Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          chat.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      : null,
              onTap: () => _navigateToChat(chat.userId),
            ),
            Divider(height: 1, thickness: 0.5, color: Colors.grey[300]),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _chatSubscription?.cancel(); // Cancel the subscription when disposing
    super.dispose();
  }
}

class _AnnouncementItem extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final bool isPinned;

  const _AnnouncementItem({
    required this.title,
    required this.content,
    required this.date,
    this.isPinned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPinned ? primaryColor.withAlpha(5) : Colors.white,
        border: Border.all(
          color: isPinned ? primaryColor.withAlpha(10) : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isPinned)
                const Icon(Icons.push_pin, color: primaryColor, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
