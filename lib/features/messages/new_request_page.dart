import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../profile/profile.dart';
import 'send_request_sheet.dart';

/// Lists other people's available listings so the demo user can pick one and
/// send a swap request. Pops with the sent [SwapRequest].
class NewRequestPage extends StatefulWidget {
  const NewRequestPage({super.key, required this.client, required this.store});
  final ApiClient client;
  final ProfileStore store;
  @override
  State<NewRequestPage> createState() => _NewRequestPageState();
}

class _NewRequestPageState extends State<NewRequestPage> {
  late Future<List<Listing>> _listings = _load();
  late Set<String> _myHobbies = {...?widget.store.profile?.hobbies.keys};
  late bool _onlyMyHobbies = _myHobbies.isNotEmpty;

  Future<List<Listing>> _load() async => [
    for (final listing in await widget.client.getListings())
      if (listing.isAvailable && listing.ownerId != ApiConfig.demoUserId)
        listing,
  ];

  Future<void> _request(Listing listing) async {
    final sent = await showSendRequestSheet(
      context,
      listing,
      client: widget.client,
    );
    if (sent != null && mounted) Navigator.of(context).pop(sent);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Request a swap')),
    body: FutureBuilder(
      future: _listings,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.error case final error?) {
          return _Message(
            icon: Icons.cloud_off_outlined,
            text: error is ApiException
                ? error.message
                : 'Could not load listings.',
            action: FilledButton(
              onPressed: () => setState(() {
                _listings = _load();
              }),
              child: const Text('Try again'),
            ),
          );
        }
        final all = snapshot.requireData;
        final shown = _onlyMyHobbies
            ? all.where((l) => _myHobbies.contains(l.hobbyId)).toList()
            : all;
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _myHobbies = {...?widget.store.profile?.hobbies.keys};
              _listings = _load();
            });
            await _listings;
          },
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Pick a listing to send its owner a swap request.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (_myHobbies.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChip(
                    label: const Text('Only my hobbies'),
                    selected: _onlyMyHobbies,
                    onSelected: (on) => setState(() => _onlyMyHobbies = on),
                  ),
                ),
              const SizedBox(height: 12),
              if (shown.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      all.isEmpty
                          ? 'No listings from other hobbyists yet. '
                                'Check back after someone posts supplies.'
                          : 'No listings for your hobbies right now. '
                                'Turn off "Only my hobbies" to see everything.',
                    ),
                  ),
                ),
              for (final listing in shown)
                Card(
                  child: ListTile(
                    leading: Icon(HobbyCatalog.iconFor(listing.hobbyId)),
                    title: Text(listing.title),
                    subtitle: Text(
                      '${HobbyCatalog.nameFor(listing.hobbyId)} · '
                      '${listing.type == ListingType.swap ? 'Swap for ${listing.wantedItem ?? 'an offer'}' : 'Giveaway'}'
                      ' · @${listing.ownerId}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _request(listing),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});
  final IconData icon;
  final String text;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(text, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    ),
  );
}
