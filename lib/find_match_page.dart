import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/database_handler.dart';
import 'package:cross_platform_test/view_dog_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:cross_platform_test/chat_page.dart';

import 'dart:async';

class FindMatchPage extends StatefulWidget {
  const FindMatchPage({super.key});

  @override
  State<FindMatchPage> createState() => _FindMatchPageState();
}

class _FindMatchPageState extends State<FindMatchPage> {

  late DocumentSnapshot _currentUserDocCopy;

  bool _userFilterAplied = false;
  bool _showSmallDogs = false;
  bool _showMediumDogs = false;
  bool _showLargeDogs = false;
  bool _showOwnersAgeAbove35 = false;
  bool _showOwnersAge25to35 = false;
  bool _showOwnersAge18to24 = false;
  bool _showHighActDogs = false;
  bool _showMediumActDogs = false;
  bool _showLowActDogs = false;
  bool _showNeuteredDogs = false;
  bool _showFemaleDogs = false;
  bool _showMaleDogs = false;
  bool _showOwnerGenderOther = false;
  bool _showOwnerGenderMale = false;
  bool _showOwnerGenderFemale = false;

  bool _updatedShowSmallDogs = false;
  bool _updatedShowMediumDogs = false;
  bool _updatedShowLargeDogs = false;
  bool _updatedShowOwnersAgeAbove35 = false;
  bool _updatedShowOwnersAge25to35 = false;
  bool _updatedShowOwnersAge18to24 = false;
  bool _updatedShowHighActDogs = false;
  bool _updatedShowMediumActDogs = false;
  bool _updatedShowLowActDogs = false;
  bool _updatedShowNeuteredDogs = false;
  bool _updatedShowFemaleDogs = false;
  bool _updatedShowMaleDogs = false;
  bool _updatedShowOwnerGenderOther = false;
  bool _updatedShowOwnerGenderMale = false;
  bool _updatedShowOwnerGenderFemale = false;
  bool disableSwipe = false; // Flag variable to control swipe behavior

  List<dynamic> _pendingMatchesField = [];

