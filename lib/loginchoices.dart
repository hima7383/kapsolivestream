import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tikvid/botnavigation/botnav.dart';
import 'package:tikvid/otpscreen.dart';
import 'package:tikvid/phonelogin.dart';

class Loginchoices extends StatefulWidget {
  const Loginchoices({super.key});

  @override
  State<Loginchoices> createState() => _LoginchoicesState();
}

class _LoginchoicesState extends State<Loginchoices> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen background image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('images/Bglogin.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Get Started",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                    _buildSignInButton(
                      icon: Image.asset(
                        'images/google_logo.png',
                        height: 24,
                        width: 24,
                      ),
                      text: 'Sign in with Google',
                    ),
                    const SizedBox(height: 20),
                    _buildSignInButton(
                      icon: Image.asset(
                        'images/apple_logo.png',
                        height: 24,
                        width: 24,
                      ),
                      text: 'Sign in with Apple',
                    ),
                    const SizedBox(height: 20),
                    _buildSignInButton(
                      icon: const Icon(Icons.phone, color: Colors.white),
                      text: 'Sign in with Phone',
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Text(
                      "I have read and agreed to the",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ), 
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    Text(
                      "Terms of Service",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 4),
                     Text(
                      "&",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 4),
                     Text(
                      "Privacy Policy",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton({
    required Widget icon,
    required String text,
  }) {
    return OutlinedButton(
      onPressed: () {
         Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) =>  PhoneInputScreen()),
    );
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade400),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}