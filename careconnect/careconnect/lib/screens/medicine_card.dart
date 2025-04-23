import 'package:flutter/material.dart';
import 'medicine_model.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;

  const MedicineCard({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: const Icon(Icons.medical_services, color: Colors.blue),
        title: Text(
          medicine.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dosage: ${medicine.dosage}'),
            Text('Frequency: ${medicine.frequency}'),
          ],
        ),
        trailing: Text(
          medicine.date, // Already formatted as "yyyy-MM-dd"
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
