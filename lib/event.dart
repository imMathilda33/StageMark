import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';

class Event extends StatefulWidget {
  @override
  _EventState createState() => _EventState();
}

class _EventState extends State<Event> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _seatController = TextEditingController();
  final TextEditingController _theatreController = TextEditingController();
  bool _isFieldEmpty = false;
  File? _image;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return null;

  String filePath = 'user_images/${currentUser.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
  Reference storageReference = FirebaseStorage.instance.ref().child(filePath);

  try {
    await storageReference.putFile(imageFile);
    String downloadUrl = await storageReference.getDownloadURL();
    print('Image uploaded: $downloadUrl');  // 添加日志来确认图片是否上传成功
    return downloadUrl;
  } catch (e) {
    print("Error uploading image: $e");
    return null;
  }
}


  void _submitData() async {
  User? currentUser = FirebaseAuth.instance.currentUser;

  // 检查用户是否已登录
  if (currentUser != null) {
    String search = _searchController.text;
    String name = _nameController.text;
    String dateTime = _dateTimeController.text;
    String seat = _seatController.text;
    String theatre = _theatreController.text;

    // 检查除图片外的所有字段是否已填写
    if (search.isNotEmpty && name.isNotEmpty && dateTime.isNotEmpty && seat.isNotEmpty && theatre.isNotEmpty) {
      String? imageUrl;
      // 如果用户选择了图片，则上传图片并获取URL
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      // 构建要保存的数据，包括 imageUrl（如果有的话）
      Map<String, dynamic> eventData = {
        'userId': currentUser.uid,
        'search': search,
        'name': name,
        'dateTime': dateTime,
        'seat': seat,
        'theatre': theatre,
      };

      // 如果用户上传了图片，将图片URL添加到 eventData 中
      if (imageUrl != null) {
        eventData['imageUrl'] = imageUrl;
      }

      // 保存数据到 Realtime Database
      DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
      await databaseReference.child('users/${currentUser.uid}/events').push().set(eventData);

      // 提交成功后，重置提醒状态
      setState(() {
        _isFieldEmpty = false;
      });
    } else {
      // 如果有必填字段未填写，则显示提醒
      setState(() {
        _isFieldEmpty = true;
      });
    }
  } else {
    // 如果用户未登录，显示登录提醒
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Not Logged In'),
        content: Text('Please log in to submit data.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add to Calendar'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16.0),
            Text('Or enter manually:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _dateTimeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Date & time',
                hintText: 'Select a Date',
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2010),
                  lastDate: DateTime(2030),
                );
                if (pickedDate != null) {
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                  setState(() {
                    _dateTimeController.text = formattedDate;
                  });
                }
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _seatController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Seat',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _theatreController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Theatre',
              ),
            ),
            SizedBox(height: 16.0),
            OutlinedButton(
              onPressed: _pickImage,
              child: Text('Add Photo'),
            ),
            SizedBox(height: 16.0),
            _image != null ? Image.file(_image!) : Text("No image selected"),
            SizedBox(height: 16.0),
            if (_isFieldEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Please fill in all fields',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: 50,
              height: 36,
              child: ElevatedButton(
                onPressed: () {
                  _submitData();
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _dateTimeController.dispose();
    _seatController.dispose();
    _theatreController.dispose();
    super.dispose();
  }
}
