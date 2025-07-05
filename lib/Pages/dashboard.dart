import 'dart:io';
import 'package:flutter/material.dart';
import 'PetSummary.dart';
import 'addPet.dart';


class Dashoard extends StatefulWidget {
  const Dashoard({super.key});

  @override
  State<Dashoard> createState() => _DashoardState();
}

class _DashoardState extends State<Dashoard> {
  List<Map<String, String>> pets = [
    {
      'name': 'Mochi',
      'breed': 'Persian',
      'birthday': 'Jan 3, 2021',
      'lastFed': '8:00 AM',
      'lastVitamin': '10:00 AM',
      'lastBath': 'June 25, 2025',
      'image': '',
    },
    {
      'name': 'Whiskers',
      'breed': 'Puspin',
      'birthday': 'July 14, 2022',
      'lastFed': '9:30 AM',
      'lastVitamin': '11:00 AM',
      'lastBath': 'June 20, 2025',
      'image': '',
    },
  ];

  final List<Map<String, String>> todayReminders = [
    {'type': 'Feeding', 'time': '8:00 AM'},
    {'type': 'Vitamin', 'time': '10:00 AM'},
    {'type': 'Bath', 'time': '5:00 PM'},
  ];

  void navigateAndRefresh() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPet()),
    );
    setState(() {
      // Reload pets if needed
    });
  }

  Widget buildPetIcon(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: 24,
          backgroundImage: FileImage(file),
        );
      }
    }
    return const CircleAvatar(
      radius: 24,
      backgroundColor: Colors.pink,
      child: Icon(Icons.pets, color: Colors.white),
    );
  }

  void openSummaryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileSummary(profiles: [],)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🐾 Pet Care App",
          style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        actions: [
          IconButton(
            icon: const Icon(Icons.insert_chart_outlined),
            tooltip: "View Summary",
            onPressed: openSummaryPage,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Pet",
            onPressed: navigateAndRefresh,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Reminders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children: todayReminders.map((reminder) {
                return ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.orange),
                  title: Text('${reminder['type']} at ${reminder['time']}'),
                );
              }).toList(),
            ),
            const Divider(height: 32),
            const Text(
              'Your Pets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children: pets.map((pet) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      // Navigate to pet profile
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          buildPetIcon(pet['image']),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pet['name']!,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                Text('Breed: ${pet['breed']}'),
                                Text('Birthday: ${pet['birthday']}'),
                                const SizedBox(height: 8),
                                Text('Last Fed: ${pet['lastFed']}'),
                                Text('Vitamin: ${pet['lastVitamin']}'),
                                Text('Bath: ${pet['lastBath']}'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
