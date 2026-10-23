import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../shared/hobby_icon.dart';
import 'available_listings.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.onExplore,
    required this.onPost,
    this.listingsReload,
  });
  final VoidCallback onExplore;
  final VoidCallback onPost;
  final Listenable? listingsReload;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF8E3DA),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFF0D4C8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppTheme.sage,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'A LITTLE CURIOSITY GOES A LONG WAY',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .7,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'A new hobby starts here.',
              style: Theme.of(context).textTheme.headlineLarge
                  ?.copyWith(color: AppTheme.sage),
            ),
            const SizedBox(height: 12),
            const Text(
              'Find inspiration, share supplies, and make room for something new.',
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: onExplore,
                  icon: const Icon(Icons.north_east, size: 18),
                  label: const Text('Explore hobbies'),
                ),
                OutlinedButton.icon(
                  onPressed: onPost,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Share some supplies'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                HobbyIcon(
                  id: 'painting',
                  icon: Icons.palette_outlined,
                  size: 40,
                ),
                SizedBox(width: 9),
                HobbyIcon(
                  id: 'gardening',
                  icon: Icons.local_florist_outlined,
                  size: 40,
                ),
                SizedBox(width: 9),
                HobbyIcon(
                  id: 'music',
                  icon: Icons.music_note_outlined,
                  size: 40,
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 30),
      AvailableListings(reloadSignal: listingsReload),
      const SizedBox(height: 20),
    ],
  );
}
