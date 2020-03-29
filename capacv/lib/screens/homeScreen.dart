import 'dart:async';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:capacv/models/pinPillInfo.dart';
import 'package:capacv/models/mapPinPillComponent.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';

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

  double pinPillPosition = -100;

  final Firestore _db = Firestore.instance;

  Location location;

  String _mapStyle;

  List<String> placeNames;

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    location = new Location();
  }

  List<PinInformation> pins;
  int currentPin = 0;

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

  Future<CameraPosition> setSourceAndDestinationIcons() async {
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

    //LocationData currentLocation = await location.getLocation();

    CameraPosition initialLocation = CameraPosition(
      zoom: CAMERA_ZOOM,
      bearing: CAMERA_BEARING,
      tilt: CAMERA_TILT,
      //target: LatLng(currentLocation.latitude, currentLocation.longitude),
      target: LatLng(34.0749, -118.4415),
    );

    pins = new List<PinInformation>();

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
            
            return StreamBuilder<QuerySnapshot>(
                stream: _db.collection('places').where('type', isEqualTo: 'Cafe').snapshots(),
                builder: (context, snapshot) {
                  if (!initLocal.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor),
                      ),
                    );
                  } else {
                    for (DocumentSnapshot doc in snapshot.data.documents) {
                      pins.add(PinInformation.fromDb(doc));
                    }
                    setMapPins(pins);
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
                            });
                          },
                        ),
                        MapPinPillComponent(
                          pinPillPosition: pinPillPosition,
                          currentPin: currentPin,
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: SizedBox(
                              height: 200,
                              width: 350,
                              child: Center(
                                child: Container(
                                  decoration: new BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 20.0,
                                        spreadRadius: -3.0,
                                        offset: Offset(
                                          5,
                                          5,
                                        ),
                                      ),
                                    ],
                                    borderRadius: new BorderRadius.circular(15),
                                  ),
                                  child: SearchBar<String>(
                                    iconActiveColor: Colors.black87,
                                    onSearch: _search,
                                    onItemFound: _found,
                                    textStyle: TextStyle(
                                      color: Colors.black87,
                                    ),
                                    searchBarStyle: SearchBarStyle(
                                      backgroundColor: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                });
          }
        },
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _controller.setMapStyle(_mapStyle);
  }

  Marker makeMarker(int i) {
    return Marker(
      markerId: MarkerId(pins[i].locationName),
      position: pins[i].location,
      onTap: () {
        setState(() {
          currentPin = i;
          pinPillPosition = 20;
        });
      },
      icon: iconPicker(
          pins[i].currCapacity.toDouble() / pins[i].maxCapacity.toDouble(),
          pins[i].type),
    );
  }

  BitmapDescriptor iconPicker(double ratio, String type) {
    if (ratio > .6) {
      if (type == "Cafe") {
        return redCoffeeIcon;
      } else if (type == "Study") {
        return redBookIcon;
      } else if (type == "Restaurant") {
        return redFoodIcon;
      } else {
        return redCartIcon;
      }
    } else if (ratio > .32) {
      if (type == "Cafe") {
        return yellowCoffeeIcon;
      } else if (type == "Study") {
        return yellowBookIcon;
      } else if (type == "Restaurant") {
        return yellowFoodIcon;
      } else {
        return yellowCartIcon;
      }
    } else {
      if (type == "Cafe") {
        return greenCoffeeIcon;
      } else if (type == "Study") {
        return greenBookIcon;
      } else if (type == "Restaurant") {
        return greenFoodIcon;
      } else {
        return greenCartIcon;
      }
    }
  }

  bool keepMarker(int i) {}

  void setMapPins(List<PinInformation> pins) {
    for (int i = 0; i < pins.length; i++) {
      _markers.add(makeMarker(i));
    }
  }

  Future<List<String>> _search(String searchQuery) {
    List<String> a = ['abcde', 'onefg', 'twoaz', 'threpoe', 'whatup'];
    print("Query: " + searchQuery);
    return Future<List<String>>.value(a);
  }

  Widget _found(String s, int i) {
    print("Found: " + s);
    print("Int: ");
    print(i);
    return ListTile(title: Text(s));
  }
}
