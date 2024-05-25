import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';

enum ImageType {
  dog,
  owner,
  location,
}

Future<bool?> showYesNoDialog(BuildContext context, String message) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
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

  static Future<File?> takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  static Future<String?> uploadImageToFirebase(
      File imageFile, String storageUrl, ImageType imageType) async {
    // Note: this is intentionally overriding the storageUrl parameter to use the Storage Bucket that resizes the image instead
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
      }else if (source == ImageSource.camera) {
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
              if (i < maxImages - 1) {
                bool? takeAnother = await showYesNoDialog(
                    context,
                    'Do you want to take another photo? You can take ${maxImages - i - 1} more.'
                );
                if (takeAnother != true) {
                  break;
                }
              }
            }
          }
          return images;
        }
      }
    }

    return null;

  }

}
