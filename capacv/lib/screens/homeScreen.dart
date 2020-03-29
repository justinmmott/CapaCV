import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:capacv/models/pinPillInfo.dart';
import 'package:capacv/models/mapPinPillComponent.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart';
// import 'package:capacv/models/locations.dart' as locations;

const double CAMERA_ZOOM = 15;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 0;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController _controller;
  Set<Marker> _markers = {};
  BitmapDescriptor sourceIcon;
  double pinPillPosition = -100;

  final Firestore _db = Firestore.instance;

  Location location;

  String _mapStyle;

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    location = new Location();
  }

  PinInformation currentlySelectedPin;

  Future<CameraPosition> setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/marker.png',
    );

    LocationData currentLocation = await location.getLocation();

    CameraPosition initialLocation = CameraPosition(
      zoom: CAMERA_ZOOM,
      bearing: CAMERA_BEARING,
      tilt: CAMERA_TILT,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );

    List<PinInformation> pins = new List<PinInformation>();

    PinInformation pin = PinInformation.fromDb(
        await _db.collection('places').document('29H9MSDxzNiRUfW15tQW').get());

    currentlySelectedPin = pin;

    pins.add(pin);

    setMapPins(pins);

    return initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<CameraPosition>(
        future: setSourceAndDestinationIcons(),
        builder: (context, initLocal) {
          if (!initLocal.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            );
          } else {
            return Stack(
              children: <Widget>[
                GoogleMap(
                  myLocationEnabled: true,
                  mapToolbarEnabled: false,
                  tiltGesturesEnabled: false,
                  compassEnabled: false,
                  markers: _markers,
                  initialCameraPosition: initLocal.data,
                  onMapCreated: onMapCreated,
                  onTap: (LatLng location) {
                    setState(() {
                      pinPillPosition = -100;
                    });
                  },
                ),
                MapPinPillComponent(
                  pinPillPosition: pinPillPosition,
                  currentlySelectedPin: currentlySelectedPin,
                )
              ],
            );
          }
        },
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _controller.setMapStyle(_mapStyle);
     
  }

  void setMapPins(List<PinInformation> pins) {
    for (PinInformation pin in pins) {
      _markers.add(
        Marker(
          markerId: MarkerId(pin.locationName),
          position: pin.location,
          onTap: () {
            setState(() {
              currentlySelectedPin = pin;
              pinPillPosition = 20;
            });
          },
          icon: sourceIcon,
        ),
      );
    }
  }
}
