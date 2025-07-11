import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schedula/userAccounts/user_model.dart';

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({super.key});

  Future<Map<String, dynamic>?> getUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return null;
    }
    String currentEmail = currentUser.email!;
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    for (var doc in querySnapshot.docs) {
      if (doc['email'] == currentEmail) {
        return doc.data() as Map<String, dynamic>;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return const EditProfileScreen();
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(),
    'id': TextEditingController(),
    'reg': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'dept': TextEditingController(),
  };
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    String currentEmail = currentUser.email!;
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    for (var doc in querySnapshot.docs) {
      if (doc['email'] == currentEmail) {
        return doc.data() as Map<String, dynamic>;
      }
    }
    return null;
  }

  Future<void> _loadUserData() async {
    final userData = await getUserData();
    if (userData != null && mounted) {
      final user = UserModel.fromJson(userData);
      setState(() {
        _controllers['name']!.text = '${user.fname} ${user.lname}';
        _controllers['id']!.text = user.id;
        _controllers['reg']!.text = user.reg;
        _controllers['email']!.text = user.email;
        _controllers['phone']!.text = user.phoneNumber;
        _controllers['dept']!.text = user.dept;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (userDoc.docs.isNotEmpty) {
          final nameParts = _controllers['name']!.text.split(' ');
          final firstName = nameParts[0];
          final lastName =
              nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

          await userDoc.docs.first.reference.update({
            'fname': firstName,
            'lname': lastName,
            'id': _controllers['id']!.text,
            'reg': _controllers['reg']!.text,
            'phoneNumber': _controllers['phone']!.text,
            'dept': _controllers['dept']!.text,
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF2196F3),
        title: const Text("Edit Profile"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2196F3), // Light blue (AppBar color)
              Color(0xFF1976D2), // Darker blue
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              ProfilePic(
                image:
                    'https://st3.depositphotos.com/32927174/36182/v/450/depositphotos_361823194-stock-illustration-glowing-neon-line-create-account.jpg',
                imageUploadBtnPress: () {
                  // Logic for uploading image
                },
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      UserInfoEditField(
                        text: "Name",
                        child: _buildTextFormField(
                          controller: _controllers['name']!,
                          hintText: "Enter your full name",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            if (!value.contains(' ')) {
                              return 'Please enter both first and last name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      UserInfoEditField(
                        text: "ID",
                        child: _buildTextFormField(
                          controller: _controllers['id']!,
                          hintText: "Enter your ID",
                        ),
                      ),
                      const SizedBox(height: 10),
                      UserInfoEditField(
                        text: "Registration",
                        child: _buildTextFormField(
                          controller: _controllers['reg']!,
                          hintText: "Enter your registration number",
                        ),
                      ),
                      const SizedBox(height: 10),
                      UserInfoEditField(
                        text: "Email",
                        child: _buildTextFormField(
                          controller: _controllers['email']!,
                          hintText: "Enter your email",
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 10),
                      UserInfoEditField(
                        text: "Phone",
                        child: _buildTextFormField(
                          controller: _controllers['phone']!,
                          hintText: "Enter your phone number",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number is required';
                            }
                            if (value.length < 10) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      UserInfoEditField(
                        text: "Department",
                        child: _buildTextFormField(
                          controller: _controllers['dept']!,
                          hintText: "Enter your department",
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 30),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 30),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Save",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ],
                      ),
                    ],
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

class ProfilePic extends StatelessWidget {
  const ProfilePic({
    super.key,
    required this.image,
    this.imageUploadBtnPress,
  });

  final String image;
  final VoidCallback? imageUploadBtnPress;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(image),
        ),
        InkWell(
          onTap: imageUploadBtnPress,
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class UserInfoEditField extends StatelessWidget {
  const UserInfoEditField({
    super.key,
    required this.text,
    required this.child,
  });

  final String text;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}
