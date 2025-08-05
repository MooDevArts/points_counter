import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:points_counter/pages/points_screen.dart';

class NamesScreen extends StatefulWidget {
  final int numberOfPlayers;
  final DatabaseReference gameRef;

  const NamesScreen({
    super.key,
    required this.numberOfPlayers,
    required this.gameRef,
  });

  @override
  State<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends State<NamesScreen> {
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      widget.numberOfPlayers,
      (_) => TextEditingController(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Names Screen')),
      body: Padding(
        padding: EdgeInsets.only(top: 50, left: 50, right: 50),
        child: ListView(
          children: [
            ...List.generate(widget.numberOfPlayers, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: controllers[index],
                  decoration: InputDecoration(
                    labelText: 'Player ${index + 1} Name',
                  ),
                ),
              );
            }),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final names = controllers.map((c) => c.text.trim()).toList();
                if (names.any((name) => name.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all player names')),
                  );
                  return;
                }
                // All fields are filled, proceed with names

                final playersRef = widget.gameRef.child('players');
                for (final name in names) {
                  await playersRef.push().set({'name': name, 'points': 0});
                }

                if (mounted) {
                  // Go back to the previous screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PointsScreen(playersRef: playersRef, roundsPlayed: 0),
                    ),
                  );
                }
              },
              child: Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
