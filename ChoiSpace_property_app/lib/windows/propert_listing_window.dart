import 'dart:convert';
import 'package:ar_property_app/constants/env.dart';
import 'package:ar_property_app/constants/styles.dart';
import 'package:ar_property_app/models/session_provider.dart';
import 'package:ar_property_app/windows/dashboard_window.dart';
import 'package:ar_property_app/windows/property_details_window.dart';
import 'package:ar_property_app/windows/property_form_window.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyListingWindow extends StatefulWidget {
  const PropertyListingWindow({super.key});

  @override
  State<PropertyListingWindow> createState() => _PropertyListingWindowState();
}

class _PropertyListingWindowState extends State<PropertyListingWindow> {
  List<Map<String, dynamic>> properties = [
    {
      'name': 'Sunny Apartment',
      'type': 'Flat',
      'address': '123 Main St',
      'owner': 'John Doe',
      'city': 'City1',
      'area': 100,
      'image': 'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg',
      'model': 'assets/3d/tower_house_design.glb',
      'isSold': false,
      'features': {
        'bedrooms': 3,
        'bathrooms': 1,
        'stories': 1,
        'mainroad': 0,
        'guestroom': 0,
        'basement': 1,
        'hotwaterheating': 0,
        'airconditioning': 1,
        'parking': 2,
        'prefarea': 1,
      }
    },
    {
      'name': 'Cozy Cottage',
      'type': 'Old',
      'address': '456 Elm St',
      'owner': 'Jane Smith',
      'city': 'City2',
      'area': 150,
      'image': 'https://img.onmanorama.com/content/dam/mm/en/lifestyle/decor/images/2023/6/1/house-middleclass.jpg',
      'model': 'assets/3d/dower.glb',
      'isSold': true,
      'features': {
        'bedrooms': 5,
        'bathrooms': 2,
        'stories': 2,
        'mainroad': 1,
        'guestroom': 0,
        'basement': 1,
        'hotwaterheating': 0,
        'airconditioning': 1,
        'parking': 3,
        'prefarea': 1,
      }
    },
    {
      'name': 'Modern House',
      'type': 'New',
      'address': '789 Oak St',
      'owner': 'Alice Johnson',
      'city': 'City3',
      'area': 200,
      'image': 'https://via.placeholder.com/100',
      'model': 'assets/3d/medieval_house.glb',
      'isSold': false,
      'features': {
        'bedrooms': 3,
        'bathrooms': 2,
        'stories': 2,
        'mainroad': 1,
        'guestroom': 0,
        'basement': 1,
        'hotwaterheating': 0,
        'airconditioning': 1,
        'parking': 2,
        'prefarea': 1,
      }
    },
    {
      'name': 'Luxury Villa',
      'type': 'New',
      'address': '101 Pine St',
      'owner': 'Bob Brown',
      'city': 'City1',
      'area': 300,
      'image': 'https://via.placeholder.com/100',
      'model': 'assets/3d/psx_old_house.glb',
      'isSold': true,
      'features': {
        'bedrooms': 3,
        'bathrooms': 2,
        'stories': 2,
        'mainroad': 1,
        'guestroom': 0,
        'basement': 1,
        'hotwaterheating': 0,
        'airconditioning': 1,
        'parking': 2,
        'prefarea': 1,
      }
    },
    {
      'name': 'Budget Studio',
      'type': 'Flat',
      'address': '202 Maple St',
      'owner': 'Charlie Green',
      'city': 'City2',
      'area': 50,
      'image': 'https://via.placeholder.com/100',
      'model': 'assets/3d/dower.glb',
      'isSold': false,
      'features': {
        'bedrooms': 3,
        'bathrooms': 2,
        'stories': 2,
        'mainroad': 1,
        'guestroom': 0,
        'basement': 1,
        'hotwaterheating': 0,
        'airconditioning': 1,
        'parking': 2,
        'prefarea': 1,
      }
    },
    {
      'name': 'Suburban Home',
      'type': 'Old',
      'address': '303 Birch St',
      'owner': 'David White',
      'city': 'City3',
      'area': 120,
      'image': 'https://via.placeholder.com/100',
      'model': 'assets/3d/dower.glb',
      'isSold': true,
      'features': {
        'bedrooms': 3,
        'bathrooms': 2,
        'stories': 2,
        'mainroad': 1,
        'guestroom': 0,
        'basement': 1,
        'hotwaterheating': 0,
        'airconditioning': 1,
        'parking': 2,
        'prefarea': 1,
      }
    },
    {
      'name': 'Penthouse Suite',
      'type': 'Flat',
      'address': '404 Cedar St',
      'owner': 'Eva Black',
      'city': 'City1',
      'area': 180,
      'image': 'https://via.placeholder.com/100',
      'model': 'assets/3d/dower.glb',
      'isSold': false,
      'features': {
        'bedrooms': 3,
        'bathrooms': 2,
        'stories': 2,
        'mainroad': 1,
        'guestroom': 0,
        'basement': 1,
        'hotwaterheating': 0,
        'airconditioning': 1,
        'parking': 2,
        'prefarea': 1,
      }
    },
  ];

