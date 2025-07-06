import 'package:flutter/material.dart';
import 'package:tikvid/botnavigation/homescreeninapp.dart';

class BotNave extends StatefulWidget {
  @override
  _BotNaveState createState() => _BotNaveState();
}

class _BotNaveState extends State<BotNave> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  bool _isAnimating = false; // Track animation state

  final List<Widget> _screens = [
    HomeScreenInApp(),
    EventsScreen(),
    AddPostScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (Rect bounds) {
      return LinearGradient(
        colors: [
          const Color.fromARGB(255, 110, 86, 86),
          Colors.red, // or Color.fromARGB(255, 184, 112, 112) for your original color
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        // Optional: Add stops for more control
        // stops: [0.3, 0.7],
      ).createShader(bounds);
    },
    child: Text(
      getAppBarTitle(),
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
    ),
  ),
  centerTitle: true,
),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _isAnimating = false;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: _buildAnimatedNavBar(),
    );
  }

  Widget _buildAnimatedNavBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => _animateToPage(index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: _AnimatedNavIcon(
                icon: Icons.home,
                isActive: _currentIndex == 0,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _AnimatedNavIcon(
                icon: Icons.event,
                isActive: _currentIndex == 1,
              ),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: _AnimatedNavIcon(
                icon: Icons.add_circle,
                isActive: _currentIndex == 2,
              ),
              label: 'Add Post',
            ),
            BottomNavigationBarItem(
              icon: _AnimatedNavIcon(
                icon: Icons.chat,
                isActive: _currentIndex == 3,
              ),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: _AnimatedNavIcon(
                icon: Icons.person,
                isActive: _currentIndex == 4,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _animateToPage(int index) {
    if (index == _currentIndex || _isAnimating) return;
    
    setState(() => _isAnimating = true);
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  String getAppBarTitle() {
    switch (_currentIndex) {
      case 0: return 'Kabso';
      case 1: return 'Events';
      case 2: return 'Add Post';
      case 3: return 'Chat';
      case 4: return 'Profile';
      default: return 'App';
    }
  }
}

class _AnimatedNavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const _AnimatedNavIcon({
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(isActive ? 1.2 : 1.0),
          child: Icon(
            icon,
            color: isActive ? Colors.red : Colors.grey,
          ),
        ),
        if (isActive)
          Container(
            margin: EdgeInsets.only(top: 4),
            height: 3,
            width: 20,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

// Placeholder screens




class EventsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Events Screen'));
  }
}

class AddPostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Add Post Screen'));
  }
}

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Chat Screen'));
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Profile Screen'));
  }
}