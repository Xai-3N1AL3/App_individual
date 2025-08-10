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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 8,
        shadowColor: Colors.pinkAccent.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profiles.photoPath != null &&
                      File(profiles.photoPath!).existsSync()
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
                    Text(
                      "Pet: ${profiles.pet}",
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
                    Text(
                      "Breed: ${profiles.breed}",
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
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
      ),
    );
  }
}
