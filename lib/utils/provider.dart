import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum DataJumlah {
  NOTIF,
  OUTLET,
  OUTLET_POS,
}

class AppState with ChangeNotifier {
  AppState();

  bool _isLoading = false;
  bool _isStarted = false;
  Map<DataJumlah, int> _jumlah = Map();

  bool get isLoading => _isLoading;
  bool get isStarted => _isStarted;
  Map<DataJumlah, int> get jumlah => _jumlah;

  set isLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  set isStarted(bool started) {
    _isStarted = true;
    notifyListeners();
  }
  updateJumlah(DataJumlah data, int jumlah) {
    _jumlah[data] = jumlah;
    notifyListeners();
  }

  //current menu
  int _currentMenu = -1;
  int get currentMenu => _currentMenu;
  set currentMenu(int indeks) {
    _currentMenu = indeks;
    notifyListeners();
  }

  //current login
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    if (value) _isStarted = true;
    notifyListeners();
  }
}
