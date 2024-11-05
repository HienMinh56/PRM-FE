import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:nomnomprm/model/cart_model.dart';
import 'package:nomnomprm/provider/auth_provider.dart';
import 'package:nomnomprm/provider/cart_provider.dart';
import 'package:nomnomprm/screen/OrderHistoryScreen.dart';
import 'package:nomnomprm/screen/UserProfileScreen.dart';
import 'package:provider/provider.dart';


class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    Provider.of<AuthProvider>(context);
    final voucherController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items.values.toList()[index];
                return CartItemCard(cartItem: item);
              },
            ),
          ),
          CheckoutSummary(totalItems: cart.itemCount, totalAmount: cart.totalAmount,voucherController: voucherController,),
          CheckoutButton(voucherController: voucherController,),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
                pageBuilder: (context, animation, secondaryAnimation) => RestaurantPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          } else if (index == 1) {
            // Stay on the cart page
          } else if (index == 2) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => OrderHistoryPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => UserProfilePage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
    );
  }
}

class CartItemCard extends StatefulWidget {
  final CartItem cartItem;

  const CartItemCard({required this.cartItem});

  @override
  _CartItemCardState createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.cartItem.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _updateNote() {
    widget.cartItem.note = _noteController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [Container(
                width: 100,
                height: 100,
                child: Image.network(
                  widget.cartItem.imageUrl, // Use the image URL from the model
                  fit: BoxFit
                      .cover, // Ensure the image covers the entire container
                ),
              ),
            SizedBox(width: 10),
           
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.cartItem.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text('${widget.cartItem.price.toStringAsFixed(0)} Nom Coin'),
                  Row(
                    children: [
                      Text('Quantity: '),
                      QuantitySelector(cartItem: widget.cartItem),
                    ],
                  ),
                  TextField(
                    controller: _noteController,
                    onChanged: (value) => _updateNote(),
                    decoration: InputDecoration(
                      labelText: 'Note',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            12.0), // Đường viền bo tròn với bán kính 12.0
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false).removeItem(widget.cartItem.foodId);
              },
            ),
          ],
        ),
      ),
    );
  }
}



class QuantitySelector extends StatefulWidget {
  final CartItem cartItem;

  const QuantitySelector({required this.cartItem});

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.cartItem.quantity;
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity > 0) {
      setState(() {
        _quantity = newQuantity;
      });
      Provider.of<CartProvider>(context, listen: false).updateItemQuantity(widget.cartItem.foodId, newQuantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () {
            if (_quantity > 1) {
              _updateQuantity(_quantity - 1);
            }
          },
        ),
        Text('$_quantity'),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            _updateQuantity(_quantity + 1);
          },
        ),
      ],
    );
  }
}

class CheckoutSummary extends StatelessWidget {
  final int totalItems;
  final int totalAmount;
  final TextEditingController voucherController; // Accept the voucher controller as a parameter

  CheckoutSummary({
    required this.totalItems,
    required this.totalAmount,
    required this.voucherController, // Initialize it here
  });

