import 'dart:convert';
import 'package:ar_property_app/constants/env.dart';
import 'package:ar_property_app/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignUpWindow extends StatefulWidget {
  @override
  _SignUpWindowState createState() => _SignUpWindowState();
}

class _SignUpWindowState extends State<SignUpWindow> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = 'Buyer'; // Default role selection
  bool _isLoading = false;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${ENVConfig.serverUrl}/signup');
    final signupData = {
      "username": _usernameController.text,
      "full_name": _fullNameController.text,
      "email": _emailController.text,
      "contact_number": _contactNumberController.text,
      "password": _passwordController.text,
      "role": _selectedRole,
    };

    try {
      print(signupData);
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(signupData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup successful!')),
        );
        Navigator.pushReplacementNamed(context, '/sign-in');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign up')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Styles.primaryColor), // Change label color
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.primaryColor), // Change enabled border color
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.primaryColor), // Change focused border color
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.primaryColor), // Change default border color
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.secondaryColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign Up',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Create an account',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Styles.secondaryAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 50,),
              TextField(
                controller: _usernameController,
                decoration: _buildInputDecoration('Username'),
                style: TextStyle(color: Colors.green.withOpacity(0.7)), // Typed text color
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _fullNameController,
                decoration: _buildInputDecoration('Full Name'),
                style: TextStyle(color: Colors.green.withOpacity(0.7)), // Typed text color
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _emailController,
                decoration: _buildInputDecoration('Email'),
                style: TextStyle(color: Colors.green.withOpacity(0.7)), // Typed text color
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _contactNumberController,
                decoration: _buildInputDecoration('Contact Number'),
                style: TextStyle(color: Colors.green.withOpacity(0.7)), // Typed text color
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: _buildInputDecoration('Password'),
                style: TextStyle(color: Colors.green.withOpacity(0.7)), // Typed text color
              ),
              SizedBox(height: 20.0),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: ['Buyer', 'Seller'].map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                style: TextStyle(color: Colors.green.withOpacity(0.7)),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
                decoration: _buildInputDecoration('Select Role'),
              ),
              SizedBox(height: 20.0),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.dangerColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('SIGN UP'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/sign-in');
                },
                child: Text(
                  'Switch to Sign In',
                  style: TextStyle(color: Styles.fontSecondaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
