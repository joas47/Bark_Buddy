import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationHandler {
  static void grabAndSaveLocation() async {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    final fireStoreInstance = FirebaseFirestore.instance;
    final usersCollectionRef = fireStoreInstance.collection('users');

    // Wait for GPS accuracy
    await Future.delayed(Duration(seconds: 3));

    // Get user's location coordinates
    // TODO: Handle location permission denied, right now it gives error when trying to access the LastLocation field
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Obfuscate location by adding random offset
    final obfuscatedPosition = obfuscateLocation(position);

    // Save obfuscated location to Firestore
/*    usersCollectionRef.doc(userUid).update({
      'LastLocation': GeoPoint(obfuscatedPosition.latitude, obfuscatedPosition.longitude),
    });*/
  }

  static Position obfuscateLocation(Position originalPosition) {
    final random = Random();
    final offsetDistance = random.nextInt(151) + 50; // Random distance between 50 and 200 meters

    // Random angle in radians
    final angle = random.nextDouble() * 2 * pi;

    // Calculate obfuscated coordinates
    final latitudeOffset = offsetDistance * cos(angle) / 111111;
    final longitudeOffset = offsetDistance * sin(angle) / (111111 * cos(originalPosition.latitude * pi / 180));

    final obfuscatedLatitude = originalPosition.latitude + latitudeOffset;
    final obfuscatedLongitude = originalPosition.longitude + longitudeOffset;

    return Position(
      latitude: obfuscatedLatitude,
      longitude: obfuscatedLongitude,
      accuracy: originalPosition.accuracy,
      altitude: originalPosition.altitude,
      heading: originalPosition.heading,
      speed: originalPosition.speed,
      speedAccuracy: originalPosition.speedAccuracy,
      timestamp: originalPosition.timestamp,
    );
  }
}