import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:capacv/models/filters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capacv/models/pin.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ScrollableExhibitionSheet extends StatefulWidget {
  final List<DocumentSnapshot> docs;

  ScrollableExhibitionSheet({this.docs});

  @override
  _ScrollableExhibitionSheetState createState() =>
      _ScrollableExhibitionSheetState();
}

class _ScrollableExhibitionSheetState extends State<ScrollableExhibitionSheet> {
  double initialPercentage = 0.15;

  List<bool> filterPressed = [true, true, true, true];
  List<String> filterText = ['Study', 'Restaurant', 'Cafe', 'Grocery'];

  List<String> searchedPlaces;

  List<Icon> filterIcons = [
    Icon(
      FontAwesomeIcons.book,
      color: Colors.white,
    ),
    Icon(
      FontAwesomeIcons.utensils,
      color: Colors.white,
    ),
    Icon(
      FontAwesomeIcons.coffee,
      color: Colors.white,
    ),
    Icon(
      FontAwesomeIcons.shoppingCart,
      color: Colors.white,
    ),
  ];

  TextEditingController _textEditingController = TextEditingController();
  FocusNode _node;

  @override
  void initState() {
    super.initState();

    searchedPlaces = widget.docs.map((doc) => doc['name'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Filters>(
      builder: (contex, filters, cart) {
        return Positioned.fill(
          child: DraggableScrollableSheet(
            minChildSize: initialPercentage,
            initialChildSize: initialPercentage,
            builder: (context, scrollController) {
              return AnimatedBuilder(
                animation: scrollController,
                builder: (context, child) {
                  double percentage = initialPercentage;
                  if (scrollController.hasClients) {
                    percentage = (scrollController.position.viewportDimension) /
                        (MediaQuery.of(context).size.height);
                  }
                  double scaledPercentage = (percentage - initialPercentage) /
                      (1 - initialPercentage);
                  return Container(
                    padding: const EdgeInsets.only(left: 32),
                    decoration: const BoxDecoration(
                      color: Color(0xFF162A49),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Opacity(
                          opacity: percentage,
                          child: StreamBuilder<List<DocumentSnapshot>>(
                              stream: Stream.fromIterable([
                                widget.docs
                                    .where((doc) => searchedPlaces
                                        ?.contains(doc['name'] as String))
                                    .toList()
                              ]),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).primaryColor),
                                    ),
                                  );
                                } else {
                                  return ListView.builder(
                                    padding:
                                        EdgeInsets.only(right: 32, top: 128),
                                    controller: scrollController,
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (context, index) {
                                      Pin pin =
                                          Pin.fromDb(snapshot.data[index]);
                                      return MyPinInfoItem(
                                        pin: pin,
                                        percentageCompleted: percentage,
                                      );
                                    },
                                  );
                                }
                              }),
                        ),
                        ...?filterIcons.map((filterIcon) {
                          int index = filterIcons.indexOf(filterIcon);
                          int heightPerElement = 150;
                          double widthPerElement =
                              (MediaQuery.of(context).size.width) /
                                      filterIcons.length -
                                  10;
                          double leftOffset = widthPerElement * index;
                          return Positioned(
                            top: 30.0 +
                                scaledPercentage * (128 - 44) +
                                heightPerElement * scaledPercentage,
                            left: leftOffset,
                            child: Opacity(
                              opacity: scaledPercentage < .5
                                  ? 1 - scaledPercentage * 2
                                  : 0,
                              child: IconButton(
                                icon: filterIcon,
                                onPressed: () {
                                  setState(() {
                                    _updateFilter(index);
                                  });
                                  if (filterPressed[index])
                                    filters.addFilter(filterText[index]);
                                  else
                                    filters.clearFilter(filterText[index]);
                                },
                              ),
                            ),
                          );
                        }),
                        IgnorePointer(
                          ignoring: percentage > .9 ? false : true,
                          child: Opacity(
                            opacity: scaledPercentage,
                            child: Container(
                              height: 100,
                              padding: EdgeInsets.only(right: 32, top: 30),
                              child: Container(
                                padding: EdgeInsets.fromLTRB(15, 10, 15, 15),
                                decoration: new BoxDecoration(
                                  color: Colors.white70,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      spreadRadius: 1.0,
                                      offset: Offset(
                                        5,
                                        5,
                                      ),
                                    ),
                                  ],
                                  borderRadius: new BorderRadius.circular(15),
                                ),
                                child: TextField(
                                  enableInteractiveSelection: false,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  controller: _textEditingController,
                                  decoration: InputDecoration(
                                    icon: Icon(FontAwesomeIcons.search),
                                  ),
                                  onChanged: (query) {
                                    searchedPlaces.clear();
                                    for (String s in widget.docs
                                        .map((doc) => doc['name'] as String)
                                        .toList()) {
                                      if (s
                                          .toLowerCase()
                                          .startsWith(query.toLowerCase())) {
                                        setState(() {
                                          searchedPlaces.add(s);
                                        });
                                      }
                                    }
                                  },
                                  onSubmitted: (query) {
                                    
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _updateFilter(int index) {
    Icon update;
    Color newColor = filterPressed[index] ? Colors.white70 : Colors.white;
    switch (index) {
      case 0:
        {
          update = new Icon(
            FontAwesomeIcons.book,
            color: newColor,
          );
        }
        break;
      case 1:
        {
          update = new Icon(
            FontAwesomeIcons.utensils,
            color: newColor,
          );
        }
        break;
      case 2:
        {
          update = new Icon(
            FontAwesomeIcons.coffee,
            color: newColor,
          );
        }
        break;
      case 3:
        {
          update = new Icon(
            FontAwesomeIcons.shoppingCart,
            color: newColor,
          );
        }
        break;
    }
    filterPressed[index] = !filterPressed[index];
    filterIcons[index] = update;
  }

  // Future<List<String>> _search(String searchQuery) {

  //   List<String> a = widget.docs.map((doc) => doc['name'] as String).toList();
  //   print("Query: " + searchQuery);
  //   return Future<List<String>>.value(a);
  // }

  // Widget _found(String s, int i) {
  //   print("Found: " + s);
  //   print("Int: ");
  //   print(i);
  //   return Container();
  // }
}

class MyPinInfoItem extends StatelessWidget {
  final Pin pin;
  final double percentageCompleted;

  const MyPinInfoItem({Key key, this.pin, this.percentageCompleted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Transform.scale(
        alignment: Alignment.topLeft,
        scale: 1 / 3 + 2 / 3 * percentageCompleted,
        child: SizedBox(
          height: 120,
          child: Row(
            children: <Widget>[
              Container(
                height: 120,
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(16),
                    right: Radius.circular(16 * (1 - percentageCompleted)),
                  ),
                  child: (pin.picture == "0000")
                      ? Container()
                      : Image.network(
                          buildPhotoURL(pin.picture),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Expanded(
                child: Opacity(
                  opacity: max(0, percentageCompleted * 2 - 1),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.horizontal(right: Radius.circular(16)),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(8),
                    child: _buildContent(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: <Widget>[
        Text(
          pin.locationName,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Row(
          children: <Widget>[
            Text(
              'Capacity: ${pin.currCapacity}/${pin.maxCapacity}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(width: 8),
            RatingBarIndicator(
              itemSize: 12,
              rating: pin.rating,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        Row(
          children: <Widget>[
            Text(
              "Hours: ${getTime(pin.hours['open'])} - ${getTime(pin.hours['close'])}",
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Spacer(),
        Row(
          children: <Widget>[
            Icon(Icons.place, color: Colors.grey.shade400, size: 16),
            Expanded(
              child: Text(
                pin.address,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
              ),
            )
          ],
        )
      ],
    );
  }
}

String buildPhotoURL(String photoReference) {
  return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${photoReference}&key=AIzaSyCQ4lOkjPK9YocNZcYrRbCeavQRwvLYOwA";
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

// class SheetHeader extends StatelessWidget {
//   final double fontSize;
//   final double topMargin;

//   const SheetHeader(
//       {Key key, @required this.fontSize, @required this.topMargin})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: 0,
//       right: 32,
//       child: IgnorePointer(
//         child: Container(
//           padding: EdgeInsets.only(top: topMargin, bottom: 12),
//           decoration: const BoxDecoration(
//             color: Color(0xFF162A49),
//           ),
//           child: Text(
//             'Booked Exhibition',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: fontSize,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MenuButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       right: 12,
//       bottom: 24,
//       child: Icon(
//         Icons.menu,
//         color: Colors.white,
//         size: 28,
//       ),
//     );
//   }
//}
