class Pet {
  int? id;
  final String name;
  final String? species;
  final String? breed;
  final String? birthDate;
  final String? imagePath;
  final DateTime createdAt;

  Pet({
    this.id,
    required this.name,
    this.species,
    this.breed,
    this.birthDate,
    this.imagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert a Pet into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'birth_date': birthDate,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create a Pet from a Map
  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'],
      name: map['name'],
      species: map['species'],
      breed: map['breed'],
      birthDate: map['birth_date'],
      imagePath: map['image_path'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // For debugging
  @override
  String toString() {
    return 'Pet{id: $id, name: $name, species: $species, breed: $breed, birthDate: $birthDate, imagePath: $imagePath}';
  }
}
