import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bmi.dart';
import 'package:careconnect/screens/awards.dart';
import 'package:careconnect/screens/emergency.dart';
import 'package:careconnect/screens/profile.dart';
import 'package:careconnect/screens/medicalquery.dart';
import 'package:careconnect/screens/HealthGraphScreen.dart';
import 'package:careconnect/screens/reminder_page.dart';
import 'package:careconnect/screens/home_screen.dart';
import 'package:careconnect/screens/appointment_page.dart';

class DashboardWidget extends StatefulWidget {
  final String uid;

  const DashboardWidget({super.key, required this.uid});

  static String routeName = 'Dashboard';
  static String routePath = 'dashboard';

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      HapticFeedback.mediumImpact();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF5F9FC),
        appBar: AppBar(
          backgroundColor: const Color(0xFF3366CC),
          automaticallyImplyLeading: false,
          title: const Text(
            'CareConnect',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.emoji_events_outlined, size: 24),
              onPressed: () {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => WeeklyChallengesScreen(uid: user.uid),
                    ),
                  );
                } else {
                  _showLoginAlert(context);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.account_circle_outlined, size: 24),
              onPressed: () {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileWidget(uid: user.uid),
                    ),
                  );
                } else {
                  _showLoginAlert(context);
                }
              },
            ),
          ],
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
          ),
        ),
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildDashboardContent(context),
              _buildMenuContent(context),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.widgets_outlined),
          activeIcon: Icon(Icons.widgets_rounded),
          label: 'Features',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xFF3366CC),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      onTap: _onItemTapped,
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Welcome Card
          _buildWelcomeCard(context),

          // Quick Actions Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _buildQuickActionCard(
                  icon: Icons.medical_services_outlined,
                  color: const Color(0xFF34A853),
                  title: 'Health Check',
                  onTap: () {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DailyHealthSurvey(uid: user.uid),
                        ),
                      );
                    } else {
                      _showLoginAlert(context);
                    }
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.monitor_weight_outlined,
                  color: const Color(0xFFFBBC05),
                  title: 'BMI Calculator',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BMIScreen()),
                    );
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.emergency_outlined,
                  color: const Color(0xFFEA4335),
                  title: 'Emergency',
                  onTap: () {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  EmergencyContactScreen(uid: user.uid),
                        ),
                      );
                    } else {
                      _showLoginAlert(context);
                    }
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.insights_outlined,
                  color: const Color(0xFF3366CC),
                  title: 'Health Stats',
                  onTap: () {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => HealthGraphScreen(uid: user.uid),
                        ),
                      );
                    } else {
                      _showLoginAlert(context);
                    }
                  },
                ),
              ],
            ),
          ),

          // Health Tips Section
          _buildHealthTipsSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3366CC), Color(0xFF34A853)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Back!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your health journey matters. Track symptoms, monitor progress, and stay connected with your care team.',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DailyHealthSurvey(uid: user.uid),
                  ),
                );
              } else {
                _showLoginAlert(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text(
              'Daily Health Check',
              style: TextStyle(
                color: Color(0xFF3366CC),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required Color color,
    required String title,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthTipsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Tips',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildHealthTipItem(
            icon: Icons.local_drink_outlined,
            title: 'Stay Hydrated',
            description: 'Drink at least 8 glasses of water daily',
          ),
          _buildHealthTipItem(
            icon: Icons.nightlight_round_outlined,
            title: 'Quality Sleep',
            description: 'Aim for 7-9 hours of sleep each night',
          ),
          _buildHealthTipItem(
            icon: Icons.directions_walk_outlined,
            title: 'Daily Movement',
            description: '30 minutes of exercise improves overall health',
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTipItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4285F4)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFeatureCard(
            icon: Icons.notifications_active_outlined,
            title: 'Medication Reminders',
            description: 'Never miss a dose with personalized alerts',
            color: const Color(0xFFEA4335),
            onTap: () {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReminderPage(uid: user.uid),
                  ),
                );
              } else {
                _showLoginAlert(context);
              }
            },
          ),
          _buildFeatureCard(
            icon: Icons.calendar_today_outlined,
            title: 'Appointments',
            description: 'Manage and schedule doctor visits',
            color: const Color(0xFF34A853),
            onTap: () {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentPage(uid: user.uid),
                  ),
                );
              } else {
                _showLoginAlert(context);
              }
            },
          ),
          _buildFeatureCard(
            icon: Icons.show_chart_outlined,
            title: 'Health Progress',
            description: 'Track your health metrics over time',
            color: const Color(0xFF4285F4),
            onTap: () {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HealthGraphScreen(uid: user.uid),
                  ),
                );
              } else {
                _showLoginAlert(context);
              }
            },
          ),
          _buildFeatureCard(
            icon: Icons.assignment_outlined,
            title: 'Medical Reports',
            description: 'Access and share your health records',
            color: const Color(0xFFFBBC05),
            onTap: () {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(uid: user.uid),
                  ),
                );
              } else {
                _showLoginAlert(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Login Required'),
            content: const Text('Please log in to access this feature.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
