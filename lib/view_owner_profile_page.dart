import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/add_location_page.dart';
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
    if(userId == 'defaultValue'){
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
                  Align(
                    alignment: Alignment.topLeft,
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
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: FutureBuilder<String?>(
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
                      ),
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
                  Text(
                    '$name $surname, ${age.toString()}',
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 300.0,
                    child: TextField(
                      readOnly: true,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '• $gender',
                        border: const OutlineInputBorder(),
                        suffixIcon: currentUser ?
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditOwnerProfilePage(),
                              ),
                            );
                          },
                        ) : null,
                      ),
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    width: 300.0,
                    child: TextField(
                      readOnly: true,
                      minLines: 5,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '• $about',
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}