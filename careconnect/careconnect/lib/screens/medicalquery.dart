import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HealthGraphScreen.dart'; // Make sure to create this file

class DailyHealthSurvey extends StatefulWidget {
  final String uid;
  final Color _primaryColor = const Color(0xFF3366CC);
  final Color _accentColor = const Color.fromARGB(255, 255, 255, 255);

  const DailyHealthSurvey({Key? key, required this.uid}) : super(key: key);

  @override
  _DailyHealthSurveyState createState() => _DailyHealthSurveyState();
}

class _DailyHealthSurveyState extends State<DailyHealthSurvey> {
  int age = 0;
  String gender = "Male";
  String fever = "No";
  String cough = "No";
  String fatigue = "No";
  String breathingDifficulty = "No";
  String pain = "No";
  String painLocation = "None";
  double severity = 1;

  final _formKey = GlobalKey<FormState>();
  final Color _primaryColor = const Color(0xFF3366CC);
  final Color _accentColor = const Color(0xFF33CC99);

  Future<void> submitData() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('health_responses')
          .add({
            'uid': uid,
            'age': age,
            'gender': gender,
            'fever': fever,
            'cough': cough,
            'fatigue': fatigue,
            'breathingDifficulty': breathingDifficulty,
            'pain': pain,
            'painLocation': painLocation,
            'severity': severity,
            'timestamp': Timestamp.now(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Data saved successfully!"),
          backgroundColor: _primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: _primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget buildRadioTile(
    String title,
    String value,
    String groupValue,
    Function(String) onChanged,
  ) {
    return RadioListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: (val) => setState(() => onChanged(val!)),
      activeColor: _primaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Daily Health Assessment",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Health Symptoms",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "1. Do you have a fever?",
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      buildRadioTile("Yes", "Yes", fever, (val) => fever = val),
                      buildRadioTile("No", "No", fever, (val) => fever = val),
                      const SizedBox(height: 16),
                      Text(
                        "2. Do you have a cough?",
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      buildRadioTile("Yes", "Yes", cough, (val) => cough = val),
                      buildRadioTile("No", "No", cough, (val) => cough = val),
                      const SizedBox(height: 16),
                      Text(
                        "3. Are you experiencing fatigue?",
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      buildRadioTile(
                        "Yes",
                        "Yes",
                        fatigue,
                        (val) => fatigue = val,
                      ),
                      buildRadioTile(
                        "No",
                        "No",
                        fatigue,
                        (val) => fatigue = val,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "4. Are you having difficulty breathing?",
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      buildRadioTile(
                        "Yes",
                        "Yes",
                        breathingDifficulty,
                        (val) => breathingDifficulty = val,
                      ),
                      buildRadioTile(
                        "No",
                        "No",
                        breathingDifficulty,
                        (val) => breathingDifficulty = val,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "5. Are you feeling pain?",
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      buildRadioTile("Yes", "Yes", pain, (val) => pain = val),
                      buildRadioTile("No", "No", pain, (val) => pain = val),
                      if (pain == "Yes") ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Where is the pain?",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged:
                              (val) => setState(() => painLocation = val),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        "6. How severe are your symptoms?",
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      Slider(
                        value: severity,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: severity.toString(),
                        onChanged: (val) => setState(() => severity = val),
                        activeColor: _primaryColor,
                        inactiveColor: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Submit Health Assessment",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => HealthGraphScreen(uid: widget.uid),
                      ),
                    );
                  },
                  icon: const Icon(Icons.show_chart),
                  label: const Text(
                    "View Health Graph",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
