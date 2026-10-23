import 'dart:convert';

import 'package:flutter/material.dart';

import '../profile/hobby_catalog.dart';

class ListingPhoto extends StatelessWidget {
  const ListingPhoto({super.key, required this.hobbyId, this.dataUrl});
  final String hobbyId;
  final String? dataUrl;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => ColoredBox(
      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.25),
      child: Center(
        child: Icon(
          HobbyCatalog.iconFor(hobbyId),
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
    Widget image = fallback();
    if (dataUrl != null &&
        dataUrl!.startsWith('data:image/') &&
        dataUrl!.contains(';base64,')) {
      try {
        final bytes = base64Decode(dataUrl!.split(';base64,').last);
        image = Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, _, _) => fallback(),
        );
      } on FormatException {
        image = fallback();
      }
    }
    return AspectRatio(aspectRatio: 4 / 3, child: image);
  }
}
