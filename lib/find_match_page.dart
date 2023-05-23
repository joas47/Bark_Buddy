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
                    backgroundImage:
                        myDogPicUrl != null ? NetworkImage(myDogPicUrl) : null,
                    child: myDogPicUrl == null ? Text('No picture') : null,
                  ),
                  CircleAvatar(
                    radius: 50, // Increased the radius of the CircleAvatar
                    backgroundImage: friendDogPicUrl != null
                        ? NetworkImage(friendDogPicUrl)
                        : null,
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
                      width: 250,
                      // Adjust the width of the buttons
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                      // Space between the buttons
                      child: TextButton(
                        onPressed: () {
                          // navigate to chat
                        },
                        child: const Text('Chat with match'),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Colors.white, // This is the text color
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
                          foregroundColor:
                              Colors.white, // This is the text color
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

  /*Future<void> _timeslotWindow(BuildContext context) async {
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
  }*/

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
                end: const TimeOfDay(hour: 17, minute: 0),
                use24HourFormat: true,
                hideButtons: true,
                labelOffset: -25,
                strokeWidth: 4,
                ticks: 24,
                ticksOffset: -7,
                ticksLength: 15,
                ticksColor: Colors.grey,
                ticksWidth: 4,
                strokeColor: Colors.lightGreen,
                selectedColor: Colors.lightGreen,
                rotateLabels: false,
                // TODO: implement max and min duration you can be available?
                maxDuration: const Duration(hours: 12),
                minDuration: const Duration(hours: 1),
                labels: [
                  "24",
                  "1",
                  "2",
                  "3",
                  "4",
                  "5",
                  "6",
                  "7",
                  "8",
                  "9",
                  "10",
                  "11",
                  "12",
                  "13",
                  "14",
                  "15",
                  "16",
                  "17",
                  "18",
                  "19",
                  "20",
                  "21",
                  "22",
                  "23",
                ].asMap().entries.map((e) {
                  return ClockLabel.fromIndex(
                    idx: e.key,
                    length: 24,
                    text: e.value,
                  );
                }).toList(),
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
              // all documents in the users collection
              final userDocs = userSnapshot.data!.docs;
              // documents that should be removed from the list of potential matches
              List<QueryDocumentSnapshot> toRemove = [];
              // the current user's document, for easy access
              DocumentSnapshot currentUserDoc = userDocs.firstWhere((element) =>
                  element.id == FirebaseAuth.instance.currentUser!.uid);
              // remove the current user from the list of potential matches (shouldn't match with yourself)
              userDocs.remove(currentUserDoc);
              // until the user has set their availability, they shouldn't be able to see any matches
              // TODO: right now only checks if the fields exist, not their values. Should take current time into account
              // TODO: range based filter. make a button that opens a dialog where you can choose the max distance you want to match with
              if (currentUserDoc.data().toString().contains('startTime') &&
                  currentUserDoc.data().toString().contains('endTime')) {
                for (var doc in userDocs) {
                  // TODO: availability check (timeslot)
                  // removes users that don't have a dog
                  doc.data().toString().contains('dogs')
                      ? null
                      : toRemove.add(doc);
                  // removes users that are already matched with the current user
                  if (currentUserDoc.data().toString().contains('matches')) {
                    if (currentUserDoc['matches'].contains(doc.id)) {
                      toRemove.add(doc);
                    }
                  }
                  // removes users that the current user has already liked
                  if (currentUserDoc
                      .data()
                      .toString()
                      .contains('pendingLikes')) {
                    if (currentUserDoc['pendingLikes'].contains(doc.id)) {
                      toRemove.add(doc);
                    }
                  }
                  // removes users that hasn't set their availability
                  doc.data().toString().contains('startTime')
                      ? null
                      : toRemove.add(doc);
                  doc.data().toString().contains('endTime')
                      ? null
                      : toRemove.add(doc);
                }
/*              if (doc.data().toString().contains('startTime') &&
                  doc.data().toString().contains('endTime')) {

                int startTimeHour = int.parse(doc['startTime'].toString().substring(0, 1));
                int startTimeMinute = int.parse(doc['startTime'].toString().substring(3, 4));
                int endTimeHour = int.parse(doc['endTime'].toString().substring(0, 1));
                int endTimeMinute = int.parse(doc['endTime'].toString().substring(3, 4));

                int currentUserStartTimeHour = int.parse(currentUserDoc['startTime'].toString().substring(0, 1));
                int currentUserStartTimeMinute = int.parse(currentUserDoc['startTime'].toString().substring(3, 4));
                int currentUserEndTimeHour = int.parse(currentUserDoc['endTime'].toString().substring(0, 1));
                int currentUserEndTimeMinute = int.parse(currentUserDoc['endTime'].toString().substring(3, 4));

                if (currentUserStartTimeHour > endTimeHour ||
                    currentUserEndTimeHour < startTimeHour) {
                  toRemove.add(doc);
                } else if (currentUserStartTimeHour == endTimeHour &&
                    currentUserStartTimeMinute > endTimeMinute) {
                  toRemove.add(doc);
                } else if (currentUserEndTimeHour == startTimeHour &&
                    currentUserEndTimeMinute < startTimeMinute) {
                  toRemove.add(doc);
                }*/

/*                  if (currentUserDoc['startTime'] >
                          doc['endTime'] ||
                      currentUserDoc['endTime'] <
                          doc['startTime']) {
                    toRemove.add(doc);
                  }*/
              } else {
                // TODO: make this message prettier
                return const Center(
                  child: Text('Click the clock icon to set your availability'),
                );
              }
              /*bool isTimeOverlap(DocumentSnapshot other, ) {
              // Extract hours and minutes from startTime and endTime
              List<int> startTimeParts = startTime.split(':').map(int.parse).toList();
              List<int> endTimeParts = endTime.split(':').map(int.parse).toList();
              List<int> otherStartTimeParts = other.startTime.split(':').map(int.parse).toList();
              List<int> otherEndTimeParts = other.endTime.split(':').map(int.parse).toList();

              // Convert hours and minutes to minutes since midnight
              int startMinutes = startTimeParts[0] * 60 + startTimeParts[1];
              int endMinutes = endTimeParts[0] * 60 + endTimeParts[1];
              int otherStartMinutes = otherStartTimeParts[0] * 60 + otherStartTimeParts[1];
              int otherEndMinutes = otherEndTimeParts[0] * 60 + otherEndTimeParts[1];

              // Check for time overlap
              if (startMinutes <= otherEndMinutes && otherStartMinutes <= endMinutes) {
                return true;
              }

              return false;
            }*/
              // removes all documents that didn't match the criteria above
              userDocs.removeWhere((element) => toRemove.contains(element));
              // TODO: make this message prettier
              // if there's no users left that match the criteria, displays a message.
              if (userDocs.isEmpty) {
                return const Center(
                  child: Text('No matches found'),
                );
              }
              /*// TODO: Special case: what to do if there's only one potential match to show?
              if (userDocs.length == 1) {
                DocumentSnapshot ownerDoc = userDocs.first;
                final dogDoc = FirebaseFirestore.instance
                    .collection('Dogs')
                    .doc(ownerDoc['dogs']);
                return _buildPotentialMatch(context, userDocs.first, dogDoc);
              }*/
              // begins the process of displaying the matches
              return CarouselSlider.builder(
                itemCount: userDocs.length,
                // loops through the list of potential matches one by one
                itemBuilder: (context, int itemIndex, int pageViewIndex) {
                  DocumentSnapshot ownerDoc = userDocs[itemIndex];
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Dogs')
                        .doc(ownerDoc['dogs'])
                        .snapshots(),
                    builder: (context, dogSnapshot) {
                      if (dogSnapshot.hasError) {
                        return const Text(
                            'Something went wrong: user has no dog probably');
                      }
                      if (dogSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final dogDoc = dogSnapshot.data!;
                      // check if the dog document has a field called 'pictureUrls'.
                      // If not, display an error message.
                      // Should never happen, but just in case.
                      // You should never be able to create a dog without a picture.
                      if (!dogDoc.data().toString().contains('pictureUrls')) {
                        return const Text('Error: dog has no picture');
                      }
                      /*List<dynamic>? dogPicURLs = dogDoc['pictureUrls'];
                      if (dogPicURLs != null && dogPicURLs.isEmpty) {
                        return const Text('Error: dog has no picture');
                      }*/
                      return _buildPotentialMatch(context, ownerDoc, dogDoc);
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

  Column _buildPotentialMatch(BuildContext context,
      DocumentSnapshot<Object?> doc, DocumentSnapshot<Object?> dogDoc) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewOwnerProfile(userId: doc.id)),
            );
          },
          child: Image(image: NetworkImage(doc['picture']), height: 100),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewDogProfilePage(userId: doc.id)),
            );
          },
          child: Container(
            // TODO: 'height' should take into account the size of the screen and try to fill as much as possible without overflowing
            height: 420,
            margin: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: NetworkImage(dogDoc['pictureUrls'][0]),
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
                // TODO: give feedback when liking a dog, right now it just disappears
                // TODO: if the last dog in the carousel is liked, the match dialog will not show if there's a match
                bool isMatch = await DatabaseHandler.sendLike(doc.id);
                if (isMatch) {
                  final User? currentUser = FirebaseAuth.instance.currentUser;
                  String? myDogPicUrl =
                      await DatabaseHandler.getDogPic(currentUser?.uid).first;
                  _showMatchDialog(
                      context, doc.id, myDogPicUrl, dogDoc['pictureUrls'][0]);
                }
              },
            ),
          ],
        )
      ],
    );
  }
}
