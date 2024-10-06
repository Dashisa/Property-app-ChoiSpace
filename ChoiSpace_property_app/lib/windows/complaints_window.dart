import 'dart:convert';
import 'package:ar_property_app/constants/env.dart';
import 'package:ar_property_app/constants/styles.dart';
import 'package:ar_property_app/models/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComplaintsWindow extends StatefulWidget {
  final String title;
  final String instruction;
  final XFile? selectedFile;

  const ComplaintsWindow({
    Key? key,
    required this.title,
    required this.instruction,
    required this.selectedFile,
  }) : super(key: key);

  @override
  State<ComplaintsWindow> createState() => _ComplaintsWindowState();
}

class _ComplaintsWindowState extends State<ComplaintsWindow> {
  final TextEditingController _detailsController = TextEditingController();
  String _selectedArea = 'Ampara'; // Default area
  bool _isLoading = false;

  Future<void> _submitComplaint() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${ENVConfig.serverUrl}/complaints');
    final complaint = {
      "title": widget.title,
      "details": _detailsController.text,
      "instruction": widget.instruction,
      "area": _selectedArea,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(complaint),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint submitted successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit complaint')),
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
              'Provide details and area of the issue', // Add your subtitle text here
              style: TextStyle(color: Colors.white70, fontSize: 12), // Adjust font size and color as needed
            ),
          ],
        ),
        backgroundColor: Styles.secondaryAccent, // Make background transparent
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
              color: Styles.primaryAccent,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 2.0),
                    Text(
                      'Title: ${widget.title}',
                      style: Styles.titleFont,
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Instruction: ${widget.instruction}',
                      style: Styles.subTitleFont,
                    ),
                    SizedBox(height: 10.0),
                    TextField(
                      controller: _detailsController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Provide more Details',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    DropdownButtonFormField<String>(
                      value: _selectedArea,

                      onChanged: (value) {
                        setState(() {
                          _selectedArea = value!;
                        });
                      },
                      items: [
                        'Ampara', 'Anuradhapura', 'Badulla', 'Batticaloa', 'Colombo', 'Galle',
                        'Gampaha', 'Hambantota', 'Jaffna', 'Kalutara', 'Kandy', 'Kegalle',
                        'Kilinochchi', 'Kurunegala', 'Mannar', 'Matale', 'Matara', 'Monaragala',
                        'Mullaitivu', 'Nuwara Eliya', 'Polonnaruwa', 'Puttalam', 'Ratnapura',
                        'Trincomalee', 'Vavuniya'
                      ].map((area) {
                        return DropdownMenuItem<String>(
                          value: area,
                          child: Text(area),
                        );
                      }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Select District',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      dropdownColor: Styles.primaryColor,
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 10.0),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: _submitComplaint,
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
