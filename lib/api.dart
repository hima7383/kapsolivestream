import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Message {
  final String id;
  final String content;
  final String senderId;
  final String receiverId;
  final String conversationId;
  final bool isSeen;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.conversationId,
    required this.isSeen,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      content: json['message'] ?? '',
      senderId: json['sender'],
      receiverId: json['receiver'],
      conversationId: json['conversation'],
      isSeen: json['isSeen'] ?? false,
      timestamp: DateTime.parse(json['createdAt']),
    );
  }
}

class Conversation {
  final String id;
  final List<String> participants;
  final Message lastMessage;

  Conversation({
    required this.id,
    required this.participants,
    required this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['_id'],
      participants: List<String>.from(json['participants']),
      lastMessage: Message.fromJson(json['lastMessage']),
    );
  }
}
class ApiService{
  static const String BASE_URL = "http://31.97.185.64:3000";
   Future<List<Conversation>> getAllConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final AUTH_TOKEN = prefs.getString('authToken');
    final response = await http.get(
      Uri.parse('$BASE_URL/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $AUTH_TOKEN',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Conversation.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load conversations. Status Code: ${response.statusCode}');
    }
  }

  Future<List<Message>> getConversationById(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final AUTH_TOKEN = prefs.getString('authToken');
    final response = await http.get(
      Uri.parse('$BASE_URL/chat/$conversationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $AUTH_TOKEN',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = json.decode(response.body);
      if (decodedBody is Map && decodedBody.containsKey('messages')) {
        List<dynamic> data = decodedBody['messages'];
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected response format for conversation details.');
      }
    } else {
      throw Exception(
          'Failed to load conversation details. Status Code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createConversation(
      String receiverId, String initialMessage) async {
    final prefs = await SharedPreferences.getInstance();
    final AUTH_TOKEN = prefs.getString('authToken');
    final response = await http.post(
      Uri.parse('$BASE_URL/chat/createConversation'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $AUTH_TOKEN',
      },
      body: json.encode({
        'receiverId': receiverId,
        'initialMessage': initialMessage,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to create conversation. Status Code: ${response.statusCode}');
    }
  }

  Future<Message> sendMessage(
      String conversationId, String receiverId, String message) async {
    final prefs = await SharedPreferences.getInstance();
    final AUTH_TOKEN = prefs.getString('authToken');
    final response = await http.post(
      Uri.parse('$BASE_URL/chat/sendMessage'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $AUTH_TOKEN',
      },
      body: json.encode({
        'conversationId': conversationId,
        'receiverId': receiverId,
        'message': message,
      }),
    );

    if (response.statusCode == 201) {
      return Message.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to send message. Status Code: ${response.statusCode}');
    }
  }
}