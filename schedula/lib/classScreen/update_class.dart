import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:schedula/classScreen/class_models.dart';

class UpdateClass extends StatefulWidget {
  const UpdateClass(
      {super.key, required this.onAddClass, required this.classitem});
  final ClassSchedule classitem;
  final void Function(ClassSchedule classSchedule) onAddClass;
  @override
  State<StatefulWidget> createState() {
    return _UpdateClassState();
  }
}

class _UpdateClassState extends State<UpdateClass> {
  final _titleController = TextEditingController();
  final _teacherController = TextEditingController();
  final _courseController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedTime;

  DateTime convertToDateTime(TimeOfDay timeOfDay) {
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );

    return dateTime;
  }

  void _timePicker() async {
    final TimeOfDay initialTime = TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    setState(() {
      _selectedTime = convertToDateTime(pickedTime!);
    });
  }

  void _datePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(now.year, now.month + 7, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _teacherController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.classitem.courseTitle;
    _teacherController.text = widget.classitem.courseTecher;
    _courseController.text = widget.classitem.courseCode;
    _selectedTime = widget.classitem.time;
    _selectedDate = widget.classitem.time;
  }

  Future<void> updateClass() async {
    final classTime = DateTime(_selectedDate!.year, _selectedDate!.month,
        _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
    ClassSchedule updatedClass = ClassSchedule(
        docID: '',
        courseCode: _courseController.text,
        courseTecher: _teacherController.text,
        courseTitle: _titleController.text,
        time: classTime,
        semester: widget.classitem.semester, // Preserve existing semester
        creatorId: widget.classitem.creatorId, // Preserve existing creator
        creatorIsCaptain: widget.classitem.creatorIsCaptain // Preserve captain status
    );

    await FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classitem.docID)
        .update(updatedClass.toJSON());
    Navigator.of(context).pop(); // Close the dialog
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            height: 60,
          ),
          TextField(
            controller: _titleController,
            maxLength: 25,
            decoration: const InputDecoration(
              label: Text('Course Title'),
            ),
          ),
          TextField(
            controller: _teacherController,
            maxLength: 20,
            decoration: const InputDecoration(
              label: Text("Teacher's name"),
            ),
          ),
          TextField(
            controller: _courseController,
            maxLength: 8,
            decoration: const InputDecoration(
              label: Text('Course Code'),
            ),
          ),
          Row(
            children: [
              Text(
                _selectedTime == null
                    ? 'Select Class Time'
                    : DateFormat.jm().format(_selectedTime!),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              IconButton(
                onPressed: _timePicker,
                icon: const Icon(Icons.timer),
              ),
              const Spacer(),
              Text(
                _selectedDate == null
                    ? "Select a Date"
                    : DateFormat('d MMMM, yyyy').format(_selectedDate!),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              IconButton(
                onPressed: _datePicker,
                icon: const Icon(Icons.calendar_month),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  updateClass();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Update Class',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
