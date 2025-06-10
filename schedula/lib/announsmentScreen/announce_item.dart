import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paper_card/paper_card.dart';
import 'package:schedula/announsmentScreen/announce_model.dart';

class AnnounceItem extends StatelessWidget {
  const AnnounceItem(this.announceItem,
      {super.key,
      required this.isStart,
      required this.isEnd,
      required this.task});
  final bool isStart;
  final bool isEnd;
  final int task;
  final Announcements announceItem;

  Future<void> delete() async {
    try {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(announceItem.docID)
          .delete();
    } catch (error) {
      print('Error deleting class: $error');
    }
    print(announceItem.docID);
  }

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      backgroundColor: Colors.purple[300],
      borderRadius: 24,
      elevation: 6,
      borderColor: Colors.blue[600],
      borderThickness: 12,
      textureOpacity: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      textureFit: BoxFit.cover,
      texture: true,
      child: Column(
        children: [
          Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      announceItem.title,
                      style: GoogleFonts.getFont(
                        'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.delete),
                    color: Colors.redAccent,
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  announceItem.description,
                  style: GoogleFonts.getFont(
                    'Montserrat',
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          (announceItem.downloadURL.isEmpty)
              ? const Text("No download File")
              : Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.download,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
