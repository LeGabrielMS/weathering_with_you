import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamMemberCard extends StatelessWidget {
  final String name, nim, role, image, link;

  const TeamMemberCard({
    super.key,
    required this.name,
    required this.nim,
    required this.role,
    required this.image,
    required this.link,
  });

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(image),
              radius: 40,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(nim, textAlign: TextAlign.center),
                  const SizedBox(height: 2),
                  Text(role, textAlign: TextAlign.center),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.link, color: Colors.blue),
              onPressed: () => _launchURL(link),
            ),
          ],
        ),
      ),
    );
  }
}
