import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tikvid/botnavigation/botnav.dart';
import 'package:tikvid/botnavigation/homescreeninapp.dart';
import 'package:tikvid/contoller/loginauth.dart';
import 'package:tikvid/loginchoices.dart';
import 'package:tikvid/onboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Add slight delay to show splash screen
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('first_launch') ?? true;
    final authService = Provider.of<AuthService>(context, listen: false);
    final isLoggedIn = await authService.isLoggedIn();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) {
          if (isFirstLaunch) {
            return const OnboardingScreen();
          } else if (!isLoggedIn) {
            return const Loginchoices();
          } else {
            return  BotNave();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'images/iconlogo1.png',
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}