import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famai/models/conversation_model.dart';
import 'package:famai/services/chat_service.dart';
import 'package:famai/screens/chat/chat_screen.dart';
import 'package:famai/utils/sample_data_util.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final _chatService = ChatService();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    try {
      // Add sample conversations for the demo
      final sampleData = SampleDataUtil();
      await sampleData.createSampleConversation();
    } catch (e) {
      debugPrint('Error initializing sample data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(), // New chat
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: _chatService.getConversations(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = snapshot.data!.docs
              .map((doc) => Conversation.fromFirestore(doc))
              .toList();

          if (conversations.isEmpty) {
            return const Center(child: Text('No conversations yet.'));
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return ListTile(
                title: Text(conversation.title),
                subtitle: Text(conversation.lastMessage),
                trailing: Text(
                  '${conversation.lastMessageTimestamp.toDate().hour}:${conversation.lastMessageTimestamp.toDate().minute}',
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(conversationId: conversation.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
