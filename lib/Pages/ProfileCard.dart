import 'package:flutter/material.dart';
import 'dart:io';
import 'Profiles.dart';

class Itemcard extends StatelessWidget {
  final Profile profiles;

  const Itemcard({super.key, required this.profiles});

  String calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int years = now.year - birthday.year;
    int months = now.month - birthday.month;
    if (months < 0) {
      years--;
      months += 12;
    }
    return "$years year(s), $months month(s)";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            profiles.photoPath != null && File(profiles.photoPath!).existsSync()
                ? CircleAvatar(
              radius: 30,
              backgroundImage: FileImage(File(profiles.photoPath!)),
            )
                : const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.pinkAccent,
              child: Icon(Icons.pets, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profiles.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Pet: ${profiles.pet}",
                      style: TextStyle(fontSize: 16, color: Colors.grey[800])),
                  Text("Breed: ${profiles.breed}",
                      style: TextStyle(fontSize: 16, color: Colors.grey[800])),
                  Text(
                    "Birthday: ${profiles.birthday.month}/${profiles.birthday.day}/${profiles.birthday.year}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  Text(
                    "Age: ${calculateAge(profiles.birthday)}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
