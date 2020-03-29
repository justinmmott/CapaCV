import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:capacv/models/pinPillInfo.dart';
import 'package:capacv/models/mapPinPillComponent.dart';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:capacv/models/locations.dart' as locations;

const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(42.7477863, -71.1699932);
const LatLng DEST_LOCATION = LatLng(42.6871386, -71.2143403);

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController _controller;
  Set<Marker> _markers = {};
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  double pinPillPosition = -100;

  String _mapStyle;

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  static PinInformation sourcePinInfo = PinInformation(
    locationName: 'Start Location',
    location: SOURCE_LOCATION,
    pinPath: 'assets/marker.png',
    avatarPath: 'assets/marker.png',
    labelColor: Colors.blueAccent,
  );
  static PinInformation destinationPinInfo = PinInformation(
    locationName: 'End Location',
    location: DEST_LOCATION,
    pinPath: 'assets/marker.png',
    avatarPath: 'assets/marker.png',
    labelColor: Colors.purple,
  );

  PinInformation currentlySelectedPin = sourcePinInfo;
  CameraPosition initialLocation = CameraPosition(
    zoom: CAMERA_ZOOM,
    bearing: CAMERA_BEARING,
    tilt: CAMERA_TILT,
    target: SOURCE_LOCATION,
  );

  Future<BitmapDescriptor> setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/marker.png',
    );

    destinationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/marker.png',
    );

    setMapPins();

    return sourceIcon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<BitmapDescriptor>(
        future: setSourceAndDestinationIcons(),
        builder: (context, bitmap) {
          if (!bitmap.hasData) {
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
                  compassEnabled: true,
                  tiltGesturesEnabled: false,
                  markers: _markers,
                  mapType: MapType.normal,
                  initialCameraPosition: initialLocation,
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

  void setMapPins() {
    _markers.add(
      Marker(
        markerId: MarkerId('sourcePin'),
        position: SOURCE_LOCATION,
        onTap: () {
          setState(() {
            currentlySelectedPin = sourcePinInfo;
            pinPillPosition = 0;
          });
        },
        icon: sourceIcon,
      ),
    );

    _markers.add(
      Marker(
        markerId: MarkerId('destPin'),
        position: DEST_LOCATION,
        onTap: () {
          setState(() {
            currentlySelectedPin = destinationPinInfo;
            pinPillPosition = 0;
          });
        },
        icon: destinationIcon,
      ),
    );
  }
}
