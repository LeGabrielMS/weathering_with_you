import 'package:flutter/material.dart';
import 'weather_row_widget.dart';

class WeatherSection extends StatelessWidget {
  final List<WeatherRow> rows;
  final int columnCount;

  const WeatherSection({
    super.key,
    required this.rows,
    this.columnCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 15,
        childAspectRatio: 3.0,
      ),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        return rows[index];
      },
    );
  }
}
