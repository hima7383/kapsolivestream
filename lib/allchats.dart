import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tikvid/dming.dart';

class AllChatsScreen extends StatefulWidget {
  const AllChatsScreen({Key? key}) : super(key: key);

  @override
  _AllChatsScreenState createState() => _AllChatsScreenState();
}

class _AllChatsScreenState extends State<AllChatsScreen> {
  List<dynamic> chats = [];
  bool isLoading = true;
  String errorMessage = '';
  String? authToken;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchChats();
  }

  Future<void> _loadTokenAndFetchChats() async {
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

      await _fetchChats();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading token: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchChats() async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      final response = await http.get(
        Uri.parse('http://31.97.185.64:3000/chat/'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            chats = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = data['message'] ?? 'Failed to load chats';
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
          errorMessage = 'Failed to load chats: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  String _getChatTitle(dynamic chat) {
    // Find the participant that's not the current user
    if (chat['participants'].length > 1) {
      final otherParticipant = chat['participants'][1];
      return otherParticipant['username'] ?? 'Unknown User';
    }
    return 'Unknown Chat';
  }

  Future<void> _refreshChats() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    await _fetchChats();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Chats'),
          automaticallyImplyLeading: false,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshChats,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : chats.isEmpty
                        ? const Center(child: Text('No chats available'))
                        : ListView.builder(
                            itemCount: chats.length,
                            itemBuilder: (context, index) {
                              final chat = chats[index];
                              final lastMessage = chat['lastMessage'];
                              final chatTitle = _getChatTitle(chat);
                              
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(chatTitle[0].toUpperCase()),
                                ),
                                title: Text(chatTitle),
                                subtitle: Text(
                                  lastMessage?['message'] ?? 'No messages',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  _formatDate(lastMessage?['createdAt']),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PrivateDMScreen(
      chatId: chat['_id'],
      otherUserId: chat['participants'][1]['_id'],
      otherUsername: chat['participants'][1]['username'],
    ),
  ),
);
                                  // Handle chat tap
                                  print('Chat tapped: ${chat['_id']}');
                                },
                              );
                            },
                          ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 7) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateString;
    }
  }
}