import 'package:flutter/material.dart';

class StartPage extends StatelessWidget {
  final VoidCallback onStart;

  const StartPage(
      {Key? key, required this.onStart, required Null Function() onNavigate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to BarkBuddy!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                onStart();
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
