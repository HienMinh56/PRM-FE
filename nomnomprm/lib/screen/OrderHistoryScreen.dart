import 'dart:convert';
import 'package:NomDeli/Provider/user_provider.dart';
import 'package:NomDeli/model/order_model.dart';
import 'package:NomDeli/page/CartScreen.dart';
import 'package:NomDeli/page/OrderDetailScreen.dart';
import 'package:NomDeli/page/RestaurantScreen.dart';
import 'package:NomDeli/page/UserProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<Order> orders = [];
  bool isLoading = true;
  bool hasError = false;
  String filter = 'All'; // Default filter value

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id;

    if (userId == null) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/order?userId=$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['isSuccess']) {
          List<Order> fetchedOrders = (data['data'] as List)
              .map((order) => Order.fromJson(order))
              .toList();

          // Sort orders by date in descending order (newest first)
          fetchedOrders.sort((a, b) => b.id.compareTo(a.id));

          setState(() {
            orders = fetchedOrders;
            isLoading = false;
            hasError = false;
          });
        } else {
          setState(() {
            isLoading = false;
            hasError = true;
          });
        }
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Order Recent'),
          centerTitle: true, // Center the title
          automaticallyImplyLeading: false, // Remove the back button
          bottom: TabBar(
            tabs: [
              Tab(text: 'Accepted'), // Switched tabs
              Tab(text: 'Finished'), // Switched tabs
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : hasError
                ? Center(child: Text('Something went wrong'))
                : TabBarView(
                    children: [
                      OrderList(
                        orders: orders
                            .where((order) => order.status == 'Accepted')
                            .toList(),
                        onRefresh: fetchOrders,
                      ), // Display status 'Accepted'
                      FinishedOrderList(
                        orders: orders,
                        filter: filter,
                        onFilterChange: (String newFilter) {
                          setState(() {
                            filter = newFilter;
                          });
                        },
                        onRefresh: fetchOrders,
                      ), // Display status 'Cancel' and 'Done' with filter
                    ],
                  ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
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
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'UserProfile',
            ),
          ],
          selectedItemColor: Color.fromARGB(255, 238, 147, 62),
          unselectedItemColor: Colors.black,
          selectedIconTheme: IconThemeData(size: 24),
          unselectedIconTheme: IconThemeData(size: 24),
          onTap: (index) {
            if (index == 0) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      RestaurantPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            } else if (index == 1) {
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
            } else if (index == 2) {
              // Stay here
            } else if (index == 3) {
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
            }
          },
        ),
      ),
    );
  }
}

class OrderList extends StatelessWidget {
  final List<Order> orders;
  final Future<void> Function() onRefresh;

  OrderList({required this.orders, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return OrderCard(order: orders[index]);
        },
      ),
    );
  }
}

class FinishedOrderList extends StatelessWidget {
  final List<Order> orders;
  final String filter;
  final Function(String) onFilterChange;
  final Future<void> Function() onRefresh;

  FinishedOrderList({
    required this.orders,
    required this.filter,
    required this.onFilterChange,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    List<Order> filteredOrders = orders.where((order) {
      if (filter == 'All') {
        return order.status == 'Cancel' || order.status == 'Done';
      } else {
        return order.status == filter;
      }
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: DropdownButton<String>(
              value: filter,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onFilterChange(newValue);
                }
              },
              items: <String>['All', 'Done', 'Cancel']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                return OrderCard(order: filteredOrders[index]);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({required this.order});

  Color getStatusColor() {
    switch (order.status) {
      case 'Accepted':
        return Colors.orange; // Màu cam cho Accepted
      case 'Done':
        return Colors.green; // Màu xanh cho Done
      case 'Cancel':
        return Colors.red; // Màu đỏ cho Cancel
      default:
        return Colors.black; // Màu mặc định
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(orderId: order.id),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.all(8.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #: ${order.id}'),
                    Text('Store: ${order.name}'),
                    Row(
                      children: [
                        Text(DateFormat('dd-MM-yyyy').format(order.date)),
                        if (order.voucher != "null") ...[
                          SizedBox(width: 5),
                          Text(' || Voucher: ${order.voucher}'),
                        ],
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 4.0),
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          color: getStatusColor(),
                        ),
                      ),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
        ));
  }
}
