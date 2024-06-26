import 'package:cross_platform_test/image_handler.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'database_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AddLocationPage extends StatefulWidget {
  const AddLocationPage({Key? key}) : super(key: key);

  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  late GoogleMapController mapController;
  bool _showThanksDialog = false;
  bool _showBioError = false;
  bool _showImageError = false;

  double _long = 0;
  double _lat = 0;
  String _bio = '';
  String _currentAddress = '';
  String? _locationPic = '';

  // Initialize to a default location,(Sweden)
  LatLng _center = LatLng(59.334591, 18.063240);
  bool _uploading = false;
  final TextEditingController _bioController = TextEditingController();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _determinePosition();
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    } else if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, Needed for user live location.');
    }
    Position position = await Geolocator.getCurrentPosition();
    _center = LatLng(position.latitude, position.longitude);

    mapController.animateCamera(
      CameraUpdate.newLatLng(_center),
    );
    return position;
  }



  Future<bool> _isLocationWater(double latitude, double longitude) async {
    final queryParameters = {
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'format': 'json',
    };

    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', queryParameters);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      var locationType = data['address']?['waterway'];
      if (locationType != null) {
        return true;
      }
    }
    return false;
  }

  void _handleTap(LatLng latLng) async{
    String storageUrl = "gs://bark-buddy.appspot.com";

    bool isWater = await _isLocationWater(latLng.latitude, latLng.longitude);
    if(isWater){
      return;
    }
    try {
      await _getAddressFromLatLng(latLng.latitude, latLng.longitude);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('No address information found for tapped location, not adding'),
        ),
      );
      return;
    }


    await _getAddressFromLatLng(latLng.latitude, latLng.longitude).catchError((error) async {
      print('Error occurred while getting address: $error');

    });

    setState(() {
      _showThanksDialog = false;
      _center = latLng;
      _lat = latLng.latitude;
      _long = latLng.longitude;
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {

          if (_uploading) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Uploading location...'),
                  CircularProgressIndicator(),
                  Text("Uploading Image, please wait..."),
                ],
              ),
            );
          } else if (_showThanksDialog) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                      "Thank you for your recommendation! It will be reviewed before it goes into the location bank."),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            return Dialog(
              child: Container(
                height: 700,
                width: 500,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('You tapped on:'),
                        TextField(
                          controller: TextEditingController(
                              text: 'Latitude: ${_center.latitude}'),
                          enabled: false,
                        ),

                        TextField(
                          controller: TextEditingController(
                              text: 'Longitude: ${_center.longitude}'),
                          enabled: false,
                        ),
                        TextField(
                          minLines: 1,
                          maxLines: 6,
                          controller: TextEditingController(
                              text: 'Address: $_currentAddress'),
                          enabled: false,
                        ),

                        TextField(
                          minLines: 1,
                          maxLines: 6,
                          controller: _bioController,
                          decoration: InputDecoration(
                            hintText: 'Describe the dog-friendly location',
                          ),
                          onChanged: (value) {
                            _bio = value;
                            _showBioError = false;
                          },
                        ),
                        // show bio error message
                        if (_showBioError) ...[
                          SizedBox(height: 10),
                          Text(
                            'Please provide a description',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                        ElevatedButton.icon(
                          icon: Icon(Icons.camera),
                          label: Text('Upload image'),
                          onPressed: _uploading? null : () async {
                            final selectedImages = await ImageUtils.showImageSourceDialog(context);

                            if (selectedImages != null  && selectedImages.isNotEmpty) {
                              setState((){
                                _uploading = true;
                              });
                              final imageUrl = await ImageUtils.uploadImageToFirebase(
                                selectedImages[0],
                                storageUrl,
                                ImageType.location);
                              setState(() {
                                _locationPic = imageUrl;
                                _showImageError = false;
                                _uploading = false;
                              });
                            } else {
                              setState(() {
                                _showImageError = true;
                              });
                            }
                          },
                        ),
                        if (_showImageError) ...[
                          SizedBox(height: 10),
                          Text(
                            'Please upload an image',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                        ElevatedButton(
                          onPressed: _uploading ? null : () {
                            if (_bio.isEmpty || _locationPic == null || _locationPic!.isEmpty) {
                              setState(() {
                                _showBioError = _bio.isEmpty;
                                _showImageError = _locationPic == null || _locationPic!.isEmpty;
                              });
                              return;
                            }
                            DatabaseHandler.addParksToDatabase(_lat, _long, _currentAddress, _bio, _locationPic);
                            setState(() {
                              _showThanksDialog = true;
                            });
                          },
                          child: Text('Add'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
      },
    );
  }

  Future<void> _getAddressFromLatLng(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      Placemark place = placemarks[0];
      String street = place.street ?? '';
      String postalCode = place.postalCode ?? '';
      String subLocality = place.subLocality ?? '';
      String administrativeArea = place.administrativeArea ?? '';
      String country = place.country ?? '';

      if(street.isEmpty || administrativeArea.isEmpty || country.isEmpty) {
        throw Exception('Invalid location');
      }

      setState(() {
        _currentAddress = '${street.isNotEmpty ? street + ', ' : ''}'
            '${postalCode.isNotEmpty ? postalCode + ', ' : ''}'
            '${subLocality.isNotEmpty ? subLocality + ', ' : ''}'
            '${administrativeArea.isNotEmpty ? administrativeArea + ', ' : ''}'
            '${country.isNotEmpty ? country : ''}';
      });
    } catch (e) {
      print(e);
      throw e;  // Re-throw the exception to be handled by the caller
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tap on the map to add location'),
         backgroundColor: Colors.green[700],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
         ),
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              myLocationEnabled: true,
              onTap: (LatLng location) {
                _handleTap(location);
              },
            ),
          ],
        ),
      ),
    );
  }

}
