import 'package:flutter/material.dart';
import 'weather_row_widget.dart';

class WeatherSection extends StatelessWidget {
  final List<WeatherRow> rows;
  final int columnCount; // Number of columns (default is 2)

  const WeatherSection({
    super.key,
    required this.rows,
    this.columnCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling (parent handles it)
      shrinkWrap: true, // Allow GridView to fit its content
      padding: EdgeInsets.zero, // Remove default padding

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount, // Number of columns
        crossAxisSpacing: 20, // Space between columns
        mainAxisSpacing: 15, // Space between rows
        childAspectRatio: 3.0, // Width-to-height ratio of items
      ),
      itemCount: rows.length, // Total number of items
      itemBuilder: (context, index) {
        return rows[index];
      },
    );
  }
}
