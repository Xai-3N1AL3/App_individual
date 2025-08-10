import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/database/database_helper.dart';
import 'package:pet_care/models/reminder.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({Key? key}) : super(key: key);

  @override
  _AddReminderScreenState createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int? _selectedPetId;
  List<Map<String, dynamic>> _pets = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final pets = await _dbHelper.getAllPets();
    setState(() {
      _pets = pets.map((pet) => {'id': pet.id, 'name': pet.name}).toList();
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final reminder = Reminder(
        title: _titleController.text,
        description: _descriptionController.text,
        dateTime: _selectedDate,
        petId: _selectedPetId,
      );

      try {
        await _dbHelper.insertReminder(reminder);
        if (mounted) {
          Navigator.pop(context, true); // Return success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save reminder')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reminder'),
        actions: [
          TextButton(
            onPressed: _saveReminder,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Date'),
                      subtitle: Text(
                        DateFormat('MMM d, y').format(_selectedDate),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
                    ),
                    ListTile(
                      title: const Text('Time'),
                      subtitle: Text(
                        DateFormat('h:mm a').format(
                          DateTime(
                            2023,
                            1,
                            1,
                            _selectedTime.hour,
                            _selectedTime.minute,
                          ),
                        ),
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectTime(context),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pet (optional)',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    DropdownButtonFormField<int>(
                      value: _selectedPetId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      hint: const Text('Select a pet'),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('No pet selected'),
                        ),
                        ..._pets.map((pet) {
                          return DropdownMenuItem<int>(
                            value: pet['id'],
                            child: Text(pet['name']),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedPetId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveReminder,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Reminder'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
