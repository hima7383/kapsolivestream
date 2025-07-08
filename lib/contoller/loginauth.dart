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

class AuthService {

   
  static const String baseUrl = "http://31.97.185.64:3000/auth";
  

  Future<bool> registerWithPhone(String phoneNumber) async {
    //try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );
      
     // if (response.statusCode == 200) {
        return true;
    //  } else {
      //  final errorData = jsonDecode(response.body);
      //  throw Exception(errorData['message'] ?? 'Failed to send OTP');
     // }
    } //catch (e) {
    //  print('3');
    //  throw Exception('Error: ${e.toString()}');
   // }
 // }

  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
      );
      print(response.body);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        
        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);
        await prefs.setString('phoneNumber', phoneNumber);
        
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      throw Exception('Error: wrong otp or user not found}');
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.get( 'authToken'));
    return prefs.containsKey('authToken');
  }

  Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phoneNumber');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('phoneNumber');
  }
}