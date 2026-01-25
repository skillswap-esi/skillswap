import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_colors.dart';
import '../auth_service.dart';

class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({super.key});

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? _verificationId;
  bool _isLoading = false;
  bool _codeSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phoneNumber = _phoneController.text.trim();
    
    if (phoneNumber.isEmpty) {
      setState(() => _errorMessage = 'Please enter a phone number');
      return;
    }

    // Validate phone number format (should start with +)
    if (!phoneNumber.startsWith('+')) {
      setState(() => _errorMessage = 'Phone number must start with country code (e.g., +212...)');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          print('[PhoneVerification] Auto-verification completed');
          await _linkPhoneCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('[PhoneVerification] Verification failed: ${e.message}');
          setState(() {
            _isLoading = false;
            _errorMessage = e.message ?? 'Verification failed';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          print('[PhoneVerification] Code sent. Verification ID: $verificationId');
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification code sent!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('[PhoneVerification] Auto-retrieval timeout');
          setState(() => _verificationId = verificationId);
        },
      );
    } catch (e) {
      print('[PhoneVerification] Error sending OTP: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to send verification code: $e';
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    
    if (otp.isEmpty) {
      setState(() => _errorMessage = 'Please enter the verification code');
      return;
    }

    if (_verificationId == null) {
      setState(() => _errorMessage = 'Please request a verification code first');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create credential with verification ID and OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _linkPhoneCredential(credential);
    } catch (e) {
      print('[PhoneVerification] Error verifying OTP: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid verification code';
      });
    }
  }

  Future<void> _linkPhoneCredential(PhoneAuthCredential credential) async {
    try {
      // Link phone credential to current user
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      await currentUser.linkWithCredential(credential);
      
      print('[PhoneVerification] Phone number linked successfully');

      // Update backend to mark phone as verified and award bonus credits
      await authService.value.verifyPhone();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone verified successfully! Bonus credits awarded.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Return to previous page
        Navigator.pop(context, true);
      }
    } on FirebaseAuthException catch (e) {
      print('[PhoneVerification] Firebase error: ${e.code} - ${e.message}');
      
      String errorMsg = 'Verification failed';
      if (e.code == 'provider-already-linked') {
        errorMsg = 'This phone number is already linked to your account';
      } else if (e.code == 'invalid-verification-code') {
        errorMsg = 'Invalid verification code';
      } else if (e.code == 'credential-already-in-use') {
        errorMsg = 'This phone number is already in use by another account';
      }

      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });
    } catch (e) {
      print('[PhoneVerification] Error linking credential: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to verify phone: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verify Phone Number'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Verify your phone number to earn bonus credits!',
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Phone number input
            if (!_codeSent) ...[
              const Text(
                'Enter your phone number',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Include country code (e.g., +212612345678)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+212612345678',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Send Verification Code',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],

            // OTP input
            if (_codeSent) ...[
              const Text(
                'Enter verification code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Code sent to ${_phoneController.text}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Verification Code',
                  hintText: '123456',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Verify Code',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : _sendOtp,
                child: const Text('Resend Code'),
              ),
            ],

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
