import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPage extends StatefulWidget {
  UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("User Profile"),
      // ),
      body: SafeArea( // 使用 SafeArea 包裹页面内容
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            CircleAvatar(
              backgroundImage: NetworkImage(
                  user?.photoURL ?? 'https://via.placeholder.com/150'),
              radius: 50,
            ),
            SizedBox(height: 10),
            Text(
              user?.displayName ?? 'User Nickname',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text('Edit Profile'),
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Log Out'),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      // 考虑添加逻辑以将用户返回登录屏幕或通知他们已注销
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
}
