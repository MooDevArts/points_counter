import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PointsScreen extends StatefulWidget {
  final DatabaseReference playersRef;
  const PointsScreen({super.key, required this.playersRef});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Points Screen')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Points Screen Content Goes Here'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Action for button
                },
                child: Text('Action Button'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
