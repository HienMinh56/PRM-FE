import 'package:flutter/material.dart';
import 'package:nomnomprm/provider/auth_provider.dart';
import 'package:nomnomprm/provider/cart_provider.dart';
import 'package:nomnomprm/provider/user_provider.dart';
import 'package:nomnomprm/screen/LoginScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('accessToken');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MyApp(accessToken: accessToken),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? accessToken;

  MyApp({this.accessToken});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (accessToken != null) {
          authProvider.setAccessToken(accessToken!);
        }
        return MaterialApp(
          title: 'NomNom',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: _decideMainScreen(authProvider),
          routes: {
            '/restaurant': (context) => RestaurantPage(),
            '/login': (context) => LoginPage(),
          },
        );
      },
    );
  }

  Widget _decideMainScreen(AuthProvider authProvider) {
    if (authProvider.checkAuthenticated()) {
      return RestaurantPage();
    } else {
      return LoginPage();
    }
  }
}
