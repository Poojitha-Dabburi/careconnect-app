import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:careconnect/screens/medicine_model.dart';

class FirestoreService {
  Future<List<Medicine>> fetchMedicineData(String uid) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('reminders')
            .orderBy('createdAt', descending: true)
            .get();

    return querySnapshot.docs
        .map(
          (doc) => Medicine.fromFirestore(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }
}
