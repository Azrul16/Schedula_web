import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedula/noteScreen/new_note.dart';
import 'package:schedula/noteScreen/notes_list.dart';
import 'package:schedula/noteScreen/notes_model.dart';
import 'package:schedula/utils/auth_gate.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({
    super.key,
    required String currentUserId,
    required semester,
    required isCaptain,
  });

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final List<ClassNotes> selectedNote = [];

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        actions: [
          FutureBuilder<bool>(
            future: GlobalUtils.isCaptain(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }
              if (snapshot.hasData && snapshot.data == true) {
                return TextButton(
                  onPressed: _onAddNotesOverlay,
                  child: const Text(
                    'Add Note',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [NotesList(selectedNote: selectedNote)]),
      ),
      floatingActionButton: null,
      floatingActionButtonLocation: null,
    );
  }
}
