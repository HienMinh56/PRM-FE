import 'package:flutter/material.dart';
import 'package:nomnomprm/provider/cart_provider.dart';
import 'package:nomnomprm/provider/user_provider.dart';
import 'package:nomnomprm/screen/CartScreen.dart';
import 'package:nomnomprm/screen/EditProfileScreen.dart';
import 'package:nomnomprm/screen/LoginScreen.dart';
import 'package:nomnomprm/screen/OrderHistoryScreen.dart';
import 'package:nomnomprm/screen/WalletScreen.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);


    Future<void> _refreshUserProfile() async {
    setState(() {
    });

    try {
      // Gọi phương thức fetchUserData từ thể hiện _userProvider
      await userProvider.fetchUserData(userProvider.user!.id);
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Error fetching user data: $e');
    } finally {
      setState(() {
      });
    }
  }
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.user == null) {
            return Center(child: CircularProgressIndicator());
          }
          final user = userProvider.user!;
          return RefreshIndicator(
            onRefresh: _refreshUserProfile,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.orange,
                      child: Text(
                        user.username.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 40.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      userProvider.user!.username,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 30),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.account_balance_wallet_outlined),
                        title: Text('Wallet'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WalletPage(userId: user.id),
                            ),
                          );
                        },
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit profile'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                userId: user.id,
                                onUpdate:
                                    _refreshUserProfile, // Pass the callback here
                              ),
                            ),
                          );
                          // You can remove this if you're using the callback
                          // await _refreshUserProfile();
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.description_outlined),
                        title: Text('Terms of Service'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QrCodePage(),
                            ),
                          );
                        },
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Log out'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _logout(userProvider,
                              cartProvider); // Call the logout method
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Powered by NomNom Team',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
        currentIndex: 3,
        selectedItemColor: Color.fromARGB(255, 238, 147, 62),
        unselectedItemColor: Colors.black,
        selectedIconTheme:
            IconThemeData(size: 24), // Keep the size consistent for selected
        unselectedIconTheme:
            IconThemeData(size: 24), // Keep the size consistent for unselected
        onTap: (index) {
          switch (index) {
            case 0:
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
              break;
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
              // Stay on the current page
              break;
          }
        },
      ),
    );
  }

  


  void _logout(UserProvider userProvider, CartProvider cartProvider) {
    // Clear user-related data
    userProvider.clearUser();

    // Clear cart for the current user
    cartProvider.clearCart();

    // Navigate to Login page and remove all routes from the stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }
}
