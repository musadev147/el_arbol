import 'package:flutter/material.dart';

class CarosulProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
