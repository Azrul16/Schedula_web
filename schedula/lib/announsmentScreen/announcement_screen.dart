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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: Text(
            'Announcements',
            style: GoogleFonts.getFont(
              'Lumanosimo',
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: Colors.purple,
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
                      onPressed: onAddAnnounceOverlay,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Add Announcement',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
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
        decoration: const BoxDecoration(),
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
