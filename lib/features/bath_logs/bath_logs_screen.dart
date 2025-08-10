import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/models/bath_log.dart';
import 'package:pet_care/database/database_helper.dart';

class BathLogsScreen extends StatefulWidget {
  final int petId;
  final String petName;

  const BathLogsScreen({
    Key? key,
    required this.petId,
    required this.petName,
  }) : super(key: key);

  @override
  _BathLogsScreenState createState() => _BathLogsScreenState();
}

class _BathLogsScreenState extends State<BathLogsScreen> {
  late Future<List<BathLog>> _logsFuture;
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _productsUsedController = TextEditingController();
  final _groomerController = TextEditingController();
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
          BathLogDB.getLogsForPet(db, widget.petId)
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

  Future<void> _addBathLog() async {
    if (_formKey.currentState!.validate()) {
      final log = BathLog(
        petId: widget.petId,
        dateTime: _selectedDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        productsUsed: _productsUsedController.text.isNotEmpty 
            ? _productsUsedController.text 
            : null,
        groomer: _groomerController.text.isNotEmpty 
            ? _groomerController.text 
            : null,
      );

      final db = await DatabaseHelper().database;
      await BathLogDB.insert(db, log);
      
      // Reset form and reload logs
      _notesController.clear();
      _productsUsedController.clear();
      _groomerController.clear();
      _loadLogs();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bath logged successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.petName}\'s Bath Logs'),
      ),
      body: Column(
        children: [
          // Add Bath Log Form
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
                      'Log a Bath',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Date & Time'),
                      subtitle: Text(
                        DateFormat('MMM d, y hh:mm a').format(_selectedDate),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDateTime,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _productsUsedController,
                      decoration: const InputDecoration(
                        labelText: 'Products Used (optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.clean_hands),
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _groomerController,
                      decoration: const InputDecoration(
                        labelText: 'Groomer (optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _addBathLog,
                      icon: const Icon(Icons.bathtub),
                      label: const Text('Log Bath'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bath Logs List
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Bath History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<BathLog>>(
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
                  return const Center(
                    child: Text(
                    'No bath logs yet.\nTap the button above to log one!',
                    textAlign: TextAlign.center,
                  ),
                  );
                }
                
                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return Dismissible(
                      key: Key(log.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Log'),
                              content: const Text('Are you sure you want to delete this bath log?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('CANCEL'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) async {
                        final db = await DatabaseHelper().database;
                        await BathLogDB.delete(db, log.id!);
                        _loadLogs();
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.bathtub, color: Colors.blue),
                          title: Text(
                            DateFormat('MMM d, y hh:mm a').format(log.dateTime),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (log.groomer?.isNotEmpty ?? false)
                                Text('Groomer: ${log.groomer}'),
                              if (log.productsUsed?.isNotEmpty ?? false)
                                Text('Products: ${log.productsUsed}'),
                              if (log.notes?.isNotEmpty ?? false)
                                Text('Notes: ${log.notes}'),
                            ],
                          ),
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
    _notesController.dispose();
    _productsUsedController.dispose();
    _groomerController.dispose();
    super.dispose();
  }
}
