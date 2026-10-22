import 'package:flutter/material.dart';

import '../../data/data.dart';
import 'profile.dart';

/// Pick the hobbies on your profile and how far along you are in each.
///
/// A search bar suggests matching hobbies as you type, including matches on
/// supplies and synonyms ("yarn" suggests Knitting and Crochet).
class HobbySelectionPage extends StatefulWidget {
  const HobbySelectionPage({
    super.key,
    required this.store,
    this.isSetup = false,
  });
  final ProfileStore store;

  /// True right after the profile is created, so the user can skip for now.
  final bool isSetup;
  @override
  State<HobbySelectionPage> createState() => _HobbySelectionPageState();
}

class _HobbySelectionPageState extends State<HobbySelectionPage> {
  late final Map<String, HobbyLevel> _selected = {
    ...?widget.store.profile?.hobbies,
  };
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _toggle(String id, bool on) => setState(() {
    if (on) {
      _selected.putIfAbsent(id, () => HobbyLevel.wantToTry);
    } else {
      _selected.remove(id);
    }
  });

  /// Picks a suggestion and clears the search, ready for the next one.
  void _pick(Hobby hobby) {
    _toggle(hobby.id, !_selected.containsKey(hobby.id));
    _search.clear();
    _searchFocus.requestFocus();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.store.setHobbies(_selected);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _search.text.trim();
    return Scaffold(
      appBar: AppBar(title: const Text('My hobbies')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Choose your hobbies', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Search ${HobbyCatalog.all.length} hobbies. Swap requests can be '
            'narrowed to these, and other hobbyists will know where you are '
            'on your journey.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _search,
            focusNode: _searchFocus,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            onSubmitted: (value) {
              final matches = HobbyCatalog.search(value, limit: 1);
              if (matches.isNotEmpty) _pick(matches.first.hobby);
            },
            decoration: InputDecoration(
              hintText: 'Search hobbies, e.g. "yarn" or "climbing"',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () => setState(_search.clear),
                      icon: const Icon(Icons.close),
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (query.isNotEmpty)
            _Suggestions(
              query: query,
              selected: _selected.keys.toSet(),
              onPick: _pick,
            )
          else ...[
            const SizedBox(height: 16),
            Text('Popular', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final id in HobbyCatalog.popularIds)
                  FilterChip(
                    avatar: Icon(HobbyCatalog.iconFor(id), size: 18),
                    label: Text(HobbyCatalog.nameFor(id)),
                    selected: _selected.containsKey(id),
                    showCheckmark: false,
                    onSelected: (on) => _toggle(id, on),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Text(
            _selected.isEmpty
                ? 'Your hobbies'
                : 'Your hobbies (${_selected.length})',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_selected.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Search or tap a hobby above to add it here.'),
              ),
            ),
          for (final MapEntry(key: id, value: level) in _selected.entries)
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(HobbyCatalog.iconFor(id)),
                    title: Text(HobbyCatalog.nameFor(id)),
                    subtitle: Text(HobbyCatalog.byId(id)?.category ?? ''),
                    trailing: IconButton(
                      tooltip: 'Remove ${HobbyCatalog.nameFor(id)}',
                      onPressed: () => _toggle(id, false),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SegmentedButton<HobbyLevel>(
                      showSelectedIcon: false,
                      segments: [
                        for (final l in HobbyLevel.values)
                          ButtonSegment(value: l, label: Text(l.label)),
                      ],
                      selected: {level},
                      onSelectionChanged: (s) =>
                          setState(() => _selected[id] = s.single),
                    ),
                  ),
                ],
              ),
            ),
          if (query.isEmpty) ...[
            const SizedBox(height: 24),
            Text('Browse by category', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final MapEntry(key: category, value: hobbies)
                      in HobbyCatalog.byCategory.entries)
                    ExpansionTile(
                      title: Text(category),
                      subtitle: Text('${hobbies.length} hobbies'),
                      children: [
                        for (final hobby in hobbies)
                          CheckboxListTile(
                            dense: true,
                            secondary: Icon(hobby.icon),
                            title: Text(hobby.name),
                            value: _selected.containsKey(hobby.id),
                            onChanged: (on) => _toggle(hobby.id, on ?? false),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
      // Pinned so Save stays reachable below the long category list.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error case final error?)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    error,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(
                  _saving
                      ? 'Saving…'
                      : _selected.isEmpty
                      ? (widget.isSetup ? 'Skip for now' : 'Save')
                      : 'Save ${_selected.length} '
                            '${_selected.length == 1 ? 'hobby' : 'hobbies'}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The suggestion list under the search bar, like a browser's.
class _Suggestions extends StatelessWidget {
  const _Suggestions({
    required this.query,
    required this.selected,
    required this.onPick,
  });
  final String query;
  final Set<String> selected;
  final ValueChanged<Hobby> onPick;

  @override
  Widget build(BuildContext context) {
    final matches = HobbyCatalog.search(query);
    return Card(
      margin: const EdgeInsets.only(top: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (matches.isEmpty)
            ListTile(
              leading: const Icon(Icons.search_off),
              title: Text('No hobbies match "$query"'),
              subtitle: const Text(
                'Try a supply or activity, like "paint" or "trail".',
              ),
            ),
          for (final match in matches)
            ListTile(
              leading: Icon(match.hobby.icon),
              title: _Highlighted(text: match.hobby.name, query: query),
              subtitle: Text(
                match.keyword == null
                    ? match.hobby.category
                    : 'Matches "${match.keyword}" · ${match.hobby.category}',
              ),
              trailing: Icon(
                selected.contains(match.hobby.id)
                    ? Icons.check_circle
                    : Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => onPick(match.hobby),
            ),
        ],
      ),
    );
  }
}

/// [text] with the part matching [query] in bold.
class _Highlighted extends StatelessWidget {
  const _Highlighted({required this.text, required this.query});
  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    final start = text.toLowerCase().indexOf(query.toLowerCase());
    if (start < 0) return Text(text);
    final end = start + query.length;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
    );
  }
}
