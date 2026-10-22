import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../../shared/section_page.dart';
import '../profile/profile.dart';
import 'new_request_page.dart';

/// Swap requests the demo user received (with accept/decline) and sent.
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key, this.client, this.store});

  /// Defaults to the shared [apiClient] and [profileStore]; tests pass fakes.
  final ApiClient? client;
  final ProfileStore? store;
  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

typedef _Inbox = ({
  List<SwapRequest> requests,
  Map<String, Listing> listings,

  /// User id → `@username` (or the id for users without a profile).
  Map<String, String> handles,
});

class _MessagesPageState extends State<MessagesPage> {
  ApiClient get _client => widget.client ?? apiClient;
  ProfileStore get _store => widget.store ?? profileStore;
  late Future<_Inbox> _inbox = _load();
  bool _showSent = false;

  @override
  void initState() {
    super.initState();
    // The new-request page filters by the user's hobbies.
    _store.ensureLoaded();
  }

  /// Request ids with an accept/decline call in flight.
  final _deciding = <String>{};

  /// Loads one after the other so a failure surfaces as the [ApiException]
  /// itself rather than a combined error.
  Future<_Inbox> _load() async {
    final requests = await _client.getRequests(userId: ApiConfig.demoUserId);
    final listings = {for (final l in await _client.getListings()) l.id: l};
    final handles = await _store.handlesFor({
      for (final r in requests) ...[
        r.requesterId,
        ?listings[r.listingId]?.ownerId,
      ],
    });
    return (requests: requests, listings: listings, handles: handles);
  }

  Future<void> _refresh() {
    setState(() {
      _inbox = _load();
    });
    return _inbox.then((_) {}, onError: (_) {});
  }

  Future<void> _newRequest() async {
    final sent = await Navigator.of(context).push<SwapRequest>(
      MaterialPageRoute(
        builder: (context) => NewRequestPage(client: _client, store: _store),
      ),
    );
    if (sent == null || !mounted) return;
    setState(() => _showSent = true);
    _snack('Swap request sent.');
    await _refresh();
  }

  Future<void> _decide(SwapRequest request, {required bool accept}) async {
    setState(() => _deciding.add(request.id));
    try {
      await (accept
          ? _client.acceptRequest(request.id)
          : _client.declineRequest(request.id));
      _snack(accept ? 'Request accepted. Time to swap!' : 'Request declined.');
      await _refresh();
    } on ApiException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _deciding.remove(request.id));
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: _refresh,
    child: FutureBuilder(
      future: _inbox,
      builder: (context, snapshot) => SectionPage(
        icon: Icons.forum_outlined,
        title: 'Keep the conversation growing.',
        description:
            'Send swap requests for supplies you want, and answer the ones '
            'other hobbyists send you.',
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _newRequest,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('New swap request'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Refresh',
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._body(context, snapshot),
        ],
      ),
    ),
  );

  List<Widget> _body(BuildContext context, AsyncSnapshot<_Inbox> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const [Center(child: CircularProgressIndicator())];
    }
    if (snapshot.error case final error?) {
      return [
        Card(
          child: ListTile(
            leading: const Icon(Icons.cloud_off_outlined),
            title: const Text('Could not load your requests'),
            subtitle: Text(
              error is ApiException ? error.message : 'Something went wrong.',
            ),
            trailing: TextButton(
              onPressed: _refresh,
              child: const Text('Retry'),
            ),
          ),
        ),
      ];
    }
    final inbox = snapshot.requireData;
    final me = ApiConfig.demoUserId;
    final sent = [
      for (final r in inbox.requests)
        if (r.isOutgoingFor(me)) r,
    ];
    final received = [
      for (final r in inbox.requests)
        if (!r.isOutgoingFor(me)) r,
    ];
    final shown = _showSent ? sent : received;
    final waiting = received
        .where((r) => r.status == RequestStatus.pending)
        .length;
    return [
      SegmentedButton<bool>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: false,
            icon: const Icon(Icons.move_to_inbox_outlined),
            label: Text(waiting == 0 ? 'Received' : 'Received ($waiting new)'),
          ),
          ButtonSegment(
            value: true,
            icon: const Icon(Icons.outbox_outlined),
            label: Text('Sent (${sent.length})'),
          ),
        ],
        selected: {_showSent},
        onSelectionChanged: (s) => setState(() => _showSent = s.single),
      ),
      const SizedBox(height: 12),
      if (shown.isEmpty)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _showSent
                  ? 'You have not sent any swap requests yet. Tap '
                        '"New swap request" to ask for supplies you want.'
                  : 'No one has requested your listings yet. Requests '
                        'for supplies you post will show up here.',
            ),
          ),
        ),
      for (final request in shown)
        _RequestCard(
          request: request,
          listing: inbox.listings[request.listingId],
          outgoing: _showSent,
          otherParty: _showSent
              ? inbox.handles[inbox.listings[request.listingId]?.ownerId] ??
                    'the listing owner'
              : inbox.handles[request.requesterId] ?? request.requesterId,
          deciding: _deciding.contains(request.id),
          onAccept: () => _decide(request, accept: true),
          onDecline: () => _decide(request, accept: false),
        ),
    ];
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.listing,
    required this.outgoing,
    required this.otherParty,
    required this.deciding,
    required this.onAccept,
    required this.onDecline,
  });
  final SwapRequest request;
  final Listing? listing;
  final bool outgoing;

  /// The other person's `@username`.
  final String otherParty;
  final bool deciding;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listing = this.listing;
    final who = outgoing ? 'To $otherParty' : 'From $otherParty';
    final date = MaterialLocalizations.of(context)
        .formatShortDate(request.createdAt.toLocal());
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  listing == null
                      ? Icons.inventory_2_outlined
                      : HobbyCatalog.iconFor(listing.hobbyId),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    listing?.title ?? 'Listing no longer available',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                _StatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$who · $date',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(request.message),
            if (!outgoing && request.status == RequestStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: deciding ? null : onDecline,
                    child: const Text('Decline'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: deciding ? null : onAccept,
                    child: const Text('Accept'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final RequestStatus status;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      RequestStatus.pending => ('Pending', scheme.secondaryContainer),
      RequestStatus.accepted => ('Accepted', scheme.primaryContainer),
      RequestStatus.declined => ('Declined', scheme.surfaceContainerHighest),
    };
    return Chip(
      label: Text(label),
      backgroundColor: color,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
