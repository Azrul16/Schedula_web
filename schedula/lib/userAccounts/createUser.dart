// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedula/userAccounts/user_model.dart';
import 'package:schedula/utils/all_dialouge.dart';
import 'package:schedula/utils/toast_message.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({super.key});

  @override
  State<CreateUser> createState() => _CreateUser();
}

class _CreateUser extends State<CreateUser> {
  final List<String> semester = Semester.values.map((e) => e.name).toList();
  String selectedSmester = Semester.First.name;
  bool isCaptain = false; // Added isCaptain state

  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController dept = TextEditingController();
  final TextEditingController id = TextEditingController();
  final TextEditingController reg = TextEditingController();
  final TextEditingController varsity = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController cpassword = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 229, 189),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.amber,
        title: Text(
          'Create New User',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Image.asset('assets/images/appstore.png'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isNotEmpty) return null;
                        return 'Please enter your first name';
                      },
                      controller: firstName,
                      maxLength: 20,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        label: Text('First Name', style: GoogleFonts.lato()),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isNotEmpty) return null;
                        return 'Please enter your last name';
                      },
                      controller: lastName,
                      maxLength: 20,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        label: Text('Last Name', style: GoogleFonts.lato()),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        Text(
                          'Select Your Semester',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 30),
                        DropdownButton<String>(
                          value: selectedSmester,
                          items: semester.map((String flavor) {
                            return DropdownMenuItem<String>(
                              value: flavor,
                              child: Text(flavor, style: GoogleFonts.lato()),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedSmester = newValue;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  // Added CR checkbox
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        Text(
                          'Are you a CR?',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 30),
                        Checkbox(
                          value: isCaptain,
                          onChanged: (bool? value) {
                            setState(() {
                              isCaptain = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextFormField(
                      controller: id,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        label: Text('Student ID No:', style: GoogleFonts.lato()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextFormField(
                      controller: reg,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        label: Text('Registration ID No:', style: GoogleFonts.lato()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextFormField(
                      controller: dept,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        label: Text('Name of Department', style: GoogleFonts.lato()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextFormField(
                      controller: varsity,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        label: Text('Name of University', style: GoogleFonts.lato()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextFormField(
                      controller: phoneNumber,
                      maxLength: 11,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        label: Text('Phone Number', style: GoogleFonts.lato()),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.contains('@')) return null;
                        return 'Please enter a valid email';
                      },
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        label: Text('Email', style: GoogleFonts.lato()),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextFormField(
                      obscureText: true,
                      controller: password,
                      maxLength: 20,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        label: Text('Password', style: GoogleFonts.lato()),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      '[Password must contain at least one special character and one number]',
                      style: GoogleFonts.lato(fontSize: 12),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextFormField(
                      validator: (value) {
                        if (password.text == value) return null;
                        return 'Confirm Password does not match';
                      },
                      obscureText: true,
                      controller: cpassword,
                      maxLength: 20,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        label: Text('Confirm Password', style: GoogleFonts.lato()),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: Text(
                      'Create Account',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> createAccount() async {
    if (formKey.currentState!.validate()) {
      showLoadingDialoge(context);
      try {
        UserModel userData = UserModel(
          lname: lastName.text.trim(),
          dept: dept.text.trim(),
          varsity: varsity.text.trim(),
          fname: firstName.text.trim(),
          phoneNumber: phoneNumber.text.trim(),
          semister: Semester.values.firstWhere((e) => e.name == selectedSmester),
          email: email.text.trim(),
          id: id.text.trim(),
          reg: reg.text.trim(),
          isCaptain: isCaptain, // Added isCaptain field
        );

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: email.text.trim(), password: password.text);

        final userID = userCredential.user!.uid;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .set(userData.toJson());

        if (mounted) {
          Navigator.of(context).pop();
          showToastMessageNormal('Account creation successful');
        }
      } catch (e) {
        Navigator.of(context).pop();
        showToastMessageNormal('Error: ${e.toString()}');
      }
    }
  }
}
