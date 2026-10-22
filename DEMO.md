# HobbySwap demo preparation

## What Abigail can show now

1. Open Home and point out the sage-and-peach styling and five tabs.
2. Tap Explore hobbies. Search for Photography; clear the search.
3. Open Painting, explain the beginner guide, and show the first project.
4. Check two starter supplies, go back, and reopen Painting to show progress retained.
   Checklist progress resets after restarting the app; it is not saved to an account.
5. With the server running, return Home and tap Refresh to load available supplies.
   Tap a listing to show its condition, description, and requested exchange.
   If there are no listings yet, the empty state is expected.

## Local setup

Start the server in a separate terminal:

```powershell
cd server
dart pub get
dart run bin/server.dart
```

From the project root in another terminal:

```powershell
flutter pub get
flutter run -d chrome
```

For a real phone use the computer's Wi-Fi address printed by the server:

```powershell
flutter run --dart-define=API_BASE_URL=http://YOUR_COMPUTER_IP:8080
```

Both devices must be able to communicate. Follow `server/README.md` for network
setup. No real user accounts or sensitive data should be used in this demo.

## Final team video outline (after the remaining screens merge)

- Abigail: introduce the purpose, hobby search, guide, and starter checklist.
- Student 2: create a swap/giveaway listing and show it reloaded on Home.
- Student 3: demonstrate a request using a second demo identity, then accept it
  as the owner. Confirm the completed listing no longer appears as available.
- Student 4: show server persistence after a restart and the successful automated
  APK build on GitHub.
- Abigail: assemble clips and add the final video link to README.

Aim for a short, continuous example with readable text. Do not claim placeholder
features are functional. Check the class's required video length before recording.

## Pages preview

The `docs/` folder contains a generated browser build, not the live Dart sources.
Rebuild it when changes are ready. GitHub Pages hosts the interface; online shared
listings require a separately hosted server reachable by browsers over HTTPS.
Without one, guides and checklists still work, and Home displays a retry message.
