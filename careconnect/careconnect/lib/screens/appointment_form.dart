import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';

class AppointmentForm extends StatefulWidget {
  final String uid;

  const AppointmentForm({Key? key, required this.uid}) : super(key: key);

  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final _doctorNameController = TextEditingController();
  final _purposeController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _prerequisitesController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final Color _primaryColor = const Color(0xFF3366CC);
  bool _isSaving = false;

  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.subscribeToTopic('appointments');
  }

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  void _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  void _saveAppointment() async {
    if (_doctorNameController.text.isEmpty ||
        _purposeController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete all fields!'),
          backgroundColor: _primaryColor,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      await _firestore
          .collection('users')
          .doc(widget.uid)
          .collection('appointments')
          .add({
            'uid': widget.uid,
            'doctorName': _doctorNameController.text,
            'purpose': _purposeController.text,
            'date': Timestamp.fromDate(selectedDate!),
            'time': _timeController.text,
            'prerequisites': _prerequisitesController.text,
            'createdAt': Timestamp.now(),
          });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving appointment: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3366CC),
        automaticallyImplyLeading: false,
        title: const Text(
          "Add Appointment",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTextField(
              controller: _doctorNameController,
              label: 'Doctor Name',
              hint: 'Enter doctor name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _purposeController,
              label: 'Purpose',
              hint: 'Enter purpose of visit',
              icon: Icons.medical_services_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _dateController,
              label: 'Date',
              hint: 'Select appointment date',
              icon: Icons.calendar_today_outlined,
              readOnly: true,
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _timeController,
              label: 'Time',
              hint: 'Select appointment time',
              icon: Icons.access_time_outlined,
              readOnly: true,
              onTap: _selectTime,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _prerequisitesController,
              label: 'Prerequisites (Optional)',
              hint: 'Any special requirements',
              icon: Icons.note_alt_outlined,
            ),
            const SizedBox(height: 30),
            _isSaving
                ? const CircularProgressIndicator()
                : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Save Appointment"),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      readOnly: readOnly,
      onTap: onTap,
    );
  }
}
