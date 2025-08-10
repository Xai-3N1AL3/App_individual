class Vaccination {
  int? id;
  final int petId;
  final String vaccineName;
  final DateTime administeredDate;
  final DateTime? expiryDate;
  final String? notes;
  final DateTime createdAt;

  Vaccination({
    this.id,
    required this.petId,
    required this.vaccineName,
    required this.administeredDate,
    this.expiryDate,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert a Vaccination into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'vaccine_name': vaccineName,
      'administered_date': administeredDate.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create a Vaccination from a Map
  factory Vaccination.fromMap(Map<String, dynamic> map) {
    return Vaccination(
      id: map['id'],
      petId: map['pet_id'],
      vaccineName: map['vaccine_name'],
      administeredDate: DateTime.parse(map['administered_date']),
      expiryDate: map['expiry_date'] != null ? DateTime.parse(map['expiry_date']) : null,
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // For debugging
  @override
  String toString() {
    return 'Vaccination{id: $id, petId: $petId, vaccineName: $vaccineName, administeredDate: $administeredDate, expiryDate: $expiryDate, notes: $notes}';
  }
}
