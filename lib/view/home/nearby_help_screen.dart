import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';

class NearbyHelpScreen extends StatelessWidget {
  const NearbyHelpScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw Exception("Could not launch dialer.");
      }
    } catch (e) {
      print("Error calling $phoneNumber: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final elements = [
      {"name": "Cyber Crime Cell HQ", "phone": "1930", "distance": "1.2 km", "type": "cyber"},
      {"name": "Police Station (Central)", "phone": "112", "distance": "2.4 km", "type": "police"},
      {"name": "District Women Help Center", "phone": "1091", "distance": "3.1 km", "type": "women"},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Nearby Emergency Stations", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: elements.length,
        itemBuilder: (context, index) {
          final item = elements[index];
          return Card(
            color: AppColors.surface,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border, width: 1.5),
            ),
            child: ListTile(
              leading: Icon(
                item['type'] == 'cyber'
                    ? Icons.security_sharp
                    : item['type'] == 'police'
                        ? Icons.local_police
                        : Icons.support_agent,
                color: AppColors.secondary,
                size: 32,
              ),
              title: Text(item['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text("Distance: ${item['distance']}", style: const TextStyle(color: Colors.white70)),
              trailing: IconButton(
                icon: const Icon(Icons.call, color: Colors.greenAccent),
                onPressed: () {
                  _makePhoneCall(item['phone']!);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}