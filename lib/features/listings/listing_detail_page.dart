import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../messages/send_request_sheet.dart';
import '../profile/profile.dart';
import 'listing_photo.dart';

class ListingDetailPage extends StatefulWidget {
  const ListingDetailPage({
    super.key,
    required this.listing,
    this.client,
    this.preview = false,
  });
  final Listing listing;
  final ApiClient? client;
  final bool preview;
  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  late final Future<Profile?> _owner;
  bool _requestSent = false;
  @override
  void initState() {
    super.initState();
    _owner = widget.preview ? Future.value(null) : _loadOwner();
  }

  Future<Profile?> _loadOwner() async {
    try {
      return await (widget.client ?? apiClient).getProfile(
        widget.listing.ownerId,
      );
    } on ApiException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.listing;
    final own = item.ownerId == ApiConfig.demoUserId;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.preview ? 'Preview listing' : 'Listing details'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              FutureBuilder<Profile?>(
                future: _owner,
                builder: (context, snapshot) {
                  final profile = snapshot.data;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: profile == null
                          ? const Icon(Icons.person_outline)
                          : Text(profile.initials),
                    ),
                    title: Text(
                      profile?.displayName ??
                          (own ? 'You' : 'Community member'),
                    ),
                    subtitle: Text(profile?.handle ?? item.ownerId),
                  );
                },
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ListingPhoto(
                  hobbyId: item.hobbyId,
                  dataUrl: item.photoDataUrl,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                item.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(
                      item.type == ListingType.swap ? 'Swap' : 'Giveaway',
                    ),
                  ),
                  Chip(label: Text(item.condition)),
                  Chip(label: Text(HobbyCatalog.nameFor(item.hobbyId))),
                  if (!item.isAvailable) const Chip(label: Text('Completed')),
                ],
              ),
              if (item.area?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('City / area: ${item.area}'),
                ),
              const SizedBox(height: 16),
              Text(item.description),
              if (item.type == ListingType.swap &&
                  item.wantedItem?.isNotEmpty == true) ...[
                const SizedBox(height: 20),
                Text('Looking for: ${item.wantedItem}'),
              ],
              const SizedBox(height: 24),
              if (widget.preview)
                const Text('Preview only — this listing has not been posted.')
              else if (own)
                const Text('This is your listing.')
              else if (!item.isAvailable)
                const Text('This item is no longer available.')
              else
                FilledButton.icon(
                  icon: Icon(_requestSent ? Icons.check : Icons.swap_horiz),
                  label: Text(
                    _requestSent
                        ? 'Request sent'
                        : item.type == ListingType.swap
                        ? 'Request swap'
                        : 'Request item',
                  ),
                  onPressed: _requestSent
                      ? null
                      : () async {
                          final result = await showSendRequestSheet(
                            context,
                            item,
                            client: widget.client,
                          );
                          if (mounted && result != null) {
                            setState(() => _requestSent = true);
                          }
                        },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
