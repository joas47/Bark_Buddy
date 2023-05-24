import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/database_handler.dart';
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
                // TODO: if the user has already set their availability, show that instead of the default
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
                // TODO: implement max and min duration you can be available? Min 1 hour, max 12-16 hours?
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
              //DatabaseHandler.setAvailability(result.startTime, result.endTime);
              DatabaseHandler.storeTimeSlot(result.startTime, result.endTime);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 18),
                const Text('Filter: '),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Filter Options'),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                // Add your filter options here
                                ExpansionTile(
                                  title: Text('Dogs'),
                                  children: <Widget>[
                                    ExpansionTile(
                                      title: Text('Size'),
                                      children: <Widget>[
                                        FilterCheckbox(title: 'Small'),
                                        FilterCheckbox(title: 'Medium'),
                                        FilterCheckbox(title: 'Large'),

                                      ],
                                    ),
                                    ExpansionTile(
                                      title: Text('Gender'),
                                      children: <Widget>[
                                        FilterCheckbox(title: 'Male'),
                                        FilterCheckbox(title: 'Female'),
                                        FilterCheckbox(title: 'Neutered'),
                                      ],
                                    ),
                                    ExpansionTile(
                                      title: Text('Activity level'),
                                      children: <Widget>[
                                        FilterCheckbox(title: 'Low'),
                                        FilterCheckbox(title: 'Medium'),
                                        FilterCheckbox(title: 'High'),
                                      ],
                                    ),
                                  ],
                                ),
                                ExpansionTile(
                                  title: Text('Owners'),
                                  children: <Widget>[
                                    ExpansionTile(
                                      title: Text('Age'),
                                      children: <Widget>[
                                        FilterCheckbox(title: '18 - 24'),
                                        FilterCheckbox(title: '25 - 35'),
                                        FilterCheckbox(title: '36+'),
                                      ],
                                    ),
                                    ExpansionTile(
                                      title: Text('Gender'),
                                      children: <Widget>[
                                        FilterCheckbox(title: 'Male'),
                                        FilterCheckbox(title: 'Female'),
                                        FilterCheckbox(title: 'Other'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Apply'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Implement filter logic here based on selected options
                              },
                            ),
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                // You can place other children here as required
                //_filterDropdown(),
                //_buildSubcategoryDropdown(),
              ],
            ),
            StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.hasData) {
                  // all documents in the users collection
                  final userDocs = userSnapshot.data!.docs;
                  // the current user's document, for easy access
                  DocumentSnapshot currentUserDoc = userDocs.firstWhere(
                      (element) =>
                          element.id == FirebaseAuth.instance.currentUser!.uid);
                  // remove the current user from the list of potential matches (shouldn't match with yourself)
                  userDocs.remove(currentUserDoc);
                  // until the user has set their availability, they shouldn't be able to see any matches
                  if (currentUserDoc
                      .data()
                      .toString()
                      .contains('availability')) {
                    Set<DocumentSnapshot<Object?>> toRemove =
                        _filterOutUsers(userDocs, currentUserDoc);
                    userDocs
                        .removeWhere((element) => toRemove.contains(element));

                    Set<DocumentSnapshot<Object?>> removeSomeMore =
                        _filterOutBasedOnAvailability(userDocs, currentUserDoc);
                    userDocs.removeWhere(
                        (element) => removeSomeMore.contains(element));

                    // sort userDocs by distance from current user
                    _sortByDistance(userDocs, currentUserDoc);
                  } else {
                    // TODO: make this message prettier
                    return const Center(
                      child:
                          Text('Click the clock icon to set your availability'),
                    );
                  }
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
                      if (!ownerDoc.data().toString().contains('dogs')) {
                        return const Text('Error: user has no dog!!');
                      }
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
                          if (!dogDoc
                              .data()
                              .toString()
                              .contains('pictureUrls')) {
                            return const Text('Error: dog has no picture');
                          }
                          List<dynamic>? dogPicURLs = dogDoc['pictureUrls'];
                          if (dogPicURLs != null && dogPicURLs.isEmpty) {
                            return const Text('Error: dog has no picture');
                          }
                          return _buildPotentialMatch(
                              context, ownerDoc, dogDoc);
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
          ],
        ),
      ),
    );
  }

  void _sortByDistance(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> userDocs,
      DocumentSnapshot<Object?> currentUserDoc) {
    GeoPoint currUGP = currentUserDoc['LastLocation'];
    /*print("Current user location: lat: " + currUGP.latitude.toString() + " long: " + currUGP.longitude.toString());

    for (var doc in userDocs) {
      GeoPoint otherUGP = doc['LastLocation'];
      print("Other user location: lat: " + otherUGP.latitude.toString() + " long: " + otherUGP.longitude.toString());
    }*/

    userDocs.sort((a, b) {
      GeoPoint aGP = a['LastLocation'];
      GeoPoint bGP = b['LastLocation'];
      double aDist = _distanceBetween(
          currUGP.latitude, currUGP.longitude, aGP.latitude, aGP.longitude);
      double bDist = _distanceBetween(
          currUGP.latitude, currUGP.longitude, bGP.latitude, bGP.longitude);
      return aDist.compareTo(bDist);
    });
/*
    for (var element in userDocs) {
      print(element.get('name') + "'s distance from current user: " + _distanceBetween(currUGP.latitude, currUGP.longitude, element['LastLocation'].latitude, element['LastLocation'].longitude).toString());
    }*/
  }

  // https://en.wikipedia.org/wiki/Great-circle_distance
  // https://stackoverflow.com/a/21623206
  double _distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = 0.5 -
        cos(p * (lat2 - lat1)) / 2 +
        cos(p * lat1) * cos(p * lat2) * (1 - cos(p * (lon2 - lon1))) / 2;
    return 12742 * asin(sqrt(c));
  }

  Set<DocumentSnapshot> _filterOutBasedOnAvailability(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> userDocs,
      DocumentSnapshot<Object?> currentUserDoc) {
    Set<DocumentSnapshot> filteredUserDocs = {};

    String currentUserStartTime = currentUserDoc['availability']['startTime'];
    String currentUserEndTime = currentUserDoc['availability']['endTime'];

    TimeRange currUserTR =
        _convertToTimeRange(currentUserStartTime, currentUserEndTime);
    //print("Current user time range: " + currUserTR.toString());

    for (var doc in userDocs) {
      String otherStartTime = doc['availability']['startTime'];
      String otherEndTime = doc['availability']['endTime'];
      TimeRange otherUserTR = _convertToTimeRange(otherStartTime, otherEndTime);

      if (!_overlapsWith(currUserTR, otherUserTR)) {
        filteredUserDocs.add(doc);
        //print("Other user time range: " + otherUserTR.toString());
      } else {
        //print("Other user time range: " + otherUserTR.toString() + " overlaps with current user time range");
      }
    }

    return filteredUserDocs;
  }

  bool _overlapsWith(TimeRange userTR, TimeRange otherTR) {
    if (userTR.startTime.hour > otherTR.endTime.hour ||
        userTR.endTime.hour < otherTR.startTime.hour) {
      return false;
    } else if (userTR.startTime.hour == otherTR.endTime.hour &&
        userTR.startTime.minute > otherTR.endTime.minute) {
      return false;
    } else if (userTR.endTime.hour == otherTR.startTime.hour &&
        userTR.endTime.minute < otherTR.startTime.minute) {
      return false;
    }
    return true;
  }

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
      DocumentSnapshot<Object?> currentUserDoc) {
    Set<DocumentSnapshot> toRemove = {};

    for (var doc in userDocs) {
      // removes users that don't have a dog
      doc.data().toString().contains('dogs') ? null : toRemove.add(doc);
      // removes users that are already matched with the current user
      if (currentUserDoc.data().toString().contains('matches')) {
        if (currentUserDoc['matches'].contains(doc.id)) {
          toRemove.add(doc);
        }
      }
      // removes users that the current user has already liked
      if (currentUserDoc.data().toString().contains('pendingLikes')) {
        if (currentUserDoc['pendingLikes'].contains(doc.id)) {
          toRemove.add(doc);
        }
      }
      // removes users that hasn't set their availability
      doc.data().toString().contains('availability') ? null : toRemove.add(doc);
    }
    return toRemove;
  }

  Column _buildPotentialMatch(BuildContext context,
      DocumentSnapshot<Object?> ownerDoc, DocumentSnapshot<Object?> dogDoc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(alignment: AlignmentDirectional.bottomCenter, children: [
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
          Positioned(
            bottom: 330,
            left: 230,
            child: InkWell(
              borderRadius: BorderRadius.circular(45),
              onTap: () {
                // TODO: when pressing the owner profile from here, and in the view owner profile page pressing the dog profile it goes back to the find match page. (pops the navigation stack)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ViewOwnerProfile(userId: ownerDoc.id)),
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
            bottom: 380,
            right: 280,
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
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dogDoc['Name'] + ", " + dogDoc['Age'].toString(),
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              dogDoc['Gender'].toString() == 'Female'
                  ? Icons.female
                  : Icons.male,
              size: 30,
              color: Colors.black,
            ),
          ],
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
          onPressed: () async {
            // TODO: give feedback when liking a dog, right now it just disappears
            // TODO: if the last dog in the carousel is liked, the match dialog will not show if there's a match
            bool isMatch = await DatabaseHandler.sendLike(ownerDoc.id);
            if (isMatch) {
              final User? currentUser = FirebaseAuth.instance.currentUser;
              String? myDogPicUrl =
                  await DatabaseHandler.getDogPic(currentUser?.uid).first;
              _showMatchDialog(
                  context, ownerDoc.id, myDogPicUrl, dogDoc['pictureUrls'][0]);
            }
          },
        ),
      ],
    );
  }

  String _selectedCategory = 'Dog';
  String _selectedSubcategory = 'Size';

  List<String> _categories = ['Dog', 'Owner'];
  Map<String, List<String>> _subcategories = {
    'Dog': ['Size', 'Gender', 'Activity Level'],
    'Owner': ['Age', 'Location', 'Experience'],
    'Size': ['Small', 'Medium', 'Large'],
    'Gender': ['Male', 'Female'],
    'Activity Level': ['High', 'Medium', 'Low'],
    'Age': ['Young', 'Adult', 'Senior']
  };

  Widget _filterDropdown() {
    return DropdownButton<String>(
      value: _selectedCategory,
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = newValue!;
          _selectedSubcategory = _subcategories[newValue]![0];
        });
      },
      items: _categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
    );
  }

  Widget _buildSubcategoryDropdown() {
    return DropdownButton<String>(
      value: _selectedSubcategory,
      onChanged: (String? newValue) {
        setState(() {
          _selectedSubcategory = newValue!;
        });
      },
      items: _subcategories[_selectedCategory]!.map((String subcategory) {
        return DropdownMenuItem<String>(
          value: subcategory,
          child: Text(subcategory),
        );
      }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedSubcategory = _subcategories[_selectedCategory]![0];
  }
}

class FilterCheckbox extends StatefulWidget {
  final String title;

  const FilterCheckbox({super.key, required this.title});

  @override
  _FilterCheckboxState createState() => _FilterCheckboxState();
}

class _FilterCheckboxState extends State<FilterCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.title),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
        });
        // Handle checkbox state change here
        print('Checkbox ${widget.title} changed to $value');
      },
    );
  }
}
