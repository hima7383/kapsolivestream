import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? userData;
  List<dynamic> userPosts = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      // Create requests with GET method but include body
      final profileRequest = http.Request(
        'GET',
        Uri.parse('http://31.97.185.64:3000/profile/get-profile'),
      );
      profileRequest.headers['Content-Type'] = 'application/json';
      profileRequest.body = json.encode({'userId': widget.userId});

      final profileResponse = await profileRequest.send();
      final profileResponseBody = await http.Response.fromStream(profileResponse);

      if (profileResponse.statusCode != 200) {
        print(profileResponseBody.body);
        throw Exception('Failed to load profile data');
      }

      final profileJson = json.decode(profileResponseBody.body);
      
      // Create posts request with GET method but include body
      final postsRequest = http.Request(
        'GET',
        Uri.parse('http://31.97.185.64:3000/profile/get-media'),
      );
      postsRequest.headers['Content-Type'] = 'application/json';
      postsRequest.body = json.encode({'flag': 'posts'});

      final postsResponse = await postsRequest.send();
      final postsResponseBody = await http.Response.fromStream(postsResponse);

      if (postsResponse.statusCode != 200) {
        throw Exception('Failed to load posts');
      }

      final postsJson = json.decode(postsResponseBody.body);

      setState(() {
        userData = profileJson['message']['userData'];
        userPosts = postsJson['message']['userReels'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text(
              "Profile",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.black,
            floating: true,
            pinned: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Header with background image and profile picture
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[900], // Placeholder for header image
                    ),
                    Positioned(
                      bottom: -60,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.black,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: userData?['profileImage'] != null && userData!['profileImage'].isNotEmpty
                                  ? NetworkImage(userData!['profileImage'])
                                  : const AssetImage('images/profilepic.png') as ImageProvider,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.edit, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 70),

                // User Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        userData?['phoneNumber'] ?? "User",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "( ${userPosts.length} )",
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Bio
                const Text("", style: TextStyle(color: Colors.white70, fontSize: 16)),

                const SizedBox(height: 24),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn("0", "Likes"),
                    _buildStatColumn("0", "Followers"),
                    _buildStatColumn("0", "Following"),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Tab Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTabIcon(Icons.favorite_border),
                  _buildTabIcon(Icons.bookmark_border),
                  _buildTabIcon(Icons.chat_bubble_outline),
                  _buildTabIcon(Icons.headset_mic_outlined),
                  _buildTabIcon(Icons.format_list_bulleted, color: Colors.red),
                ],
              ),
            ),
          ),
          
          // Posts Grid
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final post = userPosts[index];
                  final mediaUrl = post['url'] is List && post['url'].isNotEmpty 
                      ? post['url'][0] 
                      : '';
                      
                  return GestureDetector(
                    onTap: () {
                      // Handle post tap (e.g., open full screen view)
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: mediaUrl.isNotEmpty
                         ? FadeInImage(
        placeholder: const AssetImage('images/placeholder.png'),
        image: NetworkImage(mediaUrl),
        fit: BoxFit.cover,
        imageErrorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[800],
            child: const Icon(Icons.broken_image, color: Colors.white),
          );
        },
      )
    : Container(
        color: Colors.grey[800],
        child: const Center(child: Icon(Icons.no_photography, color: Colors.white)),
                    ),),
                  );
                },
                childCount: userPosts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400)),
      ],
    );
  }
  
  Widget _buildTabIcon(IconData icon, {Color color = Colors.white54}) {
    return Icon(icon, color: color, size: 28);
  }
}