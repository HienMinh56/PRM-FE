import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:NomDeli/page/LoginScreen.dart';
import 'package:NomDeli/page/SuccessScreen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedCampus;
  int _currentIndex = 1;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _usernameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isFormValid = false;
List<Map<String, String>> _campuses = [];

  @override
  void initState() {
    super.initState();
    _fetchCampuses(); // Fetch campuses when the widget is initialized
  }
  Future<void> _fetchCampuses() async {
  var url = 'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/campus';
  var response = await http.get(Uri.parse(url));
  
  if (response.statusCode == 200) {
    var responseData = json.decode(response.body);
    
    if (responseData['isSuccess']) {
      setState(() {
        _campuses = (responseData['data'] as List)
            .where((campus) => campus['status'] == 1) // Filter campuses with status 1
            .map((campus) => {
                  "name": campus['name'].toString(),
                  "id": campus['campusId'].toString(),
                })
            .toList()
            .cast<Map<String, String>>();
      });
    } else {
      // Handle the error case
      showAwesomeSnackBar(context, 'Error', 'Failed to load campuses', ContentType.failure);
    }
  } else {
    // Handle the response error
    showAwesomeSnackBar(context, 'Error', 'Failed to load campuses', ContentType.failure);
  }
}

  void _navigateToSignInScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void showAwesomeSnackBar(BuildContext context, String title, String message, ContentType type) {
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

  Future<void> _registerUser(BuildContext context) async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    var url = 'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/account/mobile';
    var data = {
      "userName": _usernameController.text,
      "password": _passwordController.text,
      "confirmPassword": _confirmPasswordController.text,
      "email": _emailController.text,
      "name": _nameController.text,
      "campusId": _selectedCampus,
      "phone": _phoneController.text
    };

    var headers = {
      'Content-Type': 'application/json',
      'accept': 'text/plain',
    };

    var response = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(data));

    var responseData = json.decode(response.body);

   if (response.statusCode == 200 && responseData['data']['isSuccess']) {
    showAwesomeSnackBar(context, 'Success', 'Register Success', ContentType.success);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SuccessScreen()),
    );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${responseData['data']['message']}")),
      );
    }
  }

  void showCustomSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Color.fromARGB(255, 70, 233, 29),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Color.fromARGB(255, 70, 233, 29), width: 2),
      ),
      margin: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _validateUsername(String value) {
    final regex = RegExp(r'^[a-zA-Z0-9_]+$');
    setState(() {
      if (value.isEmpty) {
        _usernameError = 'Please enter a username';
      } else if (!regex.hasMatch(value)) {
        _usernameError = 'Username cannot contain spaces or special characters';
      } else {
        _usernameError = null;
      }
      _validateForm();
    });
  }

  void _validatePhone(String value) {
    final regex = RegExp(r'^0\d{9,10}$');
    setState(() {
      if (value.isEmpty) {
        _phoneError = 'Please enter a phone number';
      } else if (!regex.hasMatch(value)) {
        _phoneError =
            'Phone number must start with 0 and be 10 to 11 digits long';
      } else {
        _phoneError = null;
      }
      _validateForm();
    });
  }

  void _validateEmail(String value) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Please enter an email address';
      } else if (!regex.hasMatch(value)) {
        _emailError = 'Please enter a valid email address';
      } else {
        _emailError = null;
      }
      _validateForm();
    });
  }

  void _validatePassword(String value) {
    final passwordRegex = RegExp(r'^(?=.*?[a-zA-Z])(?=.*?[0-9]).{6,16}$');
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Please enter a password';
      } else if (!passwordRegex.hasMatch(value)) {
        _passwordError =
            'Password must be 6 to 16 characters long and include both letters and numbers';
      } else {
        _passwordError = null;
      }
      _validateForm();
    });
  }
void _validateConfirmPassword(String value) {
  setState(() {
    if (value.isEmpty) {
      _confirmPasswordError = 'Please confirm your password';
    } else if (value != _passwordController.text) {
      _confirmPasswordError = 'Passwords do not match';
    } else {
      _confirmPasswordError = null;
    }
    _validateForm();
  });
}

  void _validateForm() {
    setState(() {
      _isFormValid = _usernameError == null &&
          _emailError == null &&
          _phoneError == null &&
          _passwordError == null &&
          _confirmPasswordError == null &&
          _usernameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _selectedCampus != null &&
          _nameController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Icon(
              Icons.person_add,
              size: 40,
              color: Color.fromARGB(255, 238, 147, 62),
            ),
            SizedBox(height: 40),
            Text(
              'Create Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Let\'s get started by filling out the form below.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                errorText: _usernameError,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0), // Set border color and width here
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0), // Set border color and width here
                  ),
              ),
              onChanged: _validateUsername,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _emailError,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0), // Set border color and width here
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0), // Set border color and width here
                  ),
              ),
              onChanged: _validateEmail,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                errorText: _phoneError,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0), // Set border color and width here
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0), // Set border color and width here
                  ),
              ),
              onChanged: _validatePhone,
            ),
            SizedBox(height: 20),
            DropdownButtonFormField(
              value: _selectedCampus,
              items: _campuses.map((campus) {
                return DropdownMenuItem(
                  child: Text(campus['name']!),
                  value: campus['id'],
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCampus = value as String?;
                  _validateForm();
                });
              },
              decoration: InputDecoration(
                labelText: 'Choose Campus',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.orange, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.orange, width: 2.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0), // Set border color and width here
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0), // Set border color and width here
                  ),
              ),
              onChanged: (value) => _validateForm(),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _passwordError,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0), // Set border color and width here
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0), // Set border color and width here
                  ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              onChanged: _validatePassword,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                errorText: _confirmPasswordError != null ? 'Passwords do not match' : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0), // Set border color and width here
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0), // Set border color and width here
                  ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              onChanged: _validateConfirmPassword,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isFormValid
                  ? () {
                      _registerUser(context);
                    }
                  : null,
              child: Text('Register'),
              style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 238, 147, 62),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
            ),
            ),
            SizedBox(height: 20),
           
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color.fromARGB(255, 238, 147, 62),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (_currentIndex == 0) {
              _navigateToSignInScreen();
            }
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Sign In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Sign Up',
          ),
        ],
      ),
    );
  }
}
