import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pet_care/Pages/PetSummary.dart';
import 'package:pet_care/Pages/addPet.dart';
import 'package:pet_care/Pages/add_reminder_screen.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/database/database_helper.dart';
import 'package:pet_care/models/reminder.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Pet> pets = [];
  List<Reminder> todayReminders = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
    _loadReminders();
  }

  Future<void> _loadPets() async {
    try {
      final pets = await _dbHelper.getAllPets();
      if (mounted) {
        setState(() {
          this.pets = pets;
        });
      }
    } catch (e) {
      developer.log('Error loading pets: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load pets')));
      }
    }
  }

  Future<void> _loadReminders() async {
    try {
      final now = DateTime.now();
      final reminders = await _dbHelper.getRemindersForDate(now);

      if (mounted) {
        setState(() {
          todayReminders = reminders;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading reminders: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load reminders')),
        );
      }
    }
  }

  void navigateAndRefresh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPet()),
    );

    if (result == true) {
      await _loadPets();
    }
  }

  Widget buildPetIcon(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: FileImage(File(imagePath)),
      );
    }
    return const CircleAvatar(
      radius: 30,
      backgroundColor: Colors.pink,
      child: Icon(Icons.pets, color: Colors.white, size: 30),
    );
  }

  Future<void> openSummaryPage(Pet pet) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PetSummary(pet: pet),
      ),
    );
    
    // If the pet was updated, refresh the pet list
    if (result == true && mounted) {
      await _loadPets();
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  IconData _getReminderIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('feed')) return Icons.restaurant;
    if (lowerTitle.contains('bath')) return Icons.bathtub;
    if (lowerTitle.contains('vitamin') || lowerTitle.contains('medicine'))
      return Icons.medical_services;
    if (lowerTitle.contains('walk')) return Icons.directions_walk;
    if (lowerTitle.contains('vet')) return Icons.local_hospital;
    return Icons.notifications;
  }

  Color _getReminderColor(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('feed')) return Colors.orange;
    if (lowerTitle.contains('bath')) return Colors.blue;
    if (lowerTitle.contains('vitamin') || lowerTitle.contains('medicine'))
      return Colors.green;
    if (lowerTitle.contains('walk')) return Colors.purple;
    if (lowerTitle.contains('vet')) return Colors.red;
    return Colors.orange;
  }

  Future<void> _toggleReminder(Reminder reminder) async {
    try {
      final updatedReminder = Reminder(
        id: reminder.id,
        title: reminder.title,
        description: reminder.description,
        dateTime: reminder.dateTime,
        isCompleted: !reminder.isCompleted,
        petId: reminder.petId,
      );

      await _dbHelper.updateReminder(updatedReminder);
      await _loadReminders(); // Refresh the list
    } catch (e) {
      developer.log('Error toggling reminder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update reminder')),
        );
      }
    }
  }

  Future<void> _addReminder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddReminderScreen()),
    );

    if (result == true) {
      await _loadReminders();
    }
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deleteReminder(reminder.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder deleted')),
          );
          _loadReminders();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete reminder')),
          );
        }
      }
    }
  }

  Widget _buildReminderItem(Reminder reminder) {
    return Dismissible(
      key: Key('reminder_${reminder.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Reminder'),
            content: const Text('Are you sure you want to delete this reminder?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) {
        _deleteReminder(reminder);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: ListTile(
          leading: const Icon(Icons.notifications, color: Colors.blue),
          title: Text(
            reminder.title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${DateFormat('h:mm a').format(reminder.dateTime)} • ${reminder.description}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: reminder.isCompleted,
                onChanged: (bool? value) async {
                  if (value != null) {
                    final updatedReminder = reminder.copyWith(isCompleted: value);
                    await _dbHelper.updateReminder(updatedReminder);
                    _loadReminders();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () => _deleteReminder(reminder),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemindersSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Reminders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _addReminder,
                icon: const Icon(Icons.add_alert, size: 18),
                label: const Text('Add Reminder'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (todayReminders.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'No reminders for today.\nTap "Add Reminder" to create one!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Column(
            children: todayReminders
                .map((reminder) => _buildReminderItem(reminder))
                .toList(),
          ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Care App'),
        backgroundColor: Colors.pink,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Add Pet',
            onPressed: navigateAndRefresh,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reminders Section
            _buildRemindersSection(),

            // Pets Section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'My Pets',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            if (pets.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pets, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No pets added yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your first pet',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return GestureDetector(
                      onTap: () => openSummaryPage(pet),
                      child: Container(
                        width: 150,
                        margin: const EdgeInsets.only(right: 16),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildPetIcon(pet.imagePath),
                              const SizedBox(height: 8),
                              Text(
                                pet.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (pet.species != null || pet.breed != null)
                                Text(
                                  '${pet.species ?? ''}${pet.breed != null ? ' • ${pet.breed}' : ''}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Reminders Section
            if (todayReminders.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  "Today's Reminders",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...todayReminders
                  .map(
                    (reminder) => Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getReminderIcon(reminder.title),
                          color: _getReminderColor(reminder.title),
                        ),
                        title: Text(reminder.title),
                        subtitle: Text(_formatTime(reminder.dateTime)),
                        trailing: Checkbox(
                          value: reminder.isCompleted,
                          onChanged: (value) => _toggleReminder(reminder),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ],

            // Add some bottom padding
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
