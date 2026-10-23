import 'package:flutter/material.dart';

import '../../shared/section_page.dart';
import '../../shared/hobby_icon.dart';
import 'hobby_catalog.dart';
import 'hobby_detail_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final Map<String, Set<String>> _progress = {};
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final hobbies = hobbyCatalog
        .where(
          (hobby) =>
              hobby.name.toLowerCase().contains(_query.toLowerCase().trim()),
        )
        .toList();
    return SectionPage(
      icon: Icons.explore_outlined,
      title: 'What will you try next?',
      description: 'Explore a hobby, plan a first project, and check your starter supplies.',
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search hobbies',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 16),
        if (hobbies.isEmpty) const Text('No hobbies match your search.'),
        for (final hobby in hobbies)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: HobbyIcon(id: hobby.id, icon: hobby.icon),
              title: Text(hobby.name),
              subtitle: const Text('Beginner guide and starter checklist'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => HobbyDetailPage(
                    hobby: hobby,
                    checkedItems: _progress.putIfAbsent(
                      hobby.id,
                      () => <String>{},
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
