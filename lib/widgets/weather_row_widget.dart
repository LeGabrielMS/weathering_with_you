import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WeatherRow extends StatelessWidget {
  final String title;
  final String assetPath;
  final String value;

  const WeatherRow({
    super.key,
    required this.title,
    required this.assetPath,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Lottie.asset(assetPath, width: 50),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }
}
