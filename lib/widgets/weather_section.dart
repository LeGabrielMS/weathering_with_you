import 'package:flutter/material.dart';
import 'weather_row.dart';

class WeatherSection extends StatelessWidget {
  final List<WeatherRow> rows;

  const WeatherSection({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: row,
              ),
            )
            .toList(),
      ),
    );
  }
}
