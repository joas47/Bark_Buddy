import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class DatabaseHandler {
  // TODO: profilePic not used yet
  static Future<void> addUserToDatabase(
      String name, int age, String gender, XFile profilePic) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users.add({
      'name': name,
      'age': age,
      'gender': gender,
    });
  }

  static Future<void> removeUserFromDatabase(String userId) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    users.doc(userId).delete();
  }

  // add a dog to the database
  // link it to an owner
  // breed, gender, name, owner (email)
  // TODO: link the dog to the owner with a reference
  static Future<void> addDogToDatabase(
      String name, String breed, String ownerEmail, String gender) async {
    CollectionReference dogs = FirebaseFirestore.instance.collection('Dogs');
    // add the dog to the database and save the reference
    DocumentReference dogRef = await dogs.add({
      'Breed': breed,
      'Gender': gender,
      'Name': name,
      'owner': ownerEmail,
    });

    // add the dog reference to the owner's array of dogs
    CollectionReference emails =
        FirebaseFirestore.instance.collection('emails');
    emails.doc(ownerEmail).update({
      'dogs': FieldValue.arrayUnion([dogRef])
    });
  }

// remove a dog from the database
}
