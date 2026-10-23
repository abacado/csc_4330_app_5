/// Beginner guides for every hobby in the shared catalog
/// (`features/profile/hobby_catalog.dart`) beyond the six hand-written ones
/// in `hobby_catalog.dart`. Keyed by hobby id.
library;

class HobbyGuide {
  const HobbyGuide(this.description, this.firstProject, this.starterItems);
  final String description;
  final String firstProject;
  final List<String> starterItems;
}

const hobbyGuides = <String, HobbyGuide>{
  // Art
  'watercolor': HobbyGuide(
    'Layer transparent washes of color and let the paper do some of the work. Student-grade paints are fine to start; good paper matters more than expensive paint.',
    'Paint a simple sunset by blending three wet-on-wet washes from yellow to red to purple.',
    [
      'Watercolor pan set',
      'Cold-press watercolor paper',
      'Round brush (size 8)',
      'Two water jars',
      'Paper towels',
    ],
  ),
  'drawing': HobbyGuide(
    'Train your eye by drawing what you actually see. A pencil and paper are all you need, and a few minutes a day builds skill quickly.',
    'Draw a coffee mug from life three times: a quick sketch, a careful outline, and a shaded version.',
    [
      'Sketchbook',
      'Graphite pencils (HB, 2B, 4B)',
      'Kneaded eraser',
      'Pencil sharpener',
      'Blending stump',
    ],
  ),
  'digital-art': HobbyGuide(
    'Paint and illustrate on a tablet or computer with unlimited undo. Learn layers and a few brushes before collecting hundreds of them.',
    'Recreate a favorite photo as a three-layer illustration: background, shapes, and details.',
    [
      'Drawing tablet or tablet with stylus',
      'Drawing app (free options like Krita work)',
      'Basic brush set',
      'Reference photos',
      'Screen protector for stylus grip',
    ],
  ),
  'calligraphy': HobbyGuide(
    'Write beautiful letters by controlling thick and thin strokes. Practice basic strokes before full letters, and slow down: speed comes later.',
    'Fill a page with downstrokes and upstrokes, then write your name in modern brush lettering.',
    [
      'Brush pen or dip pen with nib',
      'Smooth practice paper or marker pad',
      'Black ink (if using a dip pen)',
      'Guideline sheets',
      'Pencil and ruler',
    ],
  ),
  'pottery': HobbyGuide(
    'Shape clay by hand or on a wheel, then fire it into lasting pieces. Hand-building at home is an easy start; community studios offer wheels and kilns.',
    'Hand-build a pinch pot small enough to hold rings or keys.',
    [
      'Air-dry or studio clay',
      'Basic clay tool set',
      'Sponge',
      'Wire clay cutter',
      'Canvas or board to work on',
    ],
  ),
  'sculpture': HobbyGuide(
    'Build three-dimensional forms from clay, wire, wood, or found objects. Start small with forgiving materials like polymer clay.',
    'Sculpt a small animal figure about the size of your palm from polymer clay.',
    [
      'Polymer or modeling clay',
      'Sculpting tool set',
      'Aluminum foil for armatures',
      'Craft wire',
      'Work mat',
    ],
  ),
  'printmaking': HobbyGuide(
    'Carve or create a design once and print it many times. Linocut and block printing are easy to start at a kitchen table.',
    'Carve a simple leaf design into a soft block and print a set of greeting cards.',
    [
      'Soft carving block',
      'Lino cutter with blades',
      'Block printing ink',
      'Brayer (ink roller)',
      'Smooth printing paper',
    ],
  ),
  'scrapbooking': HobbyGuide(
    'Preserve photos and memories in decorated pages. Pick a theme for each page and keep layouts simple at first.',
    'Make a one-page spread for a recent trip or event using three photos and a short story.',
    [
      'Scrapbook album',
      'Acid-free cardstock',
      'Photo-safe adhesive',
      'Scissors or paper trimmer',
      'Stickers and pens',
    ],
  ),
  'origami': HobbyGuide(
    'Fold a single square of paper into animals, flowers, and shapes without cutting or gluing. Thin paper and sharp creases make everything easier.',
    'Fold a traditional crane, then try a jumping frog.',
    [
      'Origami paper (15 cm squares)',
      'Bone folder',
      'Diagram book or video tutorials',
      'Flat work surface',
      'Small box to keep finished pieces',
    ],
  ),
  'graphic-design': HobbyGuide(
    'Combine type, color, and images to communicate an idea. Learn alignment, contrast, and spacing before chasing trends.',
    'Design a poster for a real or imaginary event using two fonts and three colors.',
    [
      'Design software (free tools like Canva or Inkscape)',
      'Free font collection',
      'Sketchbook for thumbnails',
      'Color palette tool',
      'Reference folder of designs you like',
    ],
  ),

  // Fiber arts
  'knitting': HobbyGuide(
    'Create fabric from yarn with two needles and two basic stitches. Medium-weight, light-colored yarn shows your stitches clearly while you learn.',
    'Knit a garter-stitch dishcloth to practice casting on, the knit stitch, and binding off.',
    [
      'Medium-weight cotton or wool yarn',
      'Size 8 (5 mm) needles',
      'Scissors',
      'Yarn needle',
      'Stitch markers',
    ],
  ),
  'sewing': HobbyGuide(
    'Make and mend clothes and home goods by hand or machine. Start with straight seams on woven cotton, which is stable and easy to handle.',
    'Sew a simple drawstring bag with straight seams and a channel for the cord.',
    [
      'Sewing machine or hand-sewing needles',
      'Cotton fabric',
      'All-purpose thread',
      'Fabric scissors',
      'Pins and measuring tape',
    ],
  ),
  'embroidery': HobbyGuide(
    'Decorate fabric with stitched designs. A hoop keeps the fabric tight, and a handful of stitches covers most beginner patterns.',
    'Stitch your initials with a backstitch outline and a few French-knot flowers.',
    [
      'Embroidery hoop',
      'Cotton fabric',
      'Embroidery floss',
      'Embroidery needles',
      'Water-soluble marking pen',
    ],
  ),
  'quilting': HobbyGuide(
    'Piece fabric shapes together into layered, stitched quilts. Precut squares save cutting time while you learn accurate seams.',
    'Sew nine squares into a single nine-patch block.',
    [
      'Precut cotton fabric squares',
      'Rotary cutter and mat',
      'Quilting ruler',
      'Cotton thread',
      'Pins',
    ],
  ),
  'weaving': HobbyGuide(
    'Interlace yarn on a loom to make wall hangings, scarves, and fabric. A small frame loom is inexpensive and portable.',
    'Weave a small wall hanging with plain weave and a fringe at the bottom.',
    [
      'Frame or lap loom',
      'Cotton warp thread',
      'Assorted yarn',
      'Tapestry needle',
      'Weaving comb or fork',
    ],
  ),
  'macrame': HobbyGuide(
    'Tie decorative knots in cord to make plant hangers and wall art. A few knots, like the square knot, cover most patterns.',
    'Knot a simple plant hanger using square knots and a gathering knot.',
    [
      'Cotton macrame cord',
      'Wooden ring or dowel',
      'Scissors',
      'Measuring tape',
      'Comb for fringe',
    ],
  ),
  'spinning-yarn': HobbyGuide(
    'Twist raw fiber into your own yarn. A drop spindle is an affordable way to learn before investing in a spinning wheel.',
    'Spin and ply about 20 yards of yarn from wool roving on a drop spindle.',
    [
      'Drop spindle',
      'Wool roving',
      'Leader yarn',
      'Niddy-noddy or chair back for winding',
      'Small scale',
    ],
  ),

  // Making
  'woodworking': HobbyGuide(
    'Build useful things from wood with hand or power tools. Learn safe tool handling first, and always wear eye and ear protection.',
    'Build a small box or a cutting board from one board of pine or maple.',
    [
      'Safety glasses and ear protection',
      'Hand saw',
      'Clamps',
      'Sandpaper (80 to 220 grit)',
      'Wood glue',
    ],
  ),
  'jewelry-making': HobbyGuide(
    'Make earrings, bracelets, and necklaces from beads and wire. Basic loops and crimps are the foundation of most designs.',
    'Make a beaded bracelet and a matching pair of simple drop earrings.',
    [
      'Assorted beads',
      'Beading wire and crimp beads',
      'Round-nose and chain-nose pliers',
      'Wire cutters',
      'Clasps and ear wires',
    ],
  ),
  'candle-making': HobbyGuide(
    'Pour scented candles in jars and molds. Melt wax gently with a double boiler, never leave hot wax unattended, and keep a lid nearby for flare-ups.',
    'Pour two soy jar candles with a single scent.',
    [
      'Soy wax flakes',
      'Pre-tabbed wicks',
      'Heat-safe jars',
      'Double boiler or pouring pitcher',
      'Thermometer',
    ],
  ),
  'soap-making': HobbyGuide(
    'Make bars of soap for your home or as gifts. Melt-and-pour soap is safe for beginners; cold-process soap uses lye, which burns skin, so it needs gloves, goggles, and careful measuring.',
    'Make a batch of melt-and-pour soaps with one color and one scent.',
    [
      'Melt-and-pour soap base',
      'Silicone soap molds',
      'Soap-safe fragrance or essential oil',
      'Microwave-safe measuring cup',
      'Rubbing alcohol spray for bubbles',
    ],
  ),
  'leatherworking': HobbyGuide(
    'Cut, stitch, and tool leather into wallets, belts, and cases. Vegetable-tanned leather is easiest to cut and stamp.',
    'Hand-stitch a simple card wallet from two pieces of leather.',
    [
      'Vegetable-tanned leather',
      'Utility knife and cutting mat',
      'Stitching chisel or awl',
      'Waxed thread and needles',
      'Edge beveler',
    ],
  ),
  'model-building': HobbyGuide(
    'Assemble and paint detailed scale models of planes, cars, ships, and more. Snap-fit kits are a gentle first step before glue kits.',
    'Build and paint one beginner kit from start to finish.',
    [
      'Beginner model kit',
      'Sprue cutters',
      'Hobby knife',
      'Plastic cement',
      'Acrylic hobby paints and brushes',
    ],
  ),
  'miniature-painting': HobbyGuide(
    'Paint tiny figures for games or display. Thin your paints and build up color in layers rather than one thick coat.',
    'Prime and paint a single miniature with a base coat, a wash, and highlights.',
    [
      'Unpainted miniature',
      'Spray primer',
      'Acrylic miniature paints',
      'Small detail brushes',
      'Wet palette',
    ],
  ),
  '3d-printing': HobbyGuide(
    'Design or download models and print them in plastic. Start with well-tested files and learn bed leveling, which solves most early print failures.',
    'Print a calibration cube, then a useful object like a phone stand.',
    [
      'FDM 3D printer',
      'PLA filament',
      'Slicer software',
      'Scraper and flush cutters',
      'Glue stick or bed adhesive',
    ],
  ),
  'electronics': HobbyGuide(
    'Build circuits that blink, sense, and move. A breadboard lets you experiment without soldering, and a starter kit includes common parts.',
    'Build a circuit that turns on an LED when a button is pressed, then make it blink with a microcontroller.',
    [
      'Arduino-compatible starter kit',
      'Breadboard and jumper wires',
      'Assorted LEDs and resistors',
      'Multimeter',
      'USB cable',
    ],
  ),
  'robotics': HobbyGuide(
    'Combine motors, sensors, and code into machines that react to the world. Kits make the mechanical part easier so you can focus on behavior.',
    'Build a small wheeled robot that stops before bumping into a wall.',
    [
      'Robot car kit',
      'Microcontroller board',
      'Ultrasonic distance sensor',
      'Batteries and holder',
      'Small screwdriver set',
    ],
  ),
  'coding': HobbyGuide(
    'Write programs, games, and apps. Pick one language and one small project; finishing something teaches more than starting many.',
    'Write a number-guessing game that runs in the terminal or browser.',
    [
      'Computer',
      'Free code editor',
      'Beginner tutorial or course',
      'Notebook for ideas',
      'Version control account (like GitHub)',
    ],
  ),
  'home-improvement': HobbyGuide(
    'Fix, upgrade, and personalize your space. Learn to find studs and shut off water and power before starting projects.',
    'Patch a small hole in drywall and repaint the area.',
    [
      'Cordless drill and bits',
      'Tape measure and level',
      'Stud finder',
      'Screwdriver set',
      'Safety glasses',
    ],
  ),
  'car-restoration': HobbyGuide(
    'Bring older cars back to life one system at a time. Never work under a car supported only by a jack; use rated jack stands.',
    'Do a full fluid check and change your own oil and air filter.',
    [
      'Socket and wrench set',
      'Floor jack and jack stands',
      'Service manual for your car',
      'Oil drain pan',
      'Work gloves and safety glasses',
    ],
  ),
  'bike-repair': HobbyGuide(
    'Keep bicycles running smoothly and save on shop visits. Most fixes, like flats and brake adjustments, need only a few tools.',
    'Fix a flat tube and adjust your brakes.',
    [
      'Tire levers',
      'Patch kit or spare tube',
      'Floor pump with gauge',
      'Hex key set',
      'Chain lubricant',
    ],
  ),

  // Food & drink
  'cooking': HobbyGuide(
    'Make satisfying meals from scratch. Mastering a few techniques, like sautéing and roasting, lets you cook hundreds of recipes.',
    'Cook a one-pan dinner of roasted vegetables and a protein.',
    [
      'Chef\'s knife',
      'Cutting board',
      'Large skillet',
      'Sheet pan',
      'Measuring cups and spoons',
    ],
  ),
  'cake-decorating': HobbyGuide(
    'Turn cakes and cupcakes into edible art. Chilled cakes and a crumb coat make smooth frosting much easier.',
    'Frost a dozen cupcakes with two piping tips and two colors.',
    [
      'Piping bags',
      'Piping tip set',
      'Offset spatula',
      'Gel food coloring',
      'Turntable',
    ],
  ),
  'grilling': HobbyGuide(
    'Cook over fire with smoky flavor. Learn direct and indirect heat zones, and use a thermometer instead of guessing doneness.',
    'Grill burgers or vegetables using a two-zone fire.',
    [
      'Grill (charcoal or gas)',
      'Instant-read thermometer',
      'Long tongs and spatula',
      'Grill brush',
      'Chimney starter (for charcoal)',
    ],
  ),
  'fermentation': HobbyGuide(
    'Make sauerkraut, kimchi, and kombucha with helpful bacteria and yeast. Keep vegetables submerged under brine and toss anything moldy or foul-smelling.',
    'Ferment a jar of simple sauerkraut with cabbage and salt.',
    [
      'Wide-mouth glass jars',
      'Fermentation weights',
      'Non-iodized salt',
      'Airlock lids or cloth covers',
      'Kitchen scale',
    ],
  ),
  'coffee-brewing': HobbyGuide(
    'Brew café-quality coffee at home. Fresh beans and a consistent grind make the biggest difference.',
    'Brew the same beans two ways, like pour-over and French press, and compare.',
    [
      'Burr grinder',
      'Pour-over dripper or French press',
      'Kitchen scale',
      'Gooseneck kettle',
      'Fresh whole beans',
    ],
  ),
  'tea': HobbyGuide(
    'Explore green, black, oolong, and herbal teas. Water temperature and steeping time change the flavor more than you might expect.',
    'Taste one green and one black tea, steeped at their own temperatures and times.',
    [
      'Loose-leaf tea samples',
      'Teapot or infuser mug',
      'Kettle with temperature control',
      'Timer',
      'Airtight tea tins',
    ],
  ),
  'homebrewing': HobbyGuide(
    'Brew your own beer or cider. Sanitizing everything that touches the brew after boiling is the key to good results. Check local laws and brew only if you are of legal drinking age.',
    'Brew a one-gallon batch from a beginner extract kit.',
    [
      'One-gallon brewing kit',
      'No-rinse sanitizer',
      'Large stockpot',
      'Thermometer',
      'Bottles and caps',
    ],
  ),
  'canning': HobbyGuide(
    'Preserve jams, pickles, and sauces to enjoy all year. Follow tested recipes exactly; low-acid foods need a pressure canner to be safe.',
    'Make a small batch of strawberry jam in a water-bath canner.',
    [
      'Canning jars with new lids',
      'Large pot with rack',
      'Jar lifter',
      'Canning funnel',
      'Tested recipe book',
    ],
  ),

  // Garden & nature
  'houseplants': HobbyGuide(
    'Fill your home with greenery. Match each plant to your light, and water when the soil is dry rather than on a strict schedule.',
    'Grow a pothos from a cutting in water, then pot it in soil.',
    [
      'Easy plant (pothos or snake plant)',
      'Pots with drainage holes',
      'Indoor potting mix',
      'Watering can with narrow spout',
      'Pruning snips',
    ],
  ),
  'vegetable-gardening': HobbyGuide(
    'Grow food you can eat. Start with a few easy crops like lettuce, beans, and tomatoes in a sunny spot.',
    'Plant a small salad garden of lettuce, radishes, and herbs.',
    [
      'Seeds or seedlings',
      'Raised bed or large containers',
      'Garden soil and compost',
      'Trowel',
      'Watering hose or can',
    ],
  ),
  'composting': HobbyGuide(
    'Turn food scraps and yard waste into rich soil. Balance green scraps with brown materials like leaves and keep the pile moist.',
    'Start a compost bin and add a balanced mix of greens and browns for a month.',
    [
      'Compost bin or tumbler',
      'Kitchen scrap container',
      'Brown materials (leaves, cardboard)',
      'Garden fork',
      'Gloves',
    ],
  ),
  'beekeeping': HobbyGuide(
    'Keep a hive of honeybees for honey and pollination. Check local rules first, and take a class or find a mentor before your bees arrive. Anyone allergic to stings should talk to a doctor.',
    'Join a local beekeeping club and help inspect a mentor\'s hive.',
    [
      'Beekeeping suit or jacket with veil',
      'Gloves',
      'Hive tool',
      'Smoker',
      'Beginner hive kit',
    ],
  ),
  'bonsai': HobbyGuide(
    'Shape miniature trees through careful pruning and wiring. Patience matters: start with a hardy tree and learn its watering needs.',
    'Prune and style a nursery juniper into a simple bonsai shape.',
    [
      'Starter tree (juniper or ficus)',
      'Bonsai pot with drainage',
      'Bonsai soil mix',
      'Concave cutters',
      'Training wire',
    ],
  ),
  'foraging': HobbyGuide(
    'Find wild food like berries, greens, and mushrooms. Never eat anything you cannot identify with certainty, since some plants and mushrooms are deadly; learn with an expert and follow local rules.',
    'Join a guided foraging walk and identify five edible plants.',
    [
      'Regional field guide',
      'Basket or mesh bag',
      'Small knife',
      'Gloves',
      'Notebook for locations',
    ],
  ),
  'birdwatching': HobbyGuide(
    'Spot and identify birds in your backyard and beyond. Early mornings are busiest, and listening helps as much as looking.',
    'Identify ten bird species near your home and log them.',
    [
      'Binoculars (8x42 is a good start)',
      'Regional bird field guide or app',
      'Notebook',
      'Bird feeder',
      'Neutral-colored clothing',
    ],
  ),
  'astronomy': HobbyGuide(
    'Explore the night sky from planets to galaxies. Binoculars and a star map can show you a lot before you buy a telescope.',
    'Find the Moon\'s craters, Jupiter\'s moons, and one star cluster with binoculars.',
    [
      'Binoculars or beginner telescope',
      'Star chart or astronomy app',
      'Red flashlight',
      'Folding chair',
      'Warm layers',
    ],
  ),
  'aquariums': HobbyGuide(
    'Build a small underwater world. Cycle the tank for several weeks before adding fish so helpful bacteria can grow.',
    'Set up and cycle a planted 10-gallon tank.',
    [
      'Aquarium tank (10+ gallons)',
      'Filter and heater',
      'Water conditioner',
      'Water test kit',
      'Gravel and live plants',
    ],
  ),

  // Outdoors
  'hiking': HobbyGuide(
    'Explore trails at your own pace. Pick routes within your fitness level, check the weather, and tell someone where you are going.',
    'Hike a well-marked trail of three to five miles.',
    [
      'Comfortable hiking shoes',
      'Daypack',
      'Water bottle',
      'Trail map or app',
      'First aid kit',
    ],
  ),
  'camping': HobbyGuide(
    'Sleep under the stars and enjoy time outdoors. A campground with facilities is an easy first trip.',
    'Spend one night at a campground and cook a simple meal outdoors.',
    [
      'Tent',
      'Sleeping bag and pad',
      'Headlamp',
      'Camp stove',
      'Water and food storage',
    ],
  ),
  'rock-climbing': HobbyGuide(
    'Climb walls and rocks using strength, balance, and problem-solving. Start at a climbing gym with an intro class; rope climbing needs proper safety training.',
    'Take a bouldering or belay intro class at a local gym.',
    [
      'Climbing shoes',
      'Chalk bag and chalk',
      'Harness (for rope climbing)',
      'Gym day pass or membership',
      'Water bottle',
    ],
  ),
  'fishing': HobbyGuide(
    'Relax by the water and try to catch dinner or release your catch. Check local license rules and limits before you go.',
    'Catch a fish from a pier or lake shore with a simple bobber rig.',
    [
      'Rod and reel combo',
      'Fishing line',
      'Hooks, sinkers, and bobbers',
      'Bait or lures',
      'Fishing license',
    ],
  ),
  'kayaking': HobbyGuide(
    'Paddle calm lakes, rivers, and coastlines. Always wear a life jacket and start on flat water close to shore.',
    'Paddle a calm lake for an hour and practice turning and stopping.',
    [
      'Kayak (rental is fine)',
      'Paddle',
      'Life jacket (PFD)',
      'Dry bag',
      'Water bottle and sunscreen',
    ],
  ),
  'sailing': HobbyGuide(
    'Harness the wind to move across the water. A basic course teaches safety, knots, and how to handle a small boat.',
    'Take a beginner sailing lesson on a small dinghy.',
    [
      'Life jacket',
      'Non-slip shoes',
      'Sailing gloves',
      'Sunglasses and sunscreen',
      'Beginner sailing course',
    ],
  ),
  'surfing': HobbyGuide(
    'Ride waves on a board. A large soft-top board and small waves make learning much easier; swim near lifeguards.',
    'Take a lesson and stand up on a few small waves.',
    [
      'Soft-top surfboard',
      'Leash',
      'Wetsuit or rash guard',
      'Surf wax',
      'Reef-safe sunscreen',
    ],
  ),
  'scuba-diving': HobbyGuide(
    'Breathe underwater and explore reefs and wrecks. You must complete a certification course with a qualified instructor before diving.',
    'Try an introductory pool dive, then sign up for open water certification.',
    [
      'Mask',
      'Snorkel',
      'Fins',
      'Certification course',
      'Rental gear (regulator, BCD, tank)',
    ],
  ),
  'geocaching': HobbyGuide(
    'Use GPS coordinates to find hidden containers around the world. It turns any walk into a treasure hunt.',
    'Find three nearby geocaches using the official app.',
    [
      'Smartphone with geocaching app',
      'Pen for logbooks',
      'Small trade items',
      'Flashlight',
      'Comfortable shoes',
    ],
  ),
  'metal-detecting': HobbyGuide(
    'Search beaches, parks, and fields for buried coins and relics. Get permission and check local laws before digging, and fill every hole.',
    'Search a public beach (where allowed) and recover your first coin.',
    [
      'Beginner metal detector',
      'Headphones',
      'Pinpointer',
      'Digging trowel',
      'Finds pouch',
    ],
  ),

  // Sports & fitness
  'running': HobbyGuide(
    'Build fitness one step at a time. Start with run-walk intervals and add time gradually to avoid injury.',
    'Follow a couch-to-5K plan for two weeks.',
    [
      'Running shoes fitted at a store',
      'Moisture-wicking clothes',
      'Water bottle',
      'Running app or watch',
      'Reflective gear',
    ],
  ),
  'cycling': HobbyGuide(
    'Explore your area, commute, or train on two wheels. Always wear a helmet and learn basic road signals.',
    'Ride a 10-mile loop on a bike path.',
    [
      'Bicycle that fits you',
      'Helmet',
      'Front and rear lights',
      'Lock',
      'Water bottle and cage',
    ],
  ),
  'yoga': HobbyGuide(
    'Improve flexibility, strength, and focus. Beginner classes or videos teach safe alignment; never push into pain.',
    'Practice a 20-minute beginner flow three times in one week.',
    [
      'Yoga mat',
      'Two yoga blocks',
      'Strap',
      'Comfortable clothes',
      'Beginner class or video series',
    ],
  ),
  'weightlifting': HobbyGuide(
    'Get stronger with structured training. Learn proper form with light weights first, and consider a session with a coach.',
    'Learn the squat, deadlift, and press with an empty bar or light dumbbells.',
    [
      'Gym membership or dumbbells',
      'Training log',
      'Supportive flat shoes',
      'Water bottle',
      'Beginner program',
    ],
  ),
  'swimming': HobbyGuide(
    'A low-impact workout for the whole body. Lessons help at any age, and always swim where a lifeguard is present.',
    'Swim four lengths of a pool, resting as needed.',
    ['Swimsuit', 'Goggles', 'Swim cap', 'Towel', 'Kickboard'],
  ),
  'skateboarding': HobbyGuide(
    'Learn balance, pushing, and tricks on a board. Practice on smooth, flat ground and wear a helmet and pads while learning.',
    'Learn to push, turn, and stop smoothly in an empty parking lot.',
    [
      'Complete skateboard',
      'Helmet',
      'Knee and elbow pads',
      'Wrist guards',
      'Flat-soled shoes',
    ],
  ),
  'snowboarding': HobbyGuide(
    'Carve down snowy slopes. A lesson on your first day makes falling less frequent and learning much faster.',
    'Take a beginner lesson and link turns on a green run.',
    [
      'Rental board and boots',
      'Helmet',
      'Goggles',
      'Waterproof jacket and pants',
      'Gloves',
    ],
  ),
  'skiing': HobbyGuide(
    'Glide down mountains on two skis. Rentals and a group lesson are the easiest way to start.',
    'Take a beginner lesson and ski a green run without stopping.',
    [
      'Rental skis, boots, and poles',
      'Helmet',
      'Goggles',
      'Waterproof layers',
      'Warm socks and gloves',
    ],
  ),
  'ice-skating': HobbyGuide(
    'Glide on ice at a local rink. Bend your knees, keep your weight forward, and learn how to fall safely.',
    'Skate a full lap of the rink without holding the wall.',
    [
      'Ice skates (rentals are fine)',
      'Warm, flexible clothing',
      'Gloves',
      'Helmet for beginners',
      'Thick socks',
    ],
  ),
  'roller-skating': HobbyGuide(
    'Roll at a rink or along smooth paths. Protective gear makes the learning falls painless.',
    'Learn to stop with a toe or heel brake and skate a smooth lap.',
    [
      'Roller skates or inline skates',
      'Helmet',
      'Knee pads',
      'Wrist guards',
      'Elbow pads',
    ],
  ),
  'tennis': HobbyGuide(
    'A fun, social sport for singles or doubles. Start by rallying and learning basic forehand and backhand strokes.',
    'Rally 20 balls back and forth with a partner.',
    [
      'Tennis racket',
      'Tennis balls',
      'Court shoes',
      'Water bottle',
      'Access to a court',
    ],
  ),
  'pickleball': HobbyGuide(
    'An easy-to-learn paddle sport mixing tennis, badminton, and ping-pong. Many communities have drop-in games for beginners.',
    'Play your first game at a local drop-in session.',
    [
      'Pickleball paddle',
      'Pickleballs',
      'Court shoes',
      'Water bottle',
      'Local court schedule',
    ],
  ),
  'soccer': HobbyGuide(
    'The world\'s most popular sport. Practice passing and dribbling, then join a casual pickup game or rec league.',
    'Juggle the ball ten times in a row and join a pickup game.',
    [
      'Soccer ball',
      'Cleats',
      'Shin guards',
      'Water bottle',
      'Small practice cones',
    ],
  ),
  'basketball': HobbyGuide(
    'Shoot hoops alone or play pickup games with friends. Focus on form when shooting and practice dribbling with both hands.',
    'Make 25 free throws and practice a left-handed layup.',
    [
      'Basketball',
      'Court shoes',
      'Water bottle',
      'Access to a hoop',
      'Athletic clothing',
    ],
  ),
  'volleyball': HobbyGuide(
    'A team sport played on courts or sand. Learn to pass, set, and serve before spiking.',
    'Pass the ball back and forth with a partner 20 times without it dropping.',
    [
      'Volleyball',
      'Knee pads',
      'Court shoes',
      'Water bottle',
      'Local league or open gym',
    ],
  ),
  'golf': HobbyGuide(
    'Combine precision and patience on the course. A driving range and putting green are great places to start.',
    'Hit a bucket of balls at the range and play a par-3 course.',
    [
      'Starter set of clubs (or rentals)',
      'Golf balls',
      'Tees',
      'Golf glove',
      'Comfortable shoes',
    ],
  ),
  'disc-golf': HobbyGuide(
    'Throw discs into baskets on a course, often for free in public parks. Lightweight beginner discs fly straighter.',
    'Play nine holes at a local course.',
    [
      'Beginner disc set (putter, midrange, driver)',
      'Small bag',
      'Water bottle',
      'Course map or app',
      'Comfortable shoes',
    ],
  ),
  'martial-arts': HobbyGuide(
    'Build discipline, fitness, and self-defense skills. Try a free intro class at a few schools to find a style you enjoy.',
    'Attend three beginner classes in one style.',
    [
      'Comfortable athletic clothes',
      'Water bottle',
      'Mouth guard',
      'Hand wraps or gloves (for striking)',
      'Intro class pass',
    ],
  ),
  'dance': HobbyGuide(
    'Move to music in styles from ballet to salsa to hip-hop. Beginner classes break routines into small steps.',
    'Learn a short beginner routine from a class or video.',
    [
      'Comfortable clothes',
      'Dance shoes for your style',
      'Water bottle',
      'Mirror or phone to record',
      'Beginner class',
    ],
  ),
  'archery': HobbyGuide(
    'Focus and precision in every shot. Start at a range with an instructor who can fit you to the right bow and teach range safety.',
    'Take an intro lesson and group your arrows on the target.',
    [
      'Recurve bow (rental at first)',
      'Arrows matched to the bow',
      'Arm guard',
      'Finger tab',
      'Range time with instruction',
    ],
  ),

  // Music & performance
  'guitar': HobbyGuide(
    'Play songs on acoustic or electric guitar. Learning a few open chords lets you play hundreds of songs.',
    'Learn G, C, D, and E minor chords and play a full song.',
    [
      'Acoustic or electric guitar',
      'Clip-on tuner',
      'Picks',
      'Capo',
      'Guitar strap',
    ],
  ),
  'piano': HobbyGuide(
    'Learn melodies and harmony on the keys. A keyboard with weighted keys feels closest to a real piano.',
    'Play a simple song with your right hand, then add left-hand chords.',
    [
      'Digital keyboard (61+ keys)',
      'Sustain pedal',
      'Bench or stool',
      'Beginner method book',
      'Headphones',
    ],
  ),
  'drums': HobbyGuide(
    'Keep the beat for any band. Practice pads and electronic kits keep the noise down while you learn rhythms.',
    'Play a basic rock beat steadily to a metronome for one minute.',
    [
      'Drumsticks',
      'Practice pad',
      'Metronome app',
      'Ear protection',
      'Electronic or acoustic drum kit',
    ],
  ),
  'singing': HobbyGuide(
    'Use your voice as an instrument. Warm up gently, stay hydrated, and stop if your voice hurts.',
    'Learn a favorite song and record yourself singing it.',
    [
      'Warm-up exercises',
      'Water bottle',
      'Recording app',
      'Lyrics and backing tracks',
      'Choir or lesson info',
    ],
  ),
  'violin': HobbyGuide(
    'Play classical, folk, or fiddle music. A teacher helps with posture and bow hold, which are hard to fix later.',
    'Play a simple scale and "Twinkle Twinkle Little Star" in tune.',
    [
      'Violin sized for you (rentals are common)',
      'Bow and rosin',
      'Shoulder rest',
      'Tuner',
      'Beginner method book',
    ],
  ),
  'djing': HobbyGuide(
    'Mix songs together to keep a crowd dancing. Learn beatmatching and phrasing on a simple controller.',
    'Mix three songs together with smooth transitions.',
    ['DJ controller', 'DJ software', 'Headphones', 'Speakers', 'Music library'],
  ),
  'music-production': HobbyGuide(
    'Create, record, and mix your own tracks. Free software is enough to start; learn one program well.',
    'Produce a 30-second loop with drums, bass, and a melody.',
    [
      'Computer',
      'Digital audio workstation (free options exist)',
      'Headphones',
      'MIDI keyboard',
      'Audio interface',
    ],
  ),
  'theater': HobbyGuide(
    'Perform on stage or help backstage. Community theaters welcome beginners for acting, lighting, sets, and more.',
    'Audition for or volunteer with one community theater show.',
    [
      'Monologue to practice',
      'Script',
      'Comfortable rehearsal clothes',
      'Water bottle',
      'Local theater listings',
    ],
  ),
  'magic': HobbyGuide(
    'Amaze friends with illusions and sleight of hand. Practice in front of a mirror until each move is smooth.',
    'Learn three card tricks and perform them for a friend.',
    [
      'Deck of playing cards',
      'Beginner magic book',
      'Coins',
      'Mirror for practice',
      'Small close-up mat',
    ],
  ),

  // Photo & film
  'film-photography': HobbyGuide(
    'Shoot on film for a slower, thoughtful style. Each roll has a limited number of frames, so every shot counts.',
    'Shoot and develop one roll of 35mm film.',
    [
      '35mm film camera',
      'Rolls of film',
      'Spare camera batteries',
      'Lens cloth',
      'Local lab for developing',
    ],
  ),
  'videography': HobbyGuide(
    'Tell stories with video. A phone is enough to start; steady shots and good audio matter more than camera specs.',
    'Film and edit a one-minute video about your day.',
    [
      'Phone or camera',
      'Tripod or gimbal',
      'External microphone',
      'Editing software',
      'Small LED light',
    ],
  ),
  'drone-flying': HobbyGuide(
    'Capture aerial views and practice piloting. Learn and follow your local drone rules and registration requirements, and fly away from people and airports.',
    'Fly a beginner drone in an open field and capture a short video.',
    [
      'Beginner drone',
      'Spare batteries',
      'Propeller guards',
      'Memory card',
      'Drone rules for your area',
    ],
  ),

  // Games & puzzles
  'board-games': HobbyGuide(
    'Gather friends for strategy, teamwork, and laughs. Modern games range from five-minute fillers to epic campaigns.',
    'Host a game night with two easy-to-learn games.',
    [
      'Beginner-friendly board game',
      'Card sleeves',
      'Storage box',
      'Snacks',
      'Friends to play with',
    ],
  ),
  'tabletop-rpgs': HobbyGuide(
    'Tell collaborative stories with dice, characters, and imagination. A starter set includes everything for a first adventure.',
    'Play a one-shot adventure with three to five friends.',
    [
      'Starter set or rulebook',
      'Dice set',
      'Character sheets',
      'Pencils',
      'Snacks and a table',
    ],
  ),
  'video-games': HobbyGuide(
    'Explore worlds, solve puzzles, and play with friends. Set limits and take breaks to keep it a healthy hobby.',
    'Finish a short, well-reviewed indie game.',
    [
      'Console or PC',
      'Controller',
      'Headset',
      'Comfortable chair',
      'Game library',
    ],
  ),
  'chess': HobbyGuide(
    'A classic strategy game you can play anywhere. Learn basic openings and tactics like forks and pins.',
    'Play ten games online and review one of them.',
    [
      'Chess set',
      'Chess clock',
      'Online chess account',
      'Beginner tactics book',
      'Notebook for game notes',
    ],
  ),
  'puzzles': HobbyGuide(
    'Relax with jigsaw, crossword, or logic puzzles. Sorting edge pieces first makes jigsaws much easier.',
    'Complete a 500-piece jigsaw puzzle.',
    [
      '500-piece puzzle',
      'Puzzle mat or board',
      'Sorting trays',
      'Good lighting',
      'Crossword or sudoku book',
    ],
  ),
  'card-games': HobbyGuide(
    'From classic games to collectible card battles. Learn one game well, then try a local game night.',
    'Learn a classic game like rummy and teach it to a friend.',
    [
      'Deck of playing cards',
      'Card sleeves',
      'Deck box',
      'Rulebook or guide',
      'Score pad',
    ],
  ),
  'lego': HobbyGuide(
    'Build from instructions or invent your own creations. Sorting bricks by color or type speeds up custom builds.',
    'Build a small set, then rebuild the pieces into something new.',
    [
      'LEGO set',
      'Brick separator',
      'Sorting containers',
      'Baseplate',
      'Building idea book',
    ],
  ),

  // Collecting
  'trading-cards': HobbyGuide(
    'Collect and trade cards for sports, games, or characters. Protect valuable cards from the start.',
    'Organize your collection into a binder and trade for one card you want.',
    [
      'Penny sleeves',
      'Top loaders',
      'Binder with pocket pages',
      'Storage box',
      'Price guide or app',
    ],
  ),
  'coin-collecting': HobbyGuide(
    'Discover history through coins from different eras and countries. Handle coins by the edges, and never clean them.',
    'Complete a set of one coin type from different years.',
    [
      'Coin folders or albums',
      'Magnifying glass',
      'Cotton gloves',
      'Coin flips or holders',
      'Reference guide',
    ],
  ),
  'stamp-collecting': HobbyGuide(
    'Collect stamps from around the world and learn about history and art. Use tongs instead of fingers to protect stamps.',
    'Start a themed collection of 25 stamps.',
    [
      'Stamp album',
      'Stamp tongs',
      'Magnifying glass',
      'Stamp hinges or mounts',
      'Starter stamp packet',
    ],
  ),
  'vinyl-records': HobbyGuide(
    'Collect and listen to records with rich analog sound. Keep records clean and store them upright.',
    'Find five records at a local shop and give them a full listen.',
    [
      'Turntable',
      'Speakers',
      'Record brush',
      'Inner and outer sleeves',
      'Storage shelf or crates',
    ],
  ),
  'comics': HobbyGuide(
    'Read and collect comics, manga, and graphic novels. Start with a complete story arc or collected volume.',
    'Read a full story arc and bag and board your favorite issues.',
    [
      'Comic bags',
      'Backing boards',
      'Short storage boxes',
      'Reading list',
      'Library or local shop card',
    ],
  ),
  'action-figures': HobbyGuide(
    'Collect, display, and pose figures from your favorite series. A good shelf and some dust protection go a long way.',
    'Set up a themed display shelf with your figures.',
    [
      'Display shelf or case',
      'Figure stands',
      'Dust brush',
      'Storage boxes',
      'Collection tracker',
    ],
  ),
  'antiques': HobbyGuide(
    'Hunt for vintage treasures with history. Learn to spot reproductions and check condition before buying.',
    'Visit a flea market or antique shop and research one item\'s history.',
    [
      'Reference guide for one category',
      'Magnifying glass',
      'Measuring tape',
      'Notebook',
      'Soft cloths for cleaning',
    ],
  ),

  // Reading & writing
  'reading': HobbyGuide(
    'Discover new worlds and ideas through books. Libraries make it free, and book clubs add great conversation.',
    'Read one book a month for three months and keep short notes.',
    [
      'Library card',
      'Reading list',
      'Bookmark',
      'Reading light',
      'Reading journal',
    ],
  ),
  'writing': HobbyGuide(
    'Write stories, poems, or essays. A regular habit matters more than waiting for inspiration.',
    'Write a 1,000-word short story.',
    [
      'Notebook',
      'Pens',
      'Writing app or word processor',
      'Writing prompts',
      'Writing group or class',
    ],
  ),
  'journaling': HobbyGuide(
    'Reflect, plan, and record your days. Even five minutes of writing each night can build the habit.',
    'Journal every day for two weeks.',
    [
      'Notebook or dotted journal',
      'Pens',
      'Highlighters',
      'Ruler',
      'Prompt list',
    ],
  ),
  'languages': HobbyGuide(
    'Learn a new language to travel, connect, and think differently. Daily practice beats long, rare sessions.',
    'Learn 100 words and hold a two-minute conversation.',
    [
      'Language learning app',
      'Phrasebook',
      'Flashcards',
      'Notebook',
      'Conversation partner or class',
    ],
  ),

  // Other
  'cosplay': HobbyGuide(
    'Bring characters to life with costumes and props. Start with a closet cosplay assembled from clothes you already have.',
    'Put together one simple costume and wear it to an event or photoshoot.',
    [
      'Reference images of the character',
      'Base clothing',
      'Hot glue gun',
      'Craft foam',
      'Acrylic paints',
    ],
  ),
  'makeup': HobbyGuide(
    'Express yourself with color and technique. Clean brushes and patch-test new products to protect your skin.',
    'Recreate one tutorial look from start to finish.',
    [
      'Brush set',
      'Basic palette',
      'Primer',
      'Makeup remover',
      'Mirror with good lighting',
    ],
  ),
  'dog-training': HobbyGuide(
    'Build a strong bond with your dog through positive reinforcement. Short, frequent sessions work best.',
    'Teach your dog sit, stay, and come with treats and praise.',
    [
      'Small training treats',
      'Treat pouch',
      'Clicker',
      'Leash and collar or harness',
      'Training guide or class',
    ],
  ),
  'travel': HobbyGuide(
    'Explore new places near and far. Planning a few highlights while leaving room for surprises makes trips relaxing.',
    'Plan and take a day trip to a nearby town you\'ve never visited.',
    [
      'Carry-on bag',
      'Packing cubes',
      'Travel adapter',
      'Reusable water bottle',
      'Offline maps',
    ],
  ),
  'volunteering': HobbyGuide(
    'Give your time to causes you care about. Many groups welcome short, one-time shifts for newcomers.',
    'Sign up for one volunteer shift with a local organization.',
    [
      'Comfortable clothes',
      'Water bottle',
      'Calendar for shifts',
      'List of local organizations',
      'Friend to join you',
    ],
  ),
};
