import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:points_counter/actions/games/games.dart';
import 'package:points_counter/pages/numbers_screen.dart';
import 'package:points_counter/pages/points_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  late final DatabaseReference gamesRef;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid;
    gamesRef = FirebaseDatabase.instance.ref('users/$uid/games');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Games Screen')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(50),
        child: Center(
          child: Column(
            spacing: 16,
            children: [
              ElevatedButton(
                onPressed: () async {
                  DatabaseReference gameRef = await createGame();
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NumbersScreen(gameRef: gameRef),
                      ),
                    );
                  }
                },
                child: Text('Create Game'),
              ),
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: gamesRef.onValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData ||
                        snapshot.data!.snapshot.value == null) {
                      return Center(child: Text('No games found.'));
                    }
                    final gamesMap = Map<String, dynamic>.from(
                      snapshot.data!.snapshot.value as Map,
                    );
                    final gameKeys = gamesMap.keys.toList();
                    return ListView.builder(
                      itemCount: gameKeys.length,
                      itemBuilder: (context, index) {
                        final key = gameKeys[index];
                        final game = Map<String, dynamic>.from(gamesMap[key]);
                        final date = game['date'] ?? 'No date';
                        return InkWell(
                          child: Card(child: Center(child: Text('$date'))),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PointsScreen(
                                  playersRef: gamesRef.child('$key/players'),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
