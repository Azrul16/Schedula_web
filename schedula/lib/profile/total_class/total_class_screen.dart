import 'package:flutter/material.dart';
import 'package:schedula/utils/auth_gate.dart';

class TotalClass extends StatefulWidget {
  const TotalClass({super.key});

  @override
  State<TotalClass> createState() => _TotalClassScreenState();
}

class _TotalClassScreenState extends State<TotalClass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total class list'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await checkUserAuthAndGetSemester();
        },
      ),
    );
  }
}
