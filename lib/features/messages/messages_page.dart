import 'package:flutter/material.dart';

import '../../shared/section_page.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});
  @override
  Widget build(BuildContext context) => const SectionPage(
    icon: Icons.forum_outlined,
    title: 'Keep the conversation growing.',
    description: 'Messaging is coming soon. Your swap requests and exchange conversations will live here.',
  );
}
