import 'package:sqflite/sqflite.dart';

class FeedingLog {
  int? id;
  final int petId;
  final String foodType;
  final String amount;
  final DateTime dateTime;
  String? notes;

  FeedingLog({
    this.id,
    required this.petId,
    required this.foodType,
    required this.amount,
    required this.dateTime,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'foodType': foodType,
      'amount': amount,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
    };
  }

  factory FeedingLog.fromMap(Map<String, dynamic> map) {
    return FeedingLog(
      id: map['id'],
      petId: map['petId'],
      foodType: map['foodType'],
      amount: map['amount'],
      dateTime: DateTime.parse(map['dateTime']),
      notes: map['notes'],
    );
  }
}

// Database helper methods for FeedingLog
class FeedingLogDB {
  static const String tableName = 'feeding_logs';
  
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        petId INTEGER NOT NULL,
        foodType TEXT NOT NULL,
        amount TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (petId) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');
  }
  
  static Future<int> insert(Database db, FeedingLog log) async {
    return await db.insert(tableName, log.toMap());
  }
  
  static Future<List<FeedingLog>> getLogsForPet(Database db, int petId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'petId = ?',
      whereArgs: [petId],
      orderBy: 'dateTime DESC',
    );
    
    return List.generate(maps.length, (i) {
      return FeedingLog.fromMap(maps[i]);
    });
  }
  
  static Future<int> update(Database db, FeedingLog log) async {
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
