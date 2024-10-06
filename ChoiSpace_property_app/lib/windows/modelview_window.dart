import 'package:ar_property_app/constants/styles.dart';
import 'package:ar_property_app/models/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelViewerScreen extends StatefulWidget {
  final String modelPath;

  ModelViewerScreen({required this.modelPath});

  @override
  _ModelViewerScreenState createState() => _ModelViewerScreenState();
}

class _ModelViewerScreenState extends State<ModelViewerScreen> {
  @override
  void dispose() {
    // Perform any necessary cleanup here if needed
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
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
              'Property 3D View',
              style: TextStyle(color: Colors.white), // Make screen name white
            ),
            Text(
              'Visual Details of This Property', // Add your subtitle text here
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
      body: Center(
        child: ModelViewer(
          src: widget.modelPath, // Path to your GLB model file
          autoRotate: true,
          ar: true,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
