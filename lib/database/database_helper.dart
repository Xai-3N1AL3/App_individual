import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'dart:async';
import 'dart:developer' as developer;
import '../models/pet.dart';
import '../models/appointment.dart';
import '../models/vaccination.dart';
import '../models/reminder.dart';
import '../models/feeding_log.dart';
import '../models/bath_log.dart';
import '../models/supplement.dart';
import '../models/vaccine_record.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static sql.Database? _database;

  // Database info
  static const String _databaseName = 'pet_care.db';
  static const int _databaseVersion = 5; // Incremented version for new vaccine_records table

  // Table names
  static const String tablePets = 'pets';
  static const String tableAppointments = 'appointments';
  static const String tableVaccinations = 'vaccinations';
  static const String tableReminders = 'reminders';

  // Common column names
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnCreatedAt = 'created_at';

  // Pets table column names
  static const String columnSpecies = 'species';
  static const String columnBreed = 'breed';
  static const String columnBirthDate = 'birth_date';
  static const String columnImagePath = 'image_path';

  // Appointments table column names
  static const String columnPetId = 'pet_id';
  static const String columnDateTime = 'date_time';
  static const String columnVetName = 'vet_name';
  static const String columnNotes = 'notes';

  // Vaccinations table column names
  static const String columnVaccineName = 'vaccine_name';
  static const String columnAdministeredDate = 'administered_date';
  static const String columnExpiryDate = 'expiry_date';

  // Reminders table column names
  static const String columnTitle = 'title';
  static const String columnDescription = 'description';
  static const String columnIsCompleted = 'is_completed';

  // Get the database, create it if it doesn't exist
  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Add this method to handle database upgrades
  static void _onUpgrade(sql.Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await FeedingLogDB.createTable(db);
    }
    if (oldVersion < 3) {
      await BathLogDB.createTable(db);
    }
    if (oldVersion < 4) {
      await SupplementDB.createTable(db);
    }
    if (oldVersion < 5) {
      await VaccineRecordDB.createTable(db);
    }
  }

  // Initialize the database
  Future<sql.Database> _initDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, _databaseName),
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: _onUpgrade,
      version: _databaseVersion,
    );
    return db;
  }

  // Create the database tables
  Future<void> _createTables(sql.Database db) async {
    await db.execute('''
      CREATE TABLE $tablePets (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnSpecies TEXT,
        $columnBreed TEXT,
        $columnBirthDate TEXT,
        $columnImagePath TEXT,
        $columnCreatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAppointments (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnPetId INTEGER NOT NULL,
        $columnDateTime TEXT NOT NULL,
        $columnVetName TEXT,
        $columnNotes TEXT,
        $columnCreatedAt TEXT NOT NULL,
        FOREIGN KEY ($columnPetId) REFERENCES $tablePets ($columnId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableVaccinations (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnPetId INTEGER NOT NULL,
        $columnVaccineName TEXT NOT NULL,
        $columnAdministeredDate TEXT NOT NULL,
        $columnExpiryDate TEXT NOT NULL,
        $columnNotes TEXT,
        $columnCreatedAt TEXT NOT NULL,
        FOREIGN KEY ($columnPetId) REFERENCES $tablePets ($columnId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableReminders (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnDescription TEXT,
        $columnDateTime TEXT NOT NULL,
        $columnIsCompleted INTEGER NOT NULL DEFAULT 0,
        $columnPetId INTEGER,
        $columnCreatedAt TEXT NOT NULL,
        FOREIGN KEY ($columnPetId) REFERENCES $tablePets ($columnId) ON DELETE SET NULL
      )
    ''');
  }

  // Helper method to convert a Map to a Pet/Appointment/Vaccination object
  // You'll need to implement these in your model classes

  // Pet CRUD Operations
  Future<int> insertPet(Pet pet) async {
    final db = await database;
    final id = await db.insert(tablePets, pet.toMap());
    return id;
  }

  Future<Pet?> getPet(int id) async {
    final db = await database;
    final maps = await db.query(
      tablePets,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Pet.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Pet>> getAllPets() async {
    final db = await database;
    final result = await db.query(tablePets, orderBy: columnName);
    return result.map((map) => Pet.fromMap(map)).toList();
  }

  Future<int> updatePet(Pet pet) async {
    final db = await database;
    return await db.update(
      tablePets,
      pet.toMap(),
      where: '$columnId = ?',
      whereArgs: [pet.id],
    );
  }

  Future<int> deletePet(int id) async {
    final db = await database;
    return await db.delete(tablePets, where: '$columnId = ?', whereArgs: [id]);
  }

  // Appointment CRUD Operations
  Future<int> insertAppointment(Appointment appointment) async {
    final db = await database;
    return await db.insert(tableAppointments, appointment.toMap());
  }

  Future<List<Appointment>> getPetAppointments(int petId) async {
    final db = await database;
    final result = await db.query(
      tableAppointments,
      where: '$columnPetId = ?',
      whereArgs: [petId],
      orderBy: columnDateTime,
    );
    return result.map((map) => Appointment.fromMap(map)).toList();
  }

  Future<int> updateAppointment(Appointment appointment) async {
    final db = await database;
    return await db.update(
      tableAppointments,
      appointment.toMap(),
      where: '$columnId = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<int> deleteAppointment(int id) async {
    final db = await database;
    return await db.delete(
      tableAppointments,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Vaccination CRUD Operations
  Future<int> insertVaccination(Vaccination vaccination) async {
    final db = await database;
    return await db.insert(tableVaccinations, vaccination.toMap());
  }

  Future<List<Vaccination>> getPetVaccinations(int petId) async {
    final db = await database;
    final result = await db.query(
      tableVaccinations,
      where: '$columnPetId = ?',
      whereArgs: [petId],
      orderBy: columnAdministeredDate,
    );
    return result.map((map) => Vaccination.fromMap(map)).toList();
  }

  Future<int> updateVaccination(Vaccination vaccination) async {
    final db = await database;
    return await db.update(
      tableVaccinations,
      vaccination.toMap(),
      where: '$columnId = ?',
      whereArgs: [vaccination.id],
    );
  }

  Future<int> deleteVaccination(int id) async {
    final db = await database;
    return await db.delete(
      tableVaccinations,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Reminder CRUD Operations
  Future<int> insertReminder(Reminder reminder) async {
    final db = await database;
    return await db.insert(tableReminders, {
      'title': reminder.title,
      'description': reminder.description,
      'date_time': reminder.dateTime.toIso8601String(),
      'is_completed': reminder.isCompleted ? 1 : 0,
      'pet_id': reminder.petId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Reminder>> getRemindersForDate(DateTime date) async {
    final db = await database;
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final List<Map<String, dynamic>> maps = await db.query(
        tableReminders,
        where: '$columnDateTime >= ? AND $columnDateTime < ?',
        whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
        orderBy: columnDateTime,
      );

      return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
    } catch (e) {
      developer.log('Error getting reminders: $e');
      return [];
    }
  }

  Future<int> updateReminder(Reminder reminder) async {
    final db = await database;
    return await db.update(
      tableReminders,
      {
        'title': reminder.title,
        'description': reminder.description,
        'date_time': reminder.dateTime.toIso8601String(),
        'is_completed': reminder.isCompleted ? 1 : 0,
        'pet_id': reminder.petId,
      },
      where: '$columnId = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete(
      tableReminders,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}
