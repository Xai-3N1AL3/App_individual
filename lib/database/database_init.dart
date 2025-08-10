import 'database_helper.dart';
import 'dart:developer' as developer;

class DatabaseInitializer {
  static final DatabaseInitializer _instance = DatabaseInitializer._internal();
  factory DatabaseInitializer() => _instance;
  DatabaseInitializer._internal();

  // Initialize the database when the app starts
  static Future<void> initialize() async {
    try {
      // This will create the database if it doesn't exist
      final dbHelper = DatabaseHelper();
      await dbHelper.database;
      developer.log('Database initialized successfully', name: 'Database');
    } catch (e, stackTrace) {
      developer.log(
        'Error initializing database: $e',
        name: 'Database',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow; // Re-throw to prevent app from starting with a broken database
    }
  }
}
