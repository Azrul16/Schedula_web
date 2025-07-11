import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedula/userAccounts/user_model.dart';
import 'package:schedula/classScreen/class_models.dart';
import 'package:intl/intl.dart';

class SemesterClasses extends StatelessWidget {
  final Semester semester;

  const SemesterClasses({super.key, required this.semester});

  String _mapSemesterNameToFirestoreValue(String semesterName) {
    // Map the semester.name to the string used in Firestore documents
    // Adjust this mapping based on your actual semester names and Firestore values
    switch (semesterName.toLowerCase()) {
      case 'first':
        return '1';
      case 'second':
        return '2';
      case 'third':
        return '3';
      case 'fourth':
        return '4';
      case 'fifth':
        return '5';
      case 'sixth':
        return '6';
      case 'seventh':
        return '7';
      case 'eighth':
        return '8';
      default:
        return semesterName; // fallback to original
    }
  }

  bool isWithinNext24Hours(DateTime classTime) {
    final now = DateTime.now();
    final next24Hours = now.add(const Duration(hours: 24));
    return classTime.isAfter(now) && classTime.isBefore(next24Hours);
  }

  @override
  Widget build(BuildContext context) {
    final firestoreSemesterValue =
        _mapSemesterNameToFirestoreValue(semester.name);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: Text(
            '${semester.name} Classes',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.green,
          elevation: 4,
          centerTitle: false,
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('classes')
              .where('semester', isEqualTo: firestoreSemesterValue)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.class_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Classes Found',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            final allClasses = snapshot.data!.docs;
            final upcomingClasses = allClasses.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final classTime = (data['time'] as Timestamp).toDate();
              return classTime.isAfter(DateTime.now());
            }).toList();

            final pastClasses = allClasses.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final classTime = (data['time'] as Timestamp).toDate();
              return classTime.isBefore(DateTime.now());
            }).toList();

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Classes: ${allClasses.length}',
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Upcoming: ${upcomingClasses.length} | Past: ${pastClasses.length}',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.green[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        Container(
                          color: Colors.green.shade50,
                          child: TabBar(
                            tabs: [
                              Tab(
                                child: Text(
                                  'Upcoming (${upcomingClasses.length})',
                                  style: GoogleFonts.lato(
                                    color: Colors.green[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Past (${pastClasses.length})',
                                  style: GoogleFonts.lato(
                                    color: Colors.green[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            indicatorColor: Colors.green[900],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildClassList(upcomingClasses, true),
                              _buildClassList(pastClasses, false),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildClassList(List<QueryDocumentSnapshot> classes, bool isUpcoming) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final data = classes[index].data() as Map<String, dynamic>;
        final DateTime classTime = (data['time'] as Timestamp).toDate();
        final bool isWithin24h = isWithinNext24Hours(classTime);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: isWithin24h ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isWithin24h
                ? BorderSide(color: Colors.green.shade700, width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data['course_title'] ?? 'No Course Title',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color:
                              isUpcoming ? Colors.green[900] : Colors.grey[700],
                        ),
                      ),
                    ),
                    if (isWithin24h)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade700),
                        ),
                        child: Text(
                          'Next 24h',
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data['course_code'] ?? 'No Course Code',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data['course_teacher'] ?? 'Not specified',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('EEEE, MMM d, y • hh:mm a').format(classTime),
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
