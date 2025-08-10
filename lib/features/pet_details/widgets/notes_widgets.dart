import 'package:flutter/material.dart';

class NotesSection extends StatelessWidget {
  final List<Map<String, dynamic>> notes;
  final TextEditingController noteController;
  final VoidCallback onAddNote;
  final Function(int) onDeleteNote;
  final Function(int) onToggleNoteDone;

  const NotesSection({
    super.key,
    required this.notes,
    required this.noteController,
    required this.onAddNote,
    required this.onDeleteNote,
    required this.onToggleNoteDone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAddNoteField(),
        const SizedBox(height: 16),
        _buildNotesList(),
      ],
    );
  }

  Widget _buildAddNoteField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'Add a note...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 1,
              onSubmitted: (_) => onAddNote(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: onAddNote,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    if (notes.isEmpty) {
      return _buildEmptyState('No notes yet', Icons.notes_outlined);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Dismissible(
          key: Key('note_${note['date']}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => onDeleteNote(index),
          child: _buildNoteItem(note, index),
        );
      },
    );
  }

  Widget _buildNoteItem(Map<String, dynamic> note, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: CheckboxListTile(
        value: note['done'] ?? false,
        onChanged: (_) => onToggleNoteDone(index),
        title: Text(
          note['text'],
          style: TextStyle(
            decoration: note['done'] ? TextDecoration.lineThrough : null,
            color: note['done'] ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          _formatTimeAgo(note['date']),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        secondary: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.grey),
          onPressed: () => onDeleteNote(index),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
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
}