  Future<void> _showMatchDialog(BuildContext context) async {
    String matchOwnerID = _pendingMatchesField.first;

    String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    String? myDogPicUrl = await DatabaseHandler
        .getDogPic(currentUserUid)
        .first;
    String? matchDogPicURL = '';
    String matchOwnerName = '';
    final currentUserDoc =
    FirebaseFirestore.instance.collection('users').doc(currentUserUid);

    // Fetch user data from Firestore
    final matchOwnerDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(matchOwnerID)
        .get();
    if (matchOwnerDoc.exists) {
      //print("if user doc exists...");
      matchOwnerName = matchOwnerDoc.data()?['name'] ?? '';
      matchDogPicURL =
          await DatabaseHandler
              .getDogPic(matchOwnerID)
              .first ?? '';
      //print(matchOwnerName + " " + matchDogPicURL);
      // remove from pendingLikes
      final batch = FirebaseFirestore.instance.batch();
      batch.update(currentUserDoc, {
        'pendingMatches': FieldValue.arrayRemove([matchOwnerID])
      });
/*      .update({userDoc.reference
        'pendingLikes': FieldValue.arrayRemove([matchOwnerID])
      });*/
      await batch.commit();
      _pendingMatchesField.remove(matchOwnerID);
    }
    //print(_pendingMatchesField.toString());

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
                    radius: 50,
                    backgroundImage:
                    myDogPicUrl != null ? NetworkImage(myDogPicUrl) : null,
                    child: myDogPicUrl == null ? Text('No picture') : null,
                  ),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: matchDogPicURL != null
                        ? NetworkImage(matchDogPicURL)
                        : null,
                    child: matchDogPicURL == null ? Text('No picture') : null,
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
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                      child: TextButton(
                        onPressed: () {
                          // Take to chat page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MatchChatPage(
                                    friendId: matchOwnerID,
                                    friendName: matchOwnerName,
                                  ),
                            ),
                          );
                        },
                        child: const Text('Chat with match'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: TextButton(
                        onPressed: () {
                          // Close the dialog
                          Navigator.of(context).pop();
                        },
                        child: const Text('Continue finding matches'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
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

  @override
  void initState() {
    super.initState();
    final currentUserDoc = FirebaseAuth.instance.currentUser?.uid;
    DocumentReference reference =
    FirebaseFirestore.instance.collection('users').doc(currentUserDoc);
    reference.snapshots().listen((querySnapshot) {
      setState(() {
        Map<String, dynamic> currentUserData =
        querySnapshot.data() as Map<String, dynamic>;
        if (currentUserData.containsKey("pendingMatches")) {
          _pendingMatchesField = querySnapshot.get("pendingMatches");
          if (_pendingMatchesField.isNotEmpty) {
            _showMatchDialog(context);
          }
          //print("Lyssnar: " + _pendingMatchesField.toString());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersStream =
    FirebaseFirestore.instance.collection('users').snapshots();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Match'),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: () async {
              TimeRange result = await showTimeRangePicker(
                context: context,
                start: _getUserStartTime(),
                end: _getUserEndTime(),
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
                ]
                    .asMap()
                    .entries
                    .map((e) {
                  return ClockLabel.fromIndex(
                    idx: e.key,
                    length: 24,
                    text: e.value,
                  );
                }).toList(),
              );
              DatabaseHandler.storeTimeSlot(result.startTime, result.endTime);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
            ),
            StreamBuilder(
              stream: usersStream,
              builder: (context, userSnapshot) {
                if (userSnapshot.hasData) {
                  // all documents in the users collection
                  final userDocs = userSnapshot.data!.docs;
                  // the current user's document, for easy access
                  DocumentSnapshot currentUserDoc = userDocs.firstWhere(
                          (element) =>
                      element.id == FirebaseAuth.instance.currentUser!.uid);
                  _currentUserDocCopy = currentUserDoc;
                  // remove the current user from the list of potential matches (shouldn't match with yourself)
                  userDocs.remove(currentUserDoc);
                  Map<String, dynamic>? ownerData =
                  currentUserDoc.data() as Map<String, dynamic>?;
                  // until the user has set their availability, they shouldn't be able to see any matches
                  if (_isAvailabilityValid(currentUserDoc)) {
                    if (!ownerData!.containsKey(
                        'LastLocation') /* || ownerData['LastLocation'] == null || ownerData['LastLocation'].isEmpty*/) {
                      return const Text(
                          "Please enable location permissions to find matches");
                    }
                    // filter out users that shouldn't be shown
                    _refineMatches(userDocs, currentUserDoc);
                  } else {
                    return Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(vertical: 60),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset('assets/images/BarkBuddyChatBubble.png',
                                scale: 1.2),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(35, 125, 60, 10),
                              child: Text(
                                'Tell us when you are \n available for a walk today \n by pressing the clock icon!',
                                style: TextStyle(
                                  fontSize: 20.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ));
                  }
                  // if there's no users left that match the criteria, displays a message.
                  if (userDocs.isEmpty) {
                    return Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(vertical: 193),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset('assets/images/BarkBuddyChatBubble.png',
                                scale: 1.2),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(35, 125, 60, 10),
                              child: Text(
                                'No dogs found! \nSet another availability \n or try again later.',
                                style: TextStyle(
                                  fontSize: 20.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ));
                  }

                  // begins the process of displaying the matches
                return Padding(
                padding: const EdgeInsets.only(top: 20),

                  child: CarouselSlider.builder(
                    itemCount: userDocs.length,
                    // loops through the list of potential matches one by one
                    itemBuilder: (context, int itemIndex, int pageViewIndex) {
                      DocumentSnapshot ownerDoc = userDocs[itemIndex];
                      Map<String, dynamic>? ownerData =
                      ownerDoc.data() as Map<String, dynamic>?;
                      if (!ownerData!.containsKey('dogs')) {
                        return const Text('Error: user has no dog!!');
                      }
                      final dogsStream = FirebaseFirestore.instance
                          .collection('Dogs')
                          .doc(ownerDoc['dogs'])
                          .snapshots();
                      return StreamBuilder<DocumentSnapshot>(
                        stream: dogsStream,
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
                          Map<String, dynamic>? dogData =
                          dogDoc.data() as Map<String, dynamic>?;
                          if (!dogData!.containsKey('pictureUrls') ||
                              dogData['pictureUrls'] == null ||
                              dogData['pictureUrls'].isEmpty) {
                            return const Text('Error: dog has no picture(s)');
                          }
                          return _buildPotentialMatch(
                              context, ownerDoc, dogDoc, currentUserDoc);
                        },
                      );
                    },
                    options: CarouselOptions(height: 600,
                      enableInfiniteScroll: userDocs.length > 1,
                      disableCenter: disableSwipe,
                    ),
                  ),
                  );
                } else {
                  return const Text("No data");
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _refineMatches(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> userDocs,
      DocumentSnapshot currentUserDoc) {
    Set<DocumentSnapshot> toRemove = _filterOutUsers(userDocs, currentUserDoc);
    userDocs.removeWhere((element) => toRemove.contains(element));

    // This is difficult
    // if (_userFilterAplied) {
    //   Set<DocumentSnapshot> removeFiltered = _filterOutBasedOnFilter(userDocs);
    //   userDocs.removeWhere((element) => removeFiltered.contains(element));
    // }

    // filter out users based on their availability
    Set<DocumentSnapshot> removeSomeMore =
    _filterOutBasedOnAvailability(userDocs, currentUserDoc);
    userDocs.removeWhere((element) => removeSomeMore.contains(element));

    // sort userDocs by distance from current user
    _sortByDistance(userDocs, currentUserDoc);
  }

  void _sortByDistance(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> userDocs,
      DocumentSnapshot currentUserDoc) {
    GeoPoint currUGP = currentUserDoc['LastLocation'];

    userDocs.sort((a, b) {
      GeoPoint aGP = a['LastLocation'];
      GeoPoint bGP = b['LastLocation'];
      double aDist = _distanceBetween(
          currUGP.latitude, currUGP.longitude, aGP.latitude, aGP.longitude);
      double bDist = _distanceBetween(
          currUGP.latitude, currUGP.longitude, bGP.latitude, bGP.longitude);
      return aDist.compareTo(bDist);
    });
  }

  int _distanceBetweenTwoUsers(DocumentSnapshot a, DocumentSnapshot b) {
    GeoPoint aGP = a['LastLocation'];
    GeoPoint bGP = b['LastLocation'];
    double dist = _distanceBetween(
        aGP.latitude, aGP.longitude, bGP.latitude, bGP.longitude);

    // returns distance in kilometers
    if (dist < 1) {
      return 1;
    } else {
      return dist.round();
    }
  }

  // https://en.wikipedia.org/wiki/Great-circle_distance
  // https://stackoverflow.com/a/21623206
  double _distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = 0.5 -
        cos(p * (lat2 - lat1)) / 2 +
        cos(p * lat1) * cos(p * lat2) * (1 - cos(p * (lon2 - lon1))) / 2;
    // returns distance in kilometers
    return 12742 * asin(sqrt(c));
  }

  Set<DocumentSnapshot> _filterOutBasedOnAvailability(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> userDocs,
      DocumentSnapshot currentUserDoc) {
    Set<DocumentSnapshot> filteredUserDocs = {};

    String currentUserStartTime = currentUserDoc['availability']['startTime'];
    String currentUserEndTime = currentUserDoc['availability']['endTime'];

    TimeRange currUserTR =
    _convertToTimeRange(currentUserStartTime, currentUserEndTime);

    for (var doc in userDocs) {
      if (!_isAvailabilityValid(doc)) {
        filteredUserDocs.add(doc);
        continue;
      }
      String otherStartTime = doc['availability']['startTime'];
      String otherEndTime = doc['availability']['endTime'];
      TimeRange otherUserTR = _convertToTimeRange(otherStartTime, otherEndTime);

      if (!_availabilityOverlaps(currUserTR, otherUserTR)) {
        filteredUserDocs.add(doc);
      }
    }

    return filteredUserDocs;
  }

  bool _availabilityOverlaps(TimeRange userTR, TimeRange otherTR) {
    DateTime userStartTime = _getTimeDateTime(userTR.startTime);
    DateTime userEndTime = _getTimeDateTime(userTR.endTime);
    DateTime otherStartTime = _getTimeDateTime(otherTR.startTime);
    DateTime otherEndTime = _getTimeDateTime(otherTR.endTime);

    if (userStartTime.isAfter(otherEndTime) ||
        userEndTime.isBefore(otherStartTime)) {
      return false;
    }

    DateTime overlapStart =
        userStartTime.isAfter(otherStartTime) ? userStartTime : otherStartTime;
    DateTime overlapEnd =
        userEndTime.isBefore(otherEndTime) ? userEndTime : otherEndTime;

    Duration overlapDuration = overlapEnd.difference(overlapStart);
    return overlapDuration >= const Duration(minutes: 30);
  }

  DateTime _getTimeDateTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

/*  bool _availabilityOverlaps(TimeRange userTR, TimeRange otherTR) {
    if (userTR.endTime.hour < otherTR.startTime.hour ||
        (userTR.endTime.hour == otherTR.startTime.hour &&
            userTR.endTime.minute < otherTR.startTime.minute)) {
      return false;
    }
    if (userTR.startTime.hour > otherTR.endTime.hour ||
        (userTR.startTime.hour == otherTR.endTime.hour &&
            userTR.startTime.minute > otherTR.endTime.minute)) {
      return false;
    }
    return true;
  }*/

  TimeRange _convertToTimeRange(String startTimeString, String endTimeString) {
    final startTimeParts = startTimeString.split(':');
    final endTimeParts = endTimeString.split(':');

    final startTime = TimeOfDay(
      hour: int.parse(startTimeParts[0]),
      minute: int.parse(startTimeParts[1]),
    );

    final endTime = TimeOfDay(
      hour: int.parse(endTimeParts[0]),
      minute: int.parse(endTimeParts[1]),
    );

    final TimeRange timeRange = TimeRange(
      startTime: startTime,
      endTime: endTime,
    );
    return timeRange;
  }

  Set<DocumentSnapshot> _filterOutUsers(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> userDocs,
      DocumentSnapshot currentUserDoc) {
    Set<DocumentSnapshot> toRemove = {};

    for (var doc in userDocs) {
      Map<String, dynamic> userData = doc.data();

      if (userData.containsKey('blockedBy') &&
          userData['blockedBy'] != null &&
          userData['blockedBy'].contains(currentUserDoc.id)) {
        toRemove.add(doc);
        continue;
      }

      if (userData.containsKey('blockedUsers') &&
          userData['blockedUsers'] != null &&
          userData['blockedUsers'].contains(currentUserDoc.id)) {
        toRemove.add(doc);
        continue;
      }

      // removes users that don't have a dog
      if (!userData.containsKey('dogs') ||
          userData['dogs'] == null ||
          userData['dogs'].isEmpty) {
        toRemove.add(doc);
        continue;
      }

      // removes users that are friends
      if (userData.containsKey('friends') &&
          userData['friends'] != null &&
          userData['friends'].contains(currentUserDoc.id)) {
        toRemove.add(doc);
        continue;
      }

      // removes users with no LastLocation
      if (!userData.containsKey('LastLocation') ||
          userData['LastLocation'] == null) {
        toRemove.add(doc);
        continue;
      }

      // removes users that haven't set their availability
      if (!userData.containsKey('availability')) {
        toRemove.add(doc);
        continue;
      }

      Map<String, dynamic> currentUserData =
      currentUserDoc.data() as Map<String, dynamic>;

      // removes users that are already matched with the current user
      if (currentUserData.containsKey('matches') &&
          currentUserData['matches'] != null) {
        if (currentUserData['matches'].contains(doc.id)) {
          toRemove.add(doc);
          continue;
        }
      }

      // removes users that the current user has already liked
      if (currentUserData.containsKey('pendingLikes') &&
          currentUserData['pendingLikes'] != null) {
        if (currentUserData['pendingLikes'].contains(doc.id)) {
          toRemove.add(doc);
        }
      }
    }

    return toRemove;
  }

  Column _buildPotentialMatch(BuildContext context, DocumentSnapshot ownerDoc,
      DocumentSnapshot dogDoc, DocumentSnapshot currentUserDoc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ViewDogProfilePage(userId: ownerDoc.id)),
              );
            },
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.6,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage(dogDoc['pictureUrls'][0]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 10,
            child: InkWell(
              borderRadius: BorderRadius.circular(45),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ViewDogProfilePage(userId: ownerDoc.id)),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 46,
                child: CircleAvatar(
                  radius: 44,
                  backgroundImage: NetworkImage(
                    ownerDoc['picture'],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: 15,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ViewDogProfilePage(userId: ownerDoc.id)),
                );
              },
              child: const Icon(
                Icons.touch_app_outlined,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 15,
            child: Row(children: [
              const Icon(
                Icons.location_on,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 5),
              Text(
                  "${_distanceBetweenTwoUsers(
                      currentUserDoc, ownerDoc)} km away",
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              dogDoc['Gender'].toString() == 'Female'
                  ? Icons.female
                  : Icons.male,
              size: 30,
              color: Colors.black,
            ),
            Text(
              dogDoc['Name'] + ", " + dogDoc['Age'].toString(),
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: const CircleBorder(),
                minimumSize: const Size(45, 45),
                side: const BorderSide(width: 2, color: Colors.redAccent),
              ),
              child: const Icon(
                size: 30,
                Icons.favorite,
                color: Colors.redAccent,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                    Text('Like has been sent'),
                  ),
                );
                DatabaseHandler.sendLike(ownerDoc.id);
              },
            ),
          ],
        ),
      ],
    );
  }

  bool _isAvailabilityValid(DocumentSnapshot userDoc) {
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    if (userData != null) {
      // If the user has not set their availability yet, return false
      if (userData.containsKey('availability') &&
          userData['availability'] is Map<String, dynamic> &&
          userData['availability']!.containsKey('createdOn')) {
        Timestamp availability = userData['availability']['createdOn'];
        DateTime dateTime = availability.toDate();

        // If the availability is from yesterday, it's not valid, return false
        if (DateUtils.isSameDay(dateTime, DateTime.now())) {
          return true;
        }
      }
    }

    return false;
  }

  TimeOfDay _getUserStartTime() {
    if (_isAvailabilityValid(_currentUserDocCopy)) {
      String startTimeString = _currentUserDocCopy['availability']['startTime'];
      String endTimeString = _currentUserDocCopy['availability']['endTime'];
      TimeRange timeRange = _convertToTimeRange(startTimeString, endTimeString);

      return timeRange.startTime;
    } else {
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  TimeOfDay _getUserEndTime() {
    if (_isAvailabilityValid(_currentUserDocCopy)) {
      String startTimeString = _currentUserDocCopy['availability']['startTime'];
      String endTimeString = _currentUserDocCopy['availability']['endTime'];
      TimeRange timeRange = _convertToTimeRange(startTimeString, endTimeString);

      return timeRange.endTime;
    } else {
      return const TimeOfDay(hour: 16, minute: 0);
    }
  }

  void _resetFilter() {
    setState(() {
      _userFilterAplied = false;
      _showSmallDogs = false;
      _showMediumDogs = false;
      _showLargeDogs = false;
      _showFemaleDogs = false;
      _showMaleDogs = false;
      _showHighActDogs = false;
      _showMediumActDogs = false;
      _showLowActDogs = false;
      _showNeuteredDogs = false;
      _showOwnersAge18to24 = false;
      _showOwnersAge25to35 = false;
      _showOwnersAgeAbove35 = false;
      _showOwnerGenderMale = false;
      _showOwnerGenderFemale = false;
      _showOwnerGenderOther = false;
    });
  }

  void _applyFilter() {
    setState(() {
      _userFilterAplied = true;
      _showSmallDogs = _updatedShowSmallDogs;
      _showMediumDogs = _updatedShowMediumDogs;
      _showLargeDogs = _updatedShowLargeDogs;
      _showOwnersAgeAbove35 = _updatedShowOwnersAgeAbove35;
      _showOwnersAge25to35 = _updatedShowOwnersAge25to35;
      _showOwnersAge18to24 = _updatedShowOwnersAge18to24;
      _showHighActDogs = _updatedShowHighActDogs;
      _showMediumActDogs = _updatedShowMediumActDogs;
      _showLowActDogs = _updatedShowLowActDogs;
      _showNeuteredDogs = _updatedShowNeuteredDogs;
      _showFemaleDogs = _updatedShowFemaleDogs;
      _showMaleDogs = _updatedShowMaleDogs;
      _showOwnerGenderOther = _updatedShowOwnerGenderOther;
      _showOwnerGenderMale = _updatedShowOwnerGenderMale;
      _showOwnerGenderFemale = _updatedShowOwnerGenderFemale;
    });
  }

  void _loadSavedFilter() {
    setState(() {
      _updatedShowSmallDogs = _showSmallDogs;
      _updatedShowMediumDogs = _showMediumDogs;
      _updatedShowLargeDogs = _showLargeDogs;
      _updatedShowOwnersAgeAbove35 = _showOwnersAgeAbove35;
      _updatedShowOwnersAge25to35 = _showOwnersAge25to35;
      _updatedShowOwnersAge18to24 = _showOwnersAge18to24;
      _updatedShowHighActDogs = _showHighActDogs;
      _updatedShowMediumActDogs = _showMediumActDogs;
      _updatedShowLowActDogs = _showLowActDogs;
      _updatedShowNeuteredDogs = _showNeuteredDogs;
      _updatedShowFemaleDogs = _showFemaleDogs;
      _updatedShowMaleDogs = _showMaleDogs;
      _updatedShowOwnerGenderOther = _showOwnerGenderOther;
      _updatedShowOwnerGenderMale = _showOwnerGenderMale;
      _updatedShowOwnerGenderFemale = _showOwnerGenderFemale;
    });
  }

}