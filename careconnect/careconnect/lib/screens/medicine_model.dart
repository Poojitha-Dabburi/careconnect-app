import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Medicine {
  final String name;
  final String dosage;
  final String frequency;
  final String date; // Store date as a formatted String

  Medicine({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.date,
  });

  /// Factory method to create a `Medicine` object from Firestore data
  factory Medicine.fromFirestore(Map<String, dynamic> data) {
    // Handle Firestore timestamp conversion
    String formattedDate = "";
    if (data['createdAt'] is Timestamp) {
      formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format((data['createdAt'] as Timestamp).toDate());
    } else if (data['date'] is String) {
      formattedDate = data['date']!;
    }

    return Medicine(
      name: data['medicineName'] ?? '',
      dosage: data['dosage'] ?? '',
      frequency:
          data['duration'] ??
          '', // Assuming duration is equivalent to frequency
      date: formattedDate,
    );
  }

  /// Convert `Medicine` object to Firestore-friendly format
  Map<String, dynamic> toJson() {
    return {
      'medicineName': name,
      'dosage': dosage,
      'duration': frequency,
      'createdAt': date, // Store as String (Firestore expects Timestamp)
    };
  }
}
