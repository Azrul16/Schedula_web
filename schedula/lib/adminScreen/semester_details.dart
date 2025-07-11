import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedula/adminScreen/semester_students.dart';
import 'package:schedula/adminScreen/semester_classes.dart';
import 'package:schedula/adminScreen/semester_notes.dart';
import 'package:schedula/adminScreen/semester_assignments.dart';
import 'package:schedula/userAccounts/user_model.dart';

class SemesterDetails extends StatelessWidget {
  final Semester semester;

  const SemesterDetails({super.key, required this.semester});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: Text(
            '${semester.name} Semester Details',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.orange[900],
          elevation: 4,
          centerTitle: false,
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber.shade200, Colors.white],
          ),
        ),
        child: GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildSection(
              context,
              'Students',
              Icons.people,
              Colors.blue,
              () => _navigateToStudents(context),
              _getStudentCount(),
            ),
            _buildSection(
              context,
              'Classes',
              Icons.class_,
              Colors.green,
              () => _navigateToClasses(context),
              _getClassCount(),
            ),
            _buildSection(
              context,
              'Notes',
              Icons.note,
              Colors.purple,
              () => _navigateToNotes(context),
              _getNoteCount(),
            ),
            _buildSection(
              context,
              'Assignments',
              Icons.assignment,
              Colors.orange,
              () => _navigateToAssignments(context),
              _getAssignmentCount(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, 
      Color color, VoidCallback onTap, Stream<int> countStream) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              StreamBuilder<int>(
                stream: countStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  return Text(
                    '${snapshot.data ?? 0}',
                    style: GoogleFonts.lato(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToStudents(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SemesterStudents(semester: semester),
      ),
    );
  }

  void _navigateToClasses(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SemesterClasses(semester: semester),
      ),
    );
  }

  void _navigateToNotes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SemesterNotes(semester: semester),
      ),
    );
  }

  void _navigateToAssignments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SemesterAssignments(semester: semester),
      ),
    );
  }

  Stream<int> _getStudentCount() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('semister', isEqualTo: semester.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _getClassCount() {
    return FirebaseFirestore.instance
        .collection('classes')
        .where('semester', isEqualTo: semester.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _getNoteCount() {
    return FirebaseFirestore.instance
        .collection('notes')
        .where('semester', isEqualTo: semester.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _getAssignmentCount() {
    return FirebaseFirestore.instance
        .collection('assignments')
        .where('semester', isEqualTo: semester.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
