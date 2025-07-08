import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PrivateDMScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUsername;

  const PrivateDMScreen({
    Key? key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUsername,
  }) : super(key: key);

  @override
  _PrivateDMScreenState createState() => _PrivateDMScreenState();
}

class _PrivateDMScreenState extends State<PrivateDMScreen> {
  List<dynamic> messages = [];
  bool isLoading = true;
  String errorMessage = '';
  String? authToken;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchMessages();
  }

  Future<void> _loadTokenAndFetchMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      
      if (token == null || token.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = 'No authentication token found';
        });
        return;
      }

      setState(() {
        authToken = token;
      });

      await _fetchMessages();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading token: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchMessages() async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      final response = await http.get(
        Uri.parse('http://31.97.185.64:3000/chat/${widget.chatId}'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            messages = data['data'];
            isLoading = false;
          });
          // Scroll to bottom after messages are loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = data['message'] ?? 'Failed to load messages';
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          isLoading = false;
          errorMessage = 'Unauthorized - Please login again';
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load messages: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      final body = json.encode({
        "receiverId": widget.otherUserId,
        "message": message,
        "conversationId": widget.chatId,
      });

      final response = await http.post(
        Uri.parse('http://31.97.185.64:3000/chat/sendMessage'),
        headers: headers,
        body: body,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Refresh messages after sending
          await _fetchMessages();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Failed to send message')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _refreshMessages() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    await _fetchMessages();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUsername),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshMessages,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                      ? Center(child: Text(errorMessage))
                      : messages.isEmpty
                          ? const Center(child: Text('No messages yet'))
                          : ListView.builder(
                              controller: _scrollController,
                              // Remove reverse: true to show oldest at top
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                final isMe = message['sender'] != widget.otherUserId;
                                
                                return Align(
                                  alignment: isMe 
                                      ? Alignment.centerRight 
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4, 
                                      horizontal: 8,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isMe 
                                          ? const Color.fromARGB(255, 62, 156, 65) 
                                          : const Color.fromARGB(255, 82, 77, 33),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(message['message'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:  Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(message['createdAt']),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}