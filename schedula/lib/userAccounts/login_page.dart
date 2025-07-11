import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedula/adminScreen/admin_dashboard.dart';
import 'package:schedula/userAccounts/createUser.dart';
import 'package:schedula/userAccounts/forgot_password.dart';
import 'package:schedula/utils/all_dialouge.dart';
import 'package:schedula/utils/toast_message.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final auth = FirebaseAuth.instance;
  bool _isPasswordVisible = false; // Password visibility state

  void _startScreen() async {
    try {
      // Check for admin credentials
      if (email.text.trim() == 'admin@gmail.com' &&
          password.text == '@admin123') {
        showLoadingDialoge(context);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(); // Pop the loading dialog
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => const AdminDashboard(),
          ),
        );
        return;
      }

      // Regular user authentication
      showLoadingDialoge(context);
      await auth.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      showToastMessageWarning('Invalid email or password');
    }
  }

  void _createUserScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const CreateUser(),
      ),
    );
  }

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.amber,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade300.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: SizedBox(
                      width: 100,
                      child: Image.asset('assets/images/appstore.png'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      label: Text('Email'),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: password,
                    obscureText: !_isPasswordVisible,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      label: const Text('Password'),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[900],
                      ),
                      onPressed: _startScreen,
                      autofocus: true,
                      child: Text(
                        'Login',
                        style: GoogleFonts.getFont('Lumanosimo',
                            textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'OR',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.lato(
                          fontStyle: FontStyle.italic,
                          fontSize: 18,
                        ),
                      ),
                      GestureDetector(
                        onTap: _createUserScreen,
                        child: Text(
                          "Create account",
                          style: GoogleFonts.lato(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.orange[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
