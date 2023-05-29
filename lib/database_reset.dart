import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseReset {
  Future<void> resetEssentialFieldsInUserCollection() async {
    // Get a reference to the collection
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('users');

    // Get all documents in the collection
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Iterate through each document
    querySnapshot.docs.forEach((DocumentSnapshot docSnapshot) async {
      // Reset all fields in the document
      // commented out so we don't accidentally break something
      await collectionRef.doc(docSnapshot.id).set({
        //'LastLocation': null, this fucks with too much to reset
        'availability': [],
        'pendingLikes': [],
        'friends': [],
        'friendrequests': [],
        'receivedLikes': [],
        'matches': [],
        'pendingMatches': [],
      }, SetOptions(merge: true));
    });
  }

  // log out every user

  Future<void> resetEssentialFieldsInUserDocument(String documentID) async {
    // Get a reference to the document
    DocumentReference documentRef =
        FirebaseFirestore.instance.collection('users').doc(documentID);

    // Reset all fields in the document
    await documentRef.set({
      //'LastLocation': null, this fucks with too much to reset
      'availability': [],
      'pendingLikes': [],
      'friends': [],
      'friendrequests': [],
      'receivedLikes': [],
      'matches': [],
    }, SetOptions(merge: true));
  }
}