  List<Map<String, dynamic>> filteredProperties = [];
  bool isLoading = false;

  String selectedPropertyType = 'All';
  String selectedCity = 'All';
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('${ENVConfig.serverUrl}/properties'));

      if (response.statusCode == 200) {
        final List<dynamic> apiProperties = json.decode(response.body);

        final List<Map<String, dynamic>> formattedApiProperties = apiProperties.map((property) {
          return {
            'name': property['name'],
            'type': property['property_type'],
            'address': property['address'],
            'owner': property['owner'],
            'city': property['city'],
            'area': property['area'],
            'image': property['image_url'] ?? 'https://via.placeholder.com/100',
            'model': property['model_url'] ?? 'assets/3d/tower_house_design.glb',
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

        setState(() {
          properties.addAll(formattedApiProperties);
          filteredProperties = properties;
        });
      } else {
        // Handle error response
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

  void _filterProperties() {
    setState(() {
      filteredProperties = properties.where((property) {
        final matchesType = selectedPropertyType == 'All' || property['type'] == selectedPropertyType;
        final matchesCity = selectedCity == 'All' || property['city'] == selectedCity;
        final matchesSearch = property['name'].toLowerCase().contains(searchText.toLowerCase());

        return matchesType && matchesCity && matchesSearch;
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
                  Text(
                    property['isSold'] ? 'Sold' : 'Available',
                    style: TextStyle(
                      fontSize: 12,
                      color: property['isSold'] ? Colors.red : Colors.green,
                    ),
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
    final role = Provider.of<SessionProvider>(context).userRole;
    return Scaffold(
      backgroundColor: Styles.secondaryColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Properties List',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Details of Properties',
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
                  child: DropdownButtonFormField<String>(
                    value: selectedPropertyType,
                    items: ['All', 'Old', 'Flat', 'New']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPropertyType = value!;
                        _filterProperties();
                      });
                    },
                    decoration: _buildInputDecoration('Property Type'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCity,
                    items: ['All', 'Colombo', 'Kalutara', 'Gampaha', 'Kandy', 'Galle', 'Nuwaraeliya']
                        .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCity = value!;
                        _filterProperties();
                      });
                    },
                    decoration: _buildInputDecoration('City'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                  _filterProperties();
                });
              },
              decoration: _buildInputDecoration('Search by Name'),
            ),
            SizedBox(height: 10),
            if(role=="Seller") ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PropertyFormWindow()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.secondaryAccent,
                foregroundColor: Colors.white,
              ),
              child: Text('Add New Property'),
            ),
            SizedBox(height: 10),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
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

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Styles.secondaryAccent,
      labelStyle: TextStyle(color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.secondaryAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.secondaryAccent),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
