import 'package:flutter/material.dart';

import '../../shared/section_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});
  static const hobbies = {
    'Painting': Icons.palette_outlined,
    'Crochet': Icons.interests_outlined,
    'Gardening': Icons.local_florist_outlined,
    'Photography': Icons.camera_alt_outlined,
    'Music': Icons.music_note_outlined,
    'Baking': Icons.bakery_dining_outlined,
  };
  @override
  Widget build(BuildContext context) => SectionPage(
    icon: Icons.explore_outlined,
    title: 'What will you try next?',
    description: 'Explore a hobby and find your next interest.',
    children: [
      for (final hobby in hobbies.entries)
        Card(
          child: ListTile(
            leading: Icon(hobby.value),
            title: Text(hobby.key),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(hobby.key)),
                  body: SectionPage(
                    icon: hobby.value,
                    title: 'Start with ${hobby.key.toLowerCase()}',
                    description: 'Starter guides, supply checklists, and related listings are coming soon.',
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
