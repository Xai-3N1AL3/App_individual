import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/models/supplement.dart';
import 'package:pet_care/database/database_helper.dart';

class SupplementsScreen extends StatefulWidget {
  final int petId;
  final String petName;

  const SupplementsScreen({
    Key? key,
    required this.petId,
    required this.petName,
  }) : super(key: key);

  @override
  _SupplementsScreenState createState() => _SupplementsScreenState();
}

class _SupplementsScreenState extends State<SupplementsScreen> {
  late Future<List<Supplement>> _supplementsFuture;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  TimeOfDay _reminderTime = TimeOfDay.now();
  bool _isActive = true;
  bool _hasEndDate = false;

  @override
  void initState() {
    super.initState();
    _loadSupplements();
  }

  void _loadSupplements() {
    setState(() {
      _supplementsFuture = DatabaseHelper().database.then(
        (db) => SupplementDB.getSupplementsForPet(
          db,
          widget.petId,
          activeOnly: false,
        ),
      );
    });
  }

  Future<void> _selectDate(
    BuildContext context, {
    bool isStartDate = true,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  Future<void> _addSupplement() async {
    if (_formKey.currentState!.validate()) {
      final supplement = Supplement(
        petId: widget.petId,
        name: _nameController.text,
        dosage: _dosageController.text,
        frequency: _frequencyController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        startDate: _startDate,
        endDate: _hasEndDate ? _endDate : null,
        reminderTime: _reminderTime,
        isActive: _isActive,
      );

      final db = await DatabaseHelper().database;
      await SupplementDB.insert(db, supplement);

      // Reset form and reload supplements
      _resetForm();
      _loadSupplements();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supplement added successfully')),
        );
      }
    }
  }

  void _resetForm() {
    _nameController.clear();
    _dosageController.clear();
    _frequencyController.clear();
    _notesController.clear();
    _startDate = DateTime.now();
    _endDate = null;
    _hasEndDate = false;
    _reminderTime = TimeOfDay.now();
    _isActive = true;
  }

  Future<void> _toggleSupplementStatus(Supplement supplement) async {
    final db = await DatabaseHelper().database;
    await SupplementDB.toggleActive(db, supplement.id!, !supplement.isActive);
    _loadSupplements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.petName}\'s Supplements')),
      body: Column(
        children: [
          // Add Supplement Form
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Add New Supplement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Supplement Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medication),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a supplement name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _dosageController,
                            decoration: const InputDecoration(
                              labelText: 'Dosage *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.scale),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _frequencyController,
                            decoration: const InputDecoration(
                              labelText: 'Frequency *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.update),
                              hintText: 'e.g., 2 times daily',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: const Text('Start Date'),
                      subtitle: Text(DateFormat('MMM d, y').format(_startDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, isStartDate: true),
                    ),
                    SwitchListTile(
                      title: const Text('Set End Date'),
                      value: _hasEndDate,
                      onChanged: (value) {
                        setState(() {
                          _hasEndDate = value;
                          if (!_hasEndDate) _endDate = null;
                        });
                      },
                    ),
                    if (_hasEndDate)
                      ListTile(
                        title: const Text('End Date'),
                        subtitle: Text(
                          _endDate != null
                              ? DateFormat('MMM d, y').format(_endDate!)
                              : 'Select end date',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, isStartDate: false),
                      ),
                    ListTile(
                      title: const Text('Reminder Time'),
                      subtitle: Text(_reminderTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectTime(context),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Active'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _addSupplement,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add Supplement'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Supplements List
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Current Supplements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Supplement>>(
              future: _supplementsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final supplements = snapshot.data ?? [];

                if (supplements.isEmpty) {
                  return const Center(
                    child: Text(
                      'No supplements added yet.\nAdd one using the form above!',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: supplements.length,
                  itemBuilder: (context, index) {
                    final supplement = supplements[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      color: supplement.isActive ? null : Colors.grey[200],
                      child: ListTile(
                        leading: Icon(
                          Icons.medication,
                          color: supplement.isActive
                              ? Colors.green
                              : Colors.grey,
                        ),
                        title: Text(
                          supplement.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            decoration: supplement.isActive
                                ? null
                                : TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dosage: ${supplement.dosage}'),
                            Text('Frequency: ${supplement.frequency}'),
                            if (supplement.notes?.isNotEmpty ?? false)
                              Text('Notes: ${supplement.notes}'),
                            Text(
                              'Start: ${DateFormat('MMM d, y').format(supplement.startDate)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (supplement.endDate != null)
                              Text(
                                'End: ${DateFormat('MMM d, y').format(supplement.endDate!)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            Text(
                              'Reminder: ${supplement.reminderTime.format(context)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            supplement.isActive
                                ? Icons.toggle_on
                                : Icons.toggle_off,
                            color: supplement.isActive
                                ? Colors.green
                                : Colors.grey,
                            size: 30,
                          ),
                          onPressed: () => _toggleSupplementStatus(supplement),
                        ),
                        onTap: () {
                          // TODO: Implement edit functionality
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class Supplements {}
