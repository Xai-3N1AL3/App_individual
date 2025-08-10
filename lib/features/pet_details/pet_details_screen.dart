import 'package:flutter/material.dart';
import 'package:pet_care/features/pet_details/widgets/health_widgets.dart';
import 'package:pet_care/features/pet_details/widgets/care_logs_widgets.dart';
import 'package:pet_care/features/pet_details/widgets/notes_widgets.dart';
import 'package:pet_care/models/pet.dart';

class PetDetails extends StatefulWidget {
  final Pet pet;
  final Function(Pet) onPetUpdated;

  const PetDetails({super.key, required this.pet, required this.onPetUpdated});

  @override
  State<PetDetails> createState() => _PetDetailsState();
}

class _PetDetailsState extends State<PetDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers
  final TextEditingController _medicationNameController =
      TextEditingController();
  final TextEditingController _medicationDoseController =
      TextEditingController();
  final TextEditingController _supplementNameController =
      TextEditingController();
  final TextEditingController _supplementDoseController =
      TextEditingController();
  final TextEditingController _supplementFreqController =
      TextEditingController();
  final TextEditingController _vaccineNameController = TextEditingController();
  final TextEditingController _healthNoteTitleController =
      TextEditingController();
  final TextEditingController _healthNoteDescController =
      TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // Form keys
  final _medicationFormKey = GlobalKey<FormState>();
  final _supplementFormKey = GlobalKey<FormState>();
  final _vaccineFormKey = GlobalKey<FormState>();
  final _healthNoteFormKey = GlobalKey<FormState>();

  // Data
  final List<Map<String, dynamic>> _medicationLogs = [];
  final List<Map<String, dynamic>> _supplements = [];
  final List<Map<String, dynamic>> _vaccineRecords = [];
  final List<Map<String, dynamic>> _healthNotes = [];
  final List<Map<String, dynamic>> _notes = [];
  final List<DateTime> _feedingLogs = [];
  final List<DateTime> _bathLogs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSampleData();
  }

  void _loadSampleData() {
    // Sample data for demonstration
    setState(() {
      _medicationLogs.addAll([
        {
          'name': 'Antibiotics',
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'dose': '1 tablet',
          'notes': 'Give with food',
        },
      ]);

      _supplements.addAll([
        {
          'name': 'Fish Oil',
          'dose': '1 tsp',
          'frequency': 'Daily',
          'lastGiven': DateTime.now().subtract(const Duration(hours: 12)),
        },
      ]);

      _vaccineRecords.addAll([
        {
          'name': 'Rabies',
          'date': '2023-01-15',
          'nextDue': '2024-01-15',
          'notes': 'Next booster due',
        },
      ]);

      _healthNotes.addAll([
        {
          'title': 'Annual Checkup',
          'description': 'Vet recommended switching to senior food next month.',
          'date': DateTime.now().subtract(const Duration(days: 5)),
        },
      ]);

      _notes.addAll([
        {
          'text': 'Pick up more flea treatment',
          'date': DateTime.now().subtract(const Duration(hours: 2)),
          'done': false,
        },
        {
          'text': 'Schedule grooming appointment',
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'done': true,
        },
      ]);

      _feedingLogs.addAll([
        DateTime.now().subtract(const Duration(hours: 1)),
        DateTime.now().subtract(const Duration(hours: 4)),
      ]);

      _bathLogs.addAll([DateTime.now().subtract(const Duration(days: 3))]);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _medicationNameController.dispose();
    _medicationDoseController.dispose();
    _supplementNameController.dispose();
    _supplementDoseController.dispose();
    _supplementFreqController.dispose();
    _vaccineNameController.dispose();
    _healthNoteTitleController.dispose();
    _healthNoteDescController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.pet.name,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                // TODO: Implement edit pet functionality
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.pink,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.pink,
            tabs: const [
              Tab(icon: Icon(Icons.favorite_border), text: 'Health'),
              Tab(icon: Icon(Icons.assignment_outlined), text: 'Care Logs'),
              Tab(icon: Icon(Icons.notes_outlined), text: 'Notes'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Health Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MedicationsSection(
                    medications: _medicationLogs,
                    onAddMedication: _showAddMedicationDialog,
                    onDeleteMedication: _deleteMedication,
                  ),
                  const Divider(height: 32),

                  SupplementsSection(
                    supplements: _supplements,
                    onAddSupplement: _showAddSupplementDialog,
                    onDeleteSupplement: _deleteSupplement,
                  ),
                  const Divider(height: 32),

                  VaccineRecordsSection(
                    vaccineRecords: _vaccineRecords,
                    onAddVaccine: _showAddVaccineDialog,
                    onDeleteVaccine: _deleteVaccine,
                  ),
                  const Divider(height: 32),

                  HealthNotesSection(
                    healthNotes: _healthNotes,
                    onAddHealthNote: _showAddHealthNoteDialog,
                    onDeleteHealthNote: _deleteHealthNote,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Care Logs Tab
            CareLogsSection(
              feedingLogs: _feedingLogs,
              bathLogs: _bathLogs,
              onLogFeeding: _logFeeding,
              onLogBath: _logBath,
            ),

            // Notes Tab
            NotesSection(
              notes: _notes,
              noteController: _noteController,
              onAddNote: _addNote,
              onDeleteNote: _deleteNote,
              onToggleNoteDone: _toggleNoteDone,
            ),
          ],
        ),
      ),
    );
  }

  // Data management methods
  void _addMedication() {
    setState(() {
      _medicationLogs.add({
        'name': _medicationNameController.text,
        'date': DateTime.now(),
        'dose': _medicationDoseController.text,
        'notes': '',
      });
    });
  }

  void _deleteMedication(int index) {
    setState(() {
      _medicationLogs.removeAt(index);
    });
  }

  void _addSupplement() {
    setState(() {
      _supplements.add({
        'name': _supplementNameController.text,
        'dose': _supplementDoseController.text,
        'frequency': _supplementFreqController.text,
        'lastGiven': DateTime.now(),
      });
    });
  }

  void _deleteSupplement(int index) {
    setState(() {
      _supplements.removeAt(index);
    });
  }

  void _addVaccine() {
    final now = DateTime.now();
    final nextYear = DateTime(now.year + 1, now.month, now.day);

    setState(() {
      _vaccineRecords.add({
        'name': _vaccineNameController.text,
        'date': _formatDate(now),
        'nextDue': _formatDate(nextYear),
        'notes': '',
      });
    });
  }

  void _deleteVaccine(int index) {
    setState(() {
      _vaccineRecords.removeAt(index);
    });
  }

  void _addHealthNote() {
    setState(() {
      _healthNotes.insert(0, {
        'title': _healthNoteTitleController.text,
        'description': _healthNoteDescController.text,
        'date': DateTime.now(),
      });
    });
  }

  void _deleteHealthNote(int index) {
    setState(() {
      _healthNotes.removeAt(index);
    });
  }

  void _addNote() {
    final text = _noteController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _notes.insert(0, {'text': text, 'date': DateTime.now(), 'done': false});
        _noteController.clear();
      });
    }
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  void _toggleNoteDone(int index) {
    setState(() {
      _notes[index]['done'] = !_notes[index]['done'];
    });
  }

  void _logFeeding() {
    setState(() {
      _feedingLogs.insert(0, DateTime.now());
    });
  }

  void _logBath() {
    setState(() {
      _bathLogs.insert(0, DateTime.now());
    });
  }

  // Dialog methods
  Future<void> _showAddMedicationDialog() async {
    _medicationNameController.clear();
    _medicationDoseController.clear();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Medication'),
        content: Form(
          key: _medicationFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _medicationNameController,
                  decoration: const InputDecoration(
                    labelText: 'Medication Name',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a name' : null,
                ),
                TextFormField(
                  controller: _medicationDoseController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage (e.g., 1 tablet)',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a dosage' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_medicationFormKey.currentState?.validate() ?? false) {
                _addMedication();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSupplementDialog() async {
    _supplementNameController.clear();
    _supplementDoseController.clear();
    _supplementFreqController.clear();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Supplement'),
        content: Form(
          key: _supplementFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _supplementNameController,
                  decoration: const InputDecoration(
                    labelText: 'Supplement Name',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a name' : null,
                ),
                TextFormField(
                  controller: _supplementDoseController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage (e.g., 1 tsp)',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a dosage' : null,
                ),
                TextFormField(
                  controller: _supplementFreqController,
                  decoration: const InputDecoration(
                    labelText: 'Frequency (e.g., Daily, 2x/day)',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter frequency' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_supplementFormKey.currentState?.validate() ?? false) {
                _addSupplement();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddVaccineDialog() async {
    _vaccineNameController.clear();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Vaccine Record'),
        content: Form(
          key: _vaccineFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _vaccineNameController,
                  decoration: const InputDecoration(labelText: 'Vaccine Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                const Text('Next due date will be set to 1 year from today.'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_vaccineFormKey.currentState?.validate() ?? false) {
                _addVaccine();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddHealthNoteDialog() async {
    _healthNoteTitleController.clear();
    _healthNoteDescController.clear();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Health Note'),
        content: Form(
          key: _healthNoteFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _healthNoteTitleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _healthNoteDescController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter a description'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_healthNoteFormKey.currentState?.validate() ?? false) {
                _addHealthNote();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
