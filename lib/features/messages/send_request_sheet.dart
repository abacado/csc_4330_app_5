import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../profile/profile.dart';

/// Asks the demo user for a message and sends a swap request for [listing].
///
/// Returns the saved request, or null if the user closed the sheet. Any
/// screen that shows a listing (for example a listing details page) can call
/// this to add a "Request swap" button.
Future<SwapRequest?> showSendRequestSheet(
  BuildContext context,
  Listing listing, {
  ApiClient? client,
}) => showModalBottomSheet<SwapRequest>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) =>
      _SendRequestSheet(listing: listing, client: client ?? apiClient),
);

class _SendRequestSheet extends StatefulWidget {
  const _SendRequestSheet({required this.listing, required this.client});
  final Listing listing;
  final ApiClient client;
  @override
  State<_SendRequestSheet> createState() => _SendRequestSheetState();
}

class _SendRequestSheetState extends State<_SendRequestSheet> {
  static const maxMessageLength = 500;
  final _form = GlobalKey<FormState>();
  final _message = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || !_form.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final request = await widget.client.createRequest(
        listingId: widget.listing.id,
        requesterId: ApiConfig.demoUserId,
        message: _message.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(request);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _sending = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Request a swap', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(HobbyCatalog.iconFor(listing.hobbyId)),
              title: Text(listing.title),
              subtitle: Text(
                listing.type == ListingType.giveaway
                    ? 'Giveaway · ${listing.condition}'
                    : 'Swap for ${listing.wantedItem ?? 'an offer'}'
                          ' · ${listing.condition}',
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _message,
              autofocus: true,
              enabled: !_sending,
              maxLength: maxMessageLength,
              maxLines: 4,
              minLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Message to @${listing.ownerId}',
                hintText: listing.type == ListingType.swap
                    ? 'What can you offer in exchange?'
                    : 'Say hello and how you would use it',
              ),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'Write a short message.'
                  : null,
            ),
            if (_error case final error?)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  error,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(_sending ? 'Sending…' : 'Send request'),
            ),
          ],
        ),
      ),
    );
  }
}
