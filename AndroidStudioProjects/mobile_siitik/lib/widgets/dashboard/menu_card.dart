// lib/widgets/dashboard/menu_card.dart
import 'package:flutter/material.dart';

class MenuGrid extends StatelessWidget {
  const MenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MenuButton(
          label: 'Penetasan',
          icon: Icons.egg_outlined,
          onTap: () => _showPenetasanDialog(context),
        ),
        MenuButton(
          label: 'Penggemukan',
          icon: Icons.medication_outlined,
          onTap: () => _showPenggemukanDialog(context),
        ),
        MenuButton(
          label: 'Layer',
          icon: Icons.layers_outlined,
          onTap: () => _showLayerDialog(context),
        ),
      ],
    );
  }

  void _showPenetasanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const InfoDialog(
        title: 'Penetasan',
        subtitle: 'Informasi Penetasan',
        content: [
          '• Suhu ideal: 37.5°C - 38.5°C',
          '• Kelembaban: 55% - 60%',
          '• Periode penetasan: 28 hari',
          '• Pemutaran telur: 3x sehari',
        ],
      ),
    );
  }

  void _showPenggemukanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const InfoDialog(
        title: 'Penggemukan',
        subtitle: 'Panduan Penggemukan',
        content: [
          '• Pemberian pakan: 3-4x sehari',
          '• Jenis pakan: Konsentrat & dedak',
          '• Periode: 8-10 minggu',
          '• Target berat: 2.5-3 kg',
        ],
      ),
    );
  }

  void _showLayerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const InfoDialog(
        title: 'Layer',
        subtitle: 'Informasi Layer',
        content: [
          '• Umur mulai bertelur: 20-22 minggu',
          '• Produksi telur: 250-300 butir/tahun',
          '• Pakan layer: 160-180 gram/hari',
          '• Periode bertelur: 12-18 bulan',
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Colors.orange[800]),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> content;

  const InfoDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...content.map((text) => Text(text)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}