import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MessagePopup extends StatefulWidget {
  final String receiverId;
  final Function() onMessageSent;

  const MessagePopup({
    Key? key,
    required this.receiverId,
    required this.onMessageSent,
  }) : super(key: key);

  @override
  _MessagePopupState createState() => _MessagePopupState();
}

class _MessagePopupState extends State<MessagePopup> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  Future<void> _sendInitialMessage() async {
    if (_messageController.text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // Assuming you store token with this key

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication required')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('http://31.97.185.64:3000/chat/createConversation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'receiverId': widget.receiverId,
          'initialMessage': _messageController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          widget.onMessageSent();
          Navigator.of(context).pop(); // Close the popup
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Failed to send message')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'New Message',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Type your message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            _isSending
                ? CircularProgressIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _sendInitialMessage,
                        child: Text('Send'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}