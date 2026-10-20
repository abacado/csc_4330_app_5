import 'package:flutter/material.dart';

class SectionPage extends StatelessWidget {
  const SectionPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.children = const [],
  });
  final String title;
  final String description;
  final IconData icon;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 20),
      Text(title, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 12),
      Text(description),
      const SizedBox(height: 24),
      ...children,
    ],
  );
}
