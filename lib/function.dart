import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:flutter_sound/flutter_sound.dart';
import 'markers.dart';

class FunctionPage extends StatefulWidget {
  @override
  _FunctionPageState createState() => _FunctionPageState();
}

class _FunctionPageState extends State<FunctionPage> {
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  LatLng _currentPosition = LatLng(51.5072, -0.1276);
  FlutterSoundRecorder? _recorder;
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  int? _noiseLevel;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _getCurrentLocation();
    _markers.addAll(loadTheatreMarkers());
  }

// initialize sound recorder
  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();

    final ph.PermissionStatus status = await ph.Permission.microphone.request();
    if (status != ph.PermissionStatus.granted) {
      setState(() => _isRecorderInitialized = false);
      return;
    }

    await _recorder!.openRecorder();
    _recorder!.setSubscriptionDuration(const Duration(milliseconds: 500));
    setState(() => _isRecorderInitialized = true);
  }

  Future<void> _getCurrentLocation() async {
    Location location = new Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData currentLocation = await location.getLocation();

    setState(() {
      _currentPosition =
          LatLng(currentLocation.latitude ?? 0, currentLocation.longitude ?? 0);
    });
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

// fetch nearby locations
  Future<void> _fetchNearbyTheaters(LatLng currentPosition) async {
    const apiKey = 'AIzaSyAdTknHEdeDrUvMahgZawQo2JwmpafovPo';
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${currentPosition.latitude},${currentPosition.longitude}&radius=10000&type=theatre&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _updateMarkers(data['results']);
    } else {
      print('Failed to load nearby theatres. Error: ${response.body}');
    }
  }

// add locations to markers 
  void _updateMarkers(List<dynamic> theaters) {
    setState(() {
      _markers.clear();
      for (var theater in theaters) {
        final marker = Marker(
          markerId: MarkerId(theater['place_id']),
          position: LatLng(theater['geometry']['location']['lat'],
              theater['geometry']['location']['lng']),
          infoWindow: InfoWindow(
            title: theater['name'],
            snippet: theater['vicinity'],
          ),
        );
        _markers.add(marker);
      }
    });
  }


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    const int noiseThreshold = 50;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.transparent,
              height: 30,
            ),
            Text(
              'Noise Detector:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(144, 187, 206, 1),
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
                        onPressed: _isRecorderInitialized
                            ? _startOrStopRecording
                            : null,
                        child: Text(_isRecording
                            ? 'Stop Detecting'
                            : 'Start Detecting'),
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
                      target: _currentPosition,
                      zoom: 12.0,
                    ),
                    markers: _markers,
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
