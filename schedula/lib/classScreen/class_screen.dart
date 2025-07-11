import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedula/classScreen/class_models.dart';
import 'package:schedula/classScreen/class_list.dart';
import 'package:schedula/classScreen/new_class.dart';
import 'package:schedula/utils/auth_gate.dart';

class ClassScren extends StatefulWidget {
  const ClassScren({super.key});

  @override
  State<ClassScren> createState() => _ClassScrenState();
}

class _ClassScrenState extends State<ClassScren> {
  final List<ClassSchedule> _selectedSchedule = [];

  void _openAddClassOverlay() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        if (!mounted) return;

        showModalBottomSheet(
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          builder: (ctx) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: NewClass(
              onAddClass: _addClass,
              currentUserId: currentUser.uid,
              semester: userData['semister'] ?? '',
              isCaptain: userData['isCaptain'] ?? false,
            ),
          ),
        );
      }
    }
  }

  void _addClass(ClassSchedule classSchedule) {
    setState(() {
      _selectedSchedule.add(classSchedule);
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<DateTime> weekDates = List.generate(7, (index) {
      return now.subtract(Duration(days: now.weekday - 1 - index));
    });

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.amber,
          title: Text(
            'Classes',
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevation: 4,
          centerTitle: false,
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Today',
                  style: GoogleFonts.lato(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  7,
                  (index) {
                    bool isToday = weekDates[index].day == now.day &&
                        weekDates[index].month == now.month;
                    return Column(
                      children: [
                        Text(
                          weekdays[index],
                          style: GoogleFonts.lato(
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday ? Colors.amber[900] : Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weekDates[index].day.toString(),
                          style: GoogleFonts.lato(
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday ? Colors.amber[900] : Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        if (isToday)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            height: 2,
                            width: 20,
                            color: Colors.amber[900],
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('User data not found'));
                  }
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  return ClassList(
                    selectedSchedule: _selectedSchedule,
                    userSemester: userData['semister'] ?? '',
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
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
              onPressed: _openAddClassOverlay,
              backgroundColor: Colors.amber,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
