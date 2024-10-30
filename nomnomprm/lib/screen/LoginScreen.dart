import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:nomnomprm/model/user_model.dart';
import 'package:nomnomprm/provider/auth_provider.dart';
import 'package:nomnomprm/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool isProcessing = false;
  int _currentIndex = 0;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void showAwesomeSnackBar(
      BuildContext context, String title, String message, ContentType type) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: type,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate() && !isProcessing) {
      setState(() {
        isProcessing = true; // Disable button while processing
      });

      final url = Uri.parse(
          'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/authorize/login');
      final queryParams = {
        'userName': _usernameController.text,
        'password': _passwordController.text,
      };
      final uri = url.replace(queryParameters: queryParams);

      try {
        final response = await http.post(uri);

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          String accessToken = responseBody['accessTokenToken'];
          Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

          final user = UserModel(
            id: decodedToken['UserId'],
            username: decodedToken['UserName'],
            email: decodedToken['Email'],
            RoleId: decodedToken['Role'],
          );

          if (user.RoleId != "2") {
            showAwesomeSnackBar(context, 'Error',
                'You have no permission in system', ContentType.failure);
            return;
          }

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', accessToken);

          Provider.of<AuthProvider>(context, listen: false)
              .setAccessToken(accessToken);
          Provider.of<UserProvider>(context, listen: false).setUser(user);

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => RestaurantPage()),
          // );
        } else {
          showAwesomeSnackBar(context, 'Error', 'Username or password is wrong',
              ContentType.failure);
        }
      } catch (e) {
        showAwesomeSnackBar(
            context, 'Error', 'An error occurred', ContentType.failure);
      } finally {
        setState(() {
          isProcessing = false; // Re-enable button after processing
        });
      }
    }
  }

  void showCustomSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red, // Background color
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.red, width: 2),
      ),
      margin: EdgeInsets.only(
          top: 20.0,
          left: 10.0,
          right: 10.0), // Position at the top with some margin
      padding: EdgeInsets.symmetric(
          horizontal: 20.0, vertical: 10.0), // Padding inside the SnackBar
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // void _navigateToSignUpScreen() {
  //   Navigator.push(
  //     context,
  //     PageRouteBuilder(
  //       pageBuilder: (context, animation, secondaryAnimation) => SignUpScreen(),
  //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //         return FadeTransition(
  //           opacity: animation,
  //           child: child,
  //         );
  //       },
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LogoSection(),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: LoginForm(
                  formKey: _formKey,
                  usernameController: _usernameController,
                  passwordController: _passwordController,
                  isPasswordVisible: _isPasswordVisible,
                  togglePasswordVisibility: _togglePasswordVisibility,
                  login: _login,
                  isProcessing: isProcessing,
                ),
              ),
            ],
          ),
        ),
        // bottomNavigationBar: BottomNavigationSection(
        //   currentIndex: _currentIndex,
        //   navigateToSignUpScreen: _navigateToSignUpScreen,
        // ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm Exit'),
            content: Text('Are you sure you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
}

class LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 198, 230, 255),
            Color.fromARGB(255, 248, 211, 255),
          ], // Adjust the colors as needed
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(
                'img/logo.png'), // Replace with your logo image asset
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final VoidCallback togglePasswordVisibility;
  final Future<void> Function() login;
  final bool isProcessing;

  const LoginForm({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.togglePasswordVisibility,
    required this.login,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 238, 147, 62),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            'Fill out the information below in order to access your account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 30),
          TextFormField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: 'UserName',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                    color: Colors.orange,
                    width: 2.0), // Set border color and width here
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                    color: Colors.orange,
                    width: 2.0), // Set border color and width here
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: passwordController,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                    color: Colors.orange,
                    width: 2.0), // Set border color and width here
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                    color: Colors.orange,
                    width: 2.0), // Set border color and width here
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: togglePasswordVisibility,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: isProcessing ? null : login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 238, 147, 62),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
            ),
            child: isProcessing
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Sign In',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }
}

class BottomNavigationSection extends StatelessWidget {
  final int currentIndex;
  final VoidCallback navigateToSignUpScreen;

  const BottomNavigationSection({
    required this.currentIndex,
    required this.navigateToSignUpScreen,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Color.fromARGB(255, 238, 147, 62),
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 1) {
          navigateToSignUpScreen();
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.login),
          label: 'Sign In',
          backgroundColor: Color.fromARGB(255, 238, 147, 62),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_add),
          label: 'Sign Up',
          backgroundColor: Color.fromARGB(255, 238, 147, 62),
        ),
      ],
    );
  }
}
