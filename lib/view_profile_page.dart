import 'package:flutter/material.dart';

class ViewProfilePage extends StatelessWidget {
  const ViewProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings functionality.
              // goto settings page
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/placeholder-dog-image2.png',
              height: 200.0,
              width: 200.0,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Max',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Golden Retriever',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Male',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 20.0),
            const CircleAvatar(
              radius: 50.0,
              backgroundImage:
                  AssetImage('assets/images/placeholder-profile-image.png'),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'John Doe',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              '25 years old',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Male',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}
