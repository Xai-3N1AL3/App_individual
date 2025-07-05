import 'package:flutter/material.dart';
import 'dart:io';

class Profile {
  String name;
  String pet;
  String breed;
  DateTime birthday;
  String? photoPath;
  List<DateTime> bathLogs = [];
  List<DateTime> feedingLogs = [];
  List<DateTime> vitaminLogs = [];
  List<String> vaccineRecords = [];
  List<Map<String, dynamic>> notes = [];

  Profile({
    required this.name,
    required this.pet,
    required this.breed,
    required this.birthday,
    this.photoPath,
  });
}
