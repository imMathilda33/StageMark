import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';

class Event extends StatefulWidget {
  TabController tabController;

  Event({Key? key, required this.tabController}) : super(key: key);

  @override
  _EventState createState() => _EventState();
}

class _EventState extends State<Event> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _seatController = TextEditingController();
  final TextEditingController _theatreController = TextEditingController();
  bool _isFieldEmpty = false;
  bool _isSubmitionOk = false;
  File? _image;

  @override
  void initState() {
    super.initState();
  }

// function to pick image
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

// function to upload image
  Future<String?> _uploadImage(File imageFile) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    String filePath =
        'user_images/${currentUser.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference storageReference = FirebaseStorage.instance.ref().child(filePath);
    SettableMetadata metadata = SettableMetadata(contentType: "image/jpeg");

    try {
      UploadTask uploadTask = storageReference.putFile(imageFile, metadata);
      uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
        switch (taskSnapshot.state) {
          case TaskState.running:
            final progress = 100.0 *
                (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            print("Upload is $progress% complete.");
            break;
          case TaskState.paused:
            print("Upload is paused.");
            break;
          case TaskState.canceled:
            print("Upload was canceled");
            break;
          case TaskState.error:
            // Handle unsuccessful uploads
            print("Upload failed");
            break;
          case TaskState.success:
            // Handle successful uploads on complete
            print("Upload successful");
            break;
        }
      });

      await uploadTask;
      String downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _pickDateTime() async {
    // First let the user choose the date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 6),
    );

    if (pickedDate != null) {
      // If the user selects a date, then let the user select a time
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
       // Combine the date and time into a DateTime object.
        DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Format date and time as a string
        String formattedDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(finalDateTime);

       // Update the status to show in the UI
        setState(() {
          _dateTimeController.text = formattedDateTime;
        });
      }
    }
  }

  void _submitData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String name = _nameController.text;
      String dateTime = _dateTimeController.text;
      String seat = _seatController.text;
      String theatre = _theatreController.text;

      // Check that all fields are filled out except for the picture
      if (name.isNotEmpty &&
          dateTime.isNotEmpty &&
          seat.isNotEmpty &&
          theatre.isNotEmpty) {
        String? imageUrl;
        // If the user selects an image, upload the image and get the URL
        if (_image != null) {
          imageUrl = await _uploadImage(_image!);
        }

        // Construct the data to be saved
        Map<String, dynamic> eventData = {
          'userId': currentUser.uid,
          'name': name,
          'dateTime': dateTime,
          'seat': seat,
          'theatre': theatre,
        };

        // If the user uploaded an image, add the image URL to eventData
        if (imageUrl != null) {
          eventData['imageUrl'] = imageUrl;
        }

        // save to Realtime Database
        DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
        await databaseReference
            .child('users/${currentUser.uid}/events')
            .push()
            .set(eventData);

        // Reset reminder status after successful submission
        setState(() {
          _isFieldEmpty = false;
          _isSubmitionOk = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Seat Information Submitted!"),
            duration: Duration(seconds: 2),
          ),
        );
        Timer(Duration(seconds: 1), () {
          widget.tabController.animateTo(0);
          setState(() {
            _isFieldEmpty = false;
            _isSubmitionOk = false;
          });
        });
      } else {
        // Displays a reminder if there are required fields that are not filled in
        setState(() {
          _isFieldEmpty = true;
          _isSubmitionOk = false;
        });
      }
    } else {
      // Show login reminder if user is not logged in
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
        backgroundColor: null,
        title: Text('Add to Calendar'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
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
                labelText: 'Date & Time',
                hintText: 'Select Date and Time',
              ),
              readOnly: true, 
              onTap: _pickDateTime, 
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
            _image != null
                ? Image.file(_image!)
                : Center(
                    child: Text(
                    "No image selected",
                    style: TextStyle(color:  Color.fromARGB(255, 117, 104, 117)),
                  )),
            SizedBox(height: 16.0),
            if (_isFieldEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Please fill in all fields',
                  style: TextStyle(color:  Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_isSubmitionOk)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Submitted, Okay!',
                  style: TextStyle(color: Colors.green),
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
    _nameController.dispose();
    _dateTimeController.dispose();
    _seatController.dispose();
    _theatreController.dispose();
    super.dispose();
  }
}