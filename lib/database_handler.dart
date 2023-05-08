import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class DatabaseHandler {
  // TODO: profilePic not used yet
  // TODO: handle lName and bio
  static Future<void> addUserToDatabase(String fName, String lName,
      String gender, int age, String bio, String? profilePic) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    late final userUid = currentUser?.uid;
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final userDocumentRef = users.doc(userUid );
    await userDocumentRef.set({
      'name': fName,
      'gender': gender,
      'age': age,
      'surname': lName,
      'about' : bio,
      'picture' : profilePic
    })
    .then((value) => print("Student data Added"))
        .catchError((error) => print("Student couldn't be added."));
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

  // add a dog to the database
  // link it to an owner
  // TODO: link the dog to the owner with a reference instead of the owner's email
  static Future<void> addDogToDatabase(
      String name, String breed, String ownerEmail, String gender, String activityLevel, String size, String bio) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final dogsCollectionRef = firestoreInstance.collection('Dogs');
    final emailsCollectionRef = firestoreInstance.collection('emails');

    // Create a batch write operation
    final batch = firestoreInstance.batch();

    // Add the dog document to the 'Dogs' collection
    final dogDocumentRef = dogsCollectionRef.doc();
    batch.set(dogDocumentRef, {
      'Breed': breed,
      'Gender': gender,
      'Name': name,
      'owner': ownerEmail,
      'ActivityLevel': activityLevel,
      'Size': size,
      'About': bio,

    });

    // Add the dog reference to the owner's array of dogs in the 'emails' collection
    final emailDocumentRef = emailsCollectionRef.doc(ownerEmail);
    batch.update(emailDocumentRef, {
      'dogs': FieldValue.arrayUnion([dogDocumentRef])
    });

    // Commit the batch write operation
    await batch.commit();
  }
}
