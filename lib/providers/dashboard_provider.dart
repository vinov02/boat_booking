import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    if (_currentIndex == index) {
      notifyListeners();
      return;
    }
    _currentIndex = index;
    notifyListeners();
  }

   void reset() {
    _currentIndex = 0; // Home tab
    notifyListeners();
  }
}
