import 'package:cross_platform_test/find_match_page.dart';
import 'package:flutter/material.dart';

import 'add_location_page.dart';

class StartPage extends StatelessWidget {
  final VoidCallback onStart;

  const StartPage(
      {Key? key, required this.onStart, required Null Function() onNavigate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Start page'),
      ),
      // Added Center and SizedBox around the SingleChildScrollView
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to BarkBuddy!',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  margin:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Press the ',
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        WidgetSpan(
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints.tight(const Size.square(25)),
                              icon: const Icon(Icons.pets),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FindMatchPage(),
                                  ),
                                );
                              },
                            )),
                        const TextSpan(
                          text: ' icon \n to start finding \n other dogs!',
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(60, 10, 60, 5),
                  child: const Text(
                    'Do you have a great spot \n for dogs and owners \n to hang out?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(60, 5, 60, 10),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Press on ',
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                        ),
                        WidgetSpan(
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints.tight(const Size.square(25)),
                              icon: const Icon(Icons.add_location),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddLocationPage(),
                                  ),
                                );
                              },
                            )),
                        const TextSpan(
                          text:
                          ' through your profile to add your spot \n for others to enjoy!',
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
