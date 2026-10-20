import 'package:flutter/material.dart';

import '../../shared/section_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => const SectionPage(
    icon: Icons.person_outline,
    title: 'Your HobbySwap profile',
    description: 'Account setup is coming soon.',
    children: [
      Card(
        child: ListTile(
          title: Text('My hobbies'),
          subtitle: Text('Want to try · Learning · Experienced'),
        ),
      ),
      Card(
        child: ListTile(
          title: Text('My listings'),
          subtitle: Text('Your shared supplies will appear here.'),
        ),
      ),
      Card(
        child: ListTile(
          title: Text('Wishlist'),
          subtitle: Text('A future home for your saved interests.'),
        ),
      ),
    ],
  );
}
