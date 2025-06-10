import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:schedula/utils/auth_gate.dart';
import 'package:schedula/utils/course_data.dart';

class CreateAssignmentBottomSheet extends StatefulWidget {
  const CreateAssignmentBottomSheet({super.key});

  @override
  State<CreateAssignmentBottomSheet> createState() =>
      _CreateAssignmentBottomSheetState();
}

class _CreateAssignmentBottomSheetState
    extends State<CreateAssignmentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _assignmentNameController =
      TextEditingController();
  final TextEditingController _teacherNameController = TextEditingController();
  final TextEditingController _lastDateController = TextEditingController();
  final TextEditingController _courseTitleController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _assignmentNameController.dispose();
    _teacherNameController.dispose();
    _lastDateController.dispose();
    _courseTitleController.dispose();
    _courseCodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _lastDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _createAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final semester = await GlobalUtils.getCurrentUserSemester();
      final userId = await GlobalUtils.getCurrentUserId();

      if (semester == null || userId == null) {
        throw Exception(
            "Unable to create assignment. User information not found.");
      }

      await FirebaseFirestore.instance.collection('assignments').add({
        'assignmentName': _assignmentNameController.text.trim(),
        'courseTitle': _courseTitleController.text.trim(),
        'courseCode': _courseCodeController.text.trim(),
        'teacherName': _teacherNameController.text.trim(),
        'lastDate': _lastDateController.text,
        'semester': semester,
        'createdAt': FieldValue.serverTimestamp(),
        'completedBy': [],
        'creatorId': userId,
      });

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Assignment created successfully!",
            style: GoogleFonts.lato(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to create assignment: ${e.toString()}",
            style: GoogleFonts.lato(),
          ),
          backgroundColor: Colors.red,
        ),
      );
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
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Create Assignment",
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange[900],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _assignmentNameController,
              decoration: InputDecoration(
                labelText: "Assignment Name",
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.lato(),
              ),
              style: GoogleFonts.lato(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter assignment name";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
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
              controller: _teacherNameController,
              decoration: InputDecoration(
                labelText: "Teacher Name",
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.lato(),
              ),
              style: GoogleFonts.lato(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter teacher name";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastDateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                labelText: "Last Date",
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.lato(),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              style: GoogleFonts.lato(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select a last date";
                }
                return null;
              },
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
                  onPressed: _isLoading ? null : _createAssignment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
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
                          'Create Assignment',
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
