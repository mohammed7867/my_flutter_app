import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Conversation> _conversations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final conversations = await Provider.of<ChatProvider>(context, listen: false).getConversationHistory();
      setState(() {
        _conversations = conversations;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load conversation history.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat History'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
          ? Center(
        child: Text('No conversations yet. Start chatting!'),
      )
          : ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (ctx, index) {
          final conversation = _conversations[index];
          return ListTile(
            title: Text(conversation.title),
            subtitle: Text(
              conversation.preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              '${conversation.timestamp.day}/${conversation.timestamp.month}/${conversation.timestamp.year}',
            ),
            onTap: () async {
              await Provider.of<ChatProvider>(context, listen: false).loadConversation(conversation.id);
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}