import 'package:flutter/material.dart';

import '../profile/hobby_catalog.dart' as shared;
import 'hobby_guides.dart';

class Hobby {
  const Hobby(
    this.id,
    this.name,
    this.icon,
    this.description,
    this.firstProject,
    this.starterItems,
  );
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final String firstProject;
  final List<String> starterItems;
}

/// Every hobby in the shared catalog, in its order, each with a beginner
/// guide: the hand-written guides below for the original six, and
/// [hobbyGuides] for the rest. Hobbies without a guide are left out.
final List<Hobby> hobbyCatalog = [
  for (final h in shared.HobbyCatalog.all)
    ?(_originalById[h.id] ?? _fromGuide(h)),
];

final _originalById = {for (final h in _originalHobbies) h.id: h};

Hobby? _fromGuide(shared.Hobby hobby) => switch (hobbyGuides[hobby.id]) {
  final guide? => Hobby(
    hobby.id,
    hobby.name,
    hobby.icon,
    guide.description,
    guide.firstProject,
    guide.starterItems,
  ),
  null => null,
};

const _originalHobbies = [
  Hobby(
    'painting',
    'Painting',
    Icons.palette_outlined,
    'Experiment with color, shape, and texture. Start with a small set of watercolors and practice mixing a few colors before buying more supplies.',
    'Paint a postcard with three colors: a sky, a hill, and a tree.',
    [
      'Watercolor paints',
      'Watercolor paper',
      'One medium round brush',
      'Water cup',
      'Mixing palette or reusable plate',
    ],
  ),
  Hobby(
    'crochet',
    'Crochet',
    Icons.interests_outlined,
    'Turn yarn into fabric one stitch at a time. Light-colored, smooth yarn makes it easier to see your stitches while you learn.',
    'Practice a chain, then make a small square using single crochet.',
    [
      'Smooth medium-weight yarn',
      'Crochet hook matching the yarn label',
      'Scissors',
      'Yarn needle',
      'Stitch marker',
    ],
  ),
  Hobby(
    'gardening',
    'Gardening',
    Icons.local_florist_outlined,
    'Learn to care for plants with a small container garden. Choose a plant suited to your available sunlight and check the soil before watering.',
    'Plant a basil seedling in a pot and track its growth for a week.',
    [
      'Pot with drainage holes',
      'Potting mix',
      'Seeds or a small seedling',
      'Watering container',
      'Tray for drainage',
    ],
  ),
  Hobby(
    'photography',
    'Photography',
    Icons.camera_alt_outlined,
    'Practice noticing light, composition, and everyday details. A phone camera is enough to start; explore its settings before buying equipment.',
    'Photograph the same object from three angles using window light.',
    [
      'Phone or camera',
      'Charged battery',
      'Available storage',
      'Soft lens cloth',
    ],
  ),
  Hobby(
    'music',
    'Music',
    Icons.music_note_outlined,
    'Build confidence with short, regular practice. Choose one instrument or your voice and focus on rhythm and a few notes at a time.',
    'Clap a steady beat, then learn a short melody slowly.',
    [
      'Instrument or your voice',
      'Beginner exercise or song',
      'Metronome app or steady beat',
      'Practice notebook',
    ],
  ),
  Hobby(
    'baking',
    'Baking',
    Icons.bakery_dining_outlined,
    'Learn how measuring, mixing, and heat turn ingredients into something to share. Read the whole recipe before you begin and use the equipment it calls for.',
    'Choose a simple cookie recipe and measure all ingredients before mixing.',
    [
      'Beginner recipe and its ingredients',
      'Measuring cups/spoons or kitchen scale',
      'Mixing bowl and spoon',
      'Baking tray',
      'Oven mitts',
    ],
  ),
];

Hobby? hobbyById(String id) {
  for (final hobby in hobbyCatalog) {
    if (hobby.id == id) return hobby;
  }
  return null;
}
