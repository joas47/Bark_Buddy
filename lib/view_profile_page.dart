import 'package:flutter/material.dart';

class ViewProfilePage extends StatelessWidget {
  const ViewProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Min profil'),
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
          children: const <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: CircleAvatar(
                radius: 50.0,
                backgroundImage:
                    AssetImage('assets/images/placeholder-profile-image.png'),
              ),
            ),
            SizedBox(height: 10.0),
            CircleAvatar(
              radius: 100.0,
              backgroundImage:
                  AssetImage('assets/images/placeholder-dog-image2.png'),
            ),
            Text(
              'Max',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              //height: 500.0,
              width: 300.0,
              child: TextField(
                readOnly: true,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  // TODO: get this information from the database
                  hintText:
                      '• Tik \n• Stor \n• Golden Retriever\n• Hög aktivitetsnivå',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            SizedBox(
              //height: 500.0,
              width: 300.0,
              child: TextField(
                readOnly: true,
                minLines: 5,
                maxLines: 5,
                decoration: InputDecoration(
                  // TODO: get this information from the database
                  hintText: '• Placeholder bio',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
