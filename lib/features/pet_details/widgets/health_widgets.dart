import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedicationsSection extends StatelessWidget {
  final List<Map<String, dynamic>> medications;
  final VoidCallback onAddMedication;
  final Function(int) onDeleteMedication;

  const MedicationsSection({
    super.key,
    required this.medications,
    required this.onAddMedication,
    required this.onDeleteMedication,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title: 'Medications', onAdd: onAddMedication),
        if (medications.isEmpty)
          _buildEmptyState('No medications recorded', Icons.medication_outlined)
        else
          ...List.generate(medications.length, (index) {
            final med = medications[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.medication_outlined,
                  color: Colors.blue,
                ),
                title: Text(med['name']),
                subtitle: Text(
                  '${med['dose']} • ${_formatDateTime(med['date'])}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => onDeleteMedication(index),
                ),
              ),
            );
          }),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('MMM d, y h:mm a').format(date);
  }
}

class SupplementsSection extends StatelessWidget {
  final List<Map<String, dynamic>> supplements;
  final VoidCallback onAddSupplement;
  final Function(int) onDeleteSupplement;

  const SupplementsSection({
    super.key,
    required this.supplements,
    required this.onAddSupplement,
    required this.onDeleteSupplement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title: 'Supplements', onAdd: onAddSupplement),
        if (supplements.isEmpty)
          _buildEmptyState('No supplements recorded', Icons.medication_outlined)
        else
          ...List.generate(supplements.length, (index) {
            final supp = supplements[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.medication_outlined, color: Colors.green),
                title: Text(supp['name']),
                subtitle: Text(
                  '${supp['dose']} • ${supp['frequency']}\nLast given: ${_formatTimeAgo(supp['lastGiven'])}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => onDeleteSupplement(index),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class VaccineRecordsSection extends StatelessWidget {
  final List<Map<String, dynamic>> vaccineRecords;
  final VoidCallback onAddVaccine;
  final Function(int) onDeleteVaccine;

  const VaccineRecordsSection({
    super.key,
    required this.vaccineRecords,
    required this.onAddVaccine,
    required this.onDeleteVaccine,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title: 'Vaccine Records', onAdd: onAddVaccine),
        if (vaccineRecords.isEmpty)
          _buildEmptyState(
            'No vaccine records',
            Icons.medical_information_outlined,
          )
        else
          ...List.generate(vaccineRecords.length, (index) {
            final vax = vaccineRecords[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.medical_information_outlined,
                  color: Colors.purple,
                ),
                title: Text(vax['name']),
                subtitle: Text('Next due: ${vax['nextDue']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => onDeleteVaccine(index),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class HealthNotesSection extends StatelessWidget {
  final List<Map<String, dynamic>> healthNotes;
  final VoidCallback onAddHealthNote;
  final Function(int) onDeleteHealthNote;

  const HealthNotesSection({
    super.key,
    required this.healthNotes,
    required this.onAddHealthNote,
    required this.onDeleteHealthNote,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title: 'Health Notes', onAdd: onAddHealthNote),
        if (healthNotes.isEmpty)
          _buildEmptyState('No health notes', Icons.notes_outlined)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: healthNotes.length,
            itemBuilder: (context, index) {
              final note = healthNotes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ExpansionTile(
                  leading: const Icon(
                    Icons.medical_services,
                    color: Colors.red,
                  ),
                  title: Text(
                    note['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _formatTimeAgo(note['date']),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 16, 16),
                      child: Text(note['description']),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

// Helper widgets and functions
Widget _buildSectionHeader({
  required String title,
  required VoidCallback onAdd,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: onAdd,
          color: Colors.blue,
        ),
      ],
    ),
  );
}

Widget _buildEmptyState(String message, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
      ],
    ),
  );
}

String _formatTimeAgo(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return 'Just now';
  }
}
