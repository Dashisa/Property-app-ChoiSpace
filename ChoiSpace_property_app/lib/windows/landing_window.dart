import 'package:ar_property_app/constants/styles.dart';
import 'package:ar_property_app/models/session_provider.dart';
import 'package:ar_property_app/widgerts/social_link_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LandingWindow extends StatefulWidget {
  @override
  _LandingWindowState createState() => _LandingWindowState();
}

class _LandingWindowState extends State<LandingWindow> {
  @override
  Widget build(BuildContext context) {
    final username = Provider.of<SessionProvider>(context).username;
    return Scaffold(
      backgroundColor: Styles.primaryColor,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Transform.rotate(
              angle: 0, // Rotate by 90 degrees
              child: Image.asset(
                'assets/images/background.jpg', // Path to your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content
          Center(
            child: Consumer<SessionProvider>(
              builder: (context, sessionProvider, _) {
                return Column(
                  children: [
                    Spacer(), // Adds space before the logo and title to push them to center
                    // Logo
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Container(
                        width: 200, // Adjust the width as needed
                        height: 200, // Adjust the height as needed
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text("CHOISPACE",
                        style: TextStyle(
                            fontSize: 32,
                            color: Styles.fontColorLight,
                            fontWeight: FontWeight.bold)),
                    Center(
                      child: Text(
                        "Visualize your Dream Home.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Styles.fontColorLight.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center, // Center-aligns the text
                        softWrap: true, // Ensures text wraps to the next line
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     SocialLinkButton(icon: Icons.facebook),
                    //     SizedBox(width: 10.0),
                    //     SocialLinkButton(icon: Icons.rocket),
                    //     SizedBox(width: 10.0),
                    //     SocialLinkButton(icon: Icons.android),
                    //   ],
                    // ),
                    Spacer(), // Adds space after the logo and title to push them to center

                    // Container for buttons and social links
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Styles.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Conditionally show the ENTER or SIGN IN button
                          if ((username != null && username.isNotEmpty))
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/home');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Styles.primaryAccent,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('ENTER'),
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/sign-in');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Styles.secondaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('SIGN IN'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
