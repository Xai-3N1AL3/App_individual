import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class Supplement {
  int? id;
  final int petId;
  final String name;
  final String dosage;
  final String frequency;
  final String? notes;
  final DateTime startDate;
  final DateTime? endDate;
  final TimeOfDay reminderTime;
  final bool isActive;

  Supplement({
    this.id,
    required this.petId,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.notes,
    required this.startDate,
    this.endDate,
    required this.reminderTime,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'notes': notes,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reminderHour': reminderTime.hour,
      'reminderMinute': reminderTime.minute,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Supplement.fromMap(Map<String, dynamic> map) {
    return Supplement(
      id: map['id'],
      petId: map['petId'],
      name: map['name'],
      dosage: map['dosage'],
      frequency: map['frequency'],
      notes: map['notes'],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      reminderTime: TimeOfDay(
        hour: map['reminderHour'],
        minute: map['reminderMinute'],
      ),
      isActive: map['isActive'] == 1,
    );
  }
}

// Database helper methods for Supplement
class SupplementDB {
  static const String tableName = 'supplements';

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        petId INTEGER NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        frequency TEXT NOT NULL,
        notes TEXT,
        startDate TEXT NOT NULL,
        endDate TEXT,
        reminderHour INTEGER NOT NULL,
        reminderMinute INTEGER NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (petId) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<int> insert(Database db, Supplement supplement) async {
    return await db.insert(tableName, supplement.toMap());
  }

  static Future<List<Supplement>> getSupplementsForPet(
    Database db,
    int petId, {
    bool activeOnly = true,
  }) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'petId = ? ${activeOnly ? 'AND isActive = 1' : ''}',
      whereArgs: [petId],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => Supplement.fromMap(maps[i]));
  }

  static Future<int> update(Database db, Supplement supplement) async {
    return await db.update(
      tableName,
      supplement.toMap(),
      where: 'id = ?',
      whereArgs: [supplement.id],
    );
  }

  static Future<int> delete(Database db, int id) async {
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> toggleActive(Database db, int id, bool isActive) async {
    return await db.update(
      tableName,
      {'isActive': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
