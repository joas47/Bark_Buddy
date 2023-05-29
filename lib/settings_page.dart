import 'package:cross_platform_test/edit_dog_profile_page.dart';
import 'package:cross_platform_test/edit_owner_profile.dart';
import 'package:cross_platform_test/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditDogProfilePage(),
                      ),
                    );
                  },
                  child: const Text('Edit dog profile'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditOwnerProfilePage(),
                    ),
                  );
                },
                child: const Text('Edit owner profile'),
              ),
          TextButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
            );
          },
          child: const Text('Log out'),
          ),
            ],
          ),
        ),
      ),
    );
  }
}
