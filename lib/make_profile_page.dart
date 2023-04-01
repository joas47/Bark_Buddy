import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class MakeProfilePage extends StatefulWidget {
  const MakeProfilePage({super.key});

  @override
  _MakeProfilePageState createState() => _MakeProfilePageState();
}

class _MakeProfilePageState extends State<MakeProfilePage> {
  String _name = '';
  int _age = 0;
  String _gender = '';
  String _profilePictureUrl = '';

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tell us more about yourself!',
              style: TextStyle(fontSize: 24.0),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
              keyboardType: TextInputType.name,
              onChanged: (value) {
                _name = value;
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _age = int.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _genderOptions
                  .map((option) => Row(
                        children: [
                          Radio(
                            value: option,
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value.toString();
                              });
                            },
                          ),
                          Text(option),
                          const SizedBox(width: 16.0),
                        ],
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16.0),
            _buildProfilePictureUploadButton(),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_name.isNotEmpty || !_age.isNegative) {
                  // TODO: save owner to database
                  //Owner owner = Owner(_name, _age, _gender);
                  Navigator.pushNamed(context, '/register-dog');
                } else {
                  // TODO: fields cannot be empty message
                }
              },
              child: const Text('Save profile'),
            ),
          ],
        ),
      ),
    );
  }

  // TODO: refactor this into a separate file to be reused in other pages
  void _openFileSelector() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      PlatformFile file = result.files.first;
      // TODO: Handle the selected file here.
    } else {
      // User canceled the file selection.
    }
  }

  Widget _buildProfilePictureUploadButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Upload profile picture',
          style: TextStyle(fontSize: 18.0),
        ),
        const SizedBox(width: 16.0),
        IconButton(
          onPressed: () {
            // TODO: handle profile picture upload
            _openFileSelector();
          },
          icon: const Icon(Icons.upload),
        ),
      ],
    );
  }
}
