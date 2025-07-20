import 'package:flutter/material.dart';
import 'PetSummary.dart';
import 'Profiles.dart';
import 'ProfileCard.dart';
import 'addPet.dart';
import 'PetDetails.dart';

class Listitems extends StatefulWidget {
  const Listitems({super.key});

  @override
  State<Listitems> createState() => _ListitemsState();
}

class _ListitemsState extends State<Listitems> {
  List<Profile> profiles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text(
          "Pet Care App",
          style: TextStyle(
            color: Colors.pinkAccent,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize, color: Colors.pinkAccent),
            tooltip: "Pet Summary",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileSummary(profiles: profiles),
                ),
              );
            },
          ),
        ],
      ),
      body: profiles.isEmpty
          ? const Center(
        child: Text("No pets added yet. Tap + to add one."),
      )
          : ListView(
        children: profiles.map((profile) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetDetails(profile: profile),
                ),
              );
            },
            onLongPress: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Pet'),
                  content: const Text('Are you sure you want to delete this pet?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                setState(() {
                  profiles.remove(profile);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${profile.name} has been deleted')),
                );
              }
            },
            child: Itemcard(profiles: profile),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newPet = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPet()),
          );

          if (newPet != null && newPet is Profile) {
            setState(() {
              profiles.add(newPet);
            });
          }
        },
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
