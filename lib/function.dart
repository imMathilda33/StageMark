import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';

class FunctionPage extends StatefulWidget {
  @override
  _FunctionPageState createState() => _FunctionPageState();
}

class _FunctionPageState extends State<FunctionPage> {
  FlutterSoundRecorder? _recorder;
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  int? _noiseLevel;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      setState(() => _isRecorderInitialized = false);
      throw 'Microphone permission not granted';
    }

    await _recorder!.openRecorder();
    _recorder!.setSubscriptionDuration(const Duration(milliseconds: 500));

    setState(() => _isRecorderInitialized = true);
  }

  void _startOrStopRecording() async {
    if (_isRecording) {
      await _recorder!.stopRecorder();
      setState(() {
        _isRecording = false;
        _noiseLevel = null;
      });
    } else {
      await _recorder!.startRecorder(toFile: 'temp.wav');
      _recorder!.onProgress!.listen((event) {
        setState(() {
          // Update the noise level with the rounded decibels value.
          _noiseLevel = event.decibels?.round();
        });
      });
      setState(() {
        _isRecording = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set warning threshold for noise level to 70 dB
    const int noiseThreshold = 70;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Text(
            'Noise Detector:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(144, 187, 206, 1),
            ), // 文字样式
          ),
          SizedBox(
            width: double.infinity,
            child: Card(
              // elevation: 4.0,
              margin: EdgeInsets.symmetric(horizontal: 60,vertical: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Text(
                      _isRecorderInitialized
                          ? 'Ready to detect'
                          : 'Initializing...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_noiseLevel != null)
                      Text(
                        'Noise Level: $_noiseLevel dB',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _noiseLevel! > noiseThreshold
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed:
                          _isRecorderInitialized ? _startOrStopRecording : null,
                      child: Text(
                          _isRecording ? 'Stop Detecting' : 'Start Detecting'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_noiseLevel != null && _noiseLevel! > noiseThreshold)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.redAccent,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.warning, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'High noise level!',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    super.dispose();
  }
}
