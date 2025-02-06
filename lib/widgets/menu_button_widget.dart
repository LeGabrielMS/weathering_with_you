import 'package:flutter/material.dart';
import '../screens/about_screen.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'About') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutScreen()),
          );
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'About',
          child: Text("About"),
        ),
      ],
    );
  }
}
