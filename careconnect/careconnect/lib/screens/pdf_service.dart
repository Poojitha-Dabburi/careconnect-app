import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'medicine_model.dart';

class PdfService {
  Future<String> generateMedicineReport(List<Medicine> medicineData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Medicine Report',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(1),
                  3: pw.FlexColumnWidth(2),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(), // ✅ Fixed
                    children: [
                      _tableHeader('Name'),
                      _tableHeader('Dosage'),
                      _tableHeader('Frequency'),
                      _tableHeader('Date'),
                    ],
                  ),
                  // Table Data
                  ...medicineData.map(
                    (medicine) => pw.TableRow(
                      children: [
                        _tableCell(medicine.name),
                        _tableCell(medicine.dosage),
                        _tableCell(medicine.frequency),
                        _tableCell(_formatDate(medicine.date)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Get the directory based on platform
    final directory =
        Platform.isAndroid
            ? await getExternalStorageDirectory()
            : await getApplicationDocumentsDirectory();

    final filePath = '${directory!.path}/medicine_report.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  // Helper method for table headers
  pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    );
  }

  // Helper method for table cells
  pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text.isNotEmpty ? text : 'N/A'),
    );
  }

  // Date formatting method
  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
