import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedula/assignments/assignment_bottom_sheet.dart';
import 'package:schedula/assignments/assignment_card.dart';
import 'package:schedula/utils/auth_gate.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schedula/services/subscription_service.dart';
import 'package:schedula/userAccounts/subscription_screen.dart';

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = true;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isSubscribed = await _subscriptionService.checkSubscription(userId);
    setState(() {
      _isSubscribed = isSubscribed;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isSubscribed) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Assignments",
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue.shade700,
          elevation: 4,
        ),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF74ebd5), Color(0xFFACB6E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 90,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Subscribe to Access Assignments',
                      style: GoogleFonts.lato(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Unlock course assignments and deadlines with a subscription.',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubscriptionScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.star),
                      label: const Text(
                        'Subscribe Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

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
      floatingActionButton: FutureBuilder<bool>(
        future: GlobalUtils.isCaptain(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }
          if (snapshot.hasData && snapshot.data == true) {
            return FloatingActionButton(
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
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
