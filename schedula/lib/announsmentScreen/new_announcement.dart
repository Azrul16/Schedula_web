import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:schedula/announsmentScreen/announce_model.dart';
import 'package:schedula/announsmentScreen/announcement_service.dart';
import 'package:schedula/classScreen/new_class.dart';
import 'package:schedula/utils/all_dialouge.dart';
import 'package:schedula/utils/toast_message.dart';

class NewAnnouncement extends StatefulWidget {
  final String semester;
  
  const NewAnnouncement({
    super.key,
    required this.semester,
  });

  @override
  State<NewAnnouncement> createState() => _NewAnnouncementState();
}

class _NewAnnouncementState extends State<NewAnnouncement> {
  String? _fileName;
  File? file;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        file = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
      print('File is successfully picked: $_fileName');
    }
  }

  Future<String?> uploadFileToFirebase() async {
    try {
      if (file == null) {
        print('No file selected');

        return null;
      }

      String fileName = file!.path.split('/').last;
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref('uploads/$fileName')
          .putFile(file!);

      String? downloadUrl = await snapshot.ref.getDownloadURL();
      print('File upload successful');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Error occurred: $e');
    }
    return null;
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _publishAnnouncement(String? downloadUrl) async {
    if (_titleController.text.trim().isEmpty) {
      showToastMessageWarning('Please enter a title');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      showToastMessageWarning('Please enter description');
      return;
    }

    showLoadingDialoge(context);

    try {
      final docId = await AnnouncementService.createAnnouncement(
        title: _titleController.text,
        description: _descriptionController.text,
        downloadURL: downloadUrl ?? '',
        semester: widget.semester,
      );

      if (!mounted) return;
      Navigator.pop(context); // Remove loading dialog
      Navigator.pop(context); // Close the bottom sheet

      if (docId != null) {
        showToastMessageNormal('Announcement Published');
        sendTopicNotification(
          _titleController.text,
          _descriptionController.text,
        );
      } else {
        showToastMessageWarning('Failed to publish announcement');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Remove loading dialog
      showToastMessageWarning('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            height: 60,
          ),
          TextField(
            maxLength: 25,
            controller: _titleController,
            decoration: const InputDecoration(
              label: Text('Announcement Title'),
            ),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              label: Text('Details'),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  pickFile();
                },
                child: const Text('Upload resource'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _fileName ?? 'No file selected',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final downloadUrl = await uploadFileToFirebase();
                  await _publishAnnouncement(downloadUrl);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Publish',
                  style: TextStyle(
                    color: Colors.black,
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
