import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.4:8000/api";

  static Future<Map<String, dynamic>> sendQuery({
    required String query,
    required String userId,
    String? conversationId,
    List? chatHistory,
  }) async {
    final url = Uri.parse("$baseUrl/query");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "query": query,
        "user_id": userId,
        "conversation_id": conversationId,
        "chat_history": chatHistory ?? [],
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch response: ${response.body}");
    }
  }
}
