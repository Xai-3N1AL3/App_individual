import 'package:flutter/material.dart';
import 'dart:io';
import 'Profiles.dart';

class PetDetails extends StatefulWidget {
  final Profile profile;

  const PetDetails({super.key, required this.profile});

  @override
  State<PetDetails> createState() => _PetDetailsState();
}

class _PetDetailsState extends State<PetDetails> {
  final TextEditingController _vaccineController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String formatTime(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

  String formatFullDateTime(DateTime dt) =>
      "${dt.month}/${dt.day}/${dt.year} at ${formatTime(dt)}";

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

  void _logActivity(List<DateTime> logList, String label) {
    setState(() => logList.insert(0, DateTime.now()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label logged at ${formatTime(DateTime.now())}')),
    );
  }

  void _addVaccine() {
    final name = _vaccineController.text.trim();
    if (name.isNotEmpty) {
      final now = DateTime.now();
      setState(() {
        widget.profile.vaccineRecords.insert(0, "$name - ${formatFullDateTime(now)}");
        _vaccineController.clear();
      });
    }
  }

  void _addNote() {
    final text = _noteController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        widget.profile.notes.insert(0, {'text': text, 'done': false});
        _noteController.clear();
      });
    }
  }

  void _toggleNoteDone(int index) {
    setState(() {
      widget.profile.notes[index]['done'] = !(widget.profile.notes[index]['done'] as bool);
    });
  }

  void _deleteNote(int index) {
    setState(() {
      widget.profile.notes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final hasImage = profile.photoPath != null &&
        profile.photoPath!.isNotEmpty &&
        File(profile.photoPath!).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text("${profile.name}'s Profile"),
        backgroundColor: Colors.pink[200],
      ),
      backgroundColor: Colors.pink[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.pinkAccent,
              backgroundImage: hasImage ? FileImage(File(profile.photoPath!)) : null,
              child: !hasImage
                  ? const Icon(Icons.pets, size: 50, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(profile.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Type: ${profile.pet}"),
            Text("Breed: ${profile.breed}"),
            Text("Birthday: ${profile.birthday.month}/${profile.birthday.day}/${profile.birthday.year}"),
            Text("Age: ${calculateAge(profile.birthday)}"),
            const SizedBox(height: 20),
            const Divider(),

            const Text("Log Activities",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _logActivity(profile.bathLogs, "Bath"),
                  icon: const Icon(Icons.shower),
                  label: const Text("Bath", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[200]),
                ),
                ElevatedButton.icon(
                  onPressed: () => _logActivity(profile.feedingLogs, "Feeding"),
                  icon: const Icon(Icons.restaurant),
                  label: const Text("Feeding", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[200]),
                ),
                ElevatedButton.icon(
                  onPressed: () => _logActivity(profile.vitaminLogs, "Vitamin"),
                  icon: const Icon(Icons.local_hospital),
                  label: const Text("Vitamin", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[200]),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text("Vaccine Records",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _vaccineController,
              decoration: InputDecoration(
                labelText: "Vaccine Name",
                suffixIcon: IconButton(
                    icon: const Icon(Icons.add), onPressed: _addVaccine),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),

            _buildLogSection("Bath Logs", profile.bathLogs),
            _buildLogSection("Feeding Logs", profile.feedingLogs),
            _buildLogSection("Vitamin Logs", profile.vitaminLogs),
            _buildVaccineSection(profile.vaccineRecords),
            const SizedBox(height: 20),
            const Divider(),
            const Text("Notes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: "Add Note",
                suffixIcon: IconButton(
                    icon: const Icon(Icons.note_add), onPressed: _addNote),
              ),
            ),
            const SizedBox(height: 8),
            _buildNotesList(profile.notes),
          ],
        ),
      ),
    );
  }

  Widget _buildLogSection(String title, List<DateTime> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: logs.isEmpty
              ? const Text("No records yet.")
              : Column(
            children: logs.asMap().entries.map((entry) {
              int index = entry.key;
              DateTime log = entry.value;
              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  setState(() {
                    logs.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$title log deleted")),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  title: Text("- ${formatFullDateTime(log)}"),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVaccineSection(List<String> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Vaccines",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: records.isEmpty
              ? const Text("No vaccine records yet.")
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: records.map((entry) => Text("- $entry")).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNotesList(List<Map<String, dynamic>> notes) {
    return Column(
      children: notes.asMap().entries.map((entry) {
        final index = entry.key;
        final note = entry.value;
        final isDone = note['done'] as bool;

        return ListTile(
          title: Text(
            note['text'],
            style: TextStyle(
              decoration: isDone ? TextDecoration.lineThrough : null,
              color: isDone ? Colors.grey : Colors.black,
            ),
          ),
          leading: Checkbox(
            value: isDone,
            onChanged: (_) => _toggleNoteDone(index),
            activeColor: Colors.pink,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteNote(index),
          ),
        );
      }).toList(),
    );
  }
}
