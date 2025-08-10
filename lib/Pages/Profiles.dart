import 'package:flutter/material.dart';
import 'dart:io';

class Profile {
  final String name;
  final String breed;
  final String pet;
  final DateTime birthday;
  final String? photoPath;
  final List<DateTime> bathLogs = [];
  final List<DateTime> feedingLogs = [];
  final Map<String, List<DateTime>> supplements = {
    'Multivitamins': [],
    'Skin & Coat / Hair Shine': [],
    'Immune System Boosters': [],
    'Digestive Health / Probiotics': [],
    'Eye Health': [],
    'Bone & Teeth Health': [],
    'Urinary Tract Health': [],
    'Deworming (Anti-Parasitic)': [],
  };
  final List<String> vaccineRecords = [];
  final List<Map<String, dynamic>> notes = [];

  Profile({
    required this.name,
    required this.breed,
    required this.pet,
    required this.birthday,
    this.photoPath,
  });
}
