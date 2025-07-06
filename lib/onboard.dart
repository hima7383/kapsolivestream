import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tikvid/loginchoices.dart';
import 'package:tikvid/phonelogin.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      background: Image(image: AssetImage('images/Bg1.png')),
      title: '',
      description: 'Capture Life\'s Moments in a Flash',
      icon: Icons.star,
    ),
    const OnboardingPage(
      background: Image(image: AssetImage('images/Bg2.png')),
      title: '',
      description: 'Your Stories, Our Stage: Short, Sweet, and Stunning!',
      icon: Icons.phone_iphone,
    ),
    const OnboardingPage(
      background: Image(image: AssetImage('images/Bg3.png')),
      title: '',
      description: 'Instant Entertainment, Endless Inspiration!',
      icon: Icons.rocket,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (_) => const Loginchoices()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: _pages,
          ),
          
          // Skip button (top right)
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _completeOnboarding,
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
          
          // Page indicator (bottom center)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: const WormEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.grey,
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
            ),
          ),
          
          // Next/Done button (bottom right)
          Positioned(
            
            bottom: 30,
            right: 20,
            child: _currentPage == _pages.length - 1
                ? ElevatedButton(
                  
                    onPressed: _completeOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                    ),
                   
                  ), child: const Padding(
                    
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Get Started',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
               ) : IconButton(
                    onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    ),
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
          ),
          
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Image background;

  const OnboardingPage({
    required this.background,
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return   Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: background.image,
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           
            const SizedBox(height: 190),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 120),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic
              ),
            ),
          ],
        ),
      ),
    );
  }
}