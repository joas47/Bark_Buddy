import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/database_handler.dart';
import 'package:cross_platform_test/match_chat_page.dart';
import 'package:cross_platform_test/view_dog_profile_page.dart';
import 'package:cross_platform_test/view_owner_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class FindMatchPage extends StatefulWidget {
  const FindMatchPage({super.key});

  @override
  State<FindMatchPage> createState() => _FindMatchPageState();
}

class _FindMatchPageState extends State<FindMatchPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Match'),
      ),
      body: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Dogs')
            .where('owner',
                isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, dogSnapshot) {
          if (dogSnapshot.hasData) {
            return CarouselSlider.builder(
              itemCount: dogSnapshot.data!.docs.length,
              itemBuilder: (context, int itemIndex, int pageViewIndex) {
                DocumentSnapshot doc = dogSnapshot.data!.docs[itemIndex];
                String ownerRef = doc.get('owner');
                print(ownerRef);
                return StreamBuilder<String?>(
                  // TODO: should not include user matches or pending likes
                  stream: DatabaseHandler.getOwnerPicStream(doc['owner']),
                  // TODO: Can we pass the context without creating a new BuildContext?
                  builder: (BuildContext context,
                      AsyncSnapshot<String?> ownerSnapshot) {
                    if (ownerSnapshot.hasError) {
                      return const Text(
                          'Something went wrong: user has no dog');
                    }
                    if (ownerSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Text("Loading");
                    }
                    String? ownerPicURL = ownerSnapshot.data;
                    List<dynamic>? dogPicURLs = doc['pictureUrls'];
                    if (dogPicURLs != null && dogPicURLs.isEmpty) {
                      return const Text('Error: dog has no picture');
                    }
                    String dogPicURL = doc['pictureUrls'][0];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ViewOwnerProfile(userId: doc['owner'])),
                            );
                          },
                          child: Image(
                              image: NetworkImage(ownerPicURL!), height: 100),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ViewDogProfilePage(userId: doc['owner'])),
                            );
                          },
                          child: Container(
                            height: 300,
                            margin: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: NetworkImage(dogPicURL),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(doc['Name'] +
                                ", " +
                                doc['Age'].toString() +
                                " " +
                                doc['Gender']),
                            IconButton(
                              // TODO: make this a heart icon
                              icon: const Icon(Icons.heart_broken),
                              onPressed: () {
                                // TODO send like
                                DatabaseHandler.sendLike(doc['owner']);
                              },
                            ),
                          ],
                        )
                      ],
                    );
                  },
                );
              },
              // TODO: this should take into account the size of the screen and try to fill as much as possible
              options: CarouselOptions(height: 600),
            );
          } else {
                return const Text("No data");
              }
            },
          )),
    );
  }
}
