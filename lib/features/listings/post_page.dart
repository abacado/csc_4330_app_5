import 'package:flutter/material.dart';

import '../../shared/section_page.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});
  @override
  Widget build(BuildContext context) => const SectionPage(
    icon: Icons.add_photo_alternate_outlined,
    title: 'Give supplies a fresh start.',
    description: 'Listing creation is coming soon. Offer supplies as a swap or giveaway, with photos, a hobby category, condition, and what you want in exchange.',
  );
}
