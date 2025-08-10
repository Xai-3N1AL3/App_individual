import 'package:sqflite/sqflite.dart';

class BathLog {
  int? id;
  final int petId;
  final DateTime dateTime;
  final String? notes;
  final String? productsUsed;
  final String? groomer;

  BathLog({
    this.id,
    required this.petId,
    required this.dateTime,
    this.notes,
    this.productsUsed,
    this.groomer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
      'productsUsed': productsUsed,
      'groomer': groomer,
    };
  }

  factory BathLog.fromMap(Map<String, dynamic> map) {
    return BathLog(
      id: map['id'],
      petId: map['petId'],
      dateTime: DateTime.parse(map['dateTime']),
      notes: map['notes'],
      productsUsed: map['productsUsed'],
      groomer: map['groomer'],
    );
  }
}

// Database helper methods for BathLog
class BathLogDB {
  static const String tableName = 'bath_logs';
  
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        petId INTEGER NOT NULL,
        dateTime TEXT NOT NULL,
        notes TEXT,
        productsUsed TEXT,
        groomer TEXT,
        FOREIGN KEY (petId) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');
  }
  
  static Future<int> insert(Database db, BathLog log) async {
    return await db.insert(tableName, log.toMap());
  }
  
  static Future<List<BathLog>> getLogsForPet(Database db, int petId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'petId = ?',
      whereArgs: [petId],
      orderBy: 'dateTime DESC',
    );
    
    return List.generate(maps.length, (i) => BathLog.fromMap(maps[i]));
  }
  
  static Future<int> update(Database db, BathLog log) async {
    return await db.update(
      tableName,
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }
  
  static Future<int> delete(Database db, int id) async {
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
