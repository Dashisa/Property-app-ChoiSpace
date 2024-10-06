import 'dart:convert';
import 'package:ar_property_app/constants/env.dart';
import 'package:ar_property_app/constants/styles.dart';
import 'package:ar_property_app/models/session_provider.dart';
import 'package:ar_property_app/windows/modelview_window.dart';
import 'package:ar_property_app/windows/preview_window.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyDetailWindow extends StatefulWidget {
  final Map<String, dynamic> property;

  PropertyDetailWindow({required this.property});

  @override
  _PropertyDetailWindowState createState() => _PropertyDetailWindowState();
}

class _PropertyDetailWindowState extends State<PropertyDetailWindow> {
  double? predictedValue;

  @override
  void initState() {
    super.initState();
    _getPropertyPrediction();
  }

  Future<void> _getPropertyPrediction() async {
    final url = Uri.parse(ENVConfig.serverUrl+'/propertyPrediction');
    print(jsonEncode({
      'area': widget.property['area'],
      ...widget.property['features'],
    }));
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'area': widget.property['area'],
        ...widget.property['features'],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        predictedValue = data['prediction'][0];
      });
    } else {
      // Handle error
      print('Failed to get prediction: ${response.body}');
    }
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
              'Property Details',
              style: TextStyle(color: Colors.white), // Make screen name white
            ),
            Text(
              'Details of This Property', // Add your subtitle text here
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(widget.property['image'], height: 200, fit: BoxFit.cover),
            SizedBox(height: 10),
            Text(
              widget.property['name'],
              style: Styles.subTitleFont,
            ),
            SizedBox(height: 1),
            Text(
              '${widget.property['address']}',
              style: Styles.titleSecondaryFont,
            ),
            SizedBox(height: 10),
            Text(
              'Property Type: ${widget.property['type']}',
              style: TextStyle(fontSize: 14, color: Styles.fontColorLight),
            ),
            SizedBox(height: 5),
            Text(
              'Owner: ${widget.property['owner']}',
              style: TextStyle(fontSize: 14, color: Styles.fontColorLight),
            ),
            SizedBox(height: 5),
            Text(
              'City: ${widget.property['city']}',
              style: TextStyle(fontSize: 14, color: Styles.fontColorLight),
            ),
            SizedBox(height: 5),
            Text(
              'Area: ${widget.property['area']} sqm',
              style: TextStyle(fontSize: 14, color: Styles.fontColorLight),
            ),
            SizedBox(height: 10),
            Text(
              widget.property['isSold'] ? 'Status: Sold' : 'Status: Available',
              style: TextStyle(
                fontSize: 12,
                color: widget.property['isSold'] ? Colors.red : Colors.green,
              ),
            ),
            // if (predictedValue != null) ...[
            //   SizedBox(height: 20),
            //   Text(
            //     'Estimated: Rs.${predictedValue!.toStringAsFixed(2)}',
            //     style: TextStyle(fontSize: 24, color: Styles.primaryColor, fontWeight: FontWeight.bold),
            //   ),
            // ],
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ModelViewerScreen(modelPath: widget.property['model'] ?? 'assets/3d/tower_house_design.glb')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('SEE PREVIEW'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
