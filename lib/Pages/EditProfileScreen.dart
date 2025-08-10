import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/pet.dart';
import '../database/database_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final Pet pet;

  const EditProfileScreen({Key? key, required this.pet}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _breedController;
  late TextEditingController _birthDateController;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  DateTime? _birthDate;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _speciesController = TextEditingController(text: widget.pet.species);
    _breedController = TextEditingController(text: widget.pet.breed);
    _birthDate = widget.pet.birthDate != null
        ? DateTime.parse(widget.pet.birthDate!)
        : null;
    _birthDateController = TextEditingController(
      text: _birthDate != null
          ? DateFormat('MM/dd/yyyy').format(_birthDate!)
          : '',
    );
    _imagePath = widget.pet.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedPet = Pet(
        id: widget.pet.id,
        name: _nameController.text,
        species: _speciesController.text,
        breed: _breedController.text,
        birthDate: _birthDate?.toIso8601String(),
        imagePath: _imagePath,
      );

      await _dbHelper.updatePet(updatedPet);

      if (mounted) {
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Picture
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _imagePath != null
                                ? FileImage(File(_imagePath!)) as ImageProvider
                                : const AssetImage('assets/default_pet.png'),
                            child: _imagePath == null
                                ? const Icon(
                                    Icons.pets,
                                    size: 60,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                onPressed: () => _pickImage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Pet Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pets),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Species Field
                    TextFormField(
                      controller: _speciesController,
                      decoration: const InputDecoration(
                        labelText: 'Species (e.g., Dog, Cat) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pets),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a species';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Breed Field
                    TextFormField(
                      controller: _breedController,
                      decoration: const InputDecoration(
                        labelText: 'Breed',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Birth Date Field
                    TextFormField(
                      controller: _birthDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Birth Date',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit_calendar),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
