import 'package:flutter/material.dart';
import 'add_child_record_screen.dart';
import 'add_pregnant_record_screen.dart';

class AddRecordSelector extends StatelessWidget {
  final Function(Map<String, dynamic>) onRecordAdded;
  const AddRecordSelector({super.key, required this.onRecordAdded});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Record Type")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Add Child Record"),
              onPressed: () async {
                final record = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(builder: (_) => const AddChildRecordScreen()),
                );
                if (record != null) {
                  record['type'] = 'Child';
                  onRecordAdded(record);
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Add Pregnant Lady Record"),
              onPressed: () async {
                final record = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPregnantRecordScreen()),
                );
                if (record != null) {
                  record['type'] = 'Pregnant Lady';
                  onRecordAdded(record);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}