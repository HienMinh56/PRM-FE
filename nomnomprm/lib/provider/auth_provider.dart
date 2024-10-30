import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  String? _accessToken;
  bool _isAuthenticated = false;

  String? get accessToken => _accessToken;
  bool get isAuthenticated => _isAuthenticated;

  void setAccessToken(String token) {
    _accessToken = token;
    _isAuthenticated = true;
    notifyListeners();
  }

  bool checkAuthenticated() {
    return _isAuthenticated && _accessToken != null;
  }

  void logout() {
    _accessToken = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
