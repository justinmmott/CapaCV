import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:capacv/models/pin.dart';
import 'package:capacv/models/pinInfo.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart';
import 'package:capacv/models/scrollable_exhibition_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:capacv/models/filters.dart';

const double CAMERA_ZOOM = 15;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 0;
const double FILTER_POS = -800;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController _controller;
  Set<Marker> _markers = {};

  double pinPillPosition = -100;
  double filterPosition = FILTER_POS;
  bool enactedByMarker = false;

  Map<String, bool> markerSelected = new Map();

  final Firestore _db = Firestore.instance;

  Location location;

  String _mapStyle;

  List<String> placeNames;

  CameraPosition initialLocation = CameraPosition(
    zoom: CAMERA_ZOOM,
    bearing: CAMERA_BEARING,
    tilt: CAMERA_TILT,
    target: LatLng(34.0749, -118.4415),
  );

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    location = new Location();
  }

  List<Pin> pins;
  String uid = "";

  BitmapDescriptor redCartIcon;
  BitmapDescriptor redBookIcon;
  BitmapDescriptor redFoodIcon;
  BitmapDescriptor redCoffeeIcon;

  BitmapDescriptor greenCartIcon;
  BitmapDescriptor greenBookIcon;
  BitmapDescriptor greenFoodIcon;
  BitmapDescriptor greenCoffeeIcon;

  BitmapDescriptor yellowCartIcon;
  BitmapDescriptor yellowBookIcon;
  BitmapDescriptor yellowFoodIcon;
  BitmapDescriptor yellowCoffeeIcon;

  @override
  Widget build(BuildContext context) {
    return Consumer<Filters>(
      builder: (context, filters, child) {
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
                return StreamBuilder<QuerySnapshot>(
                  stream: _db.collection('places').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                        ),
                      );
                    } else {
                      if (_markers.isNotEmpty) _markers.clear();
                      List<DocumentSnapshot> docs =
                          new List<DocumentSnapshot>();

                      for (String filter in filters.filter) {
                        docs.addAll(snapshot.data.documents
                            .where((doc) => doc['type'] == filter));
                      }

                      if (filters.filter.length == 0) docs = [];

                      for (DocumentSnapshot doc in docs) {
                        setMapPins(Pin.fromDb(doc));
                      }
                      return Stack(
                        children: <Widget>[
                          GoogleMap(
                            myLocationButtonEnabled: false,
                            myLocationEnabled: true,
                            mapToolbarEnabled: false,
                            tiltGesturesEnabled: false,
                            compassEnabled: false,
                            markers: _markers,
                            initialCameraPosition: initLocal.data,
                            onMapCreated: onMapCreated,
                            onTap: (LatLng location) {
                              setState(() {
                                pinPillPosition = -150;
                                filterPosition = FILTER_POS;
                                markerSelected.forEach((key, value) {
                                  markerSelected[key] = false;
                                });
                              });
                            },
                            onCameraMoveStarted: () {
                              setState(() {
                                if (enactedByMarker) {
                                  enactedByMarker = false;
                                } else {
                                  pinPillPosition = -150;
                                }
                              });
                            },
                          ),
                          PinInfo(
                            pinPillPosition: pinPillPosition,
                            uid: uid,
                          ),
                          ScrollableExhibitionSheet(docs: docs),
                        ],
                      );
                    }
                  },
                );
              }
            },
          ),
        );
      },
    );
  }

  void onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _controller.setMapStyle(_mapStyle);
  }

  void setMapPins(Pin pin) {
    _markers.add(Marker(
      markerId: MarkerId(pin.uid),
      position: pin.location,
      onTap: () {
        setState(() {
          uid = pin.uid;
          pinPillPosition = MediaQuery.of(context).size.height / 2 + 30;
          enactedByMarker = true;
          markerSelected.forEach((key, value) {
            markerSelected[key] = false;
          });
          markerSelected[pin.uid] = true;
        });
      },
      icon: markerSelected[pin.uid] ?? false
          ? BitmapDescriptor.defaultMarker
          : iconPicker(pin.currCapacity.toDouble() / pin.maxCapacity.toDouble(),
              pin.type),
    ));
  }

  Future<CameraPosition> setSourceAndDestinationIcons() async {
    if (initialLocation.target.latitude != 34.0749) {
      return initialLocation;
    }

    redCartIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/map-marker-red-cart.png',
    );
    redBookIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/map-marker-red-book.png',
    );
    redFoodIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/map-marker-red-food.png',
    );
    redCoffeeIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/map-marker-red-coffee.png',
    );

    greenCartIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/map-marker-green-cart.png',
    );
    greenBookIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/map-marker-green-book.png',
    );
    greenFoodIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/map-marker-green-food.png',
    );
    greenCoffeeIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/map-marker-green-coffee.png',
    );

    yellowCartIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/map-marker-yellow-cart.png',
    );
    yellowBookIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/map-marker-yellow-book.png',
    );
    yellowFoodIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/map-marker-yellow-food.png',
    );
    yellowCoffeeIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/map-marker-yellow-coffee.png',
    );

    LocationData currentLocation = await location.getLocation();

    initialLocation = CameraPosition(
      zoom: CAMERA_ZOOM,
      bearing: CAMERA_BEARING,
      tilt: CAMERA_TILT,
      target: LatLng(34.075, -118.4415),
    );

    return initialLocation;
  }

  BitmapDescriptor iconPicker(double ratio, String type) {
    if (ratio > .6) {
      if (type == "Cafe") {
        return redCoffeeIcon;
      } else if (type == "Study") {
        return redBookIcon;
      } else if (type == "Restaurant") {
        return redFoodIcon;
      } else if (type == "Grocery") {
        return redCartIcon;
      } else {
        return BitmapDescriptor.defaultMarker;
      }
    } else if (ratio > .32) {
      if (type == "Cafe") {
        return yellowCoffeeIcon;
      } else if (type == "Study") {
        return yellowBookIcon;
      } else if (type == "Restaurant") {
        return yellowFoodIcon;
      } else if (type == "Grocery") {
        return yellowCartIcon;
      } else {
        return BitmapDescriptor.defaultMarker;
      }
    } else {
      if (type == "Cafe") {
        return greenCoffeeIcon;
      } else if (type == "Study") {
        return greenBookIcon;
      } else if (type == "Restaurant") {
        return greenFoodIcon;
      } else if (type == "Grocery") {
        return greenCartIcon;
      } else {
        return BitmapDescriptor.defaultMarker;
      }
    }
  }
}
