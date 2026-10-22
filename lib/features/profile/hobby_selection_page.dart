import 'package:flutter/material.dart';

import 'profile.dart';

/// Pick the hobbies on your profile and how far along you are in each.
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

  void _toggle(String id, bool on) => setState(
    () => on ? _selected[id] = HobbyLevel.wantToTry : _selected.remove(id),
  );

  void _save() {
    widget.store.setHobbies(_selected);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My hobbies')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Choose your hobbies',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Swap requests can be narrowed to these hobbies, and other '
          'hobbyists will know where you are on your journey.',
        ),
        const SizedBox(height: 16),
        for (final id in HobbyCatalog.ids)
          Card(
            child: Column(
              children: [
                CheckboxListTile(
                  secondary: Icon(HobbyCatalog.iconFor(id)),
                  title: Text(HobbyCatalog.nameFor(id)),
                  value: _selected.containsKey(id),
                  onChanged: (on) => _toggle(id, on ?? false),
                ),
                if (_selected[id] case final level?)
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
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _save,
          child: Text(
            _selected.isEmpty
                ? (widget.isSetup ? 'Skip for now' : 'Save')
                : 'Save ${_selected.length} '
                      '${_selected.length == 1 ? 'hobby' : 'hobbies'}',
          ),
        ),
      ],
    ),
  );
}
