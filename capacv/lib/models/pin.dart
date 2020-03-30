import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Pin {
  String picture;
  LatLng location;
  String locationName;
  String uid;
  int maxCapacity;
  int currCapacity;
  String address;
  double rating;
  Map<String, dynamic> hours;
  String type;

  Pin.fromDb(DocumentSnapshot place) {
    this.picture = place['picture'];
    this.location =
        LatLng(place['location'].latitude, place['location'].longitude);
    this.locationName = place['name'];
    this.uid = place['uid'];
    this.maxCapacity = place['maxCapacity'];
    this.currCapacity = place['currCapacity'];
    this.address = place['address'];
    this.rating = place['rating']?.toDouble();
    this.hours = place['hours'];
    this.type = place['type'];
  }

  @override
  String toString() {
    return "Name: $locationName, uid: $uid, type: $type";
  }
}
