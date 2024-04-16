import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UserPage extends StatefulWidget {
  final TabController tabController;

  UserPage({Key? key, required this.tabController}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  User? user = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();
  TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            // the avatar
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : AssetImage('lib/img/logo.png') as ImageProvider,
            ),
            SizedBox(height: 10),
            //user name
            Text(user?.displayName ?? user?.email ?? 'User Nickname',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            // update button
            ElevatedButton(
              onPressed: () => updateProfile(),
              child: Text('Edit Photo'),
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    onTap: () {
                      showEditUsernameDialog(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Log Out'),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      widget.tabController.animateTo(3);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateProfile() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File file = File(image.path);
      try {
        // Upload images to Firebase Storage
        String filePath =
            'user_profiles/${user!.uid}/${DateTime.now().millisecondsSinceEpoch}.png';
        TaskSnapshot taskSnapshot =
            await FirebaseStorage.instance.ref(filePath).putFile(file);

       // Get the image URL and update the user profile
        String photoURL = await taskSnapshot.ref.getDownloadURL();
        await user!.updatePhotoURL(photoURL);

        // Refresh the page to show the new avatar
        setState(() {
          user = FirebaseAuth.instance.currentUser;
        });
      } catch (e) {
        print('Error occurred while uploading or updating profile: $e');
      }
    }
  }

// show the dialog to edit userName
  void showEditUsernameDialog(BuildContext context) {
    print("Attempting to show edit username dialog.");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Username'),
          content: TextField(
            controller: _usernameController,
            decoration: InputDecoration(hintText: "Enter new username"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () {
                if (_usernameController.text.isNotEmpty) {
                  updateUsername(_usernameController.text);
                  Navigator.of(context).pop();
                } else {
                  print("No new username entered.");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateUsername(String newName) async {
    try {
      await user!.updateDisplayName(newName);
      await user!.reload();
      user = FirebaseAuth.instance.currentUser;
      setState(() {});
    } catch (e) {
      print('Failed to update username: $e');
    }
  }
}
