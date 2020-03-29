import 'package:flutter/material.dart';
import 'package:capacv/models/pinPillInfo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilterView extends StatefulWidget {
  final double filterPosition;
  FilterView({this.filterPosition});

  @override
  State<StatefulWidget> createState() => FilterViewState();
}

class FilterViewState extends State<FilterView> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      bottom: widget.filterPosition,
      right: 0,
      left: 0,
      duration: Duration(milliseconds: 200),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          margin: EdgeInsets.all(20),
          height: 80,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(FontAwesomeIcons.book),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.utensils),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.coffee),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.shoppingCart),
                    onPressed: () {},
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
