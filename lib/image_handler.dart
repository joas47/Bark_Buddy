import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';

enum ImageType {
  dog,
  owner,
  location,
}

class ImageUtils {
  static Future<File?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  static Future<List<File>?> pickMultipleImagesFromGallery() async {
    try {
      List<Asset> resultList = await MultiImagePicker.pickImages(
        maxImages: 5,
      );
      // Convert Asset to File
      List<File> files = [];
      for (Asset asset in resultList) {
        final byteData = await asset.getByteData();
        final buffer = byteData.buffer;
        final tempFile = File(
            "${(await getTemporaryDirectory()).path}/${asset.name}");
        final file = await tempFile.writeAsBytes(
            buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
        files.add(file);
      }
      return files;
    } catch (e) {
      print(e);
      return null;
    }
  }

  //static Future<File?> takePhoto() async {
  static Future<File?> takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

/*  static Future<void> uploadImageToFirebaseStorage(File imageFile, String userId) async {
    String storageUrl = "gs://bark-buddy";
    userId = FirebaseAuth.instance.currentUser!.uid; // testing only
    try {
      // Create a Firebase Storage reference
      final FirebaseStorage storage = FirebaseStorage.instance;
      final Reference storageRef = storage.ref();

      // Create a folder for the user within the storage bucket
      final userFolderRef = storageRef.child('users/$userId');

      // Generate a unique filename for the image
      final filename = Path.basename(imageFile.path);
      final imageRef = userFolderRef.child(filename);

      // Upload the image file to Firebase Storage
      final uploadTask = imageRef.putFile(imageFile);

      // Monitor the upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: $progress');
      });

      // Await the upload completion
      await uploadTask.whenComplete(() {
        print('Image uploaded successfully');
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }*/

  static Future<String?> uploadImageToFirebase(
      File imageFile, String storageUrl, ImageType imageType) async {
    // TODO: Note: this is intentionally overriding the storageUrl parameter to use the Storage Bucket that resizes the image instead
    String storageUrl = "gs://bark-buddy";
    try {
      // Create a StorageReference to the specified URL
      final storageReference = FirebaseStorage.instance.refFromURL(storageUrl);

      // Create a unique filename for the image
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Get the user's unique identifier or username
      final userId = FirebaseAuth.instance.currentUser?.uid;

      // Create a reference to the user's folder within the storage bucket
      final userFolderReference =
          storageReference.child('users/$userId/images/${imageType.name}');

      // Upload the image to Firebase Storage within the user's folder
      final uploadReference = userFolderReference.child('$fileName.jpg');
      final uploadTask = uploadReference.putFile(imageFile);
      await uploadTask.whenComplete(() {});

      // timestamp for measuring time between upload and resize
      final time = DateTime.now().millisecondsSinceEpoch;
      final resizedURL = await _getResizedURL(userFolderReference, fileName);
      print(
          "Time between upload and resize: ${DateTime.now().millisecondsSinceEpoch - time}ms");
      return resizedURL;
    } catch (e) {
      print("Outer error: $e");
    }
    return null;
  }

  static Future<String> _getResizedURL(
      Reference userFolderReference, String fileName) async {
    // Get the download URL of the uploaded image
    // wait for the image to be resized before returning the url
    try {
      String resizedURL = await userFolderReference
          .child('${fileName}_850x850.jpg')
          .getDownloadURL();
      return resizedURL;
    } catch (e) {
      // wait 1 second before trying again
      Future.delayed(const Duration(seconds: 1));
      return _getResizedURL(userFolderReference, fileName);
    }
  }

  // gamla
  /*static Future<String?> uploadImageToFirebase(File imageFile, String storageUrl) async {
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
  }*/

  // TODO: make this not force you to take 5 pictures in a row, but instead let you take 1, then choose to take another
  // TODO: if you choose an image from the gallery and then take 5 pictures it will upload 6 images. Probably it will upload up to 10 images if you choose 5 from the gallery and then take 5 pictures
  static Future<List?> showImageSourceDialog(BuildContext context,
      {int maxImages = 1}) async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(maxImages > 1 ? 'Select Images' : 'Select Image'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                child: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      if (source == ImageSource.gallery) {
        if (maxImages == 1) {
          final File? image = await pickImageFromGallery();
          if (image != null) {
            return [image];
          }
        } else {
          return await pickMultipleImagesFromGallery();
        }
      } else if (source == ImageSource.camera) {
        if (maxImages == 1) {
          final File? image = await takePhoto();
          if (image != null) {
            return [image];
          }
        } else {
          final images = [];
          for (int i = 0; i < maxImages; i++) {
            final image = await takePhoto();
            if (image != null) {
              images.add(image);
            }
          }
          return images;
        }
      }
    }

    return null;

  }

}
