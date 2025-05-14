import 'package:final_ecommerce/models/user_model.dart';
import 'package:final_ecommerce/providers/chat_provider.dart';
import 'package:final_ecommerce/providers/user_provider.dart';
import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/screens/chat/chat_screen.dart';
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
  String _selectedUserId = '';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map<String, UserModel?> _userCache = {}; // Cache for user data
  Map<String, int> _unreadCountCache = {}; // Cache for unread counts
  bool _initialLoadDone = false;
  final Set<String> _chatInitializedForUser = {};

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
    final chatProvider = context.read<ChatProvider>();

    if (!_initialLoadDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        chatProvider.fetchChats();
        _initialLoadDone = true;
      });
    }
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

    if (_isLargeScreen(context)) {
      setState(() {
        _selectedUserId = userId;
      });
    } else {
      Navigator.pushNamed(
        context,
        adminSingleChat,
        arguments: {"userId": userId},
      );
    }
  }

  void _sendMessage() {
    final chatProvider = context.read<ChatProvider>();
    final userProvider = context.read<UserProvider>();
    final message = _messageController.text.trim();

    if (message.isNotEmpty && _selectedUserId.isNotEmpty) {
      chatProvider.sendMessage(
        _selectedUserId,
        userProvider.user!.id,
        userProvider.user!.fullName,
        message,
      );
      _messageController.clear();
    }
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

  int _getCachedUnreadCount(ChatProvider chatProvider, String userId) {
    if (!_unreadCountCache.containsKey(userId)) {
      _unreadCountCache[userId] = 0;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await chatProvider.fetchUnreadMessagesCount(userId);
        _unreadCountCache[userId] = chatProvider.unreadMessages;
        if (mounted) setState(() {});
      });
    }
    return _unreadCountCache[userId] ?? 0;
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
              final chatProvider = Provider.of<ChatProvider>(
                context,
                listen: false,
              );
              chatProvider.fetchChats();
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
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildSearchBar(),
                        Expanded(
                          child: _buildChatList(
                            filteredChats,
                            chatProvider,
                            user,
                            isLargeScreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: borderColor, width: 0.5),
                        ),
                      ),
                      child:
                          _selectedUserId.isEmpty
                              ? _buildEmptyChatPanel()
                              : _buildChatDetailPanel(_selectedUserId),
                    ),
                  ),
                ],
              );
            } else if (isMediumScreen) {
              return Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child: _buildChatList(
                      filteredChats,
                      chatProvider,
                      user,
                      isMediumScreen,
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child: _buildChatList(
                      filteredChats,
                      chatProvider,
                      user,
                      false,
                    ),
                  ),
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

  Widget _buildEmptyChatPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "Select a conversation",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Choose a chat from the list to start messaging",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildChatDetailPanel(String userId) {
    if (_selectedUserId.isNotEmpty && _selectedUserId == userId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_chatInitializedForUser.contains(userId)) {
          final chatProvider = Provider.of<ChatProvider>(
            context,
            listen: false,
          );
          chatProvider.ensureChatExists(userId);
          chatProvider.markChatAsRead(userId);

          _chatInitializedForUser.add(userId);
        }
      });
    }

    return Column(
      children: [
        FutureBuilder<UserModel?>(
          future: _getCachedUserById(userId),
          builder: (context, snapshot) {
            String username = "User ID: $userId";
            String status = "Customer";

            if (snapshot.hasData && snapshot.data != null) {
              username = snapshot.data!.fullName;
              status = snapshot.data!.email;
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    spreadRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    radius: 20,
                    backgroundImage:
                        snapshot.hasData &&
                                snapshot.data!.avatar != null &&
                                snapshot.data!.avatar!.isNotEmpty
                            ? NetworkImage(snapshot.data!.avatar!)
                            : null,
                    child:
                        snapshot.hasData &&
                                snapshot.data!.avatar != null &&
                                snapshot.data!.avatar!.isNotEmpty
                            ? null
                            : Text(
                              username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : "?",
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.open_in_new),
                    label: const Text("Open Full Chat"),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        adminSingleChat,
                        arguments: {"userId": userId},
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
        Expanded(
          child: ChatScreen(
            key: ValueKey<String>(userId),
            userId: userId,
            isWidget: true,
          ),
        ),
      ],
    );
  }

  Widget _buildChatList(
    List chatList,
    ChatProvider chatProvider,
    dynamic user,
    bool isWideScreen,
  ) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: chatList.length,
      itemBuilder: (context, index) {
        final chat = chatList[index];

        int unreadCount = _getCachedUnreadCount(chatProvider, chat.userId);

        final isLastMessageFromAdmin = chat.userId == user?.id;

        final isSelected = chat.userId == _selectedUserId;

        return Column(
          children: [
            ListTile(
              selected: isSelected,
              selectedTileColor: Colors.blue.withAlpha(10),
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
                      backgroundColor:
                          isSelected ? Colors.blue : Colors.blue.shade100,
                      backgroundImage: NetworkImage(snapshot.data!.avatar!),
                      radius: 20,
                    );
                  }

                  return CircleAvatar(
                    backgroundColor:
                        isSelected ? Colors.blue : Colors.blue.shade100,
                    radius: 20,
                    child: Text(
                      chat.userName.isNotEmpty
                          ? chat.userName[0].toUpperCase()
                          : "?",
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.blue.shade800,
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
                      isSelected || unreadCount > 0
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
                      color: unreadCount > 0 ? Colors.black : Colors.black87,
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
                  unreadCount > 0
                      ? Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      : isSelected
                      ? const Icon(Icons.check_circle, color: Colors.blue)
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
    super.dispose();
  }
}
