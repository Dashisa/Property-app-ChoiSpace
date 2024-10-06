import 'dart:convert';
import 'package:ar_property_app/constants/env.dart';
import 'package:ar_property_app/constants/styles.dart';
import 'package:ar_property_app/models/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInWindow extends StatefulWidget {
  @override
  _SignInWindowState createState() => _SignInWindowState();
}

class _SignInWindowState extends State<SignInWindow> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${ENVConfig.serverUrl}/signin');
    final signInData = {
      "username": _usernameController.text,
      "password": _passwordController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(signInData),
      );

      if (response.statusCode == 200) {
        // Parse response data
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Store tokens in SharedPreferences
        final user = data['user'];

        await prefs.setString('authEmployeeID', user['username']);
        await prefs.setString('userRole', user['role']);
        await prefs.setString('accessToken', data['access_token']);
        await prefs.setString('refreshToken', data['refresh_token']);



        // Update session provider
        Provider.of<SessionProvider>(context, listen: false).updateSession(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          userRole: user['role'],
          authEmployeeID: user['_id'],
          contactNumber: user['contact_number'],
          createdAt: DateTime.now(),
          email: user['email'],
          fullName: user['full_name'],
          userId: user['_id'],
          username: user['username'],
          complications: []
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in successful!')),
        );

        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('Failed to sign in: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in')),
        );
      }
    } catch (error, stackTrace) {
      print('Error: $error');
      print('StackTrace: $stackTrace');
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
              'Sign In',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Access your account',
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
              SizedBox(height: 150,),
              CircleAvatar(
                radius: 40.0,
                backgroundColor: Styles.secondaryAccent,
                child: Icon(Icons.person, size: 40.0, color: Colors.white),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _usernameController,
                decoration: _buildInputDecoration('Username'),
                style: TextStyle(color: Colors.green.withOpacity(0.7)),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: _buildInputDecoration('Password'),
                style: TextStyle(color: Colors.green.withOpacity(0.7)),
              ),
              SizedBox(height: 20.0),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.dangerColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('SIGN IN'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/sign-up');
                },
                child: Text(
                  'Switch to Sign Up',
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
    _passwordController.dispose();
    super.dispose();
  }
}
