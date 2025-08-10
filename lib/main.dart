import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'Pages/dashboard.dart';
import 'database/database_init.dart';

Future<void> initializeApp() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    developer.log('Initializing database...', name: 'App');
    await DatabaseInitializer.initialize();
  } catch (e, stackTrace) {
    developer.log(
      'Error in initializeApp: $e',
      name: 'App',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Care App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const Dashboard(),
    );
  }
}

void main() async {
  try {
    await initializeApp();
    runApp(const MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Error initializing app: $e'))),
      ),
    );
  }
}
