import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String content;
  final String role;
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
      timestamp: DateTime.parse(map['timestamp']), // ✅ Fix here
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
      timestamp: DateTime.parse(map['timestamp']),
      preview: map['preview'] ?? '',
    );
  }
}


class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String apiUrl = 'http://192.168.1.11:8000/api';

  String? _currentConversationId;
  List<Message> _messages = [];

  String? get currentConversationId => _currentConversationId;
  List<Message> get messages => [..._messages];

  Future<void> sendMessage(String content) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final userMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        role: 'user',
        timestamp: DateTime.now(),
      );
      _messages.add(userMessage);
      notifyListeners();

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
        _currentConversationId ??= conversationId;

        _messages.add(Message(
          id: '${DateTime.now().millisecondsSinceEpoch}_bot',
          content: botResponse,
          role: 'assistant',
          timestamp: DateTime.now(),
        ));
        notifyListeners();
      } else {
        throw Exception('Backend Error');
      }
    } catch (e) {
      _messages.add(Message(
        id: '${DateTime.now().millisecondsSinceEpoch}_error',
        content: 'Sorry, I encountered an error processing your request.',
        role: 'assistant',
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  Future<List<Conversation>> getConversationHistory() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final response = await http.get(Uri.parse('$apiUrl/chat-history/$userId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['conversations'] as List)
            .map((conv) => Conversation.fromMap(conv, conv['id']))
            .toList();
      } else {
        throw Exception('Failed to load conversation history');
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> loadConversation(String conversationId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final response = await http.get(Uri.parse('$apiUrl/conversation/$userId/$conversationId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🛠 Fix: set _currentConversationId FIRST
        _currentConversationId = conversationId;

        // 🛠 Fix: parse messages properly
        _messages = (data['messages'] as List).map((msg) {
          return Message(
            id: msg['id'],
            content: msg['content'],
            role: msg['role'],
            timestamp: DateTime.parse(msg['timestamp']),  // Important!
          );
        }).toList();

        notifyListeners();
      }
    } catch (e) {
      _messages = [];
      notifyListeners();
    }
  }


  Future<List<Map<String, dynamic>>> fetchExamDates() async {
    final response = await http.get(Uri.parse('$apiUrl/exam-dates'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body)['exam_dates']);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchAssignments() async {
    final response = await http.get(Uri.parse('$apiUrl/assignments'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body)['assignments']);
    }
    return [];
  }

  Future<List<String>> fetchSyllabusTopics(String department) async {
    final response = await http.get(Uri.parse('$apiUrl/syllabus-topics/$department'));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body)['topics']);
    }
    return [];
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
