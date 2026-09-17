import 'package:flutter/material.dart';

class MobileOtpScreen extends StatefulWidget {
  const MobileOtpScreen({super.key});

  @override
  State<MobileOtpScreen> createState() => _MobileOtpScreenState();
}

class _MobileOtpScreenState extends State<MobileOtpScreen> {
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _otpSent = false;
  final _otpController = TextEditingController();

  void _sendOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _otpSent = true;
      });
    }
  }

  void _verifyOtp() {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP.')),
      );
      return;
    }
    
    // As per rules: DO NOT fake authentication.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backend configuration required for real OTP authentication.'),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MOBILE SIGN IN'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  _otpSent ? 'Enter OTP' : 'Enter Mobile Number',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _otpSent 
                    ? 'Please enter the 6-digit OTP sent to +91 ${_mobileController.text}' 
                    : 'We will send you an OTP to authenticate your account.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                
                if (!_otpSent) ...[
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      prefixText: '+91 ',
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      if (value.length != 10 || int.tryParse(value) == null) {
                        return 'Please enter a valid 10-digit number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _sendOtp,
                    child: const Text('SEND OTP', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(letterSpacing: 8.0),
                    decoration: const InputDecoration(
                      labelText: '6-digit OTP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _verifyOtp,
                    child: const Text('VERIFY', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _otpSent = false;
                        _otpController.clear();
                      });
                    },
                    child: const Text('Change Mobile Number', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
