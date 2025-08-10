import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/vaccine_record.dart';
import '../../database/database_helper.dart';

class VaccineRecordsScreen extends StatefulWidget {
  final int petId;
  final String petName;

  const VaccineRecordsScreen({
    Key? key,
    required this.petId,
    required this.petName,
  }) : super(key: key);

  @override
  _VaccineRecordsScreenState createState() => _VaccineRecordsScreenState();
}

class _VaccineRecordsScreenState extends State<VaccineRecordsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<VaccineRecord> _vaccineRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVaccineRecords();
  }

  Future<void> _loadVaccineRecords() async {
    try {
      final db = await _dbHelper.database;
      final records = await VaccineRecordDB.getVaccineRecordsForPet(db, widget.petId);
      if (mounted) {
        setState(() {
          _vaccineRecords = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load vaccine records')),
        );
      }
    }
  }

  Future<void> _addVaccineRecord() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddVaccineRecordDialog(petId: widget.petId),
    );

    if (result == true && mounted) {
      await _loadVaccineRecords();
    }
  }

  Future<void> _deleteVaccineRecord(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this vaccine record?'),
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

    if (confirmed == true && mounted) {
      try {
        final db = await _dbHelper.database;
        await VaccineRecordDB.delete(db, id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vaccine record deleted')),
          );
          await _loadVaccineRecords();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete vaccine record')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.petName}\'s Vaccine Records'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vaccineRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.medication, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No vaccine records yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _addVaccineRecord,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Vaccine Record'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _vaccineRecords.length,
                  itemBuilder: (context, index) {
                    final record = _vaccineRecords[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          record.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Date: ${DateFormat('MMM d, y').format(record.dateAdministered)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (record.expirationDate != null)
                              Text(
                                'Expires: ${DateFormat('MMM d, y').format(record.expirationDate!)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            if (record.notes?.isNotEmpty ?? false) ...{
                              const SizedBox(height: 8),
                              Text(
                                'Notes: ${record.notes}',
                                style: const TextStyle(fontStyle: FontStyle.italic),
                              ),
                            },
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteVaccineRecord(record.id!), 
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addVaccineRecord,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddVaccineRecordDialog extends StatefulWidget {
  final int petId;
  
  const AddVaccineRecordDialog({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  _AddVaccineRecordDialogState createState() => _AddVaccineRecordDialogState();
}

class _AddVaccineRecordDialogState extends State<AddVaccineRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _vaccineNameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _dateAdministered = DateTime.now();
  DateTime? _nextDueDate;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, {bool isNextDue = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isNextDue ? _nextDueDate ?? _dateAdministered : _dateAdministered,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        if (isNextDue) {
          _nextDueDate = picked;
        } else {
          _dateAdministered = picked;
          // If next due date is before the new administered date, clear it
          if (_nextDueDate != null && _nextDueDate!.isBefore(picked)) {
            _nextDueDate = null;
          }
        }
      });
    }
  }

  Future<void> _saveVaccineRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final record = VaccineRecord(
        petId: widget.petId,
        name: _vaccineNameController.text,
        dateAdministered: _dateAdministered,
        expirationDate: _nextDueDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      final db = await _dbHelper.database;
      await VaccineRecordDB.insert(db, record);
      
      if (mounted) {
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save vaccine record')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Vaccine Record'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _vaccineNameController,
                decoration: const InputDecoration(
                  labelText: 'Vaccine Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a vaccine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date Administered *'),
                subtitle: Text(DateFormat('MMM d, y').format(_dateAdministered)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, isNextDue: false),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Next Due Date (Optional)'),
                subtitle: Text(_nextDueDate != null
                    ? DateFormat('MMM d, y').format(_nextDueDate!)
                    : 'Not set'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, isNextDue: true),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveVaccineRecord,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
