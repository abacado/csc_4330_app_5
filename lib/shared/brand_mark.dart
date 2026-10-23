import 'package:flutter/material.dart';

/// A leaf and exchange arrows, drawn with bundled Material icons.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 38});
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'HobbySwap leaf and swap arrows',
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(size * .32),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * .12,
            child: Icon(
              Icons.eco_outlined,
              color: Colors.white,
              size: size * .52,
            ),
          ),
          Positioned(
            bottom: size * .08,
            child: Icon(
              Icons.swap_horiz,
              color: const Color(0xFFF2B5A7),
              size: size * .53,
            ),
          ),
        ],
      ),
    ),
  );
}
