import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tikvid/entityclases/userdata.dart';



class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Using CustomScrollView to allow different scrolling components
      // like the profile header and the image grid to scroll together.
      body: CustomScrollView(
        slivers: [
          // The App Bar
          SliverAppBar(
            title: const Text(
              "My Moments",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.black,
            // Makes the app bar float over the content as you scroll.
            floating: true, 
            pinned: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {},
            ),
          ),
          
          // This adapter allows us to use regular widgets inside a CustomScrollView.
          // We place the entire profile section here.
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Header with background image and profile picture
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'images/Frame7.png', // Your header image
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: -60,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          const CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.black,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: AssetImage(
                                'images/profilepic.png'), // Your profile image
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
                        Userdata.userId ?? "New user",
                        style: TextStyle(
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
                    const Text(
                      "( 5 )",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Bio
                const Text("You are unstoppable when you believe in yourself", style: TextStyle(color: Colors.white70, fontSize: 16)),

                const SizedBox(height: 24),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn("20 K", "Likes"),
                    _buildStatColumn("35 K", "Followers"),
                    _buildStatColumn("15 K", "Follow"),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // This is the icon Tab Bar section
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
                  _buildTabIcon(Icons.format_list_bulleted, color: Colors.red), // Active tab
                ],
              ),
            ),
          ),
          
          // A SliverGrid to display the 3-column image gallery
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,      // 3 items per row
                crossAxisSpacing: 8.0,  // Horizontal spacing
                mainAxisSpacing: 8.0,   // Vertical spacing
                childAspectRatio: 0.7,  // Adjust aspect ratio for item height
              ),
              // Builds the grid items
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.asset(
                      'images/postsplaceholder.jfif', // <-- Add your temp pic here
                      fit: BoxFit.cover,
                    ),
                  );
                },
                childCount: Userdata.posts.length, // The number of items in the grid
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for stats
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
  
  // Helper widget for the tab icons
  Widget _buildTabIcon(IconData icon, {Color color = Colors.white54}) {
      return Icon(icon, color: color, size: 28);
  }
}