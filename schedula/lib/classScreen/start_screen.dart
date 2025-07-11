import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedula/announsmentScreen/announcement_screen.dart';
import 'package:schedula/assignments/assignment_screen.dart';
import 'package:schedula/chatAI/chat_screen.dart';
import 'package:schedula/noteScreen/note_screen.dart';
import 'package:schedula/profile/profile_screen.dart';
import 'package:schedula/classScreen/class_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  late List<Widget> _pages;
  Map<String, dynamic>? _userData;

  Future<void> _initializeUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String currentEmail = currentUser.email!;
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      for (var doc in querySnapshot.docs) {
        if (doc['email'] == currentEmail) {
          setState(() {
            _userData = doc.data() as Map<String, dynamic>;
            _pages = [
              const ClassScren(),
              NoteScreen(
                currentUserId: currentUser.uid,
                semester: _userData?['semister'] ?? '',
                isCaptain: _userData?['isCaptain'] ?? false,
              ),
              const AssignmentsPage(),
              ChatScreen(),
              const ProfileScreen(),
            ];
          });
          break;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    requesPermission();
    _pages = [
      const ClassScren(),
      const Center(
        child: CircularProgressIndicator(),
      ), // Placeholder while loading
      const AssignmentsPage(),
      ChatScreen(),
      const ProfileScreen(),
    ];
    _initializeUserData();
  }

  void onTappedBar(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Future<void> requesPermission() async {
    // ignore: unused_local_variable
    final notificationSettings = await FirebaseMessaging.instance
        .requestPermission(provisional: true);

    // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
    final apnsToken = await FirebaseMessaging.instance.getToken();
    if (apnsToken != null) {
      print(apnsToken);
      print('-----------------');
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => onTappedBar(0),
                    child: Text(
                      'Classes',
                      style: TextStyle(
                        color: _currentIndex == 0 ? Colors.black : Colors.grey,
                        fontWeight:
                            _currentIndex == 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () => onTappedBar(1),
                    child: Text(
                      'Notes',
                      style: TextStyle(
                        color: _currentIndex == 1 ? Colors.black : Colors.grey,
                        fontWeight:
                            _currentIndex == 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () => onTappedBar(2),
                    child: Text(
                      'Assignments',
                      style: TextStyle(
                        color: _currentIndex == 2 ? Colors.black : Colors.grey,
                        fontWeight:
                            _currentIndex == 2
                                ? FontWeight.bold
                                : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () => onTappedBar(3),
                    child: Text(
                      'Chat',
                      style: TextStyle(
                        color: _currentIndex == 3 ? Colors.black : Colors.grey,
                        fontWeight:
                            _currentIndex == 3
                                ? FontWeight.bold
                                : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () => onTappedBar(4),
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        color: _currentIndex == 4 ? Colors.black : Colors.grey,
                        fontWeight:
                            _currentIndex == 4
                                ? FontWeight.bold
                                : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: PageView(
            controller: _pageController,
            children: _pages,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}


// _pageController.animateToPage(_currentIndex,
//               duration: const Duration(milliseconds: 400),
//               curve: Curves.easeOutQuad);