import 'package:flutter/material.dart';

import '../../shared/section_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onExplore, required this.onPost});
  final VoidCallback onExplore;
  final VoidCallback onPost;
  @override
  Widget build(BuildContext context) => SectionPage(
    icon: Icons.spa_outlined,
    title: 'A new hobby starts here.',
    description:
        'Find inspiration, share supplies, and make room for something new.',
    children: [
      FilledButton(onPressed: onExplore, child: const Text('Explore hobbies')),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: onPost,
        icon: const Icon(Icons.add),
        label: const Text('Share some supplies'),
      ),
      const SizedBox(height: 28),
      Text('Supplies near you', style: Theme.of(context).textTheme.titleLarge),
      const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No listings yet. Community supplies will appear here when listings are connected.',
          ),
        ),
      ),
    ],
  );
}
