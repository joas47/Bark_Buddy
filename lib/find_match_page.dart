import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/database_handler.dart';
import 'package:cross_platform_test/match_chat_page.dart';
import 'package:cross_platform_test/view_dog_profile_page.dart';
import 'package:cross_platform_test/view_owner_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';

class FindMatchPage extends StatefulWidget {
  const FindMatchPage({super.key});

  @override
  State<FindMatchPage> createState() => _FindMatchPageState();
}

class _FindMatchPageState extends State<FindMatchPage> {

  // showMatchDialog to show a dialog when a match is found
  Future<void> _showMatchDialog(BuildContext context, String friendID,
      String? myDogPicUrl, String? friendDogPicUrl) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey,
          titlePadding: EdgeInsets.all(0),
          title: Container(
            color: Colors.lightGreen,
            padding: EdgeInsets.all(20),
            child: Text(
              'You have a new match!',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    radius: 50, // Increased the radius of the CircleAvatar
                    backgroundImage: myDogPicUrl != null ? NetworkImage(myDogPicUrl) : null,
                    child: myDogPicUrl == null ? Text('No picture') : null,
                  ),
                  CircleAvatar(
                    radius: 50, // Increased the radius of the CircleAvatar
                    backgroundImage: friendDogPicUrl != null ? NetworkImage(friendDogPicUrl) : null,
                    child: friendDogPicUrl == null ? Text('No picture') : null,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 250, // Adjust the width of the buttons
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      margin: EdgeInsets.only(bottom: 10.0), // Space between the buttons
                      child: TextButton(
                        onPressed: () {
                          // navigate to chat
                        },
                        child: const Text('Chat with match'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white, // This is the text color
                        ),
                      ),
                    ),
                    Container(
                      width: 250, // Adjust the width of the buttons
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: TextButton(
                        onPressed: () {
                          // close the dialog
                          Navigator.of(context).pop();
                        },
                        child: const Text('Continue finding matches'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white, // This is the text color
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _timeslotWindow(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey,
          titlePadding: const EdgeInsets.all(0),
          title: Container(
            color: Colors.lightGreen,
            padding: const EdgeInsets.all(20),
            child: const Text(
              'Choose your availability',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Match'),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: () async {
              TimeRange result = await showTimeRangePicker(
                context: context,
                start: const TimeOfDay(hour: 9, minute: 0),
                end: const TimeOfDay(hour: 24, minute: 0),
                use24HourFormat: true,
                hideButtons: true,
                labelOffset: 40,
                strokeWidth: 4,
                ticks: 24,
                ticksOffset: -7,
                ticksLength: 15,
                ticksColor: Colors.grey,
                ticksWidth: 4,
                strokeColor: Colors.lightGreen,
                selectedColor: Colors.lightGreen,
              );
              DatabaseHandler.setAvailability(result.startTime, result.endTime);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasData) {
            final userDocs = userSnapshot.data!.docs;
            List<QueryDocumentSnapshot> toRemove = [];
            DocumentSnapshot currentUserDoc = userDocs.firstWhere((element) =>
                element.id == FirebaseAuth.instance.currentUser!.uid);
            for (var doc in userDocs) {
                // TODO: availability check (timeslot)
                // TODO: give feedback when liking a dog, right now it just disappears
                doc.id == FirebaseAuth.instance.currentUser!.uid
                    ? toRemove.add(doc)
                    : null;
                doc.data().toString().contains('dogs')
                    ? null
                    : toRemove.add(doc);
                if (currentUserDoc['matches'].contains(doc.id) ||
                    currentUserDoc['pendingLikes'].contains(doc.id)) {
                  toRemove.add(doc);
                }
                /*
              doc.data().toString().contains('startTime') ? null : toRemove.add(doc);
              doc.data().toString().contains('endTime') ? null : toRemove.add(doc);
              if (doc.data().toString().contains('startTime') &&
                  doc.data().toString().contains('endTime')) {
                int startTimeHour = int.parse(doc['startTime'].toString().substring(0, 1));
                  if (currentUserDoc['startTime'] >
                          doc['endTime'] ||
                      currentUserDoc['endTime'] <
                          doc['startTime']) {
                    toRemove.add(doc);
                  }
              }*/
              }
              userDocs.removeWhere((element) => toRemove.contains(element));
              if (userDocs.isEmpty) {
                return const Center(
                  child: Text('No matches found'),
                );
              }
              return CarouselSlider.builder(
                itemCount: userDocs.length,
                itemBuilder: (context, int itemIndex, int pageViewIndex) {
                  DocumentSnapshot doc = userDocs[itemIndex];

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Dogs')
                        .doc(doc['dogs'])
                        .snapshots(),
                    builder: (context, dogSnapshot) {
                        if (dogSnapshot.hasError) {
                          return const Text(
                              'Something went wrong: user has no dog');
                        }
                        if (dogSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text("Loading");
                        }
                        final dogDoc = dogSnapshot.data!;
                        List<dynamic>? dogPicURLs = dogDoc['pictureUrls'];
                        if (dogPicURLs != null && dogPicURLs.isEmpty) {
                          return const Text('Error: dog has no picture');
                        }
                        String dogPicURL = dogDoc['pictureUrls'][0];
                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ViewOwnerProfile(userId: doc.id)),
                                );
                              },
                              child: Image(
                                  image: NetworkImage(doc['picture']), height: 100),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ViewDogProfilePage(userId: doc.id)),
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
                                Text(dogDoc['Name'] +
                                    ", " +
                                    dogDoc['Age'].toString() +
                                    " " +
                                    dogDoc['Gender']),
                                IconButton(
                                  //TODO: make this a heart icon
                                  icon: const Icon(Icons.heart_broken),
                                  onPressed: () async {
                                    bool isMatch = await DatabaseHandler.sendLike(doc.id);
                                    if (isMatch) {
                                      final User? currentUser =
                                        FirebaseAuth.instance.currentUser;
                                    String? myDogPicUrl =
                                        await DatabaseHandler.getDogPic(
                                                currentUser?.uid)
                                            .first;
                                    _showMatchDialog(context, doc.id,
                                        myDogPicUrl, dogPicURL);
                                  }
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
        ),
      ),
      /*body: SingleChildScrollView(
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
          )),*/
    );
  }
}
