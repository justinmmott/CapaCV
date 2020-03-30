import 'package:flutter/material.dart';


class Filters extends ChangeNotifier {
  List<String> _filters = ['Study', 'Restaurant', 'Cafe', 'Grocery'];

  List<String> get filter => _filters;

  void addFilter(String filter) {
    _filters.add(filter);

    notifyListeners();
  }

  void clearFilter(String filter) {
    _filters.remove(filter);

    notifyListeners();
  }
}
