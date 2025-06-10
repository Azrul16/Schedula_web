import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedula/noteScreen/notes_model.dart';
import 'package:schedula/utils/all_dialouge.dart';
import 'package:schedula/utils/course_data.dart';
import 'package:schedula/utils/toast_message.dart';

class NewNote extends StatefulWidget {
  const NewNote({
    super.key,
    required this.currentUserId,
    required this.semester,
    required this.isCaptain,
  });

  final String currentUserId;
  final String semester;
  final bool isCaptain;

  @override
  State<NewNote> createState() => _NewNoteState();
}

class _NewNoteState extends State<NewNote> {
  String? _fileName;
  File? file;
  bool _isLoading = false;
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _courseTitleController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();

  @override
  void dispose() {
    _teacherController.dispose();
    _courseTitleController.dispose();
    _courseCodeController.dispose();
    super.dispose();
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'pptx', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        file = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<String?> uploadFileToFirebase() async {
    try {
      if (file == null) return null;

      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file!.path.split('/').last}';
      TaskSnapshot snapshot =
          await FirebaseStorage.instance.ref('notes/$fileName').putFile(file!);

      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<void> sendClassNotesToFirestore(ClassNotes notes) async {
    try {
      await FirebaseFirestore.instance.collection('notes').add(notes.toJson());
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Note uploaded successfully!',
            style: GoogleFonts.lato(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error uploading note: $e',
            style: GoogleFonts.lato(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Upload New Note',
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _courseTitleController,
            decoration: InputDecoration(
              labelText: 'Course Title',
              border: const OutlineInputBorder(),
              labelStyle: GoogleFonts.lato(),
            ),
            style: GoogleFonts.lato(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter course title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _courseCodeController,
            decoration: InputDecoration(
              labelText: 'Course Code',
              border: const OutlineInputBorder(),
              labelStyle: GoogleFonts.lato(),
            ),
            style: GoogleFonts.lato(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter course code';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _teacherController,
            decoration: InputDecoration(
              labelText: 'Teacher Name',
              border: const OutlineInputBorder(),
              labelStyle: GoogleFonts.lato(),
            ),
            style: GoogleFonts.lato(),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: pickFile,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.upload_file,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _fileName ?? 'Select a file to upload',
                      style: GoogleFonts.lato(
                        color:
                            _fileName != null ? Colors.black : Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.lato(color: Colors.grey[700]),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_courseTitleController.text.isEmpty ||
                            _courseCodeController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please enter course details',
                                style: GoogleFonts.lato(),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (file == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please select a file',
                                style: GoogleFonts.lato(),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          String? downloadUrl = await uploadFileToFirebase();
                          if (downloadUrl != null) {
                            ClassNotes notes = ClassNotes(
                              courseTitle: _courseTitleController.text.trim(),
                              downloadURL: downloadUrl,
                              creatorId: widget.currentUserId,
                              creatorIsCaptain: widget.isCaptain,
                              semester: widget.semester,
                              createdAt: DateTime.now(),
                              courseTecher: _teacherController.text.trim(),
                              docID: '',
                            );
                            await sendClassNotesToFirestore(notes);
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Upload Note',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
