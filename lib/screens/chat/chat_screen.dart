import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famai/models/chat_message.dart';
import 'package:famai/services/chat_service.dart';
import 'package:famai/widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String? conversationId;

  const ChatScreen({super.key, this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _chatService = ChatService();
  String? _currentConversationId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentConversationId = widget.conversationId;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_textController.text.isEmpty) return;
    final messageText = _textController.text;
    _textController.clear();

    setState(() => _isLoading = true);

    if (_currentConversationId == null) {
      final newConversationId = await _chatService.createNewConversation(messageText);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversationId: newConversationId),
          ),
        );
      }
    } else {
      await _chatService.sendMessage(messageText, conversationId: _currentConversationId!);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Famai Assistant')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _currentConversationId == null
                  ? const Stream.empty()
                  : _chatService.getMessages(_currentConversationId!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ChatMessage(
                    message: data['message'],
                    author: data['author'] == 'user'
                        ? MessageAuthor.user
                        : MessageAuthor.model,
                    timestamp: data['timestamp'] ?? Timestamp.now(),
                  );
                }).toList();

                return ListView.separated(
                  reverse: true,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => ChatBubble(message: messages[index]),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                );
              },
            ),
          ),
          _buildTextInput(),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return Material(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Ask me anything...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: _isLoading
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.send),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
