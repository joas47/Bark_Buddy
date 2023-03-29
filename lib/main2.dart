import 'package:flutter/material.dart';

// for the MatchChatPage
//import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Dating App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      initialRoute: '/',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/make-profile': (context) => MakeProfilePage(),
        '/find-match': (context) => FindMatchPage(),
        '/profile': (context) => ProfilePage(),
        '/match-chat': (context) => MatchChatPage(),
        '/settings': (context) => SettingsPage(),
      },
      home: LoginPage(),
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

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child:
        Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/bark_buddy_logo.png',
                height: 100.0,
              ),
              Text(
                'Welcome to Bark Buddy!',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
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
        )

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
      body: Center(
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
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement registration functionality.
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
    );
  }
}

class MakeProfilePage extends StatelessWidget {
  const MakeProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tell us more about yourself!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Hobbies',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement save profile functionality.
                Navigator.pushNamed(context, '/find-match');
              },
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

/*class FindMatchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Match'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Find your perfect match!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement find match functionality.
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MatchChatPage()),
                );
              },
              child: Text('Find Match'),
            ),
          ],
        ),
      ),
    );
  }
}*/

class FindMatchPage extends StatelessWidget {
  const FindMatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Match'),
      ),
      body: Center(
        child: Text('Find your perfect match!'),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50.0,
              backgroundImage: AssetImage(
                  'assets/images/placeholder-profile-image.png'),
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

class MatchChatPage extends StatelessWidget {
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
}*/
