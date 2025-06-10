import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paper_card/paper_card.dart';
import 'package:schedula/noteScreen/notes_model.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schedula/utils/all_dialouge.dart';
import 'dart:io';
import 'package:schedula/utils/toast_message.dart';

class NotesItem extends StatefulWidget {
  const NotesItem(
    this.notesItem, {
    super.key,
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
      print('Error deleting note: $error');
    }
  }

  @override
  State<NotesItem> createState() => _NotesItemState();
}

class _NotesItemState extends State<NotesItem> {
  bool _isDownloading = false;
  String _progress = "";
  String? _filePath;

  Future<void> downloadFile(String downloadURL) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      setState(() {
        _isDownloading = true;
        _progress = "0%";
      });

      try {
        Directory? downloadsDirectory = await getExternalStorageDirectory();
        if (downloadsDirectory == null) {
          showToastMessageWarning("Could not access storage directory.");
          return;
        }

        String fileName = downloadURL.split('/').last.split('?').first;
        String filePath = '${downloadsDirectory.path}/$fileName';

        Dio dio = Dio();
        await dio.download(
          downloadURL,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() {
                _progress = "${((received / total) * 100).toStringAsFixed(0)}%";
              });
            }
          },
        );

        setState(() {
          _filePath = filePath;
          _isDownloading = false;
        });

        if (mounted) {
          showSuccessDialoge(context);
          showToastMessageNormal('File downloaded successfully');
        }
      } catch (e) {
        if (mounted) {
          showToastMessageWarning('Failed to download file: $e');
        }
        setState(() {
          _isDownloading = false;
        });
      }
    } else {
      showToastMessageWarning('Storage permission denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    void showDeleteDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Delete Note',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to delete this note?',
              style: GoogleFonts.lato(),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Cancel',
                  style: GoogleFonts.lato(
                    color: Colors.grey[700],
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                onPressed: () async {
                  await widget.delete();
                  if (mounted) {
                    Navigator.of(context).pop();
                    showToastMessageNormal('Note deleted successfully');
                  }
                },
                child: Text(
                  'Delete',
                  style: GoogleFonts.lato(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return PaperCard(
      backgroundColor: Colors.green[100],
      borderRadius: 24,
      elevation: 6,
      borderColor: Colors.green[800],
      borderThickness: 12,
      textureOpacity: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      textureFit: BoxFit.cover,
      texture: true,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.notesItem.courseTitle,
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'By ${widget.notesItem.courseTecher}',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () => showDeleteDialog(context),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red[700],
                    size: 28,
                  ),
                ),
                const SizedBox(height: 6),
                _isDownloading
                    ? Column(
                        children: [
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _progress,
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      )
                    : IconButton(
                        onPressed: () => downloadFile(widget.notesItem.downloadURL),
                        icon: Icon(
                          Icons.download_outlined,
                          color: Colors.green[700],
                          size: 28,
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
