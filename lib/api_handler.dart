import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

// API-key: c7c0d678-eef3-479e-a11e-df7c921f1dd7

// https://openstreetws.stockholm.se/LvWS-4.0/Lv.svc/json/GetDataCatalog?apikey='
//     'c7c0d678-eef3-479e-a11e-df7c921f1dd7&featureTypeIds=[]&includeAttributeTypes=false

// https://openstreetgs.stockholm.se/geoservice/api/ba9e5991-379f-4eb4-b6a3-e288a3730b2a/wfs?typename=od_gis:Hundrastgard_Yta

// https://soa.stockholm.se/Open/TkData.svc/Rest/lv_gis/wfs?version=1.0.0&request=GetFeature&typeName=lv_gis:Hundrastgard_Yta&outputFormat=GeoPackage
// https://openstreetgs.stockholm.se/geoservice/api/ba9e5991-379f-4eb4-b6a3-e288a3730b2a/wfs?typename=od_gis:Hundrastgard_Yta

// FUNKAR
//https://openstreetws.stockholm.se/LvWS-4.0/Lv.svc/json/GetDataCatalog?apikey='
//      'c7c0d678-eef3-479e-a11e-df7c921f1dd7&featureTypeIds=[]&includeAttributeTypes=false

// hundrasgård_id: 17314453

// Define the API endpoint
const String apiUrl =
    'https://openstreetgs.stockholm.se/geoservice/api/c7c0d678-eef3-479e-a11e-df7c921f1dd7/wfs?service=wfs&version=1.1.0&request=GetFeature&typeName=od_gis%3AHundrastgard_Yta&maxFeatures=50';

class MyDataImporter {
  Future<xml.XmlDocument> getXMLData() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return xml.XmlDocument.parse(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> importXMLData() async {
    final xmlDocument = await getXMLData();
    final firestoreInstance = FirebaseFirestore.instance;
    final batch = firestoreInstance.batch();
    final placeCollection = firestoreInstance.collection('places');

    // Convert the XML data to JSON
    //final jsonData = jsonDecode(jsonEncode(xmlDocument.toXmlString()));

    // Import the JSON data
    final dataList = [xmlDocument];
    for (final item in dataList) {
      final docRef = placeCollection.doc();
      batch.set(docRef, item);
    }

    await batch.commit();
  }

  // Call the API and return the data as a JSON object
  Future<dynamic> getData() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Import the data into Firebase Realtime Database
  Future<void> importData() async {
    final data = await getData();
    final firestoreInstance = FirebaseFirestore.instance;
    final batch = firestoreInstance.batch();
    final placeCollection = firestoreInstance.collection('places');

    final dataList = [data];

    for (final item in dataList) {
      final docRef = placeCollection.doc();
      batch.set(docRef, item);
    }

    //final dbRef = FirebaseDatabase.instance.reference().child('myData');
    //batch.set(data, placeCollection);
    await batch.commit();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MyDataImporter().importData();
}

/*Future<Album> fetchAlbum() async {
  final response = await http
      .get(Uri.parse('https://openstreetws.stockholm.se/LvWS-4.0/Lv.svc/json/GetDataCatalog?apikey='
      'c7c0d678-eef3-479e-a11e-df7c921f1dd7&featureTypeIds=[]&includeAttributeTypes=false'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}*/

/*void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}*/

/*
class _MyAppState extends State<MyApp> {
  late Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<Album>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!.title);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}*/
