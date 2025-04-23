import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'medicine_model.dart';

class MedicineProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Medicine> _medicines = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Medicine> get medicines => _medicines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch medicines from Firestore and notify listeners
  Future<void> fetchMedicines(String uid) async {
    // Accept UID as parameter
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final List<Medicine> fetchedMedicines = await _firestoreService
          .fetchMedicineData(uid);

      if (fetchedMedicines != _medicines) {
        _medicines = fetchedMedicines;
        notifyListeners();
      }
    } catch (error) {
      _errorMessage = "Failed to fetch medicines: ${error.toString()}";
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes the medicine data manually
  Future<void> refreshMedicines(String uid) async {
    await fetchMedicines(uid);
  }
}
