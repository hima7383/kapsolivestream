import 'package:flutter/material.dart';

class HomeScreenInApp extends StatelessWidget {
  // Manual data for streams
  final List<LiveStream> streams = [
    LiveStream(
      imageAsset: 'images/Bg1.png',
      viewerCount: '1.2K',
      username: 'GamerPro',
      liveIconAsset: 'images/live.png', // Add your custom live icon
    ),
    LiveStream(
      imageAsset: 'images/Bg3.png',
      viewerCount: '3.5K',
      username: 'CookingMaster',
      liveIconAsset: 'images/live.png',
    ),
    LiveStream(
      imageAsset: 'images/Bg2.png',
      viewerCount: '856',
      username: 'TravelVibes',
      liveIconAsset: 'images/live.png',
    ),
    LiveStream(
      imageAsset: 'images/Bg1.png',
      viewerCount: '2.1K',
      username: 'FitnessGuru',
      liveIconAsset: 'images/live.png',
    ),
    LiveStream(
      imageAsset: 'images/Bg2.png',
      viewerCount: '5.7K',
      username: 'MusicStar',
      liveIconAsset: 'images/live.png',
    ),
    LiveStream(
      imageAsset: 'images/Bg3.png',
      viewerCount: '432',
      username: 'ArtisticSoul',
      liveIconAsset: 'images/live.png',
    ),
    LiveStream(
  imageAsset: 'images/Bg2.png',
  viewerCount: '432',
  username: 'ArtisticSoul',
  liveIconAsset: 'images/live.png',
),

LiveStream(
  imageAsset: 'images/Bg1.png',
  viewerCount: '1.2K',
  username: 'CreativeMind',
  liveIconAsset: 'images/live.png',
),

LiveStream(
  imageAsset: 'images/Bg3.png',
  viewerCount: '856',
  username: 'PixelPainter',
  liveIconAsset: 'images/live.png',
),

LiveStream(
  imageAsset: 'images/Bg1.png',
  viewerCount: '3.5K',
  username: 'DigitalDoodler',
  liveIconAsset: 'images/live.png',
),

LiveStream(
  imageAsset: 'images/Bg3.png',
  viewerCount: '724',
  username: 'InkMaster',
  liveIconAsset: 'images/live.png',
),

LiveStream(
  imageAsset: 'images/Bg2.png',
  viewerCount: '2.1K',
  username: 'CanvasQueen',
  liveIconAsset: 'images/live.png',
),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with search and notification icons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.search, size: 28, color: Colors.white),
                onPressed: () {},
              ),
              SizedBox(width: 8),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications, size: 28, color: Colors.white),
                    onPressed: () {},
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Categories horizontal scroll
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            
            children: [
              _buildCategoryChip('Mine', true),
              _buildCategoryChip('Explore', false),
              _buildCategoryChip('New', false),
              _buildCategoryChip('Nearby', false),
            ],
          ),
        ),

        // Live stream grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.5,
            ),
            itemCount: streams.length,
            itemBuilder: (context, index) {
              return _buildLiveStreamCard(streams[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.red : Colors.white,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: 4),
              height: 2,
              width: 20,
              color: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildLiveStreamCard(LiveStream stream) {
    return Stack(
      children: [
        // Background image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            stream.imageAsset,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        // Dark overlay at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),
        

        // Your custom live icon
        if (stream.liveIconAsset != null)
          Positioned(
            top: 8,
            left: 1,
            child: Image.asset(
              stream.liveIconAsset!,
              width: 50,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),

        // View count
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.remove_red_eye, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  stream.viewerCount,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Streamer info at bottom
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stream.username,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTag('#Gaming'),
                    SizedBox(width: 4),
                    _buildTag('#Live'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }
}

class LiveStream {
  final String imageAsset;
  final String viewerCount;
  final String username;
  final String? liveIconAsset;

  LiveStream({
    required this.imageAsset,
    required this.viewerCount,
    required this.username,
    this.liveIconAsset,
  });
}