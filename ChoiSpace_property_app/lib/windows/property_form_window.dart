import 'dart:convert';
import 'package:ar_property_app/constants/env.dart';
import 'package:ar_property_app/constants/styles.dart';
import 'package:ar_property_app/models/session_provider.dart';
import 'package:ar_property_app/windows/propert_listing_window.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PropertyFormWindow extends StatefulWidget {
  @override
  _PropertyFormWindowState createState() => _PropertyFormWindowState();
}

class _PropertyFormWindowState extends State<PropertyFormWindow> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _guestroomController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _storiesController = TextEditingController();
  final TextEditingController _prefareaController = TextEditingController();

  File? _image;
  File? _modelFile;
  bool _isSold = false;
  bool _isLoading = false;
  String? _imageUrl;
  String? _modelPreviewUrl;
  String? _predictedPrice; // For displaying the predicted price

  // Switch states for included options
  bool _hasBasement = false;
  bool _hasMainRoadAccess = false;
  bool _hasHotWaterHeating = false;
  bool _hasAirConditioning = false;
  bool _hasParking = false;

  Future<String?> _uploadToCloudinary(File file) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/dkox7lwxe/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = 'gtnnidje'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final cloudinaryData = json.decode(responseData);
      return cloudinaryData['secure_url'];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload to Cloudinary')));
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      _imageUrl = await _uploadToCloudinary(_image!);
      setState(() {});
    }
  }

  Future<void> _pickModel() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _modelFile = File(pickedFile.path);
      _modelPreviewUrl = await _uploadToCloudinary(_modelFile!);
      setState(() {});
    }
  }

  Future<void> _submitProperty() async {
    if (_imageUrl == null ||  _nameController.text.isEmpty || _typeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all required fields and upload image & model')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(ENVConfig.serverUrl + '/properties');
    final propertyData = {
      'name': _nameController.text,
      'property_type': _typeController.text,
      'address': _addressController.text,
      'owner': _ownerController.text,
      'city': _cityController.text,
      'area': int.parse(_areaController.text),
      'image_url': _imageUrl,
      'model_url': _modelPreviewUrl,
      'isSold': _isSold,
      'bedrooms': _bedroomsController.text.isNotEmpty ? int.parse(_bedroomsController.text) : 0,
      'bathrooms': _bathroomsController.text.isNotEmpty ? int.parse(_bathroomsController.text) : 0,
      'stories': _storiesController.text.isNotEmpty ? int.parse(_storiesController.text) : 0,
      'mainroad': _hasMainRoadAccess ? 1 : 0,
      'guestroom': _guestroomController.text.isNotEmpty ? int.parse(_guestroomController.text) : 0,
      'basement': _hasBasement ? 1 : 0,
      'hotwaterheating': _hasHotWaterHeating ? 1 : 0,
      'airconditioning': _hasAirConditioning ? 1 : 0,
      'parking': _hasParking ? 1 : 0,
      'prefarea': _prefareaController.text.isNotEmpty ? int.parse(_prefareaController.text) : 0,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(propertyData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Property submitted successfully!')));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PropertyListingWindow()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit property')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _predictPrice() async {
    if (_areaController.text.isEmpty || _bedroomsController.text.isEmpty || _bathroomsController.text.isEmpty || _storiesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all required fields for prediction')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(ENVConfig.serverUrl + '/propertyPrediction');
    final predictionData = {
      'area': int.parse(_areaController.text),
      'bedrooms': _bedroomsController.text.isNotEmpty ? int.parse(_bedroomsController.text) : 0,
      'bathrooms': _bathroomsController.text.isNotEmpty ? int.parse(_bathroomsController.text) : 0,
      'stories': _storiesController.text.isNotEmpty ? int.parse(_storiesController.text) : 0,
      'mainroad': _hasMainRoadAccess ? 1 : 0,
      'guestroom': _guestroomController.text.isNotEmpty ? int.parse(_guestroomController.text) : 0,
      'basement': _hasBasement ? 1 : 0,
      'hotwaterheating': _hasHotWaterHeating ? 1 : 0,
      'airconditioning': _hasAirConditioning ? 1 : 0,
      'parking': _hasParking ? 1 : 0,
      'prefarea': _prefareaController.text.isNotEmpty ? int.parse(_prefareaController.text) : 0,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(predictionData),
      );

      if (response.statusCode == 200) {
        print(response.body);
        final responseData = jsonDecode(response.body);
        setState(() {
          _predictedPrice = responseData['prediction'][0].toString();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to predict price')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Styles.primaryColor),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.primaryColor),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.primaryColor),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.primaryColor),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
    );
  }

  TextStyle _buildInputTextStyle() {
    return TextStyle(
      color: Colors.green.withOpacity(0.7), // Green text with less opacity
    );
  }

  Widget _buildForm() {
    final username = Provider.of<SessionProvider>(context).username;
    _ownerController.text = username!;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView(
        children: [
          Card(
            color: Styles.primaryColor,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Please fill out the form below to submit your property details. You can also predict the price of your property using the "Predict Price" button at the bottom.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 12,),
          Text(
            'Basic Details',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Styles.primaryColor),
          ),
          SizedBox(height: 10.0),
          TextFormField(
            controller: _nameController,
            decoration: _buildInputDecoration('Name'),
            style: _buildInputTextStyle(),
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _typeController.text.isNotEmpty ? _typeController.text : null, // Initial value
            decoration: _buildInputDecoration('Property Type'),
            items: ['Flat', 'House', 'Villa', 'Studio', 'Duplex'] // Add more property types here
                .map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type, style: TextStyle(color: Colors.black87),),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _typeController.text = newValue ?? ''; // Update the controller with the selected value
              });
            },
            style: _buildInputTextStyle(), // Apply the green text style
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            decoration: _buildInputDecoration('Address'),
            style: _buildInputTextStyle(),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _ownerController,
            decoration: _buildInputDecoration('Owner'),
            style: _buildInputTextStyle(),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _cityController,
            decoration: _buildInputDecoration('City'),
            style: _buildInputTextStyle(),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _areaController,
            decoration: _buildInputDecoration('Area (sq ft)'),
            style: _buildInputTextStyle(),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12),
          Text(
            'Features',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Styles.primaryColor),
          ),
          SizedBox(height: 10.0),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _bedroomsController,
                      decoration: _buildInputDecoration('Bedrooms'),
                      keyboardType: TextInputType.number,
                      style: _buildInputTextStyle(), // Apply the green text style
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Expanded(
                    child: TextField(
                      controller: _bathroomsController,
                      decoration: _buildInputDecoration('Bathrooms'),
                      keyboardType: TextInputType.number,
                      style: _buildInputTextStyle(), // Apply the green text style
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _storiesController,
                      decoration: _buildInputDecoration('Stories'),
                      keyboardType: TextInputType.number,
                      style: _buildInputTextStyle(), // Apply the green text style
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Expanded(
                    child: TextField(
                      controller: _guestroomController,
                      decoration: _buildInputDecoration('Guestroom'),
                      keyboardType: TextInputType.number,
                      style: _buildInputTextStyle(), // Apply the green text style
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _prefareaController,
                      decoration: _buildInputDecoration('Preferred Area'),
                      keyboardType: TextInputType.number,
                      style: _buildInputTextStyle(), // Apply the green text style
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          SwitchListTile(
            title: Text('Basement', style: TextStyle(fontSize: 18, color: Styles.primaryColor),),
            value: _hasBasement,
            onChanged: (value) => setState(() => _hasBasement = value),
          ),
          SwitchListTile(
            title: Text('Main Road Access', style: TextStyle(fontSize: 18, color: Styles.primaryColor),),
            value: _hasMainRoadAccess,
            onChanged: (value) => setState(() => _hasMainRoadAccess = value),
          ),
          SwitchListTile(
            title: Text('Hot Water Heating', style: TextStyle(fontSize: 18, color: Styles.primaryColor),),
            value: _hasHotWaterHeating,
            onChanged: (value) => setState(() => _hasHotWaterHeating = value),
          ),
          SwitchListTile(
            title: Text('Air Conditioning', style: TextStyle(fontSize: 18, color: Styles.primaryColor),),
            value: _hasAirConditioning,
            onChanged: (value) => setState(() => _hasAirConditioning = value),
          ),
          SwitchListTile(
            title: Text('Parking', style: TextStyle(fontSize: 18, color: Styles.primaryColor),),
            value: _hasParking,
            onChanged: (value) => setState(() => _hasParking = value),
          ),
          SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200.0,
              decoration: BoxDecoration(color: Styles.primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12.0),),
              child: _image != null
                  ? Image.file(_image!, fit: BoxFit.cover)
                  : Center(child: Text('Upload Image', style: TextStyle(color: Styles.primaryColor),)),
            ),
          ),
          SizedBox(height: 10.0),
          GestureDetector(
            onTap: _pickModel,
            child: Container(
              height: 200.0,
              decoration: BoxDecoration(color: Styles.primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12.0),),
              child: _modelFile != null
                  ? Center(child: Text('3D Model Uploaded', style: TextStyle(color: Styles.primaryColor),))
                  : Center(child: Text('Upload 3D Model', style: TextStyle(color: Styles.primaryColor),)),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Properties Form',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Provide details of the Property',
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
      backgroundColor: Styles.secondaryColor,
      body: Stack(
        children: [
          _buildForm(),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _predictPrice,
                  child: _isLoading ? CircularProgressIndicator() : Text('Predict Price'),
                ),
                if (_predictedPrice != null)
                  Text(
                    'Predicted Price: Rs.$_predictedPrice',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Styles.primaryColor),
                  ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitProperty,
                  child: _isLoading ? CircularProgressIndicator() : Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
