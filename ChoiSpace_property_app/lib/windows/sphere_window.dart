import 'package:ar_property_app/constants/styles.dart';
import 'package:ar_property_app/models/session_provider.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart' as vector;


class ARPreviewCoreView extends StatefulWidget {
  @override
  _ARPreviewCoreViewState createState() => _ARPreviewCoreViewState();
}

class _ARPreviewCoreViewState extends State<ARPreviewCoreView> {
  ArCoreController? arCoreController;

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enableTapRecognizer: true,
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    // arCoreController?.onPlaneTap = _handleOnPlaneTap;
    _addProperty(controller);
  }

  void _addProperty(ArCoreController controller) {
    final material = ArCoreMaterial(color: Colors.blue);
    final sphere = ArCoreSphere(materials: [material], radius: 0.2);
    final node = ArCoreNode(
      shape: sphere,
      position: vector.Vector3(
        0,0,-1
      ),
    );

    arCoreController?.addArCoreNode(node);
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    // final hit = hits.first;
    // final material = ArCoreMaterial(color: Colors.blue);
    // final cube = ArCoreCube(materials: [material], size: Vector3(0.1, 0.1, 0.1));
    // final node = ArCoreNode(
    //   shape: cube,
    //   position: hit.pose.translation,
    //   rotation: hit.pose.rotation,
    // );
    // arCoreController?.addArCoreNodeWithAnchor(node);
  }
}
