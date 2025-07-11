import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedula/noteScreen/new_note.dart';
import 'package:schedula/noteScreen/notes_list.dart';
import 'package:schedula/noteScreen/notes_model.dart';
import 'package:schedula/utils/auth_gate.dart';
import 'package:schedula/services/subscription_service.dart';
import 'package:schedula/userAccounts/subscription_screen.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({
    super.key,
    required this.currentUserId,
    required this.semester,
    required this.isCaptain,
  });

  final String currentUserId;
  final String semester;
  final bool isCaptain;

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final List<ClassNotes> selectedNote = [];
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = true;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    final isSubscribed = await _subscriptionService.checkSubscription(
      widget.currentUserId,
    );
    setState(() {
      _isSubscribed = isSubscribed;
      _isLoading = false;
    });
  }

  void _onAddNotesOverlay() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        if (!mounted) return;

        showModalBottomSheet(
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          builder:
              (ctx) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: NewNote(
                  currentUserId: currentUser.uid,
                  semester: userData['semister'] ?? '',
                  isCaptain: userData['isCaptain'] ?? false,
                ),
              ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isSubscribed) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Notes',
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.green.shade700,
          elevation: 4,
        ),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 100,
                      color: Colors.white.withOpacity(0.85),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Subscribe to Unlock Notes',
                      style: GoogleFonts.lato(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Premium class notes are just one step away.',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green.shade800,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubscriptionScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.star),
                      label: const Text(
                        'Subscribe Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: Text(
            'Notes',
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green,
          elevation: 4,
          centerTitle: false,
          actions: [
            FutureBuilder<bool>(
              future: GlobalUtils.isCaptain(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                if (snapshot.hasData && snapshot.data == true) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: TextButton.icon(
                      onPressed: _onAddNotesOverlay,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Add Note',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: SingleChildScrollView(
          child: Column(children: [NotesList(selectedNote: selectedNote)]),
        ),
      ),
    );
  }
}
