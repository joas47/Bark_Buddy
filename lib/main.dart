import 'package:cross_platform_test/login_page.dart';
import 'package:flutter/material.dart';

//should see this
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// for the MatchChatPage
//import 'package:cloud_firestore/cloud_firestore.dart';

// TODO: handle the case when the user is already logged in
// TODO: found bug where after you press the logout button in the settings page, then log in to another account, there's now 2 bottom navigation bars stacked ontop of each other.
void main() async {
  // Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Run the app
  runApp(const BarkBuddy());
}

class BarkBuddy extends StatelessWidget {
  const BarkBuddy({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Bark Buddy',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: const LoginPage());
  }
}