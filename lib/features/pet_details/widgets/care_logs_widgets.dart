import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CareLogsSection extends StatelessWidget {
  final List<DateTime> feedingLogs;
  final List<DateTime> bathLogs;
  final VoidCallback onLogFeeding;
  final VoidCallback onLogBath;

  const CareLogsSection({
    super.key,
    required this.feedingLogs,
    required this.bathLogs,
    required this.onLogFeeding,
    required this.onLogBath,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFeedingLogsSection(),
          const SizedBox(height: 24),
          _buildBathLogsSection(),
        ],
      ),
    );
  }

  Widget _buildFeedingLogsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Feeding Logs',
          onAdd: onLogFeeding,
        ),
        if (feedingLogs.isEmpty)
          _buildEmptyState('No feeding logs', Icons.restaurant_outlined)
        else
          ...List.generate(
            feedingLogs.length,
            (index) => _buildLogItem(
              icon: Icons.restaurant_outlined,
              title: 'Meal',
              date: feedingLogs[index],
              color: Colors.brown,
            ),
          ),
      ],
    );
  }

  Widget _buildBathLogsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Bath Logs',
          onAdd: onLogBath,
        ),
        if (bathLogs.isEmpty)
          _buildEmptyState('No bath logs', Icons.shower_outlined)
        else
          ...List.generate(
            bathLogs.length,
            (index) => _buildLogItem(
              icon: Icons.shower_outlined,
              title: 'Bath',
              date: bathLogs[index],
              color: Colors.blue,
            ),
          ),
      ],
    );
  }

  Widget _buildLogItem({
    required IconData icon,
    required String title,
    required DateTime date,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(
          '${_formatDate(date)} • ${_formatTimeAgo(date)}',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
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
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y h:mm a').format(date);
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
