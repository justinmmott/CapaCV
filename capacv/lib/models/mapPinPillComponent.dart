import 'package:flutter/material.dart';
import 'package:capacv/models/pinPillInfo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MapPinPillComponent extends StatefulWidget {
  final double pinPillPosition;
  final PinInformation currentlySelectedPin;
  MapPinPillComponent({this.pinPillPosition, this.currentlySelectedPin});

  @override
  State<StatefulWidget> createState() => MapPinPillComponentState();
}

class MapPinPillComponentState extends State<MapPinPillComponent> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      bottom: widget.pinPillPosition,
      right: 0,
      left: 0,
      duration: Duration(milliseconds: 200),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.all(20),
          height: 85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(50)),
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                blurRadius: 20,
                offset: Offset.zero,
                color: Colors.grey.withOpacity(0.5),
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 10),
                width: 55,
                height: 55,
                child: ClipOval(
                  child: Image.network(
                    widget.currentlySelectedPin.picture,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 1, 0, 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              widget.currentlySelectedPin.locationName,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.lightBlue),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: RatingBarIndicator(
                                itemSize: 18,
                                rating: widget.currentlySelectedPin.rating,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 1, 0, 1),
                        child: Text(
                          'Capacity: ${widget.currentlySelectedPin.currCapacity}/${widget.currentlySelectedPin.maxCapacity}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 1, 0, 1),
                        child: Text(
                          "Hours: ${getTime(widget.currentlySelectedPin.hours['open'])} - ${getTime(widget.currentlySelectedPin.hours['close'])}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
               // color: Colors.red,
                width: 75,
                height: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.directions,
                        color: Colors.lightBlue,
                        size: 40,
                      ),
                      onPressed: () {
                        launch('http://www.google.com/maps/place/${widget.currentlySelectedPin.location.latitude},${widget.currentlySelectedPin.location.longitude}');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getTime(int time) {
    int temp = (time < 1200) ? time : time - 1200;
    String res = temp.toString();
    if (res.length == 1) {
      res = "12:0" + res;
    } else if (res.length == 2) {
      res = "12:" + res;
    } else if (res.length == 3) {
      res = res[0] + ':' + res[1] + res[2];
    } else if (res.length == 4) {
      res = res[0] + res[1] + ':' + res[2] + res[3];
    }

    if (time < 1200) {
      res += " AM";
    } else {
      res += " PM";
    }

    return res;
  }
}
