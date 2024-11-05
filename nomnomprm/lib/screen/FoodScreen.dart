import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:nomnomprm/animation/Car_Animation.dart';
import 'package:nomnomprm/model/user_model.dart';
import 'package:nomnomprm/provider/cart_provider.dart';
import 'package:nomnomprm/provider/user_provider.dart';
import 'package:nomnomprm/screen/CartScreen.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class FoodPage extends StatefulWidget {
  final String storeId;

  FoodPage({required this.storeId});

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  List<dynamic> _foods = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchFoods();
  }

  Future<void> fetchFoods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/food?storeId=${widget.storeId}'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> foods = jsonResponse['data']['foods'];

        setState(() {
          _foods = foods;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load foods');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching foods: $e');
      // Handle error appropriately (e.g., show error message)
    }
  }

  void _showDifferentStoreSnackBar() {
  final snackBar = SnackBar(
    content: AwesomeSnackbarContent(
      title: 'Warning!',
      message: 'Sorry!!! You can only add items from one store at a time.',
      contentType: ContentType.warning,
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void _showAddToCartMessage(String itemName) {
  final snackBar = SnackBar(
    content: AwesomeSnackbarContent(
      title: 'Success!',
      message: '$itemName added to cart',
      contentType: ContentType.success,
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Center(
                    child: CarAnimation(),
                  );
                },
                barrierDismissible: true,
              );

              Future.delayed(Duration(seconds: 2), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                );
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.7,
              ),
              itemCount: _foods.length,
              itemBuilder: (context, index) {
                final food = _foods[index];
                final foodId = food['foodId'] as String;
                final name = food['title'] as String;
                final description = food['description'] as String?;
                final price = (food['price'] as num).toInt();
                final imageUrl = food['image'] as String;
                final orderCount = food['orderCount'] as int?;

                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => FoodDetailDialog(
                        foodId: foodId,
                        name: name,
                        description: description ?? 'No description',
                        price: price,
                        imageUrl: imageUrl,
                        onAddToCart: (quantity, note) {
                          UserModel? user =
                              Provider.of<UserProvider>(context, listen: false)
                                  .user;
                          if (user != null) {
                            final cartProvider = Provider.of<CartProvider>(
                                context,
                                listen: false);
                            if (cartProvider.items.isNotEmpty &&
                                cartProvider.currentStoreId != widget.storeId) {
                              _showDifferentStoreSnackBar();
                            } else {
                              cartProvider.addItem(
                                foodId,
                                name,
                                price,
                                widget.storeId,
                                imageUrl,
                                note,
                                quantity,
                              );
                              _showAddToCartMessage(name);
                            }
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Not Logged In'),
                                content:
                                    Text('Please login to add items to cart'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 2.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10.0)),
                          child: Image.network(
                            imageUrl,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  description ?? 'No description',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${price.toStringAsFixed(0)} Nom Coin',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${orderCount ?? 0}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey,fontSize: 16),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.shopping_cart,
                                            color: Colors.blueGrey, size: 16,),
                                      ],
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add_circle_outline),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              FoodDetailDialog(
                                            foodId: foodId,
                                            name: name,
                                            description:
                                                description ?? 'No description',
                                            price: price,
                                            imageUrl: imageUrl,
                                            onAddToCart: (quantity, note) {
                                              UserModel? user =
                                                  Provider.of<UserProvider>(
                                                          context,
                                                          listen: false)
                                                      .user;
                                              if (user != null) {
                                                final cartProvider =
                                                    Provider.of<CartProvider>(
                                                        context,
                                                        listen: false);
                                                if (cartProvider
                                                        .items.isNotEmpty &&
                                                    cartProvider
                                                            .currentStoreId !=
                                                        widget.storeId) {
                                                  _showDifferentStoreSnackBar();
                                                } else {
                                                  cartProvider.addItem(
                                                    foodId,
                                                    name,
                                                    price,
                                                    widget.storeId,
                                                    imageUrl,
                                                    note,
                                                    quantity,
                                                  );
                                                  _showAddToCartMessage(name);
                                                }
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title:
                                                        Text('Not Logged In'),
                                                    content: Text(
                                                        'Please login to add items to cart'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('OK'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class FoodDetailDialog extends StatefulWidget {
  final String foodId;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final Function(int quantity, String note) onAddToCart;

  FoodDetailDialog({
    required this.foodId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.onAddToCart,
  });

  @override
  _FoodDetailDialogState createState() => _FoodDetailDialogState();
}

class _FoodDetailDialogState extends State<FoodDetailDialog> {
  int _quantity = 1;
  String _note = '';

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(widget.imageUrl),
          SizedBox(height: 5),
          Text(widget.description,
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(
            'Price: ${widget.price.toStringAsFixed(0)} Nom Coin',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: _decrementQuantity,
              ),
              SizedBox(width: 8), // Khoảng cách nhỏ giữa các biểu tượng
              Text(_quantity.toString()),
              SizedBox(width: 8), // Khoảng cách nhỏ giữa các biểu tượng
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _incrementQuantity,
              ),
            ],
          ),
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              labelText: 'Note',
            ),
            onChanged: (value) {
              setState(() {
                _note = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
            side: WidgetStateProperty.all<BorderSide>(
              BorderSide(color: Colors.white),
            ),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            widget.onAddToCart(_quantity, _note);
            Navigator.of(context).pop();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Colors.orange),
            side: WidgetStateProperty.all<BorderSide>(
              BorderSide(color: Colors.white),
            ),
          ),
          child: Text(
            'Add to Cart',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
