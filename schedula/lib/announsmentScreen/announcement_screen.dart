import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedula/announsmentScreen/announce_list.dart';
import 'package:schedula/announsmentScreen/announce_model.dart';
import 'package:schedula/announsmentScreen/new_announcement.dart';
import 'package:schedula/utils/auth_gate.dart';

class Announcementscreen extends StatefulWidget {
  const Announcementscreen({super.key});

  @override
  State<Announcementscreen> createState() => _AnnouncementscreenState();
}

class _AnnouncementscreenState extends State<Announcementscreen> {
  @override
  Widget build(BuildContext context) {
    void onAddAnnounceOverlay() async {
      final semester = await GlobalUtils.getCurrentUserSemester();
      if (semester == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to create announcement. Semester not found.')),
        );
        return;
      }

      if (!mounted) return;

      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (ctx) {
          return NewAnnouncement(semester: semester);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Announcements',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple,
        actions: [
          FutureBuilder<bool>(
            future: GlobalUtils.isCaptain(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }
              if (snapshot.hasData && snapshot.data == true) {
                return TextButton(
                  onPressed: onAddAnnounceOverlay,
                  child: const Text(
                    'Add Announcement',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: const [
              AnnounceList()
            ],
          ),
        ),
      ),
    );
  }
}
