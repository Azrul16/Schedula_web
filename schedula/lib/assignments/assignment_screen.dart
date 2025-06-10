import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedula/assignments/assignment_bottom_sheet.dart';
import 'package:schedula/assignments/assignment_card.dart';
import 'package:schedula/utils/auth_gate.dart';
import 'package:intl/intl.dart';

class AssignmentsPage extends StatelessWidget {
  const AssignmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Assignments",
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          FutureBuilder<bool>(
            future: GlobalUtils.isCaptain(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }
              if (snapshot.hasData && snapshot.data == true) {
                return IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => const CreateAssignmentBottomSheet(),
                    );
                  },
                  icon: const Icon(Icons.add),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: FutureBuilder<String?>(
          future: GlobalUtils.getCurrentUserSemester(),
          builder: (context, semesterSnapshot) {
            if (semesterSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!semesterSnapshot.hasData || semesterSnapshot.data == null) {
              return Center(
                child: Text(
                  "Unable to fetch semester information",
                  style: GoogleFonts.lato(),
                ),
              );
            }

            return StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('assignments')
                      .where('semester', isEqualTo: semesterSnapshot.data)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No Assignments Found",
                      style: GoogleFonts.lato(fontSize: 16),
                    ),
                  );
                }

                // Filter assignments where the last date has not passed
                final currentDate = DateTime.now();
                List<QueryDocumentSnapshot> validAssignments =
                    snapshot.data!.docs.where((doc) {
                      final Map<String, dynamic> assignment =
                          doc.data() as Map<String, dynamic>;
                      final lastDate = assignment['lastDate'];
                      try {
                        final parsedLastDate = DateFormat(
                          'dd/MM/yyyy',
                        ).parse(lastDate);
                        return parsedLastDate.isAfter(currentDate) ||
                            parsedLastDate.isAtSameMomentAs(currentDate);
                      } catch (e) {
                        return false;
                      }
                    }).toList();

                if (validAssignments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_turned_in,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Upcoming Assignments",
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: validAssignments.length,
                  itemBuilder: (context, index) {
                    final doc = validAssignments[index];
                    final Map<String, dynamic> assignment =
                        doc.data() as Map<String, dynamic>;

                    return AssignmentCard(
                      id: doc.id,
                      assignmentName: assignment['assignmentName'] ?? '',
                      courseTitle: assignment['courseTitle'] ?? '',
                      teacherName: assignment['teacherName'] ?? '',
                      lastDate: assignment['lastDate'] ?? '',
                      completedBy: List<String>.from(
                        assignment['completedBy'] ?? [],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: null,
    );
  }
}
