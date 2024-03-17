import 'package:flutter/material.dart';
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_isRecorderInitialized
                ? 'Press the button to start recording'
                : 'Requesting permissions...'),
            if (_noiseLevel != null) Text('Noise Level: $_noiseLevel dB'),
            ElevatedButton(
              onPressed: _isRecorderInitialized ? _startOrStopRecording : null,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    super.dispose();
  }
}
