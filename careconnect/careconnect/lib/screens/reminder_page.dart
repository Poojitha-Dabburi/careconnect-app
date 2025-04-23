import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'reminder_form.dart';
import 'package:intl/intl.dart';

class ReminderPage extends StatefulWidget {
  final String uid;

  const ReminderPage({Key? key, required this.uid}) : super(key: key);

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Set<String> _shownReminders = {}; // Track shown reminders by ID

  void _addReminder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReminderFormPage(uid: widget.uid),
      ),
    );
  }

  Stream<QuerySnapshot> _fetchReminders() {
    return _firestore
        .collection('users')
        .doc(widget.uid)
        .collection('reminders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3366CC),
        automaticallyImplyLeading: false,
        title: const Text(
          "Health Reminders",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchReminders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No reminders available",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          var reminders = snapshot.data!.docs;
          final now = DateTime.now();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              var reminder = reminders[index];

              DateTime reminderTime;
              String timeString = "N/A";

              try {
                final timeField = reminder['time'];

                if (timeField is Timestamp) {
                  reminderTime = timeField.toDate();
                } else if (timeField is String) {
                  final parsedTime = DateFormat("hh:mm a").parse(timeField);
                  reminderTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    parsedTime.hour,
                    parsedTime.minute,
                  );
                } else {
                  throw Exception("Unsupported time format");
                }

                timeString = DateFormat("hh:mm a").format(reminderTime);
              } catch (e) {
                print("Error parsing time: $e");
                reminderTime = now;
              }

              final differenceInMinutes =
                  reminderTime.difference(now).inMinutes;

              // Show fullscreen dialog only if not already shown
              if (differenceInMinutes.abs() <= 10 &&
                  !_shownReminders.contains(reminder.id)) {
                _shownReminders.add(reminder.id);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: false,
                    barrierColor: Colors.black.withOpacity(0.5),
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (context, anim1, anim2) {
                      return SafeArea(
                        child: Scaffold(
                          backgroundColor: Colors.white,
                          body: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.alarm,
                                    color: Color(0xFF3366CC),
                                    size: 60,
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    "⏰ Reminder!",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3366CC),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "It's time for ${reminder['medicineName']}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(height: 32),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF3366CC),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 32,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      setState(() {});
                                    },
                                    child: const Text(
                                      "OK",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                });
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    reminder['medicineName'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    "Dosage: ${reminder['dosage']} | Time: $timeString",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _firestore
                          .collection('users')
                          .doc(widget.uid)
                          .collection('reminders')
                          .doc(reminder.id)
                          .delete();
                      _shownReminders.remove(reminder.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        backgroundColor: const Color(0xFF3366CC),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
