import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schedula/userAccounts/login_page.dart';

class VerificationDialog extends StatefulWidget {
  final User user;
  final Map<String, dynamic> userData;
  final VoidCallback onCancel;
  final VoidCallback onVerified;

  const VerificationDialog({
    super.key,
    required this.user,
    required this.userData,
    required this.onCancel,
    required this.onVerified,
  });

  @override
  State<VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<VerificationDialog> {
  bool _isVerified = false;
  bool _isLoading = true;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    while (!_isVerified && !_isCancelled) {
      await widget.user.reload();
      _isVerified = widget.user.emailVerified;

      if (_isVerified) {
        // Save user data after verification
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .set({
          ...widget.userData,
          'emailVerified': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account verified successfully!')),
          );
        }
        return;
      }

      await Future.delayed(const Duration(seconds: 3));
    }
  }

  void _cancelVerification() {
    setState(() {
      _isCancelled = true;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'A verification email has been sent to:',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              widget.user.email ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            if (_isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Waiting for email verification...'),
                ],
              ),
            if (_isVerified)
              const Column(
                children: [
                  Icon(Icons.check_circle, size: 60, color: Colors.green),
                  SizedBox(height: 20),
                  Text('Email verified successfully!'),
                ],
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _cancelVerification,
              child: const Text('Cancel and Return to Login'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => widget.user.sendEmailVerification(),
              child: const Text('Resend Verification Email'),
            ),
          ],
        ),
      ),
    );
  }
}
