import 'package:cross_platform_test/settings_page.dart';
import 'package:cross_platform_test/view_owner_profile_page.dart';
import 'package:flutter/material.dart';

import 'edit_dog_profile_page.dart';

class ViewDogProfilePage extends StatelessWidget {
  const ViewDogProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hundprofil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings functionality.
              // goto settings page
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
            },
          ),
        ],
      ),
      body: Stack(alignment: Alignment.center, children: <Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <
            Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: ElevatedButton(
              child: const Text('Lägg till plats'),
              onPressed: () {},
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ViewOwnerProfile()));
              },
              child: const CircleAvatar(
                radius: 50.0,
                backgroundImage:
                    // TODO: get this information from the database
                    AssetImage('assets/images/placeholder-profile-image.png'),
              ),
            ),
          ),
        ]),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 10.0),
            InkWell(
                onTap: () async {
                  await showDialog(
                      context: context,
                      builder: (context) => const ImageDialog(
                            imagePaths: [
                              'assets/images/placeholder-dog-image.png',
                              'assets/images/placeholder-dog-image2.png',
                            ],
                            initialIndex: 0, // Display second image first
                          ));
                },
                child: const CircleAvatar(
                  radius: 100.0,
                  backgroundImage:
                      // TODO: get this information from the database
                      AssetImage('assets/images/placeholder-dog-image2.png'),
                )),
            const Text(
              'Max',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              //height: 500.0,
              width: 300.0,
              child: TextField(
                readOnly: true,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  // TODO: get this information from the database
                    hintText:
                        '• Tik \n• Stor \n• Golden Retriever\n• Hög aktivitetsnivå',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => const EditOwnerProfile()));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EditDogProfile()));
                      },
                    )),
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            const SizedBox(
              //height: 500.0,
              width: 300.0,
              child: TextField(
                readOnly: true,
                minLines: 5,
                maxLines: 5,
                decoration: InputDecoration(
                  // TODO: get this information from the database
                  hintText: '• Placeholder bio',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

class ImageDialog extends StatefulWidget {
  const ImageDialog({Key? key, required this.imagePaths, this.initialIndex = 0})
      : super(key: key);

  final List<String> imagePaths;
  final int initialIndex;

  @override
  _ImageDialogState createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
  late PageController _pageController;
  late int _currentIndex;
  late int _totalImages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _totalImages = widget.imagePaths.length;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 500,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: _totalImages,
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: ExactAssetImage(widget.imagePaths[index]),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                );
              },
            ),
            if (_currentIndex > 0)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
              ),
            if (_currentIndex < _totalImages - 1)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child:
                      const Icon(Icons.arrow_forward_ios, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}