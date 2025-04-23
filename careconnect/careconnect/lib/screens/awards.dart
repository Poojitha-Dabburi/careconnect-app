import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyChallengesScreen extends StatefulWidget {
  final String uid;
  const WeeklyChallengesScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _WeeklyChallengesScreenState createState() => _WeeklyChallengesScreenState();
}

class _WeeklyChallengesScreenState extends State<WeeklyChallengesScreen>
    with SingleTickerProviderStateMixin {
  int totalPoints = 0;
  List<Map<String, dynamic>> weeklyTasks = [];
  Set<String> completedTaskKeys = {};
  List<Map<String, dynamic>> badges = [];
  late TabController _tabController;
  DateTime? lastGeneratedWeek;

  final Color _primaryColor = const Color(0xFF3366CC);
  final Color _accentColor = const Color(0xFF33CC99);
  final Color _dangerColor = const Color(0xFFFF6666);
  final Color _warningColor = const Color(0xFFFFCC66);

final List<Map<String, dynamic>> allTasks = [
    {'task': '🚶 Walk 10,000 steps', 'points': 10},
    {'task': '💧 Drink 2L of water', 'points': 10},
    {'task': '🧘 Meditate for 10 minutes', 'points': 10},
    {'task': '🏋️ Exercise for 30 minutes', 'points': 10},
    {'task': '🍎 Eat 3 servings of fruits', 'points': 10},
    {'task': '🌞 Get 15 min of sunlight', 'points': 10},
    {'task': '🛌 Sleep for 8 hours', 'points': 10},
    {'task': '📖 Read for 20 minutes', 'points': 10},
    {'task': '📝 Journal your thoughts', 'points': 10},
    {'task': '🚴 Cycle for 5 km', 'points': 10},
    {'task': '🫁 Deep breathing for 5 min', 'points': 10},
    {'task': '🥦 Eat 2 servings of greens', 'points': 10},
    {'task': '❄️ Take a cold shower', 'points': 10},
    {'task': '🍵 Avoid caffeine for a day', 'points': 10},
    {'task': '🏃 Run for 20 minutes', 'points': 10},
    {'task': '🎵 Listen to calming music', 'points': 10},
    {'task': '🍊 Eat an orange or citrus fruit', 'points': 10},
    {'task': '🥕 Eat a carrot', 'points': 10},
    {'task': '🍇 Snack on a handful of grapes', 'points': 10},
    {'task': '🥗 Have a healthy salad', 'points': 10},
    {'task': '🏅 Take a 10-minute walk after meals', 'points': 10},
    {'task': '🥛 Drink a glass of milk', 'points': 10},
    {'task': '🌱 Try a new healthy recipe', 'points': 10},
    {'task': '🧴 Apply sunscreen before going outside', 'points': 10},
    {'task': '💤 Practice good sleep hygiene', 'points': 10},
    {'task': '🌻 Spend 10 minutes outdoors', 'points': 10},
    {'task': '🎯 Set a goal and achieve it today', 'points': 10},
    {'task': '🧖‍♂️ Have a relaxing bath', 'points': 10},
    {'task': '🧴 Use hand sanitizer or wash hands regularly', 'points': 10},
    {'task': '🍴 Practice mindful eating for 10 minutes', 'points': 10},
    {'task': '🚶 Take a walk during lunch break', 'points': 10},
    {'task': '🏞️ Go on a nature walk or hike', 'points': 10},
    {'task': '🛋️ Take a break from sitting for 10 minutes', 'points': 10},
  ];

  final List<Map<String, dynamic>> defaultBadges = [
    {'name': '🥇 Beginner Warrior', 'points': 50, 'unlocked': false},
    {'name': '🥈 Fitness Hero', 'points': 1000, 'unlocked': false},
    {'name': '🏅 Health Champion', 'points': 2500, 'unlocked': false},
    {'name': '🏆 Ultimate Wellness', 'points': 5000, 'unlocked': false},
    {'name': '💧 Hydration Master', 'points': 7000, 'unlocked': false},
    {'name': '🧘 Mindful Guru', 'points': 9000, 'unlocked': false},
    {'name': '🚶 Walking Legend', 'points': 11000, 'unlocked': false},
    {'name': '🏋️ Gym Enthusiast', 'points': 13000, 'unlocked': false},
    {'name': '🍎 Nutrition Ninja', 'points': 15000, 'unlocked': false},
    {'name': '😴 Sleep Champion', 'points': 17500, 'unlocked': false},
    {'name': '🌞 Sunlight Seeker', 'points': 20000, 'unlocked': false},
    {'name': '📖 Knowledge Seeker', 'points': 23000, 'unlocked': false},
    {'name': '🏃 Marathoner', 'points': 26000, 'unlocked': false},
    {'name': '🛌 Rested Warrior', 'points': 29000, 'unlocked': false},
    {'name': '🚴 Cyclist Pro', 'points': 32000, 'unlocked': false},
    {'name': '🎵 Music Healer', 'points': 35000, 'unlocked': false},
    {'name': '🍵 Herbal Champion', 'points': 38000, 'unlocked': false},
    {'name': '❄️ Ice Bath Expert', 'points': 41000, 'unlocked': false},
    {'name': '🫁 Breathing Master', 'points': 44000, 'unlocked': false},
    {'name': '🍏 Organic Eater', 'points': 47000, 'unlocked': false},
    {'name': '🤸 Flexible Master', 'points': 50000, 'unlocked': false},
    {'name': '💪 Strength Titan', 'points': 55000, 'unlocked': false},
    {'name': '🩺 Health Guardian', 'points': 60000, 'unlocked': false},
    {'name': '🧑‍⚕️ Doctor’s Favorite', 'points': 65000, 'unlocked': false},
    {'name': '🔥 Fat Burner', 'points': 70000, 'unlocked': false},
    {'name': '📆 Consistency King', 'points': 75000, 'unlocked': false},
    {'name': '🦸‍♂️ Superhuman', 'points': 80000, 'unlocked': false},
    {'name': '🌍 Eco Health Warrior', 'points': 85000, 'unlocked': false},
    {'name': '👑 Ultimate Health Master', 'points': 100000, 'unlocked': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void generateNewWeeklyTasks() {
    final random = Random();
    Set<int> taskIndexes = {};
    while (taskIndexes.length < 5) {
      taskIndexes.add(random.nextInt(allTasks.length));
    }

    setState(() {
      weeklyTasks = taskIndexes.map((index) => allTasks[index]).toList();
      completedTaskKeys.clear();
      lastGeneratedWeek = DateTime.now();
    });
    saveProgress();
  }

  void completeTask(int index) {
    String taskKey = weeklyTasks[index]['task'];
    if (!completedTaskKeys.contains(taskKey)) {
      setState(() {
        completedTaskKeys.add(taskKey);
        totalPoints += (weeklyTasks[index]['points'] as num).toInt();
      });
      checkAndUnlockBadges();
      saveProgress();
    }
  }

  void checkAndUnlockBadges() {
    bool updated = false;
    for (var badge in badges) {
      if (totalPoints >= badge['points'] && !badge['unlocked']) {
        setState(() {
          badge['unlocked'] = true;
        });
        updated = true;
      }
    }
    if (updated) saveProgress();
  }

  Future<void> saveProgress() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
      'totalPoints': totalPoints,
      'completedTaskKeys': completedTaskKeys.toList(),
      'weeklyTasks': weeklyTasks.map((task) => json.encode(task)).toList(),
      'badges': badges,
      'lastGeneratedWeek': lastGeneratedWeek?.toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> loadProgress() async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        totalPoints = (data['totalPoints'] as num?)?.toInt() ?? 0;
        completedTaskKeys = Set<String>.from(data['completedTaskKeys'] ?? []);
        weeklyTasks =
            (data['weeklyTasks'] as List?)
                ?.map((task) => json.decode(task))
                .cast<Map<String, dynamic>>()
                .toList() ??
            [];
        badges =
            (data['badges'] as List?)
                ?.map(
                  (badge) => {
                    'name': badge['name'],
                    'points': badge['points'],
                    'unlocked': badge['unlocked'],
                  },
                )
                .toList() ??
            defaultBadges;
        lastGeneratedWeek =
            data['lastGeneratedWeek'] != null
                ? DateTime.parse(data['lastGeneratedWeek'])
                : null;
      });

      if (lastGeneratedWeek == null ||
          DateTime.now().difference(lastGeneratedWeek!).inDays >= 7) {
        generateNewWeeklyTasks();
      }
      checkAndUnlockBadges();
    } else {
      setState(() {
        badges = List.from(defaultBadges);
      });
      generateNewWeeklyTasks();
    }
  }

  int getNextBadgePoints() {
    for (var badge in badges) {
      if (!badge['unlocked']) {
        return badge['points'] - totalPoints;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weekly Challenges",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'Challenges'), Tab(text: 'Badges')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildChallengesTab(), _buildBadgesTab()],
      ),
    );
  }

  Widget _buildChallengesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPointsCard(),
          const SizedBox(height: 20),
          const Text(
            "This Week's Tasks",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 10),
          _buildTasksList(),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Progress",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              "$totalPoints pts",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Next badge in ${getNextBadgePoints()} pts",
              style: TextStyle(
                fontSize: 14,
                color: _primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: weeklyTasks.length,
      itemBuilder: (context, index) {
        final task = weeklyTasks[index];
        final isCompleted = completedTaskKeys.contains(task['task']);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Checkbox(
              value: isCompleted,
              onChanged: (bool? value) => completeTask(index),
              activeColor: _primaryColor,
            ),
            title: Text(
              task['task'],
              style: TextStyle(
                fontSize: 16,
                decoration:
                    isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                color: isCompleted ? Colors.grey : const Color(0xFF333333),
              ),
            ),
            trailing: Text(
              '${task['points']} pts',
              style: TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Achievements",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 10),
          _buildBadgesList(),
        ],
      ),
    );
  }

  Widget _buildBadgesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    badge['unlocked']
                        ? _primaryColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                badge['unlocked'] ? Icons.emoji_events : Icons.lock,
                color: badge['unlocked'] ? _primaryColor : Colors.grey,
              ),
            ),
            title: Text(
              badge['name'],
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF333333),
                fontWeight:
                    badge['unlocked'] ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              '${badge['points']} pts',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            trailing:
                badge['unlocked']
                    ? Icon(Icons.check_circle, color: _primaryColor)
                    : null,
          ),
        );
      },
    );
  }
}
