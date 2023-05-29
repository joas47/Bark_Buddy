import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/material/time.dart';

class DatabaseHandler {

  static Future<bool> doesCurrentUserHaveProfile() {
    final firestoreInstance = FirebaseFirestore.instance;
    final usersCollectionRef = firestoreInstance.collection('users');
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    final userDocumentRef = usersCollectionRef.doc(userUid);
    return userDocumentRef.get().then((value) => value.exists);
  }

  static Future<bool> doesCurrentUserHaveDogProfile() async {
    final firestoreInstance = FirebaseFirestore.instance;
    final usersCollectionRef = firestoreInstance.collection('users');

    final userUid = FirebaseAuth.instance.currentUser?.uid;

    final userDocumentRef = usersCollectionRef.doc(userUid);

    final userSnapshot = await userDocumentRef.get();

    if (userSnapshot.exists) {
      final data = userSnapshot.data();
      if (data != null && data.containsKey('dogs')) {
        return true;
      }
    }
    return false;
  }

// Sends like to other person, if they have already liked you, it will create a match
  static Future<bool> sendLike(String friendID) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final usersCollectionRef = firestoreInstance.collection('users');
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String? userUid = currentUser?.uid;

    final ownerDocumentRef = usersCollectionRef.doc(userUid);
    final friendDocumentRef = usersCollectionRef.doc(friendID);

    try {
      final ownerSnapshot = await ownerDocumentRef.get();
      final friendSnapshot = await friendDocumentRef.get();

      if (ownerSnapshot.exists && friendSnapshot.exists) {
        final ownerData = ownerSnapshot.data();
        final friendData = friendSnapshot.data();

        if (ownerData != null && friendData != null) {
          if (ownerData.containsKey('matches') &&
              ownerData['matches'].contains(friendID)) {
            return true;
          } else if (ownerData.containsKey('matches') &&
              ownerData['pendingLikes'].contains(friendID)) {
            return false;
          }

          final batch = firestoreInstance.batch();

          if (ownerData.containsKey('receivedLikes') &&
              ownerData['receivedLikes'].contains(friendID)) {
            batch.update(ownerDocumentRef, {
              'matches': FieldValue.arrayUnion([friendID]),
              'receivedLikes': FieldValue.arrayRemove([friendID]),
              'pendingMatches': FieldValue.arrayUnion([friendID]),
            });

            batch.update(friendDocumentRef, {
              'matches': FieldValue.arrayUnion([userUid]),
              'pendingLikes': FieldValue.arrayRemove([userUid]),
              'pendingMatches': FieldValue.arrayUnion([userUid]),
            });

            await batch.commit();
            return true;
          } else {
            batch.update(ownerDocumentRef, {
              'pendingLikes': FieldValue.arrayUnion([friendID]),
            });

            batch.update(friendDocumentRef, {
              'receivedLikes': FieldValue.arrayUnion([userUid]),
            });

            await batch.commit();
            return false;
          }
        }
      }
    } catch (error) {
      print('Error sending like: $error');
    }

    return false;
  }


  static Future<void> addFriend(String friendUid) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final usersCollectionRef = firestoreInstance.collection('users');

    final User? currentUser = FirebaseAuth.instance.currentUser;
    late final userUid = currentUser?.uid;

    // Create a batch write operation
    final batch = firestoreInstance.batch();

    final userDocumentRef = usersCollectionRef.doc(userUid);
    batch.update(userDocumentRef, {
      'friends': FieldValue.arrayUnion([friendUid]),
      'friendrequests': FieldValue.arrayRemove([friendUid]),
      'matches': FieldValue.arrayRemove([friendUid])
    });

    final friendDocumentRef = usersCollectionRef.doc(friendUid);
    batch.update(friendDocumentRef, {
      'friends': FieldValue.arrayUnion([userUid]),
      'friendrequests': FieldValue.arrayRemove([userUid]),
      'matches': FieldValue.arrayRemove([userUid])
    });

    // Commit the batch write operation
    await batch.commit();
  }

  static Future<void> removeFriend(String friendUid) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final usersCollectionRef = firestoreInstance.collection('users');

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final userUid = currentUser?.uid;

    // Create a batch write operation
    final batch = firestoreInstance.batch();

    // Remove the friendUid from the owner's 'friends' array in the 'users' collection
    final userDocumentRef = usersCollectionRef.doc(userUid);
    batch.update(userDocumentRef, {
      'friends': FieldValue.arrayRemove([friendUid])
    });

    final friendDocumentRef = usersCollectionRef.doc(friendUid);
    batch.update(friendDocumentRef, {
      'friends': FieldValue.arrayRemove([userUid])
    });

    // Commit the batch write operation
    await batch.commit();
  }

  static Future<void> removeFriendrequest(String friendUid) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final usersCollectionRef = firestoreInstance.collection('users');

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final userUid = currentUser?.uid;

    // Create a batch write operation
    final batch = firestoreInstance.batch();

    // Remove the friendUid from the owner's 'friends' array in the 'users' collection
    final userDocumentRef = usersCollectionRef.doc(userUid);
    batch.update(userDocumentRef, {
      'friendrequests': FieldValue.arrayRemove([friendUid])
    });

    // Commit the batch write operation
    await batch.commit();
  }

  static Future<void> sendFriendRequest(String friendUid) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final usersCollectionRef = firestoreInstance.collection('users');
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String? userUid = currentUser?.uid;

    final ownerDocumentRef = usersCollectionRef.doc(userUid);
    final friendDocumentRef = usersCollectionRef.doc(friendUid);

    try {
      final ownerSnapshot = await ownerDocumentRef.get();
      final friendSnapshot = await friendDocumentRef.get();

      if (ownerSnapshot.exists && friendSnapshot.exists) {
        final ownerData = ownerSnapshot.data();
        final friendData = friendSnapshot.data();

        if (ownerData != null && friendData != null) {

          if (ownerData.containsKey('friendrequests') &&
              ownerData['friendrequests'].contains(friendUid)) {
            addFriend(friendUid);
          } else {
            final batch = firestoreInstance.batch();
            batch.update(friendDocumentRef, {
              'friendrequests': FieldValue.arrayUnion([userUid]),
            });

            await batch.commit();
          }
        }
      }
    } catch (error) {
      print('Error sending like: $error');
    }
  }

  static Future<void> block(String friendUid) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final usersCollectionRef = firestoreInstance.collection('users');

    final User? currentUser = FirebaseAuth.instance.currentUser;
    late final userUid = currentUser?.uid;

    // Create a batch write operation
    final batch = firestoreInstance.batch();

    final userDocumentRef = usersCollectionRef.doc(userUid);
    batch.update(userDocumentRef, {
      'blockedUsers': FieldValue.arrayUnion([friendUid]),
      'friendrequests': FieldValue.arrayRemove([friendUid]),
      'friends': FieldValue.arrayRemove([friendUid]),
      'matches': FieldValue.arrayRemove([friendUid])
    });

    final friendDocumentRef = usersCollectionRef.doc(friendUid);
    batch.update(friendDocumentRef, {
      'blockedBy': FieldValue.arrayUnion([userUid]),
      'friendrequests': FieldValue.arrayRemove([userUid]),
      'friends': FieldValue.arrayRemove([userUid]),
      'matches': FieldValue.arrayRemove([userUid])
    });

    // Commit the batch write operation
    await batch.commit();
  }

  static Future<void> unmatch(String matchUid) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final usersCollectionRef = firestoreInstance.collection('users');

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final userUid = currentUser?.uid;

    // Create a batch write operation
    final batch = firestoreInstance.batch();

    // Remove the matchUid from the owner's 'matches' array in the 'users' collection
    final userDocumentRef = usersCollectionRef.doc(userUid);
    batch.update(userDocumentRef, {
      'matches': FieldValue.arrayRemove([matchUid])
    });

    final friendDocumentRef = usersCollectionRef.doc(matchUid);
    batch.update(friendDocumentRef, {
      'matches': FieldValue.arrayRemove([userUid])
    });

    // Commit the batch write operation
    await batch.commit();
  }

  static Future<void> addUserToDatabase(String fName, String lName,
      String gender, int age, String bio, String? profilePic) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    late final userUid = currentUser?.uid;
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final userDocumentRef = users.doc(userUid);
    await userDocumentRef.set({
      'name': fName,
      'gender': gender,
      'age': age,
      'surname': lName,
      'about': bio,
      'picture': profilePic
    });
  }

  static Future<void> addParksToDatabase(double lat, double long, String currentAddress, String bio, String? locationPic) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    late final userUid = currentUser?.uid;
    CollectionReference userparks = FirebaseFirestore.instance.collection('user-parks');
    CollectionReference realParkList = FirebaseFirestore.instance.collection('parks');

    await userparks.add({
      'uid': userUid,
      'latitude': lat,
      'logitude': long,
      'address': currentAddress,
      'about': bio,
      'picture': locationPic
    });

    await realParkList.add({
      'uid': userUid,
      'mid_point': '$lat, $long',
      'address': currentAddress,
      'about': bio,
      'od_gis_id' : null,
      'picture': locationPic
    });


  }

  static Future<void> updateUser(String fName, String lName, String gender,
      int age, String bio, String? profilePic, String dogRef) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    late final userUid = currentUser?.uid;
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final userDocumentRef = users.doc(userUid);
    await userDocumentRef.update({
      'name': fName,
      'gender': gender,
      'age': age,
      'surname': lName,
      'about': bio,
      'picture': profilePic,
      'dogs': dogRef
    });
  }

  static Future<void> addDogToDatabase(String name, String breed, int age, String gender, bool isCastrated, String activity, String size, String biography, List<String> pictureUrls,) async { //String? profilePic
    final firestoreInstance = FirebaseFirestore.instance;
    final dogsCollectionRef = firestoreInstance.collection('Dogs');
    final usersCollectionRef = firestoreInstance.collection('users');

    final User? currentUser = FirebaseAuth.instance.currentUser;
    late final userUid = currentUser?.uid;

    // Create a batch write operation
    final batch = firestoreInstance.batch();

    // Add the dog document to the 'Dogs' collection
    final dogDocumentRef = dogsCollectionRef.doc();
    batch.set(dogDocumentRef, {
      'Name': name,
      'Breed': breed,
      'Age': age,
      'Gender': gender,
      'Is castrated': isCastrated,
      'Activity Level': activity,
      'Size': size,
      'Biography': biography,
      'owner': userUid.toString(),
      'pictureUrls': pictureUrls
    });

    final userDocumentRef = usersCollectionRef.doc(userUid);
    batch.update(userDocumentRef, {
      'dogs': dogDocumentRef.id
    });

    // Commit the batch write operation
    await batch.commit();
  }

  static Future<void> updateDog(String name,
      String breed,
      String gender,
      int age,
      String bio,
      List<String>? pictureUrls,
      String size,
      bool isCastrated,
      String activity,
      String? dogRef) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final dogsCollectionRef = firestoreInstance.collection('Dogs');

    final User? currentUser = FirebaseAuth.instance.currentUser;
    late final userUid = currentUser?.uid;

    final batch = firestoreInstance.batch();

    final dogDocumentRef = dogsCollectionRef.doc(dogRef);
    batch.update(dogDocumentRef, {
      'Name': name,
      'Breed': breed,
      'Age': age,
      'Gender': gender,
      'Is castrated': isCastrated,
      'Activity Level': activity,
      'Size': size,
      'Biography': bio,
      'owner': userUid.toString(),
      'pictureUrls': FieldValue.arrayUnion(pictureUrls!),
    });

    await batch.commit();
  }

  static Stream<String?> getDogId(String? userId) async* {
    String? userUid = userId;
    if(userId == 'defaultValue'){
      userUid = FirebaseAuth.instance.currentUser?.uid;
    }
    final users = FirebaseFirestore.instance.collection('users');
    final dogs = await users.doc(userUid).get().then((doc) => doc.get('dogs') as String?);
    if (dogs != null) {
      yield dogs.toString();
    } else {
      yield null;
    }
  }

  static Stream<String?> getDogPic(String? userId) async* {
    final dogUid = await getDogId(userId).first;
    if (dogUid != null) {
      final dogs = FirebaseFirestore.instance.collection('Dogs');
      yield* dogs.doc(dogUid).snapshots().map((doc) {
        if (doc.exists) {
          final data = doc.data();
          if (data != null && data.containsKey('pictureUrls')) {
            final pictureUrls = data['pictureUrls'] as List<dynamic>;
            if (pictureUrls.isNotEmpty && pictureUrls[0] is String) {
              return pictureUrls[0] as String;
            }
          }
        }
        return null;
      }).handleError((error) {
        print("Error getting dog picture: $error");
        return null;
      });
    } else {
      yield null;
    }
  }

  static Stream<String?> getOwnerPicStream(String userId) {
    final users = FirebaseFirestore.instance.collection('users');
    final ownerDocumentRef = users.doc(userId);

    return ownerDocumentRef.snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data()?['picture'] as String?;
      } else {
        return null;
      }
    });
  }

  static Stream<String?> getDogNameFromOwnerID(String ownerID) async* {
    final users = FirebaseFirestore.instance.collection('users');
    final dogs = await users
        .doc(ownerID)
        .get()
        .then((doc) => doc.get('dogs') as String?);

    if (dogs != null) {
      final dog = FirebaseFirestore.instance.collection('Dogs');
      final name =
      await dog.doc(dogs).get().then((doc) => doc.get('Name') as String?);
      yield name;
    } else {
      yield null;
    }
  }

  static Future<bool> checkIfFriendRequestSent(String friendID)  async {
    final users = FirebaseFirestore.instance.collection('users');
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    final friendSnapshot = await users.doc(friendID).get();
    final friendData = friendSnapshot.data();

    if (friendData != null && friendData.containsKey('friendrequests') && friendData['friendrequests'].contains(userUid)) {
      return true;
    } else {
      return false;
    }
  }

  static void storeTimeSlot(TimeOfDay startTime, TimeOfDay endTime) {
    final firestoreInstance = FirebaseFirestore.instance;
    final usersCollectionRef = firestoreInstance.collection('users');
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String? userUid = currentUser?.uid;
    final batch = firestoreInstance.batch();

    final availability = {
      "createdOn": DateTime.now(),
      "startTime": '${startTime.hour}:${startTime.minute}',
      "endTime": '${endTime.hour}:${endTime.minute}',
    };

    final userDocumentRef = usersCollectionRef.doc(userUid);

    batch.update(userDocumentRef, {'availability': availability});
    batch.commit();
  }
}
