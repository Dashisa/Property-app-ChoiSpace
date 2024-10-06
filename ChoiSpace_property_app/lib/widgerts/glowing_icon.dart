import 'package:flutter/material.dart';

class GlowingIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final Color color;
  final double size;

  const GlowingIcon({
    Key? key,
    required this.icon,
    required this.isSelected,
    required this.color,
    this.size = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isSelected
          ? BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            spreadRadius: 3,
            blurRadius: 10,
            offset: Offset(0, 0),
          ),
        ],
      )
          : null,
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}
