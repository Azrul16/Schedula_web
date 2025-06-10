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

  @override
  Widget build(context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (int index) {
              onTappedBar(index);
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.today_outlined),
                selectedIcon: Icon(Icons.today),
                label: Text('Classes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: Text('Notes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.campaign_outlined),
                selectedIcon: Icon(Icons.campaign),
                label: Text('Assignments'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.chat_outlined),
                selectedIcon: Icon(Icons.chat),
                label: Text('Chat'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
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
        ],
      ),
    );
  }
}
