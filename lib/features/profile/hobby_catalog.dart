/// Every hobby a user can pick, with search keywords.
///
/// Ids are lowercase slugs of the name (`painting`, `board-games`). The
/// Explore tab's hobbies (`features/hobbies/hobby_catalog.dart`) keep the same
/// names, ids, and icons here, so listings filed under them match profiles.
library;

import 'package:flutter/material.dart';

class Hobby {
  const Hobby(this.name, this.category, this.icon, [this.keywords = const []]);

  final String name;
  final String category;
  final IconData icon;

  /// Other words people might type for this hobby (supplies, synonyms).
  final List<String> keywords;

  String get id => HobbyCatalog.idFor(name);
}

/// A search result: the hobby and, when it matched on a keyword instead of
/// its name, which keyword.
class HobbyMatch {
  const HobbyMatch(this.hobby, {this.keyword});
  final Hobby hobby;
  final String? keyword;
}

abstract final class HobbyCatalog {
  static String idFor(String name) => name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  /// Shown before the user types anything; the Explore tab's hobbies.
  static const popularIds = [
    'painting',
    'crochet',
    'gardening',
    'photography',
    'music',
    'baking',
  ];

  static final Map<String, Hobby> _byId = {for (final h in all) h.id: h};

  static Hobby? byId(String id) => _byId[id];

  /// The hobby's name, or the raw id for hobbies no longer in the catalog.
  static String nameFor(String id) => _byId[id]?.name ?? id;

  static IconData iconFor(String id) =>
      _byId[id]?.icon ?? Icons.interests_outlined;

  /// Categories in display order, each with its hobbies sorted by name.
  static Map<String, List<Hobby>> get byCategory {
    final result = <String, List<Hobby>>{};
    for (final hobby in all) {
      (result[hobby.category] ??= []).add(hobby);
    }
    for (final list in result.values) {
      list.sort((a, b) => a.name.compareTo(b.name));
    }
    return result;
  }

  /// Hobbies matching [query], best first, like search-bar suggestions.
  ///
  /// Matching ignores case. A name that starts with the query beats one with
  /// a word that starts with it, which beats a keyword match, which beats the
  /// query appearing mid-word.
  static List<HobbyMatch> search(String query, {int limit = 8}) {
    final q = query.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    if (q.isEmpty) return const [];
    final scored = <(int, HobbyMatch)>[];
    for (final hobby in all) {
      final name = hobby.name.toLowerCase();
      final words = name.split(RegExp(r'[^a-z0-9]+'));
      String? keywordHit(bool Function(String) test) {
        for (final k in hobby.keywords) {
          if (test(k.toLowerCase())) return k;
        }
        return null;
      }

      final (int, HobbyMatch)? match;
      if (name.startsWith(q)) {
        match = (name == q ? 0 : 1, HobbyMatch(hobby));
      } else if (words.any((w) => w.startsWith(q))) {
        match = (2, HobbyMatch(hobby));
      } else if (keywordHit((k) => k.startsWith(q)) case final k?) {
        match = (3, HobbyMatch(hobby, keyword: k));
      } else if (name.contains(q)) {
        match = (4, HobbyMatch(hobby));
      } else if (hobby.category.toLowerCase().startsWith(q)) {
        match = (5, HobbyMatch(hobby));
      } else if (keywordHit((k) => k.contains(q)) case final k?) {
        match = (6, HobbyMatch(hobby, keyword: k));
      } else {
        match = null;
      }
      if (match != null) scored.add(match);
    }
    scored.sort((a, b) {
      final byScore = a.$1.compareTo(b.$1);
      return byScore != 0
          ? byScore
          : a.$2.hobby.name.compareTo(b.$2.hobby.name);
    });
    return [for (final (_, m) in scored.take(limit)) m];
  }

