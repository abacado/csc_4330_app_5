import 'package:flutter/material.dart';

import 'hobby_catalog.dart';
import '../../shared/hobby_icon.dart';

class HobbyDetailPage extends StatefulWidget {
  const HobbyDetailPage({
    super.key,
    required this.hobby,
    required this.checkedItems,
  });
  final Hobby hobby;
  final Set<String> checkedItems;
  @override
  State<HobbyDetailPage> createState() => _HobbyDetailPageState();
}

class _HobbyDetailPageState extends State<HobbyDetailPage> {
  @override
  Widget build(BuildContext context) {
    final hobby = widget.hobby;
    return Scaffold(
      appBar: AppBar(title: Text(hobby.name)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: HobbyIcon(id: hobby.id, icon: hobby.icon, size: 80),
              ),
              const SizedBox(height: 20),
              Text(
                'Start with ${hobby.name.toLowerCase()}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(hobby.description),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your first project',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(hobby.firstProject),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Starter checklist',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text(
                'Check what you already have. Progress stays while the app is open.',
              ),
              const SizedBox(height: 12),
              Text(
                '${widget.checkedItems.length} of ${hobby.starterItems.length} ready',
              ),
              const SizedBox(height: 10),
              Semantics(
                label: 'Starter supplies progress',
                child: LinearProgressIndicator(
                  minHeight: 9,
                  value: hobby.starterItems.isEmpty
                      ? 0
                      : widget.checkedItems.length / hobby.starterItems.length,
                ),
              ),
              const SizedBox(height: 16),
              for (final item in hobby.starterItems)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item),
                  value: widget.checkedItems.contains(item),
                  onChanged: (checked) => setState(() {
                    if (checked == true) {
                      widget.checkedItems.add(item);
                    } else {
                      widget.checkedItems.remove(item);
                    }
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
