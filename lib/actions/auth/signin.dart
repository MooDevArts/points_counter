import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:points_counter/pages/games_screen.dart';

signIn(emailController, passwordController, mounted, context) async {
  try {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final UserCredential userCredential = await auth
        .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GamesScreen()),
      );
    }
  } on FirebaseAuthException catch (signUpError) {
    //errors

    if (signUpError.code == 'email-already-in-use') {
      try {
        final FirebaseAuth auth = FirebaseAuth.instance;
        final UserCredential userCredential = await auth
            .signInWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GamesScreen()),
          );
        }
      } on FirebaseAuthException catch (signInError) {
        if (signInError.code == 'user-not-found') {
        } else if (signInError.code == 'wrong-password') {}
      } catch (e) {}
    } else {
      if (signUpError.code == 'weak-password') {
      } else {}
    }
  } catch (e) {}
}

signOut() {
  print('Out');
}
