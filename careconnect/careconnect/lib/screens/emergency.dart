import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactScreen extends StatefulWidget {
  final String uid;
  final Color _primaryColor = const Color(0xFF3366CC);
  final Color _dangerColor = const Color(0xFFEA4335);
  final Color _accentColor = const Color(0xFF33CC99);

  const EmergencyContactScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _EmergencyContactScreenState createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  String emergencyContactNumber = "Not Available";

  @override
  void initState() {
    super.initState();
    fetchEmergencyContact();
  }

  Future<void> fetchEmergencyContact() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          emergencyContactNumber =
              userDoc.get('emergencyContact') ?? "Not Available";
        });
      }
    } catch (e) {
      print("Error fetching emergency contact: $e");
    }
  }

  void callNumber(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: "tel", path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print("Could not launch $phoneUri");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Emergency Contacts",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: widget._dangerColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(0),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildEmergencyBox(
                title: "In Case of Emergency",
                description: "Your designated caregiver contact is available below. Tap the call button to immediately connect with them.",
                contactName: "Caregiver",
                contactNumber: emergencyContactNumber,
                buttonText: "Call Now",
                buttonIcon: Icons.phone,
                boxColor: widget._dangerColor,
                textColor: Colors.white,
                buttonColor: Colors.white,
                buttonTextColor: widget._dangerColor,
                onPressed: () => callNumber(emergencyContactNumber),
              ),
              const SizedBox(height: 20),
              _buildEmergencyBox(
                title: "Emergency Ambulance (India)",
                description: "Dial the national emergency ambulance number for immediate assistance.",
                contactName: "Ambulance Service",
                contactNumber: "102",
                buttonText: "Call Ambulance",
                buttonIcon: Icons.local_hospital,
                boxColor: Colors.white,
                textColor: Colors.grey[800]!,
                buttonColor: widget._primaryColor,
                buttonTextColor: Colors.white,
                onPressed: () => callNumber("102"),
              ),
              const SizedBox(height: 20),
              _buildEmergencyBox(
                title: "Police Emergency",
                description: "Dial the national police emergency number for immediate assistance.",
                contactName: "Police Service",
                contactNumber: "100",
                buttonText: "Call Police",
                buttonIcon: Icons.local_police,
                boxColor: Colors.white,
                textColor: Colors.grey[800]!,
                buttonColor: widget._primaryColor,
                buttonTextColor: Colors.white,
                onPressed: () => callNumber("100"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyBox({
    required String title,
    required String description,
    required String contactName,
    required String contactNumber,
    required String buttonText,
    required IconData buttonIcon,
    required Color boxColor,
    required Color textColor,
    required Color buttonColor,
    required Color buttonTextColor,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: boxColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.9),
              ),
            ),
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contactName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contactNumber,
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: Icon(buttonIcon, color: buttonTextColor),
                  label: Text(
                    buttonText,
                    style: TextStyle(color: buttonTextColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}