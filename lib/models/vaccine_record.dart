import 'package:sqflite/sqflite.dart';

class VaccineRecord {
  int? id;
  final int petId;
  final String name;
  final DateTime dateAdministered;
  final DateTime? expirationDate;
  final String? vetName;
  final String? lotNumber;
  final String? notes;
  final String? location;
  final String? administeredBy;
  final String? nextDoseReminder;

  VaccineRecord({
    this.id,
    required this.petId,
    required this.name,
    required this.dateAdministered,
    this.expirationDate,
    this.vetName,
    this.lotNumber,
    this.notes,
    this.location,
    this.administeredBy,
    this.nextDoseReminder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'dateAdministered': dateAdministered.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'vetName': vetName,
      'lotNumber': lotNumber,
      'notes': notes,
      'location': location,
      'administeredBy': administeredBy,
      'nextDoseReminder': nextDoseReminder,
    };
  }

  factory VaccineRecord.fromMap(Map<String, dynamic> map) {
    return VaccineRecord(
      id: map['id'],
      petId: map['petId'],
      name: map['name'],
      dateAdministered: DateTime.parse(map['dateAdministered']),
      expirationDate: map['expirationDate'] != null 
          ? DateTime.parse(map['expirationDate']) 
          : null,
      vetName: map['vetName'],
      lotNumber: map['lotNumber'],
      notes: map['notes'],
      location: map['location'],
      administeredBy: map['administeredBy'],
      nextDoseReminder: map['nextDoseReminder'],
    );
  }
}

// Database helper methods for VaccineRecord
class VaccineRecordDB {
  static const String tableName = 'vaccine_records';
  
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        petId INTEGER NOT NULL,
        name TEXT NOT NULL,
        dateAdministered TEXT NOT NULL,
        expirationDate TEXT,
        vetName TEXT,
        lotNumber TEXT,
        notes TEXT,
        location TEXT,
        administeredBy TEXT,
        nextDoseReminder TEXT,
        FOREIGN KEY (petId) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');
  }
  
  static Future<int> insert(Database db, VaccineRecord record) async {
    return await db.insert(tableName, record.toMap());
  }
  
  static Future<List<VaccineRecord>> getVaccineRecordsForPet(
    Database db, 
    int petId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'petId = ?',
      whereArgs: [petId],
      orderBy: 'dateAdministered DESC',
    );
    
    return List.generate(maps.length, (i) => VaccineRecord.fromMap(maps[i]));
  }
  
  static Future<int> update(Database db, VaccineRecord record) async {
    return await db.update(
      tableName,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }
  
  static Future<int> delete(Database db, int id) async {
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  static Future<List<VaccineRecord>> getUpcomingVaccinations(
    Database db, {
    int daysAhead = 30,
  }) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: daysAhead));
    
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM $tableName 
      WHERE dateAdministered BETWEEN ? AND ?
      ORDER BY dateAdministered ASC
    ''', [now.toIso8601String(), endDate.toIso8601String()]);
    
    return List.generate(maps.length, (i) => VaccineRecord.fromMap(maps[i]));
  }
}
