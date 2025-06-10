import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schedula/userAccounts/user_model.dart';

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({super.key});

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
  final List<String> semester = Semester.values.map((e) => e.name).toList();
  String selectedSemester = Semester.First.name;
  bool isCaptain = false;

  final Map<String, TextEditingController> _controllers = {
    'firstName': TextEditingController(),
    'lastName': TextEditingController(),
    'id': TextEditingController(),
    'reg': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'dept': TextEditingController(),
    'varsity': TextEditingController(),
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
        _controllers['firstName']!.text = user.fname;
        _controllers['lastName']!.text = user.lname;
        _controllers['id']!.text = user.id;
        _controllers['reg']!.text = user.reg;
        _controllers['email']!.text = user.email;
        _controllers['phone']!.text = user.phoneNumber;
        _controllers['dept']!.text = user.dept;
        _controllers['varsity']!.text = user.varsity ?? '';
        selectedSemester = user.semister.name;
        isCaptain = user.isCaptain;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: user.email)
                .get();

        if (userDoc.docs.isNotEmpty) {
          await userDoc.docs.first.reference.update({
            'fname': _controllers['firstName']!.text,
            'lname': _controllers['lastName']!.text,
            'id': _controllers['id']!.text,
            'reg': _controllers['reg']!.text,
            'phoneNumber': _controllers['phone']!.text,
            'dept': _controllers['dept']!.text,
            'varsity': _controllers['varsity']!.text,
            'semister': selectedSemester,
            'isCaptain': isCaptain,
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
      validator:
          validator ??
          (value) =>
              (value == null || value.isEmpty)
                  ? 'This field is required'
                  : null,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 24,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            const ProfilePic(
              image:
                  'https://st3.depositphotos.com/32927174/36182/v/450/depositphotos_361823194-stock-illustration-glowing-neon-line-create-account.jpg',
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name Fields
                    Row(
                      children: [
                        Expanded(
                          child: UserInfoEditField(
                            text: "First Name",
                            child: _buildTextFormField(
                              controller: _controllers['firstName']!,
                              hintText: "Enter first name",
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: UserInfoEditField(
                            text: "Last Name",
                            child: _buildTextFormField(
                              controller: _controllers['lastName']!,
                              hintText: "Enter last name",
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    UserInfoEditField(
                      text: "ID",
                      child: _buildTextFormField(
                        controller: _controllers['id']!,
                        hintText: "Student ID",
                      ),
                    ),
                    const SizedBox(height: 15),
                    UserInfoEditField(
                      text: "Registration",
                      child: _buildTextFormField(
                        controller: _controllers['reg']!,
                        hintText: "Registration number",
                      ),
                    ),
                    const SizedBox(height: 15),
                    UserInfoEditField(
                      text: "Email",
                      child: _buildTextFormField(
                        controller: _controllers['email']!,
                        hintText: "Email",
                        enabled: false,
                      ),
                    ),
                    const SizedBox(height: 15),
                    UserInfoEditField(
                      text: "Phone",
                      child: _buildTextFormField(
                        controller: _controllers['phone']!,
                        hintText: "Phone number",
                      ),
                    ),
                    const SizedBox(height: 15),
                    UserInfoEditField(
                      text: "Department",
                      child: _buildTextFormField(
                        controller: _controllers['dept']!,
                        hintText: "Department",
                      ),
                    ),
                    const SizedBox(height: 15),
                    UserInfoEditField(
                      text: "University",
                      child: _buildTextFormField(
                        controller: _controllers['varsity']!,
                        hintText: "University",
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Semester:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 20),
                        DropdownButton<String>(
                          value: selectedSemester,
                          borderRadius: BorderRadius.circular(10),
                          items:
                              semester.map((String s) {
                                return DropdownMenuItem<String>(
                                  value: s,
                                  child: Text(s),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedSemester = newValue;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'Are you a CR?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Checkbox(
                          value: isCaptain,
                          onChanged: (val) {
                            setState(() => isCaptain = val ?? false);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.cancel),
                          label: const Text("Cancel"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 30,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveProfile,
                          icon: const Icon(Icons.save),
                          label:
                              _isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text("Save"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 30,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
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
    );
  }
}

class ProfilePic extends StatelessWidget {
  final String image;
  final VoidCallback? imageUploadBtnPress;
  const ProfilePic({super.key, required this.image, this.imageUploadBtnPress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(radius: 60, backgroundImage: NetworkImage(image)),
        InkWell(
          onTap: imageUploadBtnPress,
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue,
            child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}

class UserInfoEditField extends StatelessWidget {
  final String text;
  final Widget child;
  const UserInfoEditField({super.key, required this.text, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}
