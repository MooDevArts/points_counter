import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Create
createGame() async {
  // db ref
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  // auth ref
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // get current user id
  String userId = _auth.currentUser!.uid;
  //get date
  DateTime now = DateTime.now();
  String readableDate = '${now.day} - ${now.month} - ${now.year}';

  final gameRef = _database.child('users').child(userId).child('games').push();

  await gameRef.set({'date': readableDate, 'roundsPlayed': 0});

  return gameRef;
}

// Read

// Update
setNumberOfPlayersforGame(
  DatabaseReference gameRef,
  int numberOfPlayers,
) async {
  gameRef.update({'numberOfPlayers': numberOfPlayers});
}

// Delete
