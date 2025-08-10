import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../database/database_helper.dart';
import '../models/pet.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({Key? key}) : super(key: key);

  @override
  _PetListScreenState createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Pet> _pets = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _breedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    developer.log('Initializing PetListScreen', name: 'UI');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPets().catchError((error) {
        developer.log('Error loading pets: $error', name: 'UI');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pets: $error')),
        );
      });
    });
  }

  Future<void> _loadPets() async {
    try {
      developer.log('Loading pets...', name: 'UI');
      final pets = await _dbHelper.getAllPets();
      developer.log('Loaded ${pets.length} pets', name: 'UI');
      if (mounted) {
        setState(() {
          _pets = pets;
        });
      }
    } catch (e, stackTrace) {
      developer.log('Error in _loadPets: $e', 
                   name: 'UI', 
                   error: e, 
                   stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _addPet() async {
    if (_formKey.currentState!.validate()) {
      final newPet = Pet(
        name: _nameController.text,
        species: _speciesController.text,
        breed: _breedController.text,
      );
      
      await _dbHelper.insertPet(newPet);
      
      // Clear the form
      _nameController.clear();
      _speciesController.clear();
      _breedController.clear();
      
      // Reload the list
      _loadPets();
      
      // Hide the keyboard
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _deletePet(int id) async {
    await _dbHelper.deletePet(id);
    _loadPets();
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building PetListScreen UI', name: 'UI');
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Pet Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _speciesController,
                    decoration: const InputDecoration(labelText: 'Species'),
                  ),
                  TextFormField(
                    controller: _breedController,
                    decoration: const InputDecoration(labelText: 'Breed'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addPet,
                    child: const Text('Add Pet'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _pets.length,
              itemBuilder: (context, index) {
                final pet = _pets[index];
                return ListTile(
                  title: Text(pet.name),
                  subtitle: Text('${pet.species ?? 'Unknown'} • ${pet.breed ?? 'Mixed'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePet(pet.id!),
                  ),
                  onTap: () {
                    // Navigate to pet details screen
                    // Navigator.push(...)
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
