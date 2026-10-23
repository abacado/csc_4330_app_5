import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../profile/hobby_catalog.dart';
import 'listing_detail_page.dart';
import 'listing_photo.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({super.key, required this.listing, this.client});
  final Listing listing;
  final ApiClient? client;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ListingDetailPage(listing: listing, client: client),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListingPhoto(hobbyId: listing.hobbyId, dataUrl: listing.photoDataUrl),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${HobbyCatalog.nameFor(listing.hobbyId)} · ${listing.condition}',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Chip(
                      label: Text(
                        listing.type == ListingType.swap ? 'Swap' : 'Giveaway',
                      ),
                    ),
                    if (listing.area?.isNotEmpty == true) Text(listing.area!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
