import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const MessageBubble({
    required Key key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible( // <--- Important fix
          child: Container(
            decoration: BoxDecoration(
              color: isMe ? Colors.blue[300] : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
                bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
              ),
              textAlign: isMe ? TextAlign.right : TextAlign.left,
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }
}
