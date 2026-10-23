import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../data/models.dart';

class ListingBadge extends StatelessWidget {
  const ListingBadge({super.key, required this.type});
  final ListingType type;
  @override
  Widget build(BuildContext context) {
    final swap = type == ListingType.swap;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: swap ? AppTheme.sage : AppTheme.peach,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            swap ? Icons.swap_horiz : Icons.volunteer_activism_outlined,
            size: 16,
            color: swap ? Colors.white : AppTheme.charcoal,
          ),
          const SizedBox(width: 5),
          Text(
            swap ? 'Swap' : 'Giveaway',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: swap ? Colors.white : AppTheme.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