  @override
  Widget build(BuildContext context) {
    // Calculate ship fee based on whether the cart is empty
    int shipFee = totalItems > 0 ? 5 : 0;
    int finalAmount = totalAmount + shipFee;

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text('Count'),
          //     Text(totalItems.toString()),
          //   ],
          // ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total'),
              Text('${totalAmount} Nom Coin'),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ship Fee'),
              Text('${shipFee} Nom Coin'),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Final Amount'),
              Text('${finalAmount} Nom Coin'),
            ],
          ),
          SizedBox(height: 10),
          // BalanceDisplay(),
          SizedBox(height: 10),
          TextField(
            controller: voucherController, // Connect the voucherController here
            decoration: InputDecoration(
              labelText: 'Enter Voucher Code',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}




class BalanceDisplay extends StatefulWidget {
  @override
  _BalanceDisplayState createState() => _BalanceDisplayState();
}

class _BalanceDisplayState extends State<BalanceDisplay> {
  late Future<int> _userBalanceFuture;

  @override
  void initState() {
    super.initState();
    _userBalanceFuture = _fetchUserBalance(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _userBalanceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Balance'),
              Text('${snapshot.data.toString()} Nom Coin'),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  Future<int> _fetchUserBalance(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (auth.accessToken == null) {
      throw Exception('User not authenticated');
    }

    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(auth.accessToken!);
      final userId = decodedToken['UserId'];

      final url = 'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/user?userId=$userId';
      final headers = {
        'accept': '*/*',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final userBalance = responseBody['data'][0]['balance'] as int;
        return userBalance;
      } else {
        throw Exception('Failed to fetch user balance');
      }
    } catch (e) {
      throw Exception('Failed to fetch user balance: $e');
    }
  }
}

class CheckoutButton extends StatefulWidget {
  final TextEditingController voucherController;
  CheckoutButton({required this.voucherController});
  _CheckoutButtonState createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<CheckoutButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: isLoading ? null : () => _handleCheckout(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 128.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 238, 147, 62),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      'Checkout',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: const Color.fromARGB(255, 1, 238, 9)),
            SizedBox(width: 10),
            Expanded(child: Text(message, style: TextStyle(color: Colors.black),)),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  void _showFailureMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Expanded(child: Text(message, style: TextStyle(color: Colors.black),)),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  bool _isWithinSession(DateTime currentTime) {
    List<Map<String, String>> sessions = [
      {"SessionId": "SESSION001", "StartTime": "04:00:00", "EndTime": "08:30:00"},
      {"SessionId": "SESSION002", "StartTime": "08:35:00", "EndTime": "11:30:00"},
      {"SessionId": "SESSION003", "StartTime": "13:00:00", "EndTime": "22:00:00"},
    ];

    for (var session in sessions) {
      final startTime = DateFormat.Hms().parse(session["StartTime"]!);
      final endTime = DateFormat.Hms().parse(session["EndTime"]!);

      if (currentTime.isAfter(DateTime(
              currentTime.year, currentTime.month, currentTime.day, startTime.hour, startTime.minute, startTime.second)) &&
          currentTime.isBefore(DateTime(
              currentTime.year, currentTime.month, currentTime.day, endTime.hour, endTime.minute, endTime.second))) {
        return true;
      }
    }

    return false;
  }

  void _handleCheckout(BuildContext context) async {
  final cart = Provider.of<CartProvider>(context, listen: false);
  final auth = Provider.of<AuthProvider>(context, listen: false);
  final voucherCode = widget.voucherController.text;

  if (cart.items.isEmpty) {
    _showFailureMessage(context, 'Giỏ hàng của bạn trống. Vui lòng thêm sản phẩm vào giỏ.');
    return;
  }

  setState(() {
    isLoading = true;
  });

  if (auth.accessToken == null) {
    _showFailureMessage(context, 'User not authenticated');
    setState(() {
      isLoading = false;
    });
    return;
  }

  final currentTime = DateTime.now();
  if (!_isWithinSession(currentTime)) {
    _showFailureMessage(context, 'No active session found. Please try again later.');
    setState(() {
      isLoading = false;
    });
    return;
  }

  try {
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(auth.accessToken!);
    final userId = decodedToken['UserId'];

    final balanceUrl = 'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/user/balance?userId=$userId&amount=-${cart.totalAmount.toInt() + 5}';
    final balanceHeaders = {
      'accept': '*/*',
      'Authorization': 'Bearer ${auth.accessToken}',
    };

    final balanceResponse = await http.put(Uri.parse(balanceUrl), headers: balanceHeaders);

    if (balanceResponse.statusCode == 200) {
      final orderUrl = 'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/order';
      final orderHeaders = {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Authorization': 'Bearer ${auth.accessToken}',
      };

      final orderBody = jsonEncode({
        "foodItems": cart.items.values.map((item) => {
          "foodId": item.foodId,
          "quantity": item.quantity,
          "note": item.note.isEmpty ? "nothing" : item.note,
        }).toList(),
        "voucherCode": voucherCode,  // Include voucher code in the request
      });

      final orderResponse = await http.post(Uri.parse(orderUrl), headers: orderHeaders, body: orderBody);

      if (orderResponse.statusCode == 200) {
        cart.clearCart();
        _showSuccessMessage(context, 'Checkout successful!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OrderHistoryPage()),
        );
      } else {
        _showFailureMessage(context, 'Order creation failed. Please try again.');
      }
    } else {
      _showFailureMessage(context, 'Failed to update balance. Please try again.');
    }
  } catch (e) {
    print('Error during checkout: $e');
    _showFailureMessage(context, 'An error occurred. Please try again.');
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


}