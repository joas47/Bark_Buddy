import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class DatabaseHandler {
  static Future<void> getOwnerProfileData() async {
    final firestoreInstance = FirebaseFirestore.instance;
    final usersCollectionRef = firestoreInstance.collection('users');

    final userUid = FirebaseAuth.instance.currentUser?.uid;

    final userDocumentRef = usersCollectionRef.doc(userUid);

    final userData = await userDocumentRef.get();

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

  static Future<void> updateUser(String fName, String lName, String gender,
      int age, String bio, String? profilePic, String dogRef) async {
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
      'picture': profilePic,
      'dogs': dogRef
    });
  }

  static Future<void> removeUserFromDatabase(String userId) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    users.doc(userId).delete();
  }

  static Future<void> removeOwnerFromDatabase(String emailDocumentId) async {
    // Get a reference to the Firestore instance
    final firestoreInstance = FirebaseFirestore.instance;

    // Define a list to store the references of the dog documents to be removed
    final List<DocumentReference> dogReferencesToRemove = [];

    // Create a batch write operation
    final batch = firestoreInstance.batch();

    // Get a reference to the email document to be removed
    final emailDocumentRef =
    firestoreInstance.collection('emails').doc(emailDocumentId);

    // Retrieve the array field 'dogs' from the email document
    final emailDocumentSnapshot = await emailDocumentRef.get();
    final dogReferences = emailDocumentSnapshot.get('dogs');

    // Iterate through the 'dogs' array and add the corresponding document references to the list
    for (final dogReference in dogReferences) {
      final dogDocumentRef = dogReference as DocumentReference;
      dogReferencesToRemove.add(dogDocumentRef);
    }

    // Remove the email document from the 'emails' collection
    batch.delete(emailDocumentRef);

    // Remove the corresponding dog documents from the 'Dogs' collection
    for (final dogRefToRemove in dogReferencesToRemove) {
      batch.delete(dogRefToRemove);
    }

    // Commit the batch write operation
    await batch.commit();
  }

  static Future<void> addDogToDatabase(String name, String breed, int age, String gender, bool isCastrated, String activity, String size, String biography, String? profilePic) async {
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
      'owner': usersCollectionRef.doc(userUid),
      'picture': profilePic,
    });

    // Add the dog reference to the owner's array of dogs in the 'emails' collection
    final userDocumentRef = usersCollectionRef.doc(userUid);
    batch.update(userDocumentRef, {
      //'dogs': FieldValue.arrayUnion([dogDocumentRef])
      'dogs': dogDocumentRef.id
    });


    // Commit the batch write operation
    await batch.commit();
  }

  static Future<String?> getDogId() async {
    final firestoreInstance = FirebaseFirestore.instance;
    final usersCollectionRef = firestoreInstance.collection('users');

    final User? currentUser = FirebaseAuth.instance.currentUser;
    late final userUid = currentUser?.uid;

    final userDocumentRef = usersCollectionRef.doc(userUid);
    final dogDocumentRef = userDocumentRef.collection('dogs');
    String? dogID = (await dogDocumentRef.get()).docs[0].id;
    return dogID;
  }

  static Future<String?> getDogId2() async {
    String? dogRef;
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    DocumentSnapshot documentSnapshot = await users.doc(userUid).get();
    if (documentSnapshot.exists) {
      dogRef = documentSnapshot.get('dogs');
    }
    return dogRef;
  }

  static Stream<String?> getDogId3() async* {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    final users = FirebaseFirestore.instance.collection('users');
    final dogs = await users.doc(userUid).get().then((doc) => doc.get('dogs') as String?);
    if (dogs != null) {
      yield dogs.toString();
    } else {
      yield null;
    }
  }
  //funkar inte
  static Future<String?>? getDogPic() async {
    final dogUid = await getDogId3().first;
    if (dogUid != null) {
      final dogs = FirebaseFirestore.instance.collection('Dogs');
      final pic = await dogs.doc(dogUid).get().then((doc) => doc.get('picture') as String?).catchError((error) => print("Error getting dog picture: $error"));;
      return pic;
    } else {
      return null;
    }
  }

  static Future<String?>? getOwnerPic() {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    final dogs = FirebaseFirestore.instance.collection('users');
    final pic = dogs.doc(userUid).get().then((doc) => doc.get('picture') as String?);
    if (pic != null) {
      return pic;
    } else {
      return null;
    }
  }

}
