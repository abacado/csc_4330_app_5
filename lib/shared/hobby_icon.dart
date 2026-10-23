import 'package:flutter/material.dart';

/// Stable pastel colors shared by hobby tiles, guides, and empty photos.
class HobbyIcon extends StatelessWidget {
  const HobbyIcon({
    super.key,
    required this.id,
    required this.icon,
    this.size = 52,
  });
  final String id;
  final IconData icon;
  final double size;
  static Color colorFor(String id) {
    const colors = [
      Color(0xFFF7DED5),
      Color(0xFFE4E0F3),
      Color(0xFFDDEADB),
      Color(0xFFDAE9EE),
      Color(0xFFF5E9C8),
      Color(0xFFF1DFE5),
    ];
    const featured = [
      'painting',
      'crochet',
      'gardening',
      'photography',
      'music',
      'baking',
    ];
    final index = featured.indexOf(id);
    return colors[index < 0
        ? id.codeUnits.fold(0, (a, b) => a + b) % colors.length
        : index];
  }

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: colorFor(id),
      borderRadius: BorderRadius.circular(size * .28),
    ),
    child: Icon(
      icon,
      size: size * .5,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  );
}
