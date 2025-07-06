import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:tikvid/botnavigation/homescreeninapp.dart';
import 'package:tikvid/contoller/loginauth.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({super.key, required this.phoneNumber});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _otp = '';
  bool _isLoading = false;
  String? _errorMessage;

  bool isButtonDisabled = false;
  int _start = 60;
  Timer? _timer;

  void startTimer() {
    print("timer started");
    setState(() {
      isButtonDisabled = true;
      _start = 60;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 1) {
        timer.cancel();
        setState(() {
          isButtonDisabled = false;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }
  void onResendPressed() async{
    startTimer();
     final authService = Provider.of<AuthService>(context, listen: false);
      await authService.registerWithPhone(widget.phoneNumber.trim());

    // Start the cooldown timer
  }
   @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.verifyOTP(widget.phoneNumber, _otp);
      
      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreenInApp()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/iconlogo1.png', width: 100, height: 100),
              const SizedBox(height: 20),
              Text(
                'Enter the OTP sent to ${widget.phoneNumber}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 20),
              PinCodeTextField(
                appContext: context,
                length: 6,
                onChanged: (value) => _otp = value,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 6) {
                    return 'Please enter a valid 6-digit OTP';
                  }
                  return null;
                },
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.underline,
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey,
                  selectedColor: Colors.white,
                  fieldHeight: 50,
                  fieldWidth: 40,
                ),
                keyboardType: TextInputType.number,
                textStyle: const TextStyle(color: Colors.white),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _verifyOTP,
                      child: const Text('Verify OTP'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
              TextButton(
                onPressed: ()async {
                  print(isButtonDisabled);
                  isButtonDisabled ? null : onResendPressed();
                  // Resend OTP logic
                },
                child:  Text(
                  isButtonDisabled ? 'Resend in $_start s' : 'Resend OTP',
        style: TextStyle(
          color: isButtonDisabled ? Colors.grey : Colors.blue,
        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}