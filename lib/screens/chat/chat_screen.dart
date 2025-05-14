import 'dart:async';
import 'dart:io';

import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/services/cloudinary_service.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/utils.dart';
import 'package:final_ecommerce/widgets/widgets_export.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final bool isWidget;

  const ChatScreen({super.key, required this.userId, this.isWidget = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _viewImages = [];
  final List<XFile> _selectedImages = [];
  late UserModel user;
  bool _isFirstLoad = true;
  StreamSubscription? _messageSubscription;
  Timer? _debounce;
  bool _chatInitialized = false;

  @override
  void initState() {
    super.initState();

    final currentUser = context.read<UserProvider>().user;
    if (currentUser != null) {
      user = currentUser;
    }

    // Delay initialization slightly to prevent UI blocking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatInitialized) {
        _initializeChat();
        _chatInitialized = true;
      }
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the userId changes, reinitialize the chat
    if (oldWidget.userId != widget.userId) {
      // Cancel existing subscription first
      _cancelMessageSubscription();

      final chatProvider = context.read<ChatProvider>();
      chatProvider.clearMessages(); // Clear previous messages
      _chatInitialized = false; // Reset initialization flag

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeChat(); // Load new messages for the changed userId
        _chatInitialized = true;
      });
    }
  }

  void _cancelMessageSubscription() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
  }

  void _initializeChat() async {
    final chatProvider = context.read<ChatProvider>();

    setState(() => _isFirstLoad = true);

    // Only ensure the chat exists once
    await chatProvider.ensureChatExists(widget.userId);

    // Cancel previous subscription if exists
    _cancelMessageSubscription();

    // Setup a single subscription to messages
    _messageSubscription = chatProvider.listenToMessages(widget.userId).listen((
      messages,
    ) {
      if (_isFirstLoad) {
        setState(() => _isFirstLoad = false);
      }
    });

    // Mark as read only once during initialization
    chatProvider.markChatAsRead(widget.userId);
  }

  void _onScroll() {
    // Debounce the scroll event to prevent multiple API calls
    if (!(_debounce?.isActive ?? false)) {
      _debounce = Timer(const Duration(milliseconds: 300), () {
        final chatProvider = context.read<ChatProvider>();
        if (_scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 100 &&
            chatProvider.hasMoreMessages &&
            !chatProvider.isLoadingMore) {
          chatProvider.fetchMessages(widget.userId, loadMore: true);
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final List<XFile> pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.isEmpty) return;

    for (var file in pickedFiles) {
      if (kIsWeb) {
        Uint8List webImage = await file.readAsBytes();
        setState(() {
          _viewImages.add(webImage);
          _selectedImages.add(file);
        });
      } else {
        setState(() {
          _viewImages.add(File(file.path));
          _selectedImages.add(file);
        });
      }
    }
  }

  void _openImagePreview(
    BuildContext context,
    List<dynamic> images,
    dynamic selectedImage,
  ) {
    int initialIndex = images.indexOf(selectedImage);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(backgroundColor: Colors.black),
              body: PhotoViewGallery.builder(
                itemCount: images.length,
                pageController: PageController(initialPage: initialIndex),
                builder: (context, index) {
                  final image = images[index];

                  return PhotoViewGalleryPageOptions(
                    imageProvider:
                        (image is String)
                            ? NetworkImage(image)
                            : kIsWeb
                            ? MemoryImage(image as Uint8List) as ImageProvider
                            : FileImage(image as File) as ImageProvider,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered,
                  );
                },
              ),
            ),
      ),
    );
  }

  void _sendMessage() async {
    final chatProvider = context.read<ChatProvider>();
    if (_controller.text.isEmpty && _selectedImages.isEmpty) return;

    final String messageText = _controller.text;

    try {
      final String tempMessageId =
          "temp_${DateTime.now().millisecondsSinceEpoch}";

      List<String> tempImageUrls =
          _selectedImages.map((_) => "loading").toList();

      Message tempMessage = Message(
        id: tempMessageId,
        senderId: user.id,
        senderName: user.fullName,
        message: messageText,
        timestamp: DateTime.now(),
        imageUrls: tempImageUrls,
        isRead: false,
      );

      chatProvider.addLocalMessage(tempMessage);
      setState(() => _viewImages.clear());
      _controller.clear();

      List<String> uploadedImageUrls = [];
      for (var i = 0; i < _selectedImages.length; i++) {
        String? imageUrl = await CloudinaryService.uploadImage(
          _selectedImages[i],
        );
        if (imageUrl != null) {
          uploadedImageUrls.add(imageUrl);
        } else {
          debugPrint("Failed to upload image: ${_selectedImages[i].path}");
        }
      }

      await chatProvider.sendMessage(
        widget.userId,
        user.id,
        user.fullName,
        messageText,
        imageUrls: uploadedImageUrls,
      );

      chatProvider.replaceTempMessage(tempMessage, uploadedImageUrls);

      setState(() => _selectedImages.clear());
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to send message")));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _cancelMessageSubscription();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final userProvider = context.watch<UserProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return Scaffold(
      appBar:
          !widget.isWidget
              ? AppBar(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                centerTitle: isLargeScreen,
                title: FutureBuilder<UserModel?>(
                  future:
                      isAdmin(user)
                          ? userProvider.getUserById(widget.userId)
                          : null,
                  builder: (context, snapshot) {
                    if (isAdmin(user)) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Loading...");
                      }
                      return Text(
                        snapshot.hasData
                            ? snapshot.data!.fullName
                            : "Chat with Customer",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    } else {
                      return const Text(
                        "Chat with Admin",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                  },
                ),
              )
              : null,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 800 : double.infinity,
          ),
          child:
              _isFirstLoad
                  ? const ChatSkeletonLoader()
                  : Column(
                    children: [
                      Expanded(
                        child:
                            chatProvider.messages.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline,
                                        size: isLargeScreen ? 80 : 60,
                                        color: Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "No messages yet",
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 20 : 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Start a conversation with our support team",
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 16 : 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : Column(
                                  children: [
                                    if (chatProvider.isLoadingMore)
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        reverse: true,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isLargeScreen ? 24 : 8,
                                          vertical: isLargeScreen ? 16 : 8,
                                        ),
                                        itemCount: chatProvider.messages.length,
                                        itemBuilder: (context, index) {
                                          final message =
                                              chatProvider.messages[index];
                                          final bool isCurrentUser =
                                              message.senderId ==
                                              (isAdmin(user)
                                                  ? user.id
                                                  : widget.userId);
                                          final bool showTime =
                                              _shouldShowTimeSeparator(
                                                chatProvider.messages,
                                                index,
                                              );

                                          return Column(
                                            children: [
                                              if (showTime)
                                                _buildTimeSeparator(
                                                  message.timestamp,
                                                  isLargeScreen: isLargeScreen,
                                                ),
                                              _buildBubbleChat(
                                                isCurrentUser,
                                                message,
                                                isLargeScreen: isLargeScreen,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                      SafeArea(child: _buildMessageInput(isLargeScreen)),
                    ],
                  ),
        ),
      ),
    );
  }

  bool _shouldShowTimeSeparator(List<Message> messages, int index) {
    if (index == messages.length - 1) return true;

    final currentMessageTime = messages[index].timestamp;
    final previousMessageTime = messages[index + 1].timestamp;

    if (currentMessageTime.difference(previousMessageTime).inDays > 0) {
      return true;
    }

    return currentMessageTime.difference(previousMessageTime).inMinutes > 15;
  }

  Widget _buildTimeSeparator(DateTime timestamp, {bool isLargeScreen = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 16.0 : 8.0),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isLargeScreen ? 6 : 4,
            horizontal: isLargeScreen ? 16 : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
          ),
          child: Text(
            DateFormat("MMM d, yyyy - h:mm a").format(timestamp),
            style: TextStyle(
              fontSize: isLargeScreen ? 14 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBubbleChat(
    bool isCurrentUser,
    Message message, {
    bool isLargeScreen = false,
  }) {
    final bubbleMaxWidth =
        isLargeScreen
            ? MediaQuery.of(context).size.width * 0.4
            : MediaQuery.of(context).size.width * 0.7;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
        child: Container(
          margin: EdgeInsets.all(isLargeScreen ? 12 : 8),
          padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
          decoration: BoxDecoration(
            color: isCurrentUser ? bubbleChat : Colors.grey[300],
            borderRadius: BorderRadius.circular(isLargeScreen ? 12 : 8),
            boxShadow:
                isLargeScreen
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ]
                    : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.imageUrls.isNotEmpty)
                GestureDetector(
                  onTap:
                      () => _openImagePreview(
                        context,
                        message.imageUrls,
                        message.imageUrls.first,
                      ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isLargeScreen ? 8 : 6),
                    child:
                        message.imageUrls.first == "loading"
                            ? ImageSkeletonLoader(
                              width: isLargeScreen ? 300 : 200,
                              height: isLargeScreen ? 300 : 200,
                            )
                            : Image.network(
                              message.imageUrls.first,
                              width: isLargeScreen ? 300 : 200,
                              height: isLargeScreen ? 300 : 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: isLargeScreen ? 300 : 200,
                                  height: isLargeScreen ? 300 : 200,
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: isLargeScreen ? 70 : 50,
                                  ),
                                );
                              },
                            ),
                  ),
                ),
              if (message.message.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(
                    top:
                        message.imageUrls.isNotEmpty
                            ? (isLargeScreen ? 12 : 8)
                            : 0,
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 16.0 : 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_viewImages.isNotEmpty)
            SizedBox(
              height: isLargeScreen ? 120 : 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._viewImages.asMap().entries.map((entry) {
                    int index = entry.key;
                    var image = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap:
                            () =>
                                _openImagePreview(context, _viewImages, image),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  kIsWeb
                                      ? Image.memory(
                                        image as Uint8List,
                                        width: isLargeScreen ? 120 : 100,
                                        height: isLargeScreen ? 120 : 100,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.file(
                                        image as File,
                                        width: isLargeScreen ? 120 : 100,
                                        height: isLargeScreen ? 120 : 100,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                            Positioned(
                              top: -6,
                              right: -5,
                              child: GestureDetector(
                                onTap:
                                    () => setState(() {
                                      _viewImages.removeAt(index);
                                      _selectedImages.removeAt(index);
                                    }),
                                child: CircleAvatar(
                                  radius: isLargeScreen ? 12 : 10,
                                  backgroundColor: primaryColor,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: isLargeScreen ? 12 : 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.image,
                  color: primaryColor,
                  size: isLargeScreen ? 28 : 24,
                ),
                onPressed: _pickImage,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 16 : 12,
                    vertical: isLargeScreen ? 8 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    maxLines: isLargeScreen ? 2 : 1,
                    style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: primaryColor,
                  size: isLargeScreen ? 28 : 24,
                ),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
