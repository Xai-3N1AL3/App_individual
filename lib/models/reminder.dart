class Reminder {
  final int? id;
  final String title;
  final String description;
  final DateTime dateTime;
  final bool isCompleted;
  final int? petId; // Optional: link to a specific pet

  Reminder({
    this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
    this.petId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date_time': dateTime.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'pet_id': petId,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dateTime: DateTime.parse(map['date_time']),
      isCompleted: map['is_completed'] == 1,
      petId: map['pet_id'],
    );
  }

  Reminder copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
    int? petId,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      petId: petId ?? this.petId,
    );
  }
}
