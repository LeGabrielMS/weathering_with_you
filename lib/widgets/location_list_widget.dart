import 'package:flutter/material.dart';

class LocationList extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> locations;
  final Function(Map<String, dynamic>) onSelect;
  final Function(Map<String, dynamic>) onRemove;
  final bool showSaveButton;
  final Function(Map<String, dynamic>)? onSave;
  final bool showRemoveButton;

  const LocationList({
    super.key,
    required this.title,
    required this.locations,
    required this.onSelect,
    required this.onRemove,
    this.showSaveButton = false,
    this.onSave,
    this.showRemoveButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final location = locations[index];
            return ListTile(
              title: Text(
                location['name'],
                style: const TextStyle(color: Colors.black),
              ),
              trailing: showSaveButton
                  ? ElevatedButton(
                      onPressed: () {
                        if (onSave != null) onSave!(location);
                      },
                      child: const Text("Save"),
                    )
                  : showRemoveButton
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onRemove(location),
                        )
                      : null,
              onTap: () => onSelect(location),
            );
          },
        ),
      ],
    );
  }
}
