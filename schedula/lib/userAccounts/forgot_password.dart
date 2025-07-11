import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedula/utils/toast_message.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();

    // Validate email format
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      showToastMessageWarning('Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Try sending reset email directly
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // If no error, email was sent successfully

      showToastMessageSuccess('Password reset email sent to $email');
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToastMessageWarning('No account found with this email');
      } else {
        showToastMessageWarning(
            'Error: ${e.message ?? 'Failed to send reset email'}');
      }
    } catch (e) {
      showToastMessageWarning('An unexpected error occurred');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: Text(
            'Reset Password',
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 4,
          centerTitle: false,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter your email to receive a password reset link',
              style: GoogleFonts.lato(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendPasswordResetEmail,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }
}
