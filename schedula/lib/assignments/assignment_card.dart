import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedula/utils/auth_gate.dart';
import 'package:schedula/utils/toast_message.dart';

class AssignmentCard extends StatefulWidget {
  final String id;
  final String assignmentName;
  final String courseTitle;
  final String teacherName;
  final String lastDate;
  final List<String> completedBy;

  const AssignmentCard({
    super.key,
    required this.id,
    required this.assignmentName,
    required this.courseTitle,
    required this.teacherName,
    required this.lastDate,
    required this.completedBy,
  });

  @override
  State<AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<AssignmentCard> {
  late bool isCompleted;
  String? currentUserId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final userId = await GlobalUtils.getCurrentUserId();
    if (mounted) {
      setState(() {
        currentUserId = userId;
        isCompleted = widget.completedBy.contains(userId);
      });
    }
  }

  Future<void> _toggleCompletion() async {
    if (currentUserId == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final assignmentRef = FirebaseFirestore.instance
          .collection('assignments')
          .doc(widget.id);

      List<String> updatedCompletedBy = List.from(widget.completedBy);
      if (isCompleted) {
        updatedCompletedBy.remove(currentUserId);
      } else {
        updatedCompletedBy.add(currentUserId!);
      }

      await assignmentRef.update({'completedBy': updatedCompletedBy});

      if (mounted) {
        setState(() {
          isCompleted = !isCompleted;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCompleted ? 'Marked as completed' : 'Marked as incomplete',
              style: GoogleFonts.lato(),
            ),
            backgroundColor: isCompleted ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update assignment status: $e',
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isCompleted
                ? [Colors.green.shade100, Colors.green.shade300]
                : [Colors.orange.shade100, Colors.orange.shade300],
          ),
        ),
        child: InkWell(
          onTap: _toggleCompletion,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.assignmentName,
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    else
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.circle_outlined,
                        color: isCompleted ? Colors.green.shade800 : Colors.orange.shade800,
                        size: 28,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Course: ${widget.courseTitle}",
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Teacher: ${widget.teacherName}",
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Due: ${widget.lastDate}",
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      isCompleted ? "Completed" : "Pending",
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green.shade800 : Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
