import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nomnomprm/model/user_model.dart';
import 'package:http/http.dart' as http;

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
  Future<void> fetchUserData(String userId) async {
    final url = 'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/user?userId=$userId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      // Check if the response indicates success and contains data
      if (responseData['isSuccess'] == true && responseData['data'] is List) {
        // Get the first user data from the list
        final userData = responseData['data'][0];
        setUser(UserModel.fromJson(userData)); // Update user
      } else {
        throw Exception('Failed to load user data');
      }
    } else {
      throw Exception('Failed to load user data');
    }
  }
}
