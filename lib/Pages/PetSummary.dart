import 'package:flutter/material.dart';
import 'dart:io';
import '../models/pet.dart';
import '../features/feeding_logs/feeding_logs_screen.dart';
import '../features/bath_logs/bath_logs_screen.dart';
import '../features/supplements/supplements_screen.dart';
import 'EditProfileScreen.dart';
import '../features/vaccine_records/vaccine_records_screen.dart';

class PetSummary extends StatelessWidget {
  final Pet pet;

  const PetSummary({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage =
        pet.imagePath != null &&
        pet.imagePath!.isNotEmpty &&
        File(pet.imagePath!).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text('${pet.name}\'s Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(pet: pet),
                ),
              );
              
              // If the profile was updated, pop with true to refresh the parent
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Profile Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Pet Image and Basic Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pet Image
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: hasImage
                              ? FileImage(File(pet.imagePath!))
                              : null,
                          child: !hasImage
                              ? const Icon(
                                  Icons.pets,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        // Pet Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet.name,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (pet.species != null || pet.breed != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${pet.species ?? ''}${pet.breed != null ? ' • ${pet.breed}' : ''}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                              if (pet.birthDate != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '🎂 ${pet.birthDate}',
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Additional Pet Information
                    if (pet.species != null ||
                        pet.breed != null ||
                        pet.birthDate != null) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Pet Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (pet.species != null)
                        _buildInfoRow('Species', pet.species!),
                      if (pet.breed != null) _buildInfoRow('Breed', pet.breed!),
                      if (pet.birthDate != null)
                        _buildInfoRow('Birth Date', pet.birthDate!),
                    ],
                    const SizedBox(height: 8),
                    // Pet Care Features
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Pet Care Features',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureButton(
                      context,
                      'Feeding Logs',
                      Icons.restaurant,
                      Colors.orange,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FeedingLogsScreen(
                              petId: pet.id!,
                              petName: pet.name,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildFeatureButton(
                      context,
                      'Bath Logs',
                      Icons.bathtub,
                      Colors.blue,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BathLogsScreen(
                              petId: pet.id!,
                              petName: pet.name,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildFeatureButton(
                      context,
                      'Supplements',
                      Icons.medication,
                      Colors.green,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SupplementsScreen(
                              petId: pet.id!,
                              petName: pet.name,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildFeatureButton(
                      context,
                      'Vaccine Records',
                      Icons.medication_liquid,
                      Colors.deepPurple,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VaccineRecordsScreen(
                              petId: pet.id!,
                              petName: pet.name,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// VaccineRecordsScreen has been moved to features/vaccine_records/vaccine_records_screen.dart
