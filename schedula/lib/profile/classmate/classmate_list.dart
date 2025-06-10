import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedula/utils/auth_gate.dart';

class ClassmateList extends StatelessWidget {
  const ClassmateList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: GlobalUtils.getCurrentUserSemester(),
      builder: (context, semesterSnapshot) {
        if (semesterSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }

        if (!semesterSnapshot.hasData || semesterSnapshot.data == null) {
          return Center(
            child: Text(
              'Unable to fetch semester information',
              style: GoogleFonts.lato(fontSize: 16),
            ),
          );
        }

        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('semister', isEqualTo: semesterSnapshot.data)
              .orderBy('fname')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Classmates Found',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'in ${semesterSnapshot.data} Semester',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            final allusers = snapshot.data?.docs;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    '${semesterSnapshot.data} Semester Classmates',
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
                ListView.builder(
                  itemCount: allusers!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final DocumentSnapshot document = allusers[index];
                    final bool isCaptain = document['isCaptain'] ?? false;
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            isCaptain 
                                ? Colors.amber.withOpacity(0.2)
                                : Colors.blue.withOpacity(0.2),
                            Colors.green.withOpacity(0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: isCaptain ? Colors.amber.shade900 : Colors.blue.shade900,
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${document['fname']} ${document['lname']}",
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isCaptain ? Colors.amber[900] : Colors.blue[900],
                                  ),
                                ),
                              ),
                              if (isCaptain)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.amber[900]!,
                                    ),
                                  ),
                                  child: Text(
                                    'CR',
                                    style: GoogleFonts.lato(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[900],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${document['ID']}',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Reg: ${document['Registration']}',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  document['email'],
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // Add email functionality
                                },
                                icon: Icon(
                                  Icons.mail,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  document['phoneNumber'],
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: Colors.green[900],
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // Add phone functionality
                                },
                                icon: Icon(
                                  Icons.call,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
