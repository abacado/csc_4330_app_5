import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../../shared/section_page.dart';
import 'hobby_selection_page.dart';
import 'profile.dart';
import 'profile_form_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.store, this.client});

  /// Defaults to the shared [profileStore] and [apiClient]; tests pass fakes.
  final ProfileStore? store;
  final ApiClient? client;

  @override
  Widget build(BuildContext context) {
    final store = this.store ?? profileStore;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => switch (store.profile) {
        null => SectionPage(
          icon: Icons.person_outline,
          title: 'Your HobbySwap profile',
          description:
              'Create a profile so other hobbyists know who they are swapping '
              'with. Accounts are a demo placeholder for now: you act as '
              '@${ApiConfig.demoUserId}.',
          children: [
            FilledButton.icon(
              onPressed: () => _push(context, ProfileFormPage(store: store)),
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Create profile'),
            ),
          ],
        ),
        final profile => _ProfileView(
          profile: profile,
          store: store,
          client: client ?? apiClient,
        ),
      },
    );
  }
}

void _push(BuildContext context, Widget page) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (context) => page));

class _ProfileView extends StatelessWidget {
  const _ProfileView({
    required this.profile,
    required this.store,
    required this.client,
  });
  final UserProfile profile;
  final ProfileStore store;
  final ApiClient client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: theme.colorScheme.secondary,
              child: Text(profile.initials, style: theme.textTheme.titleLarge),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    style: theme.textTheme.headlineSmall,
                  ),
                  Text(
                    '@${ApiConfig.demoUserId}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit profile',
              onPressed: () => _push(context, ProfileFormPage(store: store)),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        if (profile.bio.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(profile.bio),
        ],
        const SizedBox(height: 24),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text('My hobbies'),
                subtitle: profile.hobbies.isEmpty
                    ? const Text('Want to try · Learning · Experienced')
                    : null,
                trailing: TextButton(
                  onPressed: () =>
                      _push(context, HobbySelectionPage(store: store)),
                  child: Text(profile.hobbies.isEmpty ? 'Choose' : 'Edit'),
                ),
              ),
              if (profile.hobbies.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final MapEntry(key: id, value: level)
                          in profile.hobbies.entries)
                        Chip(
                          avatar: Icon(HobbyCatalog.iconFor(id), size: 18),
                          label: Text(
                            '${HobbyCatalog.nameFor(id)} · ${level.label}',
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        _MyListingsCard(client: client),
        _WishlistCard(profile: profile, store: store),
      ],
    );
  }
}

/// Listings the demo user has posted, loaded from the server.
class _MyListingsCard extends StatefulWidget {
  const _MyListingsCard({required this.client});
  final ApiClient client;
  @override
  State<_MyListingsCard> createState() => _MyListingsCardState();
}

class _MyListingsCardState extends State<_MyListingsCard> {
  late Future<List<Listing>> _listings = _load();

  Future<List<Listing>> _load() async => [
    for (final listing in await widget.client.getListings())
      if (listing.ownerId == ApiConfig.demoUserId) listing,
  ];

  @override
  Widget build(BuildContext context) => Card(
    child: FutureBuilder(
      future: _listings,
      builder: (context, snapshot) {
        final refresh = IconButton(
          tooltip: 'Refresh',
          onPressed: () => setState(() {
            _listings = _load();
          }),
          icon: const Icon(Icons.refresh),
        );
        if (snapshot.connectionState != ConnectionState.done) {
          return const ListTile(
            title: Text('My listings'),
            subtitle: LinearProgressIndicator(),
          );
        }
        if (snapshot.error case final error?) {
          return ListTile(
            title: const Text('My listings'),
            subtitle: Text(
              error is ApiException
                  ? error.message
                  : 'Could not load listings.',
            ),
            trailing: refresh,
          );
        }
        final listings = snapshot.requireData;
        return Column(
          children: [
            ListTile(
              title: const Text('My listings'),
              subtitle: listings.isEmpty
                  ? const Text('Your shared supplies will appear here.')
                  : null,
              trailing: refresh,
            ),
            for (final listing in listings)
              ListTile(
                dense: true,
                leading: Icon(HobbyCatalog.iconFor(listing.hobbyId)),
                title: Text(listing.title),
                subtitle: Text(
                  '${listing.type == ListingType.swap ? 'Swap' : 'Giveaway'}'
                  ' · ${listing.condition}',
                ),
                trailing: Text(listing.isAvailable ? 'Available' : 'Completed'),
              ),
          ],
        );
      },
    ),
  );
}

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({required this.profile, required this.store});
  final UserProfile profile;
  final ProfileStore store;

  Future<void> _add(BuildContext context) async {
    final item = await showDialog<String>(
      context: context,
      builder: (context) => const _AddWishDialog(),
    );
    if (item == null || !context.mounted) return;
    if (!store.addWish(item)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${item.trim()}" is already on your wishlist.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('Wishlist'),
          subtitle: profile.wishlist.isEmpty
              ? const Text('Supplies you are hoping to swap for.')
              : null,
          trailing: TextButton(
            onPressed: () => _add(context),
            child: const Text('Add'),
          ),
        ),
        if (profile.wishlist.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in profile.wishlist)
                  InputChip(
                    label: Text(item),
                    onDeleted: () => store.removeWish(item),
                  ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _AddWishDialog extends StatefulWidget {
  const _AddWishDialog();
  @override
  State<_AddWishDialog> createState() => _AddWishDialogState();
}

class _AddWishDialogState extends State<_AddWishDialog> {
  final _item = TextEditingController();

  @override
  void dispose() {
    _item.dispose();
    super.dispose();
  }

  void _submit() {
    if (_item.text.trim().isNotEmpty) Navigator.of(context).pop(_item.text);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add to wishlist'),
    content: TextField(
      controller: _item,
      autofocus: true,
      maxLength: UserProfile.maxWishLength,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        hintText: 'e.g. Size 4 knitting needles',
      ),
      onSubmitted: (_) => _submit(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Add')),
    ],
  );
}
