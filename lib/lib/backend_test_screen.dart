import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BackendTestScreen extends StatelessWidget {
  const BackendTestScreen({super.key});

  Future<void> testBackendConnection(BuildContext context) async {
    const apiUrl = 'http://192.168.1.4:8000/api/test'; // Replace with your backend IP

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Backend says: $message")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error ${response.statusCode}: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Connection failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Backend API')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => testBackendConnection(context),
          child: const Text("Ping Backend"),
        ),
      ),
    );
  }
}
