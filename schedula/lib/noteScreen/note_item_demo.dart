import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paper_card/paper_card.dart';
import 'package:schedula/noteScreen/notes_model.dart';
import 'package:schedula/utils/download_file.dart';

class NoteItemsDeo extends StatelessWidget {
  const NoteItemsDeo({
    super.key,
    required this.notesItem,
    required this.isStart,
    required this.isEnd,
    required this.task,
  });

  final ClassNotes notesItem;
  final bool isStart;
  final bool isEnd;
  final int task;

  Future<void> delete() async {
    try {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(notesItem.docID)
          .delete();
    } catch (error) {
      print('Error deleting class: $error');
    }
    print(notesItem.docID);
  }

  @override
  Widget build(BuildContext context) {
    void showDeleteDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete'),
            content: const Text('Are you sure you want to delete this class?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                onPressed: () async {
                  // await delete();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    }

    return PaperCard(
      backgroundColor: Colors.green[100],
      borderRadius: 20,
      elevation: 3,
      borderColor: Colors.green[700],
      borderThickness: 10,
      textureOpacity: 2,
      margin: const EdgeInsets.all(5),
      textureFit: BoxFit.cover,
      texture: true,
      child: Row(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  notesItem.courseTitle,
                  style: GoogleFonts.getFont(
                    'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  notesItem.courseTitle,
                  style: GoogleFonts.getFont(
                    'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
              onPressed: () {
                String downloadURL = notesItem.downloadURL;
                DownloadFile(
                  downloadURL: downloadURL,
                );
              },
              icon: const Icon(Icons.download)),
        ],
      ),
    );
  }
}
