import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:schedula/classScreen/class_models.dart';
import 'package:schedula/utils/course_data.dart';
import 'package:http/http.dart' as http;

class NewClass extends StatefulWidget {
  const NewClass({
    super.key,
    required this.onAddClass,
    required this.currentUserId,
    required this.semester,
    required this.isCaptain,
  });

  final void Function(ClassSchedule classSchedule) onAddClass;
  final String currentUserId;
  final String semester;
  final bool isCaptain;

  @override
  State<StatefulWidget> createState() => _NewClassState();
}

class _NewClassState extends State<NewClass> {
  final _formKey = GlobalKey<FormState>();
  final _teacherController = TextEditingController();
  final TextEditingController _courseTitleController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _teacherController.dispose();
    _courseTitleController.dispose();
    _courseCodeController.dispose();
    super.dispose();
  }

  DateTime? _combinedDateTime;

  void _updateCombinedDateTime() {
    if (_selectedDate != null && _selectedTime != null) {
      _combinedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }
  }

  void _timePicker() async {
    final TimeOfDay initialTime = TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.amber.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        _updateCombinedDateTime();
      });
    }
  }

  void _datePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(now.year + 1, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.amber.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _updateCombinedDateTime();
      });
    }
  }

  Future<void> _submitClassDate() async {
    if (!_formKey.currentState!.validate() || _combinedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all fields',
            style: GoogleFonts.lato(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final thisClass = ClassSchedule(
          docID: '',
          courseTitle: _courseTitleController.text.trim(),
          courseTecher: _teacherController.text.trim(),
          time: _combinedDateTime!,
          courseCode: _courseCodeController.text.trim(),
          semester: widget.semester,
          creatorId: widget.currentUserId,
          creatorIsCaptain: widget.isCaptain);

      await FirebaseFirestore.instance
          .collection('classes')
          .add(thisClass.toJSON());

      // Send notification
      await sendTopicNotification(
        _courseTitleController.text.trim(),
        'New class by ${_teacherController.text.trim()}',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Class created successfully!',
              style: GoogleFonts.lato(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create class: $e',
              style: GoogleFonts.lato(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20,
        // MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create New Class',
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber[900],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _courseTitleController,
              decoration: InputDecoration(
                labelText: 'Course Title',
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.lato(),
              ),
              style: GoogleFonts.lato(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter course title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _courseCodeController,
              decoration: InputDecoration(
                labelText: 'Course Code',
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.lato(),
              ),
              style: GoogleFonts.lato(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter course code';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _teacherController,
              decoration: InputDecoration(
                labelText: 'Teacher Name',
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.lato(),
              ),
              style: GoogleFonts.lato(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter teacher name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _timePicker,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Class Time',
                        border: const OutlineInputBorder(),
                        labelStyle: GoogleFonts.lato(),
                      ),
                      child: Text(
                        _selectedTime == null
                            ? 'Select Time'
                            : _selectedTime!.format(context),
                        style: GoogleFonts.lato(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _datePicker,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Class Date',
                        border: const OutlineInputBorder(),
                        labelStyle: GoogleFonts.lato(),
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'Select Date'
                            : DateFormat('MMM d, y').format(_selectedDate!),
                        style: GoogleFonts.lato(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.lato(color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitClassDate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Create Class',
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Function to send notification
Future<void> sendTopicNotification(String title, String body) async {
  const String baseUrl =
      'https://us-central1-schedula-6bd5d.cloudfunctions.net/sendTopicNotification';

  final Map<String, String> queryParams = {
    'topic': 'general',
    'title': title,
    'body': body,
  };

  final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

  try {
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      print('Failed to send notification. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error occurred while sending notification: $e');
  }
}
