import 'dart:convert';
import 'package:NomDeli/Provider/user_provider.dart';
import 'package:NomDeli/model/store_model.dart';
import 'package:NomDeli/page/CartScreen.dart';
import 'package:NomDeli/page/FoodScreen.dart';
import 'package:NomDeli/page/OrderHistoryScreen.dart';
import 'package:NomDeli/page/UserProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantPage extends StatefulWidget {
  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  List<Store> _stores = [];
  List<Store> _filteredStores = [];
  bool _isLoading = false;
  String? _areaName;
  String? _currentSessionId; 
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserAreaAndStores();
  }

  Future<void> fetchUserAreaAndStores() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id;

      if (userId == null) {
        throw Exception('User ID not found');
      }

      final userResponse = await http.get(Uri.parse(
          'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/user?userId=$userId'));

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);
        if (userData['isSuccess']) {
          final user = userData['data'][0];
          setState(() {
             _currentSessionId = _getCurrentSessionId();
            _areaName = user['area'];
          });
          fetchStores(_areaName!);
        } else {
          throw Exception('Failed to fetch user data');
        }
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching user data: $e');
    }
  }

  Future<void> fetchStores(String areaName) async {
    try {
      final sessionId = _getCurrentSessionId();
      if (sessionId == null) {
        throw Exception('No active session found');
      }

      final response = await http.get(Uri.parse(
          'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/store?status=1&sessionId=$sessionId&areaName=$areaName'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> storeJson = jsonResponse['data'];

        setState(() {
          _stores = storeJson.map((json) => Store.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load stores');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching stores: $e');
    }
  }

  String? _getCurrentSessionId() {
    final currentTime = DateTime.now();

    List<Map<String, String>> sessions = [
      {"SessionId": "SESSION001", "StartTime": "04:00:00", "EndTime": "08:30:00"},
      {"SessionId": "SESSION002", "StartTime": "08:35:00", "EndTime": "11:30:00"},
      {"SessionId": "SESSION003", "StartTime": "13:00:00", "EndTime": "22:00:00"},
    ];

    for (var session in sessions) {
      final startTimeParts = session["StartTime"]!.split(':');
      final endTimeParts = session["EndTime"]!.split(':');

      final startTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        int.parse(startTimeParts[0]),
        int.parse(startTimeParts[1]),
        int.parse(startTimeParts[2]),
      );
      final endTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        int.parse(endTimeParts[0]),
        int.parse(endTimeParts[1]),
        int.parse(endTimeParts[2]),
      );

      if (currentTime.isAfter(startTime) && currentTime.isBefore(endTime)) {
        return session["SessionId"];
      }
    }

    return null;
  }

  void filterStores(String query) {
    List<Store> filteredList = _stores.where((store) {
      return store.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredStores = filteredList;
    });
  }

  Future<void> handleRefresh() async {
    if (_areaName != null) {
      await fetchStores(_areaName!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              'img/logo.png', // Replace with your actual image path
              width: 32, // Adjust size as needed
              height: 32, // Adjust size as needed
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
               _currentSessionId ?? '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 238, 147, 62),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: handleRefresh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                String url =
                    'https://hanoi.fpt.edu.vn/tin-tuc-su-kien/truong-dai-hoc-fpt-thong-bao-cap-hoc-bong-toan-phan-cho-tat-ca-cac-truong-thpt-tren-toan-quoc-nam-2024.html';
                launch(url);
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.asset(
                        'img/qc.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  filterStores(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search by store name',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0), // Set border color and width here
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0), // Set border color and width here
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _filteredStores.isEmpty
                          ? _stores.length
                          : _filteredStores.length,
                      itemBuilder: (context, index) {
                        final store = _filteredStores.isEmpty
                            ? _stores[index]
                            : _filteredStores[index];
                        return StoreCard(
                          store: store,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FoodPage(storeId: store.storeId),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Color.fromARGB(255, 238, 147, 62),
        unselectedItemColor: Colors.black,
        selectedIconTheme: IconThemeData(size: 24),
        unselectedIconTheme: IconThemeData(size: 24),
        onTap: (index) {
          switch (index) {
            case 0:
              break; // Stay on the current page
            case 1:
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      CartPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      OrderHistoryPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      UserProfilePage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
              break;
          }
        },
      ),
    );
  }
}

class StoreCard extends StatelessWidget {
  final Store store;
  final VoidCallback onTap;

  const StoreCard({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Image.asset(
              'img/store.png',
              width: 60, // Adjust the width and height as needed
              height: 60,
              fit: BoxFit.cover,
            ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      store.address,
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      store.phone,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