  static const all = [
    // Art & drawing
    Hobby('Painting', 'Art', Icons.palette_outlined, [
      'paint',
      'acrylic',
      'oil',
      'canvas',
      'brushes',
      'easel',
      'watercolor',
    ]),
    Hobby('Watercolor', 'Art', Icons.water_drop_outlined, ['paint', 'brushes']),
    Hobby('Drawing', 'Art', Icons.draw_outlined, [
      'sketching',
      'pencils',
      'charcoal',
      'sketchbook',
    ]),
    Hobby('Digital Art', 'Art', Icons.design_services_outlined, [
      'tablet',
      'stylus',
      'procreate',
      'illustration',
    ]),
    Hobby('Calligraphy', 'Art', Icons.edit_outlined, [
      'lettering',
      'hand lettering',
      'ink',
      'pens',
      'nibs',
    ]),
    Hobby('Pottery', 'Art', Icons.coffee_outlined, [
      'ceramics',
      'clay',
      'wheel',
      'kiln',
      'glaze',
    ]),
    Hobby('Sculpture', 'Art', Icons.architecture_outlined, ['clay', 'carving']),
    Hobby('Printmaking', 'Art', Icons.print_outlined, [
      'linocut',
      'block printing',
      'screen printing',
    ]),
    Hobby('Scrapbooking', 'Art', Icons.photo_album_outlined, [
      'stickers',
      'paper',
      'journaling',
    ]),
    Hobby('Origami', 'Art', Icons.category_outlined, ['paper folding']),
    Hobby('Graphic Design', 'Art', Icons.brush_outlined, ['logos', 'posters']),

    // Fiber arts
    Hobby('Crochet', 'Fiber Arts', Icons.interests_outlined, [
      'yarn',
      'hook',
      'amigurumi',
      'granny squares',
    ]),
    Hobby('Knitting', 'Fiber Arts', Icons.gesture_outlined, [
      'yarn',
      'needles',
      'wool',
      'sweaters',
    ]),
    Hobby('Sewing', 'Fiber Arts', Icons.content_cut_outlined, [
      'sewing machine',
      'fabric',
      'patterns',
      'thread',
    ]),
    Hobby('Embroidery', 'Fiber Arts', Icons.blur_on_outlined, [
      'cross stitch',
      'hoop',
      'floss',
      'needlepoint',
    ]),
    Hobby('Quilting', 'Fiber Arts', Icons.grid_view_outlined, [
      'fabric',
      'quilt',
      'batting',
    ]),
    Hobby('Weaving', 'Fiber Arts', Icons.view_week_outlined, ['loom', 'yarn']),
    Hobby('Macrame', 'Fiber Arts', Icons.link_outlined, ['cord', 'knots']),
    Hobby('Spinning Yarn', 'Fiber Arts', Icons.cyclone_outlined, [
      'spinning wheel',
      'drop spindle',
      'fiber',
      'wool',
    ]),

    // Making & building
    Hobby('Woodworking', 'Making', Icons.carpenter_outlined, [
      'wood',
      'saw',
      'carving',
      'furniture',
      'lathe',
    ]),
    Hobby('Jewelry Making', 'Making', Icons.diamond_outlined, [
      'beads',
      'beading',
      'wire',
      'silver',
    ]),
    Hobby('Candle Making', 'Making', Icons.local_fire_department_outlined, [
      'wax',
      'wicks',
      'soy',
    ]),
    Hobby('Soap Making', 'Making', Icons.soap_outlined, ['lye', 'molds']),
    Hobby('Leatherworking', 'Making', Icons.work_outline, [
      'leather',
      'tooling',
    ]),
    Hobby('Model Building', 'Making', Icons.build_outlined, [
      'scale models',
      'miniatures',
      'kits',
      'airbrush',
    ]),
    Hobby('Miniature Painting', 'Making', Icons.format_paint_outlined, [
      'warhammer',
      'miniatures',
      'figures',
    ]),
    Hobby('3D Printing', 'Making', Icons.view_in_ar_outlined, [
      'filament',
      'printer',
      'resin',
    ]),
    Hobby('Electronics', 'Making', Icons.memory_outlined, [
      'arduino',
      'raspberry pi',
      'soldering',
      'circuits',
    ]),
    Hobby('Robotics', 'Making', Icons.smart_toy_outlined, [
      'arduino',
      'robots',
    ]),
    Hobby('Coding', 'Making', Icons.code_outlined, [
      'programming',
      'software',
      'apps',
      'games',
    ]),
    Hobby('Home Improvement', 'Making', Icons.handyman_outlined, [
      'diy',
      'tools',
      'renovation',
    ]),
    Hobby('Car Restoration', 'Making', Icons.directions_car_outlined, [
      'cars',
      'mechanic',
      'auto',
    ]),
    Hobby('Bike Repair', 'Making', Icons.pedal_bike_outlined, ['bicycle']),

    // Food & drink
    Hobby('Baking', 'Food & Drink', Icons.bakery_dining_outlined, [
      'bread',
      'sourdough',
      'pastry',
      'cookies',
      'pans',
    ]),
    Hobby('Cooking', 'Food & Drink', Icons.restaurant_outlined, [
      'recipes',
      'kitchen',
      'cookware',
    ]),
    Hobby('Cake Decorating', 'Food & Drink', Icons.cake_outlined, [
      'frosting',
      'piping',
      'fondant',
    ]),
    Hobby('Grilling', 'Food & Drink', Icons.outdoor_grill_outlined, [
      'bbq',
      'barbecue',
      'smoking',
    ]),
    Hobby('Fermentation', 'Food & Drink', Icons.science_outlined, [
      'kombucha',
      'kimchi',
      'pickling',
      'sourdough',
    ]),
    Hobby('Coffee Brewing', 'Food & Drink', Icons.local_cafe_outlined, [
      'espresso',
      'pour over',
      'beans',
      'roasting',
    ]),
    Hobby('Tea', 'Food & Drink', Icons.emoji_food_beverage_outlined, [
      'loose leaf',
      'teapot',
    ]),
    Hobby('Homebrewing', 'Food & Drink', Icons.sports_bar_outlined, [
      'beer',
      'brewing',
      'cider',
    ]),
    Hobby('Canning', 'Food & Drink', Icons.kitchen_outlined, [
      'preserves',
      'jam',
      'jars',
    ]),

    // Garden & nature
    Hobby('Gardening', 'Garden & Nature', Icons.local_florist_outlined, [
      'plants',
      'seeds',
      'flowers',
      'soil',
      'tools',
    ]),
    Hobby('Houseplants', 'Garden & Nature', Icons.yard_outlined, [
      'plants',
      'cuttings',
      'succulents',
      'pots',
    ]),
    Hobby('Vegetable Gardening', 'Garden & Nature', Icons.grass_outlined, [
      'seeds',
      'tomatoes',
      'raised beds',
    ]),
    Hobby('Composting', 'Garden & Nature', Icons.eco_outlined, ['worms']),
    Hobby('Beekeeping', 'Garden & Nature', Icons.emoji_nature_outlined, [
      'bees',
      'honey',
      'hive',
    ]),
    Hobby('Bonsai', 'Garden & Nature', Icons.park_outlined, ['trees']),
    Hobby('Foraging', 'Garden & Nature', Icons.forest_outlined, [
      'mushrooms',
      'wild food',
    ]),
    Hobby('Birdwatching', 'Garden & Nature', Icons.visibility_outlined, [
      'birding',
      'binoculars',
      'birds',
    ]),
    Hobby('Astronomy', 'Garden & Nature', Icons.nights_stay_outlined, [
      'stargazing',
      'telescope',
      'stars',
    ]),
    Hobby('Aquariums', 'Garden & Nature', Icons.set_meal_outlined, [
      'fish',
      'fish tank',
      'aquascaping',
    ]),

    // Outdoors
    Hobby('Hiking', 'Outdoors', Icons.hiking_outlined, [
      'trails',
      'backpacking',
      'boots',
    ]),
    Hobby('Camping', 'Outdoors', Icons.cabin_outlined, [
      'tent',
      'sleeping bag',
    ]),
    Hobby('Rock Climbing', 'Outdoors', Icons.terrain_outlined, [
      'bouldering',
      'climbing',
      'harness',
      'chalk',
    ]),
    Hobby('Fishing', 'Outdoors', Icons.phishing_outlined, [
      'rod',
      'reel',
      'tackle',
      'fly fishing',
    ]),
    Hobby('Kayaking', 'Outdoors', Icons.kayaking_outlined, [
      'paddling',
      'canoe',
      'paddleboard',
    ]),
    Hobby('Sailing', 'Outdoors', Icons.sailing_outlined, ['boats']),
    Hobby('Surfing', 'Outdoors', Icons.surfing_outlined, [
      'surfboard',
      'waves',
    ]),
    Hobby('Scuba Diving', 'Outdoors', Icons.scuba_diving_outlined, [
      'snorkeling',
      'diving',
    ]),
    Hobby('Geocaching', 'Outdoors', Icons.map_outlined, ['gps', 'treasure']),
    Hobby('Metal Detecting', 'Outdoors', Icons.sensors_outlined, ['detector']),

    // Sports & fitness
    Hobby('Running', 'Sports & Fitness', Icons.directions_run_outlined, [
      'jogging',
      'marathon',
      'shoes',
    ]),
    Hobby('Cycling', 'Sports & Fitness', Icons.directions_bike_outlined, [
      'biking',
      'bicycle',
      'mountain biking',
    ]),
    Hobby('Yoga', 'Sports & Fitness', Icons.self_improvement_outlined, [
      'mat',
      'meditation',
      'pilates',
    ]),
    Hobby('Weightlifting', 'Sports & Fitness', Icons.fitness_center_outlined, [
      'gym',
      'weights',
      'strength',
    ]),
    Hobby('Swimming', 'Sports & Fitness', Icons.pool_outlined, ['pool']),
    Hobby('Skateboarding', 'Sports & Fitness', Icons.skateboarding_outlined, [
      'skateboard',
      'deck',
    ]),
    Hobby('Snowboarding', 'Sports & Fitness', Icons.snowboarding_outlined, [
      'snow',
      'board',
    ]),
    Hobby('Skiing', 'Sports & Fitness', Icons.downhill_skiing_outlined, [
      'snow',
      'skis',
    ]),
    Hobby('Ice Skating', 'Sports & Fitness', Icons.ice_skating_outlined, [
      'skates',
      'figure skating',
    ]),
    Hobby('Roller Skating', 'Sports & Fitness', Icons.roller_skating_outlined, [
      'skates',
      'rollerblading',
    ]),
    Hobby('Tennis', 'Sports & Fitness', Icons.sports_tennis_outlined, [
      'racket',
      'racquet',
    ]),
    Hobby('Pickleball', 'Sports & Fitness', Icons.sports_tennis_outlined, [
      'paddle',
    ]),
    Hobby('Soccer', 'Sports & Fitness', Icons.sports_soccer_outlined, [
      'football',
      'cleats',
    ]),
    Hobby('Basketball', 'Sports & Fitness', Icons.sports_basketball_outlined),
    Hobby('Volleyball', 'Sports & Fitness', Icons.sports_volleyball_outlined),
    Hobby('Golf', 'Sports & Fitness', Icons.sports_golf_outlined, ['clubs']),
    Hobby('Disc Golf', 'Sports & Fitness', Icons.sports_outlined, [
      'frisbee',
      'discs',
    ]),
    Hobby(
      'Martial Arts',
      'Sports & Fitness',
      Icons.sports_martial_arts_outlined,
      ['karate', 'judo', 'jiu jitsu', 'taekwondo', 'boxing'],
    ),
    Hobby('Dance', 'Sports & Fitness', Icons.nightlife_outlined, [
      'dancing',
      'ballet',
      'salsa',
      'hip hop',
    ]),
    Hobby('Archery', 'Sports & Fitness', Icons.adjust_outlined, [
      'bow',
      'arrows',
    ]),

    // Music & performance
    Hobby('Music', 'Music & Performance', Icons.music_note_outlined, [
      'instruments',
      'songs',
    ]),
    Hobby('Guitar', 'Music & Performance', Icons.music_note_outlined, [
      'bass',
      'ukulele',
      'strings',
      'amp',
      'pedals',
    ]),
    Hobby('Piano', 'Music & Performance', Icons.piano_outlined, [
      'keyboard',
      'keys',
      'synth',
    ]),
    Hobby('Drums', 'Music & Performance', Icons.album_outlined, [
      'percussion',
      'drum kit',
      'sticks',
    ]),
    Hobby('Singing', 'Music & Performance', Icons.mic_outlined, [
      'vocals',
      'choir',
      'karaoke',
    ]),
    Hobby('Violin', 'Music & Performance', Icons.queue_music_outlined, [
      'fiddle',
      'cello',
      'viola',
      'strings',
    ]),
    Hobby('DJing', 'Music & Performance', Icons.headphones_outlined, [
      'turntables',
      'mixing',
      'vinyl',
    ]),
    Hobby(
      'Music Production',
      'Music & Performance',
      Icons.graphic_eq_outlined,
      ['recording', 'beats', 'audio'],
    ),
    Hobby('Theater', 'Music & Performance', Icons.theater_comedy_outlined, [
      'acting',
      'drama',
      'improv',
    ]),
    Hobby('Magic', 'Music & Performance', Icons.auto_fix_high_outlined, [
      'card tricks',
      'illusions',
    ]),

    // Photo & film
    Hobby('Photography', 'Photo & Film', Icons.camera_alt_outlined, [
      'camera',
      'lenses',
      'tripod',
      'dslr',
    ]),
    Hobby('Film Photography', 'Photo & Film', Icons.camera_roll_outlined, [
      'film',
      'darkroom',
      '35mm',
    ]),
    Hobby('Videography', 'Photo & Film', Icons.videocam_outlined, [
      'filmmaking',
      'video',
      'youtube',
      'editing',
    ]),
    Hobby('Drone Flying', 'Photo & Film', Icons.flight_outlined, [
      'drones',
      'fpv',
      'aerial',
    ]),

    // Games & puzzles
    Hobby('Board Games', 'Games & Puzzles', Icons.casino_outlined, [
      'tabletop',
      'dice',
    ]),
    Hobby('Tabletop RPGs', 'Games & Puzzles', Icons.auto_awesome_outlined, [
      'dungeons and dragons',
      'd&d',
      'dnd',
      'dice',
    ]),
    Hobby('Video Games', 'Games & Puzzles', Icons.sports_esports_outlined, [
      'gaming',
      'console',
      'controller',
    ]),
    Hobby('Chess', 'Games & Puzzles', Icons.grid_on_outlined),
    Hobby('Puzzles', 'Games & Puzzles', Icons.extension_outlined, [
      'jigsaw',
      'crosswords',
      'sudoku',
    ]),
    Hobby('Card Games', 'Games & Puzzles', Icons.style_outlined, [
      'poker',
      'magic the gathering',
      'pokemon',
    ]),
    Hobby('LEGO', 'Games & Puzzles', Icons.view_module_outlined, [
      'bricks',
      'building sets',
    ]),

    // Collecting
    Hobby('Trading Cards', 'Collecting', Icons.collections_bookmark_outlined, [
      'pokemon',
      'baseball cards',
      'sports cards',
    ]),
    Hobby('Coin Collecting', 'Collecting', Icons.monetization_on_outlined, [
      'coins',
      'numismatics',
    ]),
    Hobby('Stamp Collecting', 'Collecting', Icons.local_post_office_outlined, [
      'stamps',
      'philately',
    ]),
    Hobby('Vinyl Records', 'Collecting', Icons.album_outlined, [
      'records',
      'turntable',
      'lp',
    ]),
    Hobby('Comics', 'Collecting', Icons.auto_stories_outlined, [
      'manga',
      'graphic novels',
    ]),
    Hobby('Action Figures', 'Collecting', Icons.toys_outlined, [
      'toys',
      'figures',
    ]),
    Hobby('Antiques', 'Collecting', Icons.watch_outlined, [
      'vintage',
      'thrifting',
    ]),

    // Reading & writing
    Hobby('Reading', 'Reading & Writing', Icons.menu_book_outlined, [
      'books',
      'book club',
      'novels',
    ]),
    Hobby('Writing', 'Reading & Writing', Icons.create_outlined, [
      'fiction',
      'poetry',
      'stories',
    ]),
    Hobby('Journaling', 'Reading & Writing', Icons.edit_note_outlined, [
      'bullet journal',
      'notebooks',
      'planners',
    ]),
    Hobby('Languages', 'Reading & Writing', Icons.translate_outlined, [
      'language learning',
      'spanish',
      'french',
    ]),

    // Other
    Hobby('Cosplay', 'Other', Icons.checkroom_outlined, ['costumes', 'props']),
    Hobby('Makeup', 'Other', Icons.face_outlined, ['cosmetics', 'brushes']),
    Hobby('Dog Training', 'Other', Icons.pets_outlined, ['dogs', 'pets']),
    Hobby('Travel', 'Other', Icons.travel_explore_outlined, [
      'luggage',
      'trips',
    ]),
    Hobby('Volunteering', 'Other', Icons.volunteer_activism_outlined),
  ];
}
