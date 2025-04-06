import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_message.dart';
import '../widgets/new_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();
  bool _isLoading = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await Provider.of<AuthProvider>(context, listen: false).getUserData();
      if (userData != null) {
        setState(() {
          _userName = userData['name'] ?? 'User';
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load user data.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = Provider.of<ChatProvider>(context).messages;

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: Text('Academic Assistant'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'logout') {
                Provider.of<AuthProvider>(context, listen: false).signOut();
              } else if (value == 'history') {
                Navigator.of(context).pushNamed('/history');
              } else if (value == 'feedback') {
                Navigator.of(context).pushNamed('/feedback');
              } else if (value == 'new') {
                Provider.of<ChatProvider>(context, listen: false).startNewConversation();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'new',
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('New Chat'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Chat History'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'feedback',
                child: Row(
                  children: [
                    Icon(Icons.feedback, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Feedback'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : messages.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome, $_userName!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Ask me anything about your syllabus, exams, or assignments!',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (ctx, index) {
                  return ChatMessage(messages[index]);
                },
              ),
            ),
            NewMessage(),
          ],
        ),
      ),
    );
  }
}