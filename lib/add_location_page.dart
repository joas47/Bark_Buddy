import 'package:cross_platform_test/image_handler.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'database_handler.dart';
import 'file_selector_handler.dart';
import 'package:geocoding/geocoding.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({Key? key}) : super(key: key);

  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  late GoogleMapController mapController;
  bool _showThanksDialog = false;
  //bool _showError = false;
  bool _showBioError = false;
  bool _showImageError = false;

  double _long = 0;
  double _lat = 0;
  String _bio = '';
  String _currentAddress = '';
  String? _locationPic = '';

  // Initialize to a default location
  LatLng _center = LatLng(59.334591, 18.063240);



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
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition();
    _center = LatLng(position.latitude, position.longitude);

    mapController.animateCamera(
      CameraUpdate.newLatLng(_center),
    );
    return position;
  }

  void _handleTap(LatLng latLng) async{
    String storageUrl = "gs://bark-buddy.appspot.com"; // ask about this from morgan. where does the image is stored at? = firebase storage section.
    // and also is it possible to bring this image to the "parks" collection in firestore? = new collection in firebase, called "user-parks"
    // is it possible to pull images from that storage? = no need because we are just gonna be suggesting with text, image suggestion is an extra feature.
    // is it possible to connect a specific userID to those pictures?
    // is the only connection between images in storage and owners collection regarding pictures, pictures field? = yes.

    await _getAddressFromLatLng(latLng.latitude, latLng.longitude);

    setState(() {
      _showThanksDialog = false; // Reset the dialog state
      _center = latLng;
      _lat = latLng.latitude;
      _long = latLng.longitude;
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          if (_showThanksDialog) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                      "Thank you for your recommendation! It will be reviewed before it goes into the location bank."),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog when 'OK' is pressed
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            return Dialog(
              child: Container(
                height: 700, // Change as per your requirement
                width: 500, // Change as per your requirement
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView( // this is the new line
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
                          decoration: InputDecoration(
                            hintText: 'Describe the dog-friendly location',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _bio = value;
                              _showBioError = false; // Reset the error state
                            });
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

                        // ElevatedButton for uploading image
                        ElevatedButton.icon(
                          icon: Icon(Icons.camera),
                          label: Text('Upload image'),
                          onPressed: () async {
                            final selectedImages = await ImageUtils.showImageSourceDialog(context);

                            if (selectedImages != null  && selectedImages.isNotEmpty) {
                              final imageUrl = await ImageUtils.uploadImageToFirebase(
                                selectedImages[0],
                                storageUrl,
                              );
                              setState(() {
                                _locationPic = imageUrl;
                                _showImageError = false; // Reset the error state
                              });
                            } else {
                              setState(() {
                                _showImageError = true;
                              });
                            }
                          },
                        ),
                        // Show image error message
                        if (_showImageError) ...[
                          SizedBox(height: 10),
                          Text(
                            'Please upload an image',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],

                        // ElevatedButton for adding location
                        ElevatedButton(
                          onPressed: () {
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

  // creating an address from LAT and LONG
  Future<void> _getAddressFromLatLng(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      Placemark place = placemarks[0];
      print (place);
      String street = place.street ?? '';
      String postalCode = place.postalCode ?? '';
      String subLocality = place.subLocality ?? '';
      String administrativeArea = place.administrativeArea ?? '';
      String country = place.country ?? '';

      setState(() {
        _currentAddress = '${street.isNotEmpty ? street + ', ' : ''}'
            '${postalCode.isNotEmpty ? postalCode + ', ' : ''}'
            '${subLocality.isNotEmpty ? subLocality + ', ' : ''}'
            '${administrativeArea.isNotEmpty ? administrativeArea + ', ' : ''}'
            '${country.isNotEmpty ? country : ''}';
      });
    } catch (e) {
      print(e);
    }
  }







  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tap on the map to add location'),
          backgroundColor: Colors.green[700],
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
