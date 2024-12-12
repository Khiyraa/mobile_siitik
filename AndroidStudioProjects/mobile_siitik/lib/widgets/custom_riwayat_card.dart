import 'package:flutter/material.dart';
import 'package:mobile_siitik/core/constants/app_colors.dart';

class CustomRiwayatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final Map<String, String> details;

  const CustomRiwayatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.background,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40.0, color: Colors.orange),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ...details.entries.map(
                    (entry) => Text('${entry.key}: ${entry.value}'),
                  ),
                  const SizedBox(height: 8.0),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
