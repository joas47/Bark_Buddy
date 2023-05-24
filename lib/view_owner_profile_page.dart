import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/add_location_page.dart';
import 'package:cross_platform_test/view_dog_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'database_handler.dart';
import 'edit_owner_profile.dart';
import 'settings_page.dart';

class ViewOwnerProfile extends StatelessWidget {
  String? userId;
  ViewOwnerProfile({Key? key, this.userId = 'defaultValue'}) : super(key: key);

  bool currentUser = false;

  @override
  Widget build(BuildContext context) {
    if (userId == 'defaultValue' ||
        userId == FirebaseAuth.instance.currentUser?.uid) {
      userId = FirebaseAuth.instance.currentUser?.uid;
      currentUser = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final userData = snapshot.data!;
          final name = userData.get('name');
          final surname = userData.get('surname');
          final about = userData.get('about') as String?;
          final age = userData.get('age') as int?;
          final gender = userData.get('gender');
          final String? profilePic = userData.get('picture') as String?;

          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 120.0), // Adjust the padding value as needed
                          child: currentUser
                              ? ElevatedButton.icon(
                            icon: const Icon(Icons.add_location),
                            label: const Text('Add location'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddLocationPage(),
                                ),
                              );
                            },
                          )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        // something like this is probably needed
/*                        if (currentUser) {
                          Navigator.pop(context);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewDogProfilePage(),
                            ),
                          );
                        }*/
                      },
                      child: StreamBuilder<String?>(
                        stream: DatabaseHandler.getDogPic(userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasData && snapshot.data != null) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                radius: 50.0,
                                backgroundImage: NetworkImage(snapshot.data!),
                              ),
                            );
                          } else {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                radius: 50.0,
                                backgroundImage: AssetImage(
                                  'assets/images/placeholder-dog-image.png',
                                ),
                              ),
                            );
                          }
                        },
                      ),






                      /*child: FutureBuilder<String?>(
                        future: DatabaseHandler.getDogPic(userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasData && snapshot.data != null) {
                            return CircleAvatar(
                              radius: 50.0,
                              backgroundImage: NetworkImage(snapshot.data!),
                            );
                          } else {
                            return CircleAvatar(
                              radius: 50.0,
                              backgroundImage: AssetImage(
                                'assets/images/placeholder-profile-image.png',
                              ),
                            );
                          }
                        },
                      ),*/
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.network(
                                profilePic ?? '',
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: 100.0,
                      backgroundImage: profilePic != null
                          ? NetworkImage(profilePic)
                          : AssetImage(
                        'assets/images/placeholder-profile-image.png',
                      ) as ImageProvider<Object>,
                    ),
                  ),
          Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
         child: Text(
                    '$name $surname, ${age.toString()}',
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
                    SizedBox(
                    width: 300.0,
                    child: Wrap(
                    spacing: 10.0, // Adjust the spacing between tags as needed
                    // runSpacing: 1.0, // Adjust the spacing between rows of tags as needed
                    children: [
                    if (gender != null)
                    Chip(
                    label: Text('• $gender'),
                    // Add any additional styling properties for the chip as needed
                    ),
          ],
          ),
          ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    width: 300.0,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: <Widget>[
                        TextField(
                          readOnly: true,
                          minLines: 5,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: '• $about',
                            border: const OutlineInputBorder(),
                          ),
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}