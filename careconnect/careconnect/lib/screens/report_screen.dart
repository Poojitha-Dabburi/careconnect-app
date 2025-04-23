import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'pdf_service.dart';
import 'medicine_model.dart';

class ReportScreen extends StatefulWidget {
  final String uid; // User ID for Firestore queries

  const ReportScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Medicine> _medicines = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMedicineData();
  }

  Future<void> _fetchMedicineData() async {
    setState(() => _isLoading = true);

    try {
      // Fetch reminders from Firestore under users/{uid}/reminders
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .collection('reminders')
              .orderBy('createdAt', descending: true)
              .get();

      setState(() {
        _medicines =
            querySnapshot.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return Medicine(
                name: data['medicineName'] ?? 'Unknown',
                dosage: data['dosage'] ?? 'N/A',
                frequency:
                    data['duration'] ?? 'N/A', // Using 'duration' for now
                date: _formatDate((data['createdAt'] as Timestamp).toDate()),
              );
            }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
    }
  }

  // Helper method to format DateTime to String
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  Future<void> _generatePDFReport() async {
    final pdfFilePath = await PdfService().generateMedicineReport(_medicines);
    OpenFile.open(pdfFilePath); // Open the generated PDF
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Report')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _medicines.isEmpty
              ? const Center(child: Text('No medicine data available'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _medicines.length,
                      itemBuilder: (context, index) {
                        final medicine = _medicines[index];
                        return ListTile(
                          title: Text(medicine.name),
                          subtitle: Text(
                            'Dosage: ${medicine.dosage}, Duration: ${medicine.frequency}\nDate: ${medicine.date}',
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _generatePDFReport,
                      child: const Text('Generate PDF Report'),
                    ),
                  ),
                ],
              ),
    );
  }
}
