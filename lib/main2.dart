import 'package:flutter/material.dart';

// for the MatchChatPage
//import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bark Buddy',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      initialRoute: '/',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/make-profile': (context) => MakeProfilePage(),
        '/find-match': (context) => FindMatchPage(),
        '/profile': (context) => ViewProfilePage(),
        '/match-chat': (context) => MatchChatPage(),
        '/settings': (context) => SettingsPage(),
        '/register-dog': (context) => RegisterDogPage(),
      },
      home: LoginPage(),
    );
  }
}

class RegisterDogPage extends StatefulWidget {
  @override
  _RegisterDogPageState createState() => _RegisterDogPageState();
}

class _RegisterDogPageState extends State<RegisterDogPage> {
  String _name = '';
  String _breed = '';
  int _age = 0;
  String _gender = '';
  String _imageUrl = '';

  final List<String> _genderOptions = ['Male', 'Female'];

  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register your dog'),
      ),
      body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100.0),
                Text(
                  'Enter your dog\'s information',
                  style: TextStyle(fontSize: 24.0),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                  keyboardType: TextInputType.name,
                  onChanged: (value) {
                    _name = value;
                  },
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _breedController,
                  decoration: InputDecoration(
                    labelText: 'Breed',
                  ),
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    _breed = value;
                  },
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _age = int.tryParse(value) ?? 0;
                  },
                ),
                SizedBox(height: 16.0),
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
                              SizedBox(width: 16.0),
                            ],
                          ))
                      .toList(),
                ),
                SizedBox(height: 16.0),
                _buildImageUploadButton(),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // TODO: save dog information
                    Navigator.pushNamed(context, '/find-match');
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildImageUploadButton() {
    return Container(
      child: Column(
        children: [
          _imageUrl.isEmpty
              ? Container()
              : Container(
                  width: 200.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(_imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Upload dog picture',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(width: 16.0),
              IconButton(
                onPressed: () {
                  // TODO: handle image upload
                },
                icon: Icon(Icons.upload),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
            child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 64.0),
              Image.asset(
                'assets/images/bark_buddy_logo.png',
                height: 100,
              ),
              SizedBox(height: 64.0),
              Text(
                'Welcome to Bark Buddy!',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32.0),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement login functionality.
                  Navigator.pushNamed(context, '/make-profile');
                },
                child: Text('Login'),
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('Don\'t have an account? Register here.'),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Register'),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Create your account!',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32.0),
                TextField(
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement registration functionality.
                    Navigator.pushNamed(context, '/make-profile');
                  },
                  child: Text('Register'),
                ),
                SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Already have an account? Login here.'),
                ),
              ],
            ),
          ),
        ));
  }
}

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
        title: Text('Make profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tell us more about yourself!',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
              keyboardType: TextInputType.name,
              onChanged: (value) {
                _name = value;
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: 'Age',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _age = int.tryParse(value) ?? 0;
              },
            ),
            SizedBox(height: 16.0),
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
                          SizedBox(width: 16.0),
                        ],
                      ))
                  .toList(),
            ),
            SizedBox(height: 16.0),
            _buildProfilePictureUploadButton(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // TODO: save profile
                Navigator.pushNamed(context, '/register-dog');
              },
              child: Text('Save profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureUploadButton() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Upload profile picture',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(width: 16.0),
          IconButton(
            onPressed: () {
              // TODO: handle profile picture upload
            },
            icon: Icon(Icons.upload),
          ),
        ],
      ),
    );
  }
}

class FindMatchPage extends StatelessWidget {
  const FindMatchPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Match'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dog image, name, breed, gender, and owner info
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  image: DecorationImage(
                    image:
                        AssetImage('assets/images/placeholder-dog-image.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16.0),
                          bottomRight: Radius.circular(16.0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dog Name',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Breed, Gender',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            children: [
                              Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/placeholder-profile-image.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Owner Name',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Age, Distance',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Like and dislike buttons
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_down),
                    onPressed: () {},
                  ),
                  SizedBox(width: 64.0),
                  IconButton(
                    icon: Icon(Icons.thumb_up),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Match Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'Friends',
        ),
      ],
      currentIndex: 0,
      selectedItemColor: Theme.of(context).colorScheme.secondary,
      onTap: (index) {
        if (index == 0) {
          // Navigate to the profile page
          Navigator.pushNamed(context, '/profile');
        } else if (index == 1) {
          // Navigate to the match chat page
          Navigator.pushNamed(context, '/match-chat');
        }
      },
    );
  }
}

class ViewProfilePage extends StatelessWidget {
  const ViewProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings functionality.
              // goto settings page
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50.0,
              backgroundImage:
                  AssetImage('assets/images/placeholder-profile-image.png'),
            ),
            SizedBox(height: 10.0),
            Text(
              'John Doe',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              '25 years old',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'Male',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'Likes: Pizza, hiking, and reading',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.0),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchChatPage extends StatelessWidget {
  const MatchChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Chat'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chat with your match!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.0),
            // TODO: Implement chat UI.
          ],
        ),
      ),
    );
  }
}

// with some basic API calls
/*class MatchChatPage extends StatelessWidget {
  final String matchId;

  MatchChatPage({required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('matchId', isEqualTo: matchId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs;
                List<Widget> messages = docs.map((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String,
                      dynamic>;
                  return ListTile(
                    title: Text(data['message']),
                    subtitle: Text(data['sender']),
                  );
                }).toList();

                return ListView(
                  reverse: true,
                  children: messages,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // TODO: Implement send message functionality.
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/
