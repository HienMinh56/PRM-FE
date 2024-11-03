import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nomnomprm/screen/LoginScreen.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  final VoidCallback onUpdate;

  EditProfilePage({required this.userId, required this.onUpdate});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _campusController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  final Map<String, bool> _obscureText = {
    'oldPassword': true,
    'newPassword': true,
    'confirmPassword': true,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    var url =
        'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/user?userId=${widget.userId}';
    var response = await http.get(Uri.parse(url));

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      if (responseBody['isSuccess']) {
        var userData = responseBody['data'][0];
        setState(() {
          _nameController.text = userData['name'];
          _phoneController.text = userData['phone'];
          _emailController.text = userData['email'];
          _campusController.text = _getCampusIdFromName(userData['campus']);
        });
      } else {
        _showSnackBar('Failed to load user data', ContentType.failure);
      }
    } else {
      _showSnackBar('Failed to load user data', ContentType.failure);
    }
  }

  String _getCampusIdFromName(String campusName) {
    switch (campusName) {
      case 'Campus A':
        return 'CAMP001';
      case 'Campus B':
        return 'CAMP002';
      case 'Campus C':
        return 'CAMP003';
      default:
        return '';
    }
  }

  void showCustomSnackBar(BuildContext context, String message) {
    _showSnackBar(message, ContentType.success);
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    var url =
        'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/user?userId=${widget.userId}';
    var data = {
      "oldPassword": _oldPasswordController.text,
      "newPassword": _newPasswordController.text,
      "confirmPassword": _confirmPasswordController.text,
      "email": _emailController.text,
      "name": _nameController.text,
      "phone": _phoneController.text,
      // "campusId": _campusController.text,
    };

    var headers = {
      'accept': 'text/plain',
      'Content-Type': 'application/json',
    };

    var response = await http.put(Uri.parse(url),
        headers: headers, body: jsonEncode(data));

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      if (responseBody['isSuccess'] && responseBody['data'] ['code'] == 200) {
        _showSnackBar('Update Profile is successful', ContentType.warning);

        // Call the callback function to refresh the user profile
        widget.onUpdate();

        // Optionally, you can also show a dialog
        // _showLogoutDialog(); // Or just remove this if you want to avoid logging out
        setState(() {
          _isEditing = false;
        });
      } else {
        _showSnackBar('Failed to update profile: ${responseBody['message']}',
            ContentType.failure);
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profile Updated'),
          content: Text('Please click ok to apply changes.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                // Navigate to login page
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, ContentType contentType) {
  final overlay = Overlay.of(context);

  final snackBarContent = AwesomeSnackbarContent(
    title: contentType == ContentType.success ? 'NomNom!' : 'NomNom!',
    message: message,
    contentType: contentType,
  );

  // Create an overlay entry to display the SnackBar at the top
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 10, // Top of screen + some padding
      left: 10,
      right: 10,
      child: Material(
        color: Colors.transparent,
        child: snackBarContent,
      ),
    ),
  );

  // Insert the overlay entry into the current overlay
  overlay.insert(overlayEntry);

  // Automatically remove the overlay after 3 seconds
  Future.delayed(Duration(seconds: 3)).then((_) {
    overlayEntry.remove();
  });
}


  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _campusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Edit your Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.orange,
                        child: Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text
                                  .substring(0, 1)
                                  .toUpperCase()
                              : '',
                          style: TextStyle(
                            fontSize: 40.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Text(
                        'Edit your Profile',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      _buildTextFormField(_nameController, 'Name'),
                      SizedBox(height: 20),
                      _buildTextFormField(_phoneController, 'Phone'),
                      SizedBox(height: 20),
                      _buildTextFormField(_emailController, 'Email'),
                      // SizedBox(height: 20),
                      // _buildReadOnlyTextFormField(_campusController, 'Campus'),
                      SizedBox(height: 20),
                      _buildPasswordField(_oldPasswordController,
                          'Old Password', 'oldPassword'),
                      SizedBox(height: 20),
                      _buildPasswordField(_newPasswordController,
                          'New Password', 'newPassword'),
                      SizedBox(height: 20),
                      _buildPasswordField(_confirmPasswordController,
                          'Confirm New Password', 'confirmPassword'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isEditing ? _updateUser : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(_isEditing ? 'Cancel' : 'Edit'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      readOnly: !_isEditing,
      enabled: _isEditing,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      style: TextStyle(fontSize: 16),
      onChanged: (value) {
        _formKey.currentState!.validate();
      },
      validator: (value) {
        if (labelText == 'Name') {
          if (value!.trim().isEmpty) {
            return 'Name cannot be empty';
          }
          if (value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
            return 'Name cannot contain special characters or spaces';
          }
        } else if (labelText == 'Phone') {
          if (value!.trim().isEmpty) {
            return 'Phone cannot be empty';
          }
          if (!RegExp(r'^0[0-9]{9,10}$').hasMatch(value)) {
            return 'Invalid phone number format';
          }
        } else if (labelText == 'Email') {
          if (value!.trim().isEmpty) {
            return 'Email cannot be empty';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Invalid email format';
          }
        }
        return null;
      },
    );
  }

  Widget _buildReadOnlyTextFormField(
      TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: false,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      style: TextStyle(fontSize: 16),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller, String labelText, String key) {
    return TextFormField(
      controller: controller,
      readOnly: !_isEditing,
      enabled: _isEditing,
      obscureText: _obscureText[key]!,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: IconButton(
          icon: Icon(
              _obscureText[key]! ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _obscureText[key] = !_obscureText[key]!;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      style: TextStyle(fontSize: 16),
      onChanged: (value) {
        _formKey.currentState!.validate();
      },
      validator: (value) {
        if (labelText == 'Old Password' ||
            labelText == 'New Password' ||
            labelText == 'Confirm New Password') {
          if (value!.trim().isEmpty) {
            return 'Password cannot be empty';
          }
          if (value.length < 6 || value.length > 16) {
            return 'Password must be between 6 and 16 characters';
          }
          // Check if password contains both letters and numbers
          if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).*$').hasMatch(value)) {
            return 'Password must contain both letters and numbers';
          }
          if (labelText == 'Confirm New Password' &&
              _newPasswordController.text != _confirmPasswordController.text) {
            return 'New passwords do not match';
          }
        }
        return null;
      },
    );
  }
}
