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
