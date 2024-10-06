import 'dart:convert';
import 'package:ar_property_app/windows/dashboard_window.dart';
import 'package:flutter/material.dart';
import 'package:ar_property_app/constants/env.dart';
import 'package:ar_property_app/constants/styles.dart';
import 'package:ar_property_app/models/session_provider.dart';
import 'package:ar_property_app/windows/property_details_window.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyOwnerListingWindow extends StatefulWidget {
  final String? owner;
  const PropertyOwnerListingWindow({super.key, required this.owner});

  @override
  State<PropertyOwnerListingWindow> createState() => _PropertyOwnerListingWindowState();
}

class _PropertyOwnerListingWindowState extends State<PropertyOwnerListingWindow> {
  List<Map<String, dynamic>> properties = [];
  List<Map<String, dynamic>> filteredProperties = [];
  bool isLoading = false;

  bool showAvailableProperties = true; // For Sold/Available filter
  String searchText = ''; // For search functionality

  @override
  void initState() {
    super.initState();
    _loadPropertiesByOwner();
  }

  Future<void> _loadPropertiesByOwner() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('${ENVConfig.serverUrl}/properties/owner/${widget.owner}'));

      if (response.statusCode == 200) {
        final List<dynamic> apiProperties = json.decode(response.body);

        setState(() {
          properties = apiProperties.map((property) {
            return {
              'id': property['_id'], // Store the property ID for updates
              'name': property['name'],
              'type': property['property_type'],
              'address': property['address'],
              'owner': property['owner'],
              'city': property['city'],
              'area': property['area'],
              'image': property['image_url'] ?? 'https://via.placeholder.com/100',
              'isSold': property['is_sold'],
              'features': {
                'bedrooms': property['bedrooms'],
                'bathrooms': property['bathrooms'],
                'stories': property['stories'],
                'mainroad': property['mainroad'],
                'guestroom': property['guestroom'],
                'basement': property['basement'],
                'hotwaterheating': property['hotwaterheating'],
                'airconditioning': property['airconditioning'],
                'parking': property['parking'],
                'prefarea': property['prefarea'],
              }
            };
          }).toList();
          filteredProperties = properties;
        });
      } else {
        print('Failed to load properties');
      }
    } catch (e) {
      print('Error loading properties: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updatePropertySoldStatus(String propertyId, bool isSold) async {
    print(propertyId);
    try {
      final response = await http.put(
        Uri.parse('${ENVConfig.serverUrl}/properties/update_by_address/$propertyId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'is_sold': isSold}),
      );

      if (response.statusCode == 200) {
        print('Property updated successfully.');
      } else {
        print('Failed to update property status.');
      }
    } catch (e) {
      print('Error updating property status: $e');
    }
  }

  void _filterProperties() {
    setState(() {
      filteredProperties = properties.where((property) {
        final matchesAvailability = showAvailableProperties ? !property['isSold'] : property['isSold'];
        final matchesSearch = property['name'].toLowerCase().contains(searchText.toLowerCase());
        return matchesAvailability && matchesSearch;
      }).toList();
    });
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PropertyDetailWindow(property: property)),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Styles.primaryAccent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 100, // Set fixed width for the image container
              height: 100, // Set fixed height for the image container
              child: Image.network(
                property['image'],
                fit: BoxFit.cover, // Ensure the image fits within the container
                errorBuilder: (context, error, stackTrace) {
                  return Image.network('https://via.placeholder.com/100'); // Load placeholder if there's an error
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    property['type'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    property['address'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Styles.fontSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Owner: ${property['owner']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Styles.fontSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'City: ${property['city']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Styles.fontSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Area: ${property['area']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Styles.fontSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        property['isSold'] ? 'Sold' : 'Available',
                        style: TextStyle(
                          fontSize: 12,
                          color: property['isSold'] ? Colors.red : Colors.green,
                        ),
                      ),
                      Switch(
                        value: property['isSold'],
                        onChanged: (value) {
                          setState(() {
                            property['isSold'] = value;
                          });
                          _updatePropertySoldStatus(property['address'], value);
                        },
                        activeColor: Colors.red,
                        inactiveThumbColor: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
              'Owner\'s Properties List',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Details of Properties owned by ${widget.owner}',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Styles.secondaryAccent,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                        _filterProperties();
                      });
                    },
                    decoration: _buildInputDecoration('Search by Name'),
                  ),
                ),
                SizedBox(width: 10),
                Switch(
                  value: showAvailableProperties,
                  onChanged: (value) {
                    setState(() {
                      showAvailableProperties = value;
                      _filterProperties();
                    });
                  },
                  activeColor: Styles.secondaryAccent,
                  inactiveThumbColor: Colors.redAccent,
                  inactiveTrackColor: Colors.red.withOpacity(0.5),
                ),
                Text(
                  showAvailableProperties ? 'Available' : 'Sold',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Expanded(
              child: isLoading
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : filteredProperties.isEmpty
                  ? Center(
                child: Text('No properties found'),
              )
                  : ListView.builder(
                itemCount: filteredProperties.length,
                itemBuilder: (context, index) {
                  return _buildPropertyCard(filteredProperties[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Styles.primaryAccent,
      hintText: hintText,
      hintStyle: TextStyle(color: Styles.fontSecondaryColor),
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(Icons.search, color: Styles.fontSecondaryColor),
    );
  }
}
