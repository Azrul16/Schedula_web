import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:schedula/classScreen/class_models.dart';
import 'package:schedula/classScreen/class_item.dart';
import 'package:schedula/utils/auth_gate.dart';

class ClassList extends StatelessWidget {
  const ClassList({
    super.key,
    required this.selectedSchedule,
    required this.userSemester,
  });

  final List<ClassSchedule> selectedSchedule;
  final String userSemester;

  bool isWithinNext24Hours(DateTime classTime) {
    final now = DateTime.now();
    final next24Hours = now.add(const Duration(hours: 24));
    return classTime.isAfter(now) && classTime.isBefore(next24Hours);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('classes')
          .orderBy('time')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/no_class.jpg'),
            ],
          );
        }

        final allClasses = snapshot.data?.docs;
        List<ClassSchedule> allClassesInModel = [];

        for (var e in allClasses!) {
          allClassesInModel.add(ClassSchedule.fromJSON(e.data(), e.id));
        }

        return FutureBuilder<bool>(
          future: GlobalUtils.isCaptain(),
          builder: (context, isAdminSnapshot) {
            if (isAdminSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            List<ClassSchedule> filteredClasses = [];

            if (isAdminSnapshot.data == true) {
              // Admin sees all upcoming classes filtered by semester
              filteredClasses = allClassesInModel.where((element) {
                return element.time.isAfter(DateTime.now()) &&
                    element.semester == userSemester;
              }).toList();
            } else {
              // Students see only classes in next 24 hours filtered by semester
              filteredClasses = allClassesInModel.where((element) {
                return isWithinNext24Hours(element.time) &&
                    element.semester == userSemester;
              }).toList();
            }

            if (filteredClasses.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/no_class.jpg'),
                  const SizedBox(height: 16),
                  Text(
                    isAdminSnapshot.data == true
                        ? 'No upcoming classes'
                        : 'No classes in the next 24 hours',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    isAdminSnapshot.data == true
                        ? 'All Upcoming Classes'
                        : 'Classes in Next 24 Hours',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                ListView.builder(
                  itemCount: filteredClasses.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (ctx, index) {
                    return ClassItem(
                      filteredClasses[index],
                      isStart: index == 0,
                      isEnd: index == filteredClasses.length - 1,
                      task: filteredClasses.length,
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
