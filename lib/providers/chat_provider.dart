import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/lib/services/api_service.dart';

class Message {
  final String id;
  final String content;
  final String role; // 'user' or 'assistant'
  final DateTime timestamp;

  Message({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      content: map['content'] ?? '',
      role: map['role'] ?? 'user',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}

class Conversation {
  final String id;
  final String title;
  final DateTime timestamp;
  final String preview;

  Conversation({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.preview,
  });

  factory Conversation.fromMap(Map<String, dynamic> map, String id) {
    return Conversation(
      id: id,
      title: map['title'] ?? 'New Conversation',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      preview: map['preview'] ?? '',
    );
  }
}

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String apiUrl = 'http://z/api';

  String? _currentConversationId;
  List<Message> _messages = [];

  String? get currentConversationId => _currentConversationId;
  List<Message> get messages => [..._messages];

  Future<void> sendMessage(String content) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Add message to local list immediately for UI update
      final userMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        role: 'user',
        timestamp: DateTime.now(),
      );

      _messages.add(userMessage);
      notifyListeners();

      // Send to backend
      final response = await http.post(
        Uri.parse('$apiUrl/query'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'query': content,
          'user_id': userId,
          'conversation_id': _currentConversationId,
          'chat_history': _messages.map((m) => {
            'role': m.role,
            'content': m.content,
          }).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final botResponse = data['response'];
        final conversationId = data['conversation_id'];

        print("✅ BOT RESPONSE: $botResponse");
        print("📩 Conversation ID: $conversationId");

        // Update current conversation ID if needed
        if (_currentConversationId == null) {
          _currentConversationId = conversationId;
        }

        // Add bot response to local list
        final botMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_bot',
          content: botResponse,
          role: 'assistant',
          timestamp: DateTime.now(),
        );


        _messages.add(botMessage);
        notifyListeners();
      } else {
        print("❌ Backend Error ${response.statusCode}: ${response.body}");
        // Handle error
        final botMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_error',
          content: 'Sorry, I encountered an error processing your request.',
          role: 'assistant',
          timestamp: DateTime.now(),
        );

        _messages.add(botMessage);
        notifyListeners();
      }
    } catch (e) {
      print('Error sending message: $e');
      // Add error message
      final botMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_error',
        content: 'Sorry, I encountered an error processing your request.',
        role: 'assistant',
        timestamp: DateTime.now(),
      );

      _messages.add(botMessage);
      notifyListeners();
    }
  }

  Future<List<Conversation>> getConversationHistory() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final response = await http.get(Uri.parse('$apiUrl/chat-history/$userId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> conversations = data['conversations'];

        return conversations.map((conv) => Conversation.fromMap(conv, conv['id'])).toList();
      } else {
        throw Exception('Failed to load conversation history');
      }
    } catch (e) {
      print('Error getting conversation history: $e');
      return [];
    }
  }

  Future<void> loadConversation(String conversationId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final response = await http.get(Uri.parse('$apiUrl/conversation/$userId/$conversationId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> messagesData = data['messages'];

        _currentConversationId = conversationId;
        _messages = messagesData.map((msg) => Message.fromMap(msg, msg['id'])).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load conversation');
      }
    } catch (e) {
      print('Error loading conversation: $e');
      _messages = [];
      notifyListeners();
    }
  }

  void startNewConversation() {
    _currentConversationId = null;
    _messages = [];
    notifyListeners();
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}