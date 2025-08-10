class Appointment {
  int? id;
  final int petId;
  final DateTime dateTime;
  final String? vetName;
  final String? notes;
  final DateTime createdAt;

  Appointment({
    this.id,
    required this.petId,
    required this.dateTime,
    this.vetName,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert an Appointment into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'date_time': dateTime.toIso8601String(),
      'vet_name': vetName,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create an Appointment from a Map
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      petId: map['pet_id'],
      dateTime: DateTime.parse(map['date_time']),
      vetName: map['vet_name'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // For debugging
  @override
  String toString() {
    return 'Appointment{id: $id, petId: $petId, dateTime: $dateTime, vetName: $vetName, notes: $notes}';
  }
}
