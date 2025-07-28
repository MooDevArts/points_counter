import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:points_counter/actions/games/games.dart';
import 'package:points_counter/pages/names_screen.dart';

class NumbersScreen extends StatefulWidget {
  final DatabaseReference gameRef;
  const NumbersScreen({super.key, required this.gameRef});

  @override
  State<NumbersScreen> createState() => _NumbersScreenState();
}

class _NumbersScreenState extends State<NumbersScreen> {
  TextEditingController noOfPlayers = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Numbers Screen')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(50),
        child: Center(
          child: Column(
            spacing: 16,
            children: [
              TextField(
                controller: noOfPlayers,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  label: Center(child: Text('How many players ?')),
                ),
                keyboardType: TextInputType.numberWithOptions(),
              ),
              ElevatedButton(
                onPressed: () {
                  if (noOfPlayers.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a number')),
                    );
                    return;
                  }
                  if (int.parse(noOfPlayers.text) > 8) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Maximum 8 players allowed')),
                    );
                    return;
                  }
                  setNumberOfPlayersforGame(
                    widget.gameRef,
                    int.parse(noOfPlayers.text),
                  );
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NamesScreen(
                          numberOfPlayers: int.parse(noOfPlayers.text),
                          gameRef: widget.gameRef,
                        ),
                      ),
                    );
                  }
                },
                child: Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
