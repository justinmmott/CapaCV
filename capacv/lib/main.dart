import 'package:flutter/material.dart';
import 'package:capacv/screens/homeScreen.dart';
import 'package:provider/provider.dart';
import 'package:capacv/models/filters.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => Filters(),
        child: CapaCV(),
      ),
    );

class CapaCV extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CapaCV',
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
      ),
      home: HomeScreen(),
    );
  }

  void filterHandler(BuildContext context) {}
}
