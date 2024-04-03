import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FunctionPage extends StatefulWidget {
  FunctionPage();

  @override
  _FunctionPageState createState() => _FunctionPageState();
}

class _FunctionPageState extends State<FunctionPage> {
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433);

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
      return;
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
          _noiseLevel = event.decibels?.round();
        });
      });
      setState(() => _isRecording = true);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if(Brightness.dark == MediaQuery.of(context).platformBrightness){
      mapController?.setMapStyle('''
            [
        {
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#242f3e"
            }
          ]
        },
        {
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#746855"
            }
          ]
        },
        {
          "elementType": "labels.text.stroke",
          "stylers": [
            {
              "color": "#242f3e"
            }
          ]
        },
        {
          "featureType": "administrative.locality",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#d59563"
            }
          ]
        },
        {
          "featureType": "poi",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#d59563"
            }
          ]
        },
        {
          "featureType": "poi.park",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#263c3f"
            }
          ]
        },
        {
          "featureType": "poi.park",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#6b9a76"
            }
          ]
        },
        {
          "featureType": "road",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#38414e"
            }
          ]
        },
        {
          "featureType": "road",
          "elementType": "geometry.stroke",
          "stylers": [
            {
              "color": "#212a37"
            }
          ]
        },
        {
          "featureType": "road",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#9ca5b3"
            }
          ]
        },
        {
          "featureType": "road.highway",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#746855"
            }
          ]
        },
        {
          "featureType": "road.highway",
          "elementType": "geometry.stroke",
          "stylers": [
            {
              "color": "#1f2835"
            }
          ]
        },
        {
          "featureType": "road.highway",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#f3d19c"
            }
          ]
        },
        {
          "featureType": "transit",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#2f3948"
            }
          ]
        },
        {
          "featureType": "transit.station",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#d59563"
            }
          ]
        },
        {
          "featureType": "water",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#17263c"
            }
          ]
        },
        {
          "featureType": "water",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#515c6d"
            }
          ]
        },
        {
          "featureType": "water",
          "elementType": "labels.text.stroke",
          "stylers": [
            {
              "color": "#17263c"
            }
          ]
        }
      ]
      ''');
    }else{
      mapController?.setMapStyle('''[]''');
    }
  }

  @override
  Widget build(BuildContext context) {
    const int noiseThreshold = 70;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color:  Colors.transparent,
              height: 30,
            ),
            Text(
              'Noise Detector:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:  Color.fromRGBO(144, 187, 206, 1),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      Text(
                        _isRecorderInitialized ? 'Ready to detect' : 'Initializing...',
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
                            color: _noiseLevel! > noiseThreshold ? ( Colors.red) : (Colors.green),
                          ),
                        ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isRecorderInitialized ? _startOrStopRecording : null,
                        child: Text(_isRecording ? 'Stop Detecting' : 'Start Detecting'),
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
                        Icon(Icons.warning, color:  Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'High noise level!',
                          style: TextStyle(color:  Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(height: 20),
            Container(
              height: 400, 
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: SizedBox(
                  height: size.height,
                  width: size.width * 0.85,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 11.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    mapController?.dispose();
    super.dispose();
  }
}
