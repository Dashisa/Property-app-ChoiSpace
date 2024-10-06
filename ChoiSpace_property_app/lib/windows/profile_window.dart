import 'package:ar_property_app/constants/env.dart';
import 'package:ar_property_app/constants/styles.dart';
import 'package:ar_property_app/models/session_provider.dart';
import 'package:ar_property_app/windows/dashboard_window.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileWindow extends StatefulWidget {
  const ProfileWindow({Key? key}) : super(key: key);

  @override
  _ProfileWindowState createState() => _ProfileWindowState();
}

class _ProfileWindowState extends State<ProfileWindow> {
  String? fullName;
  String? email;
  String? contactNumber;
  String? user;
  String? role;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final username = Provider.of<SessionProvider>(context, listen: false).username;
    final userrole = Provider.of<SessionProvider>(context, listen: false).userRole;
    if (username != null) {
      try {
        final response = await http.get(Uri.parse(ENVConfig.serverUrl+'/user/$username'));

        if (response.statusCode == 200) {
          final userData = json.decode(response.body);
          setState(() {
            fullName = userData['full_name'];
            email = userData['email'];
            contactNumber = userData['contact_number'];
            user = username;
            role = userrole;
          });
        } else {
          // Handle error
          print('Failed to load user profile');
        }
      } catch (e) {
        // Handle error
        print('Error loading user profile: $e');
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    // Clear session
    Provider.of<SessionProvider>(context, listen: false).clearSession();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all preferences
    Navigator.pushReplacementNamed(context, '/landing');
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
              'Profile',
              style: TextStyle(color: Colors.white), // Make screen name white
            ),
            Text(
              'Details of your Free Account', // Add your subtitle text here
              style: TextStyle(color: Colors.white70, fontSize: 12), // Adjust font size and color as needed
            ),
          ],
        ),
        backgroundColor: Styles.secondaryAccent, // Make background transparent
        iconTheme: IconThemeData(color: Colors.white), // Make icons white
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Logout icon
            onPressed: () => _logout(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DashboardWindow()),
          );
        },
        backgroundColor: Styles.secondaryAccent,
        child: Icon(Icons.house, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/profile.png'), // Use a placeholder image
                  ),
                  SizedBox(height: 20),
                  Text(
                    user ?? "Username", // Display user's full name
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "($role)" ?? "User Role", // Display user's full name
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Full Name: $fullName" ?? "Full Name", // Display user's full name
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Email: $email" ?? "Email: user@example.com", // Display user's email
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Contact Number: $contactNumber" ?? "Contact Number", // Display user's contact number
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
