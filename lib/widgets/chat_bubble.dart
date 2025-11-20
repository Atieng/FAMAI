import 'package:flutter/material.dart';
import 'package:famai/models/chat_message.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUserMessage = message.author == MessageAuthor.user;
    final theme = Theme.of(context);

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUserMessage ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUserMessage ? Radius.zero : const Radius.circular(16),
          ),
        ),
        color: isUserMessage ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.message),
              const SizedBox(height: 4),
              Text(
                DateFormat('hh:mm a').format(message.timestamp.toDate()),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
