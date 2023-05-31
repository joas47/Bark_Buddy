import 'package:cross_platform_test/database_reset.dart';
import 'package:cross_platform_test/home_page.dart';
import 'package:cross_platform_test/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
/*  DatabaseReset databaseReset = DatabaseReset();
  databaseReset.resetEssentialFieldsInUserCollection();*/
  // Run the app
  runApp(const BarkBuddy());
}

class BarkBuddy extends StatelessWidget {
  const BarkBuddy({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BarkBuddy',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Firebase authentication state is still loading
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasData) {
              // User is signed in, navigate to StartPage
              return const HomePage();
            } else {
              // User is not signed in, navigate to LoginPage
              return const LoginPage();
            }
          }
        },
      ),
    );
  }
}
