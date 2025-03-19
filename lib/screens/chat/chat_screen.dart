import 'dart:io';

import 'package:final_ecommerce/data/mock_chat_provider.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/services/cloudinary_service.dart';
import 'package:final_ecommerce/utils/constants.dart';
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
  final String userName;
  final bool isAdmin;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.isAdmin,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _viewImages = [];
  final List<XFile> _selectedImages = [];

  late String chatId;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    chatId = "chat_${widget.userId}";
    final chatProvider = context.read<MockChatProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatProvider.fetchMockMessages(widget.userId).then((_) {
        setState(() {
          _isFirstLoad = false;
        });
      });
      chatProvider.markChatAsRead(widget.userId);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final chatProvider = context.read<MockChatProvider>();
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        chatProvider.hasMoreMessages &&
        !chatProvider.isLoading) {
      debugPrint("Loading more messages");
      chatProvider.fetchMockMessages(widget.userId, loadMore: true);
    }
  }

  Future<void> _pickImage() async {
    final List<XFile> pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.isEmpty) return;

    for (var file in pickedFiles) {
      if (kIsWeb) {
        Uint8List webImage = await file.readAsBytes(); // Web uses bytes
        setState(() {
          _viewImages.add(webImage);
          _selectedImages.add(file);
        });
      } else {
        setState(() {
          _viewImages.add(File(file.path));
          _selectedImages.add(file);
        }); // Mobile uses File
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
                        (image is String) // If image is a URL from Firestore/Cloudinary
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
    final chatProvider = context.read<MockChatProvider>();

    if (_controller.text.isEmpty && _selectedImages.isEmpty) return;

    // Create a temporary message for instant UI feedback
    List<String> tempImageUrls = _selectedImages.map((_) => "loading").toList();
    Message tempMessage = Message(
      id: DateTime.now().toString(),
      senderId: widget.isAdmin ? "admin" : widget.userId,
      senderName: widget.isAdmin ? "Admin" : widget.userName,
      message: _controller.text,
      timestamp: DateTime.now(),
      imageUrls: tempImageUrls,
      isRead: false,
    );

    chatProvider.addLocalMessage(tempMessage); // Add temp message to UI
    setState(() {
      _viewImages.clear();
    });
    _controller.clear();

    // Upload images in the background
    List<String> uploadedImageUrls = [];
    for (var i = 0; i < _selectedImages.length; i++) {
      String? imageUrl = await CloudinaryService.uploadImage(
        _selectedImages[i],
      );
      uploadedImageUrls.add(imageUrl ?? ""); // Keep empty if upload fails
    }

    // Replace temp message with final message
    chatProvider.replaceTempMessage(tempMessage, uploadedImageUrls);
    // Clear selected images after upload success
    setState(() {
      _selectedImages.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isAdmin ? widget.userName : "Chat with Admin",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: borderColor, width: 0.5)),
        ),
        child: Column(
          children: [
            Expanded(
              child: Consumer<MockChatProvider>(
                builder: (context, chatProvider, _) {
                  return StreamBuilder<List<Message>>(
                    stream: chatProvider.listenToMessages(widget.userId),
                    builder: (context, snapshot) {
                      if (chatProvider.isLoading && _isFirstLoad) {
                        return ChatSkeletonLoader();
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text("Error loading messages"),
                        );
                      }

                      final messages = snapshot.data ?? [];
                      return Column(
                        children: [
                          if (chatProvider.isLoading)
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
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                final bool isCurrentUser =
                                    message.senderId ==
                                    (widget.isAdmin ? "admin" : widget.userId);
                                final bool showTime = _shouldShowTimeSeparator(
                                  messages,
                                  index,
                                );

                                return Column(
                                  children: [
                                    if (showTime)
                                      _buildTimeSeparator(
                                        message.timestamp,
                                        index,
                                        messages,
                                      ),
                                    _buildBubbleChat(isCurrentUser, message),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            SafeArea(child: _buildMessageInput()),
          ],
        ),
      ),
    );
  }

  bool _shouldShowTimeSeparator(List<Message> messages, int index) {
    if (index == messages.length - 1) return true;

    final currentMessageTime = messages[index].timestamp;
    final previousMessageTime = messages[index + 1].timestamp;

    // Show full date if more than 1 day apart
    if (currentMessageTime.difference(previousMessageTime).inDays > 0) {
      return true;
    }

    // Show time separator if more than 15 minutes apart
    return currentMessageTime.difference(previousMessageTime).inMinutes > 15;
  }

  /// **Time Separator Widget**
  Widget _buildTimeSeparator(
    DateTime timestamp,
    int index,
    List<Message> messages,
  ) {
    bool isFullDateNeeded =
        (index == messages.length - 1) ||
        messages[index].timestamp
                .difference(messages[index + 1].timestamp)
                .inDays >
            0;

    String formattedTime =
        isFullDateNeeded
            ? DateFormat("MMM d, yyyy - h:mm a").format(timestamp)
            : DateFormat("h:mm a").format(timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            formattedTime,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildBubbleChat(bool isCurrentUser, Message message) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser ? bubbleChat : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
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
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    message.imageUrls.first,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (message.message.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  top: message.imageUrls.isNotEmpty ? 8 : 0,
                ),
                child: Text(
                  message.message,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (_viewImages.isNotEmpty)
            Row(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._viewImages.asMap().entries.take(2).map((entry) {
                      int index = entry.key;
                      var image = entry.value;

                      return GestureDetector(
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
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.file(
                                        image as File,
                                        width: 100,
                                        height: 100,
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
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: primaryColor,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Show third image with counter if more than 2 images
                    if (_viewImages.length > 2)
                      GestureDetector(
                        onTap:
                            () => _openImagePreview(
                              context,
                              _viewImages,
                              _viewImages[2],
                            ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  kIsWeb
                                      ? Image.memory(
                                        _viewImages[2] as Uint8List,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.file(
                                        _viewImages[2] as File,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                            Container(
                              width: 100,
                              height: 100,
                              color: const Color.fromARGB(136, 158, 158, 158),
                              alignment: Alignment.center,
                              child: Text(
                                "+${_selectedImages.length - 2}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image, color: primaryColor),
                onPressed: _pickImage,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: primaryColor),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
