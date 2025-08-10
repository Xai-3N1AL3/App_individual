import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/pet.dart';
import '../database/database_helper.dart';

class AddPet extends StatefulWidget {
  const AddPet({super.key});

  @override
  State<AddPet> createState() => _AddPetState();
}

class _AddPetState extends State<AddPet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _petController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  DateTime _birthday = DateTime.now();
  File? _imageFile;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _savePet() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? imagePath;

        // Save the image to a permanent location if an image was selected
        if (_imageFile != null) {
          final directory = await getApplicationDocumentsDirectory();
          final fileName = 'pet_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final savedImage = await _imageFile!.copy(
            '${directory.path}/$fileName',
          );
          imagePath = savedImage.path;
        }

        final newPet = Pet(
          name: _nameController.text.trim(),
          species: _petController.text.trim(),
          breed: _breedController.text.trim(),
          birthDate: _birthday.toString(),
          imagePath: imagePath,
        );

        // Save to database
        final dbHelper = DatabaseHelper();
        await dbHelper.insertPet(newPet);

        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error saving pet. Please try again.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text(
          "Add Pet",
          style: TextStyle(
            color: Colors.pinkAccent,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1.5, 1.5),
                blurRadius: 3.0,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 12,
        shadowColor: Colors.black54,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.pinkAccent),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 📷 Pet Image Picker
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.pink[200],
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : null,
                    child: _imageFile == null
                        ? const Icon(Icons.pets, color: Colors.white, size: 40)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🐶 Pet Type
              TextFormField(
                controller: _petController,
                decoration: const InputDecoration(
                  labelText: 'Pet Type',
                  prefixIcon: Icon(Icons.pets, color: Colors.pinkAccent),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter pet type'
                    : null,
              ),
              const SizedBox(height: 20),

              // 🐾 Pet Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.badge, color: Colors.pinkAccent),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter pet name'
                    : null,
              ),
              const SizedBox(height: 20),

              // 🐕 Breed
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Breed',
                  prefixIcon: Icon(Icons.category, color: Colors.pinkAccent),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter pet breed'
                    : null,
              ),
              const SizedBox(height: 20),

              // 🎂 Birthday Picker
              Row(
                children: [
                  const Icon(Icons.cake, color: Colors.pinkAccent),
                  const SizedBox(width: 8),
                  const Text(
                    "Birthday:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _birthday,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _birthday = picked;
                        });
                      }
                    },
                    child: Text(
                      "${_birthday.month}/${_birthday.day}/${_birthday.year}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.pinkAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              elevation: 8,
              shadowColor: Colors.pinkAccent.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: _savePet,
            child: const Text(
              "Save Pet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 2.0,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
