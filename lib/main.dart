import 'package:flutter/material.dart';
import 'Pages/Listitems.dart';
import 'Pages/addPet.dart';


void main() {
  runApp(MaterialApp(
      routes: {
        '/': (context)=> Listitems(),
            '/add': (context)=> const AddPet(),

      }
  ));
}

