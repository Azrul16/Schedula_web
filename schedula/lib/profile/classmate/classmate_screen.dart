import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedula/profile/classmate/classmate_list.dart';

class ClassmateScreen extends StatelessWidget {
  const ClassmateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.blue.shade800,
          title: Text(
            'Classmates',
            style: GoogleFonts.getFont(
              'Belanosima',
              textStyle: const TextStyle(
                fontSize: 28,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: true,
          elevation: 4,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.blue.shade800,
                      width: 1.5,
                    ),
                  ),
                  elevation: 8,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        ClassmateList(), // Display the list of classmates
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
