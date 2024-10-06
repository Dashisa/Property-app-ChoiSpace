import 'package:ar_property_app/constants/styles.dart';
import 'package:ar_property_app/widgerts/glowing_icon.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomBar({Key? key, required this.selectedIndex, required this.onItemTapped}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.selectedIndex,
      onTap: widget.onItemTapped,
      showSelectedLabels: false,
      selectedItemColor: Styles.fontSecondaryColor,
      unselectedItemColor: Styles.fontDarkColorLight,
      type: BottomNavigationBarType.shifting,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: GlowingIcon(
            icon: Icons.dashboard,
            isSelected: widget.selectedIndex == 0,
            color: widget.selectedIndex == 0 ? Styles.primaryColor : Styles.fontDarkColorLight,
          ),
          label: 'Dashboard',
          backgroundColor: Styles.secondaryAccent,
        ),
        BottomNavigationBarItem(
          icon: GlowingIcon(
            icon: Icons.map,
            isSelected: widget.selectedIndex == 1,
            color: widget.selectedIndex == 1 ? Styles.primaryColor : Styles.fontDarkColorLight,
          ),
          label: 'Detector',
          backgroundColor: Styles.secondaryAccent,
        ),
        BottomNavigationBarItem(
          icon: GlowingIcon(
            icon: Icons.account_circle,
            isSelected: widget.selectedIndex == 2,
            color: widget.selectedIndex == 2 ? Styles.primaryColor : Styles.fontDarkColorLight,
          ),
          label: 'Profile',
          backgroundColor: Styles.secondaryAccent,
        ),
      ],
    );
  }
}
