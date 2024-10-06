import 'dart:convert';

import 'package:ar_property_app/constants/styles.dart';
import 'package:ar_property_app/models/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportsWindow extends StatefulWidget {
  final String? nutrition;
  final List<dynamic> pesticides;
  final XFile? selectedFile;

  const ReportsWindow({
    Key? key,
    required this.nutrition,
    required this.pesticides,
    required this.selectedFile,
  }) : super(key: key);

  @override
  State<ReportsWindow> createState() => _ReportsWindowState();
}

class _ReportsWindowState extends State<ReportsWindow> {
  final TextEditingController _detailsController = TextEditingController();
  String _selectedCategory = 'BUG'; // Default category



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.primaryColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paddy Issues Detector',
              style: TextStyle(color: Colors.white), // Make screen name white
            ),
            Text(
              'Provide Images or evidences to detect issues', // Add your subtitle text here
              style: TextStyle(color: Colors.white, fontSize: 12), // Adjust font size and color as needed
            ),
          ],
        ),
        backgroundColor: Colors.transparent, // Make background transparent
        iconTheme: IconThemeData(color: Colors.white), // Make icons white
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Logout icon
            onPressed: () async {
              // Clear session
              Provider.of<SessionProvider>(context, listen: false).clearSession();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('accessToken');
              await prefs.remove('refreshToken');
              await prefs.remove('accessTokenExpireDate');
              await prefs.remove('refreshTokenExpireDate');
              await prefs.remove('userRole');
              await prefs.remove('authEmployeeID');
              Navigator.pushReplacementNamed(context, '/landing');
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form section
            Card(
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 2.0),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      items: [
                        'BUG',
                        'OTHER'
                      ].map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: (){},
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }
}
