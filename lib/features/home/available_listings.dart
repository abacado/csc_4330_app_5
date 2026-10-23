import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../listings/listing_card.dart';

/// Optional client lets tests use the same UI without a running server.
///
/// [reloadSignal] reloads the list from the server whenever it fires, for
/// example after a new listing is posted or when Home is shown again.
class AvailableListings extends StatefulWidget {
  const AvailableListings({super.key, this.client, this.reloadSignal});
  final ApiClient? client;
  final Listenable? reloadSignal;
  @override
  State<AvailableListings> createState() => _AvailableListingsState();
}

class _AvailableListingsState extends State<AvailableListings> {
  late Future<List<Listing>> _listings;
  @override
  void initState() {
    super.initState();
    _listings = _load()..ignore();
    widget.reloadSignal?.addListener(_refresh);
  }

  @override
  void didUpdateWidget(AvailableListings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadSignal != widget.reloadSignal) {
      oldWidget.reloadSignal?.removeListener(_refresh);
      widget.reloadSignal?.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.reloadSignal?.removeListener(_refresh);
    super.dispose();
  }

  Future<List<Listing>> _load() async =>
      (await (widget.client ?? apiClient).getListings())
          .where((item) => item.isAvailable)
          .toList();
  void _refresh() {
    if (!mounted) return;
    final next = _load();
    // A reload can start outside a build (from a tap or a new post) and fail
    // before FutureBuilder subscribes. Mark the error as handled here; the
    // FutureBuilder still receives it and shows the retry card.
    next.ignore();
    setState(() {
      _listings = next;
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Community supplies',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            onPressed: _refresh,
            tooltip: 'Refresh listings',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      const Text(
        'Available swaps and giveaways. Distance filtering is not available yet.',
      ),
      const SizedBox(height: 12),
      FutureBuilder<List<Listing>>(
        future: _listings,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Supplies could not be loaded.'),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error is ApiException
                          ? (snapshot.error as ApiException).message
                          : 'Please try again.',
                    ),
                    TextButton(
                      onPressed: _refresh,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }
          final listings = snapshot.data ?? [];
          if (listings.isEmpty) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No supplies listed yet. Check back after the first listing is posted.',
                ),
              ),
            );
          }
          return Column(
            children: [
              for (final listing in listings)
                ListingCard(listing: listing, client: widget.client),
            ],
          );
        },
      ),
    ],
  );
}
