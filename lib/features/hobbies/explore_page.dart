import 'package:flutter/material.dart';

import '../../shared/section_page.dart';
import '../profile/hobby_catalog.dart' as shared;
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

  static final _byId = {for (final hobby in hobbyCatalog) hobby.id: hobby};

  @override
  Widget build(BuildContext context) {
    final searching = _query.trim().isNotEmpty;
    return SectionPage(
      icon: Icons.explore_outlined,
      title: 'What will you try next?',
      description:
          'Explore ${hobbyCatalog.length} hobbies, plan a first project, and '
          'check your starter supplies.',
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search hobbies',
            hintText: 'Try a hobby or a supply, like "yarn"',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 16),
        if (searching) ..._searchResults() else ..._byCategory(context),
      ],
    );
  }

  /// Ranked matches on names, categories, and supply keywords.
  List<Widget> _searchResults() {
    final matches = [
      for (final match in shared.HobbyCatalog.search(_query, limit: 50))
        if (_byId[match.hobby.id] case final hobby?) (hobby, match),
    ];
    if (matches.isEmpty) return const [Text('No hobbies match your search.')];
    return [
      for (final (hobby, match) in matches)
        _tile(
          hobby,
          match.keyword == null
              ? match.hobby.category
              : 'Matches "${match.keyword}" · ${match.hobby.category}',
        ),
    ];
  }

  /// Every hobby under its category heading, in catalog order.
  List<Widget> _byCategory(BuildContext context) {
    final groups = <String, List<Hobby>>{};
    for (final hobby in hobbyCatalog) {
      final category = shared.HobbyCatalog.byId(hobby.id)?.category ?? 'Other';
      (groups[category] ??= []).add(hobby);
    }
    return [
      for (final MapEntry(key: category, value: hobbies) in groups.entries) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
          child: Text(
            '$category (${hobbies.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        for (final hobby in hobbies)
          _tile(hobby, 'Beginner guide and starter checklist'),
      ],
    ];
  }

  Widget _tile(Hobby hobby, String subtitle) => Card(
    child: ListTile(
      leading: Icon(hobby.icon),
      title: Text(hobby.name),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => HobbyDetailPage(
            hobby: hobby,
            checkedItems: _progress.putIfAbsent(hobby.id, () => <String>{}),
          ),
        ),
      ),
    ),
  );
}
