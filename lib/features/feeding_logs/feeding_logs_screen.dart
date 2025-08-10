import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/models/feeding_log.dart';
import 'package:pet_care/database/database_helper.dart';

class FeedingLogsScreen extends StatefulWidget {
  final int petId;
  final String petName;

  const FeedingLogsScreen({
    Key? key,
    required this.petId,
    required this.petName,
  }) : super(key: key);

  @override
  _FeedingLogsScreenState createState() => _FeedingLogsScreenState();
}

class _FeedingLogsScreenState extends State<FeedingLogsScreen> {
  late Future<List<FeedingLog>> _logsFuture;
  final _formKey = GlobalKey<FormState>();
  final _foodTypeController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() {
    setState(() {
      _logsFuture = DatabaseHelper().database.then((db) => 
          FeedingLogDB.getLogsForPet(db, widget.petId)
      );
    });
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );
      
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year, date.month, date.day,
            time.hour, time.minute,
          );
          _selectedTime = time;
        });
      }
    }
  }

  Future<void> _addFeedingLog() async {
    if (_formKey.currentState!.validate()) {
      final log = FeedingLog(
        petId: widget.petId,
        foodType: _foodTypeController.text,
        amount: _amountController.text,
        dateTime: _selectedDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      final db = await DatabaseHelper().database;
      await FeedingLogDB.insert(db, log);
      
      // Reset form and reload logs
      _foodTypeController.clear();
      _amountController.clear();
      _notesController.clear();
      _loadLogs();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feeding logged successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.petName}\'s Feeding Logs'),
      ),
      body: Column(
        children: [
          // Add Feeding Log Form
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
                      'Log a Feeding',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _foodTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Food Type',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the food type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount (e.g., 1 cup, 200g)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: const Text('Date & Time'),
                      subtitle: Text(
                        DateFormat('MMM d, y hh:mm a').format(_selectedDate),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDateTime,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addFeedingLog,
                      child: const Text('Log Feeding'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Feeding Logs List
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Feeding History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<FeedingLog>>(
              future: _logsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final logs = snapshot.data ?? [];
                
                if (logs.isEmpty) {
                  return const Center(child: Text('No feeding logs yet.'));
                }
                
                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        title: Text(log.foodType),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Amount: ${log.amount}'),
                            if (log.notes?.isNotEmpty ?? false)
                              Text('Notes: ${log.notes}'),
                            Text(
                              DateFormat('MMM d, y hh:mm a').format(log.dateTime),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            // Add delete functionality
                            final db = await DatabaseHelper().database;
                            await FeedingLogDB.delete(db, log.id!);
                            _loadLogs();
                          },
                        ),
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
    _foodTypeController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
