import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'add_record_page.dart';
import 'child_records_screen.dart';
import 'pregnant_records_screen.dart';
import 'reminders_screen.dart';
import 'vaccination_screen.dart';
import 'malnutrition_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/language_selector.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> records = [];
  @override
  void initState() {
    super.initState();
    fetchRecords();
  }
  // Fetch all records from MongoDB
  Future<void> fetchRecords() async {
    try {
      final childResp =
          await http.get(Uri.parse('http://x.x.x.x:3000/child'));
      final pregnantResp =
          await http.get(Uri.parse('http://x.x.x.x:3000/pregnant'));

      if (childResp.statusCode == 200 && pregnantResp.statusCode == 200) {
        final children = List<Map<String, dynamic>>.from(jsonDecode(childResp.body))
            .map((m) => {
                  ...m,
                  'type': 'Child',
                })
            .toList();
        final pregnant = List<Map<String, dynamic>>.from(jsonDecode(pregnantResp.body))
            .map((m) => {
                  ...m,
                  'type': 'Pregnant Lady',
                })
            .toList();
        setState(() {
          records = [
            ...children,
            ...pregnant,
          ];
        });
      } else {
        print("Failed to fetch records");
      }
    } catch (e) {
      print("Error fetching records: $e");
    }
  }

  void _addRecord(Map<String, dynamic> newRecord) async {
    final url = newRecord['type'] == 'Child'
        ? 'http://x.x.x.x:3000/child'
        : 'http://x.x.x.x:3000/pregnant';
    try {
      final resp = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newRecord),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        setState(() {
          records.add(newRecord);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Record added successfully")),
        );
      } else {
        print("Failed to save record: ${resp.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save record")),
        );
      }
    } catch (e) {
      print("Error saving record: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error saving record")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    int pregnantCount =
        records.where((r) => r['type'] == 'Pregnant Lady').length;
    int childCount = records.where((r) => r['type'] == 'Child').length;
    int remindersCount =
        records.where((r) => (r['nextAppointment'] ?? '').isNotEmpty).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr()),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          const LanguageSelector(),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: fetchRecords,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await fetchRecords(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${'welcome'.tr()}\n\n${'welcome_description'.tr()}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statCard('pregnant_women'.tr(), pregnantCount, Colors.orange),
                _statCard('children_under_5'.tr(), childCount, Colors.purple),
                _statCard('upcoming_reminders'.tr(), remindersCount, Colors.green),
              ],
            ),
            const SizedBox(height: 20),
            _navigationCard(
              context,
              title: 'child_records'.tr(),
              subtitle: 'child_records_subtitle'.tr(),
              color: Colors.teal[200]!,
              icon: Icons.child_care,
              screen: const ChildRecordsScreen(),
            ),
            const SizedBox(height: 12),

            _navigationCard(
              context,
              title: 'pregnant_records'.tr(),
              subtitle: 'pregnant_records_subtitle'.tr(),
              color: Colors.pink[200]!,
              icon: Icons.pregnant_woman,
              screen: const PregnantRecordsScreen(),
            ),
            const SizedBox(height: 12),

            _navigationCard(
              context,
              title: 'add_record'.tr(),
              subtitle: 'add_record_subtitle'.tr(),
              color: Colors.blue[300]!,
              icon: Icons.add,
              screen: AddRecordSelector(
                onRecordAdded: (record) {
                  _addRecord(record);
                },
              ),
            ),
            const SizedBox(height: 12),

            _navigationCard(
              context,
              title: 'reminders'.tr(),
              subtitle: 'reminders_subtitle'.tr(),
              color: Colors.orange[200]!,
              icon: Icons.alarm,
              screen: const RemindersScreen(),
            ),
            const SizedBox(height: 12),

            _navigationCard(
              context,
              title: 'malnutrition_monitor'.tr(),
              subtitle: 'malnutrition_subtitle'.tr(),
              color: Colors.purple[200]!,
              icon: Icons.monitor_weight,
              screen: MalnutritionScreen(
                records: records,
                onRefresh: fetchRecords,
              ),
            ),
            const SizedBox(height: 12),

            _navigationCard(
              context,
              title: 'vaccinations'.tr(),
              subtitle: 'vaccinations_subtitle'.tr(),
              color: Colors.green[300]!,
              icon: Icons.medical_services,
              screen: VaccinationScreen(records: records),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      width: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$count',
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _navigationCard(BuildContext context,
      {required String title,
      required String subtitle,
      required Color color,
      required IconData icon,
      required Widget screen}) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(icon, size: 40, color: Colors.white),
          title: Text(title,
              style: const TextStyle(fontSize: 18, color: Colors.white)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
          trailing: const Icon(Icons.arrow_forward, color: Colors.white),
        ),
      ),
    );
  }
}
