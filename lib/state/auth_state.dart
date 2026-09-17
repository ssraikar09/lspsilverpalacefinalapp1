import 'package:flutter/material.dart';

class AuthState extends ChangeNotifier {
  bool _isGuest = false;
  bool _isAuthenticated = false;

  bool get isGuest => _isGuest;
  bool get isAuthenticated => _isAuthenticated;

  void loginAsGuest() {
    _isGuest = true;
    _isAuthenticated = false;
    notifyListeners();
  }

  void logout() {
    _isGuest = false;
    _isAuthenticated = false;
    notifyListeners();
  }

  void setAuthenticated() {
    _isAuthenticated = true;
    _isGuest = false;
    notifyListeners();
  }
}

final globalAuthState = AuthState();
