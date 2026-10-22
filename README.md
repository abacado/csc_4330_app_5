# csc_4330_hobby_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Running with the server

Listings and swap requests are stored by the HobbySwap server in `server/`.
Start it before running the app:

```bash
cd server && dart pub get && dart run bin/server.dart
```

Then run the app with `flutter run`. See [server/README.md](server/README.md)
for connecting a real phone, the API reference, and tests.

## Hobby guides and Home

Explore includes searchable guides for Painting, Crochet, Gardening, Photography,
Music, and Baking. Each has a first-project suggestion and a starter checklist.
Checks survive reopening a hobby during the current app session, but reset after
an app restart. Hobby content lives in `lib/features/hobbies/hobby_catalog.dart`.
Use its lowercase IDs (`painting`, `crochet`, `gardening`, `photography`, `music`,
`baking`) when creating listings so Home can show matching names and icons.

Home reads available listings from the shared API client. Tap Refresh after
creating or completing a listing. A listing opens a read-only summary; sending
requests belongs to the exchange feature still being implemented. Home shows an
error and retry button if the server is unavailable. There is no distance filter.

See `TASKS.md` for ownership and remaining integration work, and `DEMO.md` for
local setup and the recording outline.
