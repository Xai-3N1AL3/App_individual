import 'package:flutter/material.dart';
import 'Profiles.dart';
import 'dart:io';

class ProfileSummary extends StatelessWidget {
  final List<Profile> profiles;

  const ProfileSummary({super.key, required this.profiles});

  int _countToday(List<DateTime> logs) {
    final now = DateTime.now();
    return logs.where((log) =>
    log.year == now.year &&
        log.month == now.month &&
        log.day == now.day
    ).length;
  }

  int _countThisMonth(List<DateTime> logs) {
    final now = DateTime.now();
    return logs.where((log) =>
    log.year == now.year &&
        log.month == now.month
    ).length;
  }

  Widget _buildSummaryCard(Profile profile) {
    final hasImage = profile.photoPath != null &&
        profile.photoPath!.isNotEmpty &&
        File(profile.photoPath!).existsSync();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.pinkAccent,
                  backgroundImage: hasImage ? FileImage(File(profile.photoPath!)) : null,
                  child: !hasImage
                      ? const Icon(Icons.pets, size: 30, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text("Today:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("- Feedings: ${_countToday(profile.feedingLogs)}"),
            Text("- Baths: ${_countToday(profile.bathLogs)}"),
            Text("- Vitamins: ${_countToday(profile.vitaminLogs)}"),
            const SizedBox(height: 12),
            const Text("This Month:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("- Feedings: ${_countThisMonth(profile.feedingLogs)}"),
            Text("- Baths: ${_countThisMonth(profile.bathLogs)}"),
            Text("- Vitamins: ${_countThisMonth(profile.vitaminLogs)}"),
            Text("- Vaccines: ${profile.vaccineRecords.length}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pet Summary"),
        backgroundColor: Colors.pinkAccent,
      ),
      backgroundColor: Colors.pink[50],
      body: ListView(
        children: profiles.map(_buildSummaryCard).toList(),
      ),
    );
  }
}
