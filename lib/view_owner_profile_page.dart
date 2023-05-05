import 'package:cross_platform_test/settings_page.dart';
import 'package:flutter/material.dart';

class ViewOwnerProfile extends StatelessWidget {
  const ViewOwnerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ägarprofil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings functionality.
              // goto settings page
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
            },
          ),
        ],
      ),
      body: Stack(alignment: Alignment.center, children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: ElevatedButton(
                  child: const Text('Lägg till plats'),
                  onPressed: () {},
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const CircleAvatar(
                    radius: 50.0,
                    backgroundImage:
                    // TODO: get this information from the database
                    AssetImage('assets/images/placeholder-dog-image2.png'),
                  ),
                ),
              ),
            ]),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 10.0),
            const CircleAvatar(
              radius: 100.0,
              backgroundImage:
              // TODO: get this information from the database
              AssetImage('assets/images/placeholder-profile-image.png'),
            ),
            const Text(
              'John',
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
                    '• Man \n• Stor \n• Golden Retriever lover\n• Hög aktivitetsnivå',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => const EditOwnerProfile()));
                      },
                    )),
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            const SizedBox(
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
      ]),
    );
  }
}
