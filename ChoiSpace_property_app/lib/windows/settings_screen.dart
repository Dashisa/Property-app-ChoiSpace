import 'package:ar_property_app/constants/styles.dart';
import 'package:ar_property_app/models/session_provider.dart';
import 'package:ar_property_app/windows/dashboard_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  double _fontSize = 16.0;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
      _language = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setString('language', _language);
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('Dark Mode', style: TextStyle(color: Styles.primaryColor),),
              value: _darkMode,
              onChanged: (bool value) {
                setState(() {
                  _darkMode = value;
                  _saveSettings();
                });
              },
            ),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('File Size', style: TextStyle(color: Styles.primaryColor),),
              value: _darkMode,
              onChanged: (bool value) {
                setState(() {
                  _darkMode = value;
                  _saveSettings();
                });
              },
            ),
            SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}
