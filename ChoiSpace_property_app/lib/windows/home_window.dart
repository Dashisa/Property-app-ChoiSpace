import 'package:ar_property_app/widgerts/bottom_bar.dart';
import 'package:ar_property_app/windows/dashboard_window.dart';
import 'package:ar_property_app/windows/profile_window.dart';
import 'package:flutter/material.dart';

class HomeWindow extends StatefulWidget {
  const HomeWindow({super.key});

  @override
  State<HomeWindow> createState() => _HomeWindowState();
}

class _HomeWindowState extends State<HomeWindow> {

  late PageController _pageController;
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardWindow(),
    ProfileWindow(),
    ProfileWindow()
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Home'),
      // ),
      body: PageView(
        children: _screens,
        controller: _pageController,
        onPageChanged: _onItemTapped,
      ),
      bottomNavigationBar: BottomBar(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped,),
    );
  }
}
