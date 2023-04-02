import 'package:image_picker/image_picker.dart';

class FileSelectorHandler {
  static Future<XFile> selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      throw Exception('No image selected.');
    } else {
      return pickedFile;
    }
  }
}
