import 'package:flutter/material.dart';

class ForecastSection extends StatelessWidget {
  final List<Map<String, dynamic>> forecast;

  const ForecastSection({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecast.length,
        itemBuilder: (context, index) {
          final item = forecast[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  item['date'],
                  style: const TextStyle(color: Colors.white),
                ),
                Image.network(
                  'https://openweathermap.org/img/wn/${item['icon']}@2x.png',
                  width: 50,
                  height: 50,
                ),
                Text('${item['temp_max']}°C / ${item['temp_min']}°C',
                    style: const TextStyle(color: Colors.white)),
                Text(item['description'],
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}
