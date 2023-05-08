import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/widgets.dart';

class ImageUtils {
  static Future<File?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  static Future<File?> takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  static Future<String?> uploadImageToFirebase(File imageFile, String storageUrl) async {
    try {
      // Create a StorageReference to the specified URL
      final storageReference = FirebaseStorage.instance.refFromURL(storageUrl);

      // Create a unique filename for the image
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final uploadReference = storageReference.child('images/$fileName');

      // Upload the image to Firebase Storage
      final uploadTask = uploadReference.putFile(imageFile);
      await uploadTask.whenComplete(() {});

      // Get the download URL of the uploaded image
      final url = await uploadReference.getDownloadURL();
      return url;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<File?> showImageSourceDialog(BuildContext context) async {
    return showDialog<File>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Select Image'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context, await pickImageFromGallery());
                },
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                child: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context, await takePhoto());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
