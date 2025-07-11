import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedula/userAccounts/user_model.dart';
import 'package:intl/intl.dart';

class SemesterAssignments extends StatelessWidget {
  final Semester semester;

  const SemesterAssignments({super.key, required this.semester});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: Text(
            '${semester.name} Assignments',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.orange,
          elevation: 4,
          centerTitle: false,
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('assignments')
              .where('semester', isEqualTo: semester.name)
              .orderBy('createdAt', descending: true)
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
                      Icons.assignment_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Assignments Found',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Filter assignments
            final currentDate = DateTime.now();
            final allAssignments = snapshot.data!.docs;
            final activeAssignments = allAssignments.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final lastDate = data['lastDate'];
              try {
                final parsedLastDate = DateFormat('dd/MM/yyyy').parse(lastDate);
                return parsedLastDate.isAfter(currentDate) ||
                    parsedLastDate.isAtSameMomentAs(currentDate);
              } catch (e) {
                return false;
              }
            }).toList();

            final expiredAssignments = allAssignments.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final lastDate = data['lastDate'];
              try {
                final parsedLastDate = DateFormat('dd/MM/yyyy').parse(lastDate);
                return parsedLastDate.isBefore(currentDate);
              } catch (e) {
                return false;
              }
            }).toList();

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
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
                        'Total Assignments: ${snapshot.data!.docs.length}',
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Active: ${activeAssignments.length} | Expired: ${expiredAssignments.length}',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.orange[900],
                        ),
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
                          color: Colors.orange.shade50,
                          child: TabBar(
                            tabs: [
                              Tab(
                                child: Text(
                                  'Active (${activeAssignments.length})',
                                  style: GoogleFonts.lato(
                                    color: Colors.orange[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Expired (${expiredAssignments.length})',
                                  style: GoogleFonts.lato(
                                    color: Colors.orange[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            indicatorColor: Colors.orange[900],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildAssignmentList(activeAssignments),
                              _buildAssignmentList(expiredAssignments),
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

  Widget _buildAssignmentList(List<QueryDocumentSnapshot> assignments) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final data = assignments[index].data() as Map<String, dynamic>;
        final completedBy = List<String>.from(data['completedBy'] ?? []);
        final isExpired = _isExpired(data['lastDate']);
        
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              data['assignmentName'] ?? 'No Title',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Course: ${data['courseTitle'] ?? 'Not specified'}',
                  style: GoogleFonts.lato(),
                ),
                Text(
                  'Due: ${data['lastDate'] ?? 'Not specified'}',
                  style: GoogleFonts.lato(
                    color: isExpired ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${completedBy.length}',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: completedBy.isEmpty ? Colors.red : Colors.green,
                  ),
                ),
                Text(
                  'Completed',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Teacher: ${data['teacherName'] ?? 'Not specified'}',
                      style: GoogleFonts.lato(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completion Status',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      completedBy.isEmpty
                          ? 'No students have completed this assignment yet'
                          : '${completedBy.length} students have completed this assignment',
                      style: GoogleFonts.lato(
                        color: completedBy.isEmpty ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isExpired(String? dateStr) {
    if (dateStr == null) return true;
    try {
      final date = DateFormat('dd/MM/yyyy').parse(dateStr);
      return date.isBefore(DateTime.now());
    } catch (e) {
      return true;
    }
  }
}
