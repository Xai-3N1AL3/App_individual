import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pet_care/Pages/PetDetails.dart';
import 'package:pet_care/Pages/addPet.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/database/database_helper.dart';

class PetList extends StatefulWidget {
  const PetList({super.key});

  @override
  State<PetList> createState() => _PetListState();
}

class _PetListState extends State<PetList> {
  List<Pet> _pets = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    try {
      final pets = await _dbHelper.getAllPets();
      if (mounted) {
        setState(() {
          _pets = pets;
        });
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load pets')));
      }
    }
  }

  Future<void> _deletePet(Pet pet) async {
    try {
      await _dbHelper.deletePet(pet.id!);
      if (mounted) {
        setState(() {
          _pets.removeWhere((p) => p.id == pet.id);
        });
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to delete pet')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'My Pets',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.pink,
        elevation: 8,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Add Pet',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPet()),
              );
              if (result == true) {
                _loadPets();
              }
            },
          ),
        ],
      ),
      body: _pets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No pets added yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddPet()),
                      );
                      if (result == true) {
                        _loadPets();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Add Your First Pet',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: _pets.length,
              itemBuilder: (context, index) {
                final pet = _pets[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetDetails(
                            pet: pet,
                            onPetUpdated: (InvalidType) {},
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          pet.imagePath != null &&
                                  File(pet.imagePath!).existsSync()
                              ? CircleAvatar(
                                  backgroundImage: FileImage(
                                    File(pet.imagePath!),
                                  ),
                                  radius: 30,
                                  backgroundColor: Colors.grey[200],
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.pink[50],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.pets,
                                    size: 30,
                                    color: Colors.pink[300],
                                  ),
                                ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pet.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pet.breed ?? 'Unknown breed',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                if (pet.species != null &&
                                    pet.species!.isNotEmpty)
                                  Text(
                                    pet.species!,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pink[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'View',
                              style: TextStyle(
                                color: Colors.pink[700],
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPet()),
          );
          if (result == true) {
            _loadPets();
          }
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Pet pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Are you sure you want to delete ${pet.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deletePet(pet);
    }
  }
}
