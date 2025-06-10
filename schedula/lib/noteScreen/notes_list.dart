import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedula/noteScreen/note_item.dart';
import 'package:schedula/noteScreen/notes_model.dart';
import 'package:schedula/utils/auth_gate.dart';

class NotesList extends StatelessWidget {
  const NotesList({
    super.key,
    required this.selectedNote,
  });

  final List<ClassNotes> selectedNote;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: GlobalUtils.getCurrentUserSemester(),
      builder: (context, semesterSnapshot) {
        if (semesterSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!semesterSnapshot.hasData || semesterSnapshot.data == null) {
          return Center(
            child: Text(
              'Unable to fetch semester information',
              style: GoogleFonts.lato(fontSize: 16),
            ),
          );
        }

        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('notes')
              .where('semester', isEqualTo: semesterSnapshot.data)
              .orderBy('created_at', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Notes Available',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'for ${semesterSnapshot.data} Semester',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            final allNotes = snapshot.data?.docs;
            List<ClassNotes> semesterNotes = [];

            for (var doc in allNotes!) {
              semesterNotes.add(ClassNotes.fromJSON(doc.data(), doc.id));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${semesterSnapshot.data} Semester Notes',
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                ListView.builder(
                  itemCount: semesterNotes.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (ctx, index) {
                    return NotesItem(
                      semesterNotes[index],
                      isStart: index == 0,
                      isEnd: index == semesterNotes.length - 1,
                      task: semesterNotes.length,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
