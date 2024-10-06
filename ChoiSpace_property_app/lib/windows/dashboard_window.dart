import 'dart:async';
import 'package:ar_property_app/constants/env.dart';
import 'package:ar_property_app/constants/styles.dart';
import 'package:ar_property_app/models/session_provider.dart';
import 'package:ar_property_app/windows/modelview_window.dart';
import 'package:ar_property_app/windows/preview_window.dart';
import 'package:ar_property_app/windows/profile_window.dart';
import 'package:ar_property_app/windows/propert_listing_window.dart';
import 'package:ar_property_app/windows/property_owner_listing.dart';
import 'package:ar_property_app/windows/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardWindow extends StatefulWidget {
  const DashboardWindow({super.key});

  @override
  State<DashboardWindow> createState() => _DashboardWindowState();
}

class _DashboardWindowState extends State<DashboardWindow> {
  List<Map<String, dynamic>> collectionData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCollectionData();
  }

  Future<void> _fetchCollectionData() async {
    final apiUrl = '${ENVConfig.serverUrl}/properties';

    try {
      // final response = await http.get(Uri.parse(apiUrl));
      // if (response.statusCode == 200) {
      //   setState(() {
      //     collectionData = List<Map<String, dynamic>>.from(json.decode(response.body));
      //     isLoading = false;
      //   });
      // } else {
      //   print('Failed to fetch collection data');
      //   setState(() {
      //     isLoading = false;
      //   });
      // }
    } catch (e) {
      print('Error fetching collection data: $e');
      // setState(() {
      //   isLoading = false;
      // });
    }
  }

  Future<void> _logout() async {
    Provider.of<SessionProvider>(context, listen: false).clearSession();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('accessTokenExpireDate');
    await prefs.remove('refreshTokenExpireDate');
    await prefs.remove('userRole');
    await prefs.remove('authEmployeeID');
    Navigator.pushReplacementNamed(context, '/landing');
  }

  // Function to generate a rectangular status card for each achievement
  Widget _buildAchievementCard(Map<String, dynamic> data) {
    return Container(
      width: MediaQuery.of(context).size.width - 20,
      margin: EdgeInsets.symmetric(vertical: 5.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Styles.primaryAccent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 4, // Blur radius
            offset: Offset(0, 4), // Shadow offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${data['title']} (${data['area']})",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            data['instruction'].length > 150
                ? "${data['instruction'].substring(0, 150)}..."
                : data['instruction'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            data['createdDate'],
            style: TextStyle(
              fontSize: 12,
              color: Styles.fontSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Function to generate grid items
  Widget _buildGridItem(String iconPath, String title, String description, Widget targetScreen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Styles.secondaryAccent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color
              spreadRadius: 2, // Spread radius
              blurRadius: 4, // Blur radius
              offset: Offset(0, 4), // Shadow offset
            ),
          ],
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 60, height: 60), // Adjust the size as needed
            SizedBox(height: 10),
            Text(
              title,
              style: Styles.subTitleFont,
            ),
            SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color: Styles.fontSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<SessionProvider>(context).username;
    final userole = Provider.of<SessionProvider>(context).userRole;
    return Scaffold(
      backgroundColor: Styles.secondaryColor,
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 1,),
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Styles.primaryColor.withOpacity(0.15), // Adjust opacity as needed
                            spreadRadius: 8,
                            blurRadius: 12,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          height: 100, // Adjust height to fit content
                          decoration: BoxDecoration(
                            color: Styles.primaryAccent, // Replace with your desired background color
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0), // Adjust padding as needed
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "WELCOME",
                                style: Styles.subTitleDarkFont,
                              ),
                              SizedBox(height: 5),
                              Text(
                                username ?? 'No User',
                                style: Styles.titleFont,
                              ),
                            ],
                          ),
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Styles.secondaryAccent, // Border color
                                width: 5.0, // Border width
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 30, // Adjust the size as needed
                              backgroundImage: AssetImage(
                                  'assets/images/profile.png'), // Replace with your profile image path
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("MAIN MENU", style: Styles.subTitleFont,),

                  ],
                ),
                SizedBox(height: 10,),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildGridItem('assets/images/house.png', 'Property Listing', 'List of Properties Available', PropertyListingWindow()),
                    _buildGridItem('assets/images/fave.png', 'My Profile', 'Personal Details of User', ProfileWindow()),
                    if(userole=="Seller") _buildGridItem('assets/images/sold.png', 'Success Stories', 'Previous Property sales', PropertyOwnerListingWindow(owner: username)),
                    _buildGridItem('assets/images/setting.png', 'Settings', 'App Settings', SettingsScreen()),
                  ],
                ),
                SizedBox(height: 10,),

              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _logout,
        backgroundColor: Styles.secondaryAccent,
        child: Icon(Icons.logout, color: Colors.white),
      ),
    );
  }
}
