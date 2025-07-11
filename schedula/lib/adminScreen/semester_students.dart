import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedula/userAccounts/user_model.dart';
import 'package:schedula/utils/toast_message.dart';

class SemesterStudents extends StatelessWidget {
  final Semester semester;

  const SemesterStudents({
    super.key,
    required this.semester,
  });

  Future<void> _toggleCaptain(
      BuildContext context, String studentId, bool currentStatus) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // First, remove captain status from all students in this semester
      if (!currentStatus) {
        final currentCaptainQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('semister', isEqualTo: semester.name)
            .where('isCaptain', isEqualTo: true)
            .get();

        for (var doc in currentCaptainQuery.docs) {
          batch.update(doc.reference, {'isCaptain': false});
        }
      }

      // Update the selected student's captain status
      final studentRef =
          FirebaseFirestore.instance.collection('users').doc(studentId);
      batch.update(studentRef, {'isCaptain': !currentStatus});

      await batch.commit();
      showToastMessageNormal(currentStatus
          ? 'Captain status removed'
          : 'Successfully assigned as captain');
    } catch (e) {
      showToastMessageWarning('Failed to update captain status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${semester.name} Semester Students',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange[900],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('semister', isEqualTo: semester.name)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No students found in this semester',
                style: GoogleFonts.lato(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final user = UserModel.fromJson(data);
              final isCaptain = data['isCaptain'] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                color: isCaptain ? Colors.red[100] : Colors.green[100],
                child: ListTile(
                  title: Text(
                    '${user.fname} ${user.lname}',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Reg: ${user.reg}\nDept: ${user.dept}',
                    style: GoogleFonts.lato(),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCaptain ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _toggleCaptain(context, doc.id, isCaptain),
                    child: Text(
                      isCaptain ? 'Remove Captain' : 'Make Captain',
                      style: GoogleFonts.lato(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
