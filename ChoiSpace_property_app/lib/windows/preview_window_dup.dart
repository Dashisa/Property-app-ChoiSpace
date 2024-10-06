import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        title: Text('ARCore View'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enableTapRecognizer: true,
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    _addProperty(controller);
  }

  void _addProperty(ArCoreController controller) async {
    final ByteData modelData = await rootBundle.load('assets/3d/house01/scene.bin');

    final material = ArCoreMaterial(color: Colors.blue);
    final node = ArCoreReferenceNode(
      name: "gltfModel",
      object3DFileName: "assets/models/your_model.gltf",
      position: vector.Vector3(0, 0, -1),
      scale: vector.Vector3(0.1, 0.1, 0.1),
    );

    arCoreController?.addArCoreNodeWithAnchor(node);
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    final hit = hits.first;
    final material = ArCoreMaterial(color: Colors.blue);
    final cube = ArCoreCube(materials: [material], size: vector.Vector3(0.1, 0.1, 0.1));
    final node = ArCoreNode(
      shape: cube,
      position: hit.pose.translation,
      rotation: hit.pose.rotation,
    );
    arCoreController?.addArCoreNodeWithAnchor(node);
  }
}
