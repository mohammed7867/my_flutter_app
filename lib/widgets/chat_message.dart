import 'package:flutter/material.dart';
import '../providers/chat_provider.dart';
import 'message_bubble.dart';

class ChatMessage extends StatelessWidget {
  final Message message;

  ChatMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: MessageBubble(
        message: message.content,
        isMe: message.role == 'user',
        key: ValueKey(message.id),
      ),
    );
  }
}