# HobbySwap server

A small Dart server that stores listings and swap requests in a JSON file, so
data survives restarts. It uses only the Dart SDK that comes with Flutter;
there is nothing else to install.

## Run it

```bash
cd server
dart pub get          # first time only
dart run bin/server.dart
```

It prints something like:

```
HobbySwap server listening on port 8080
Data file: .../server/data/hobbyswap.json
Try: http://localhost:8080/health
Phones on the same Wi-Fi: http://192.168.1.20:8080
```

Press Ctrl-C to stop. Options: `--port 9000`, `--data path/to/file.json`
(or the `PORT` and `DATA_FILE` environment variables). To start over with no
data, stop the server and delete `server/data/hobbyswap.json`.

## Connect the app

The app reads the server address from `API_BASE_URL` at build time
(`lib/data/api_config.dart`).

| Running the app on | Command |
| --- | --- |
| Android emulator | `flutter run` (uses `http://10.0.2.2:8080`, the emulator's name for your computer) |
| Chrome, desktop, iOS simulator | `flutter run` (uses `http://localhost:8080`) |
| A real phone | `flutter run --dart-define=API_BASE_URL=http://<your computer's Wi-Fi IP>:8080` |

For a real phone:

1. Put the phone and the computer on the same Wi-Fi network. Campus networks
   often block device-to-device traffic. If the phone can't connect, use a
   phone hotspot and connect the computer to it.
2. Use the "Phones on the same Wi-Fi" address the server prints. A phone's own
   `localhost` is the phone, not your computer.
3. Check the address first by opening `http://<ip>:8080/health` in the
   phone's browser. You should see `{"status":"ok"}`.
4. If the browser can't load it, allow incoming connections for Dart on port
   8080 in your computer's firewall (Windows asks the first time you run the
   server; choose "Allow").

To bake an address into the APK built by GitHub Actions, set a repository
variable named `API_BASE_URL` (Settings → Secrets and variables → Actions →
Variables).

### Demo users

There are no real accounts yet. The app acts as `demo-user` unless built with
`--dart-define=DEMO_USER_ID=<name>`. To demo a swap between two people, run a
second phone or emulator with a different `DEMO_USER_ID`.

## API

All bodies are JSON. Errors look like `{"error": "title is required.", "field": "title"}`.
The server sets `id`, `status`, `createdAt`, and `updatedAt`.

| Method | Path | Body / query | Success |
| --- | --- | --- | --- |
| GET | `/health` | | `200 {"status":"ok"}` |
| GET | `/listings` | `?hobbyId=painting` (optional) | `200` list, newest first |
| GET | `/listings/:id` | | `200` listing |
| POST | `/listings` | `ownerId`, `hobbyId`, `title`, `description`, `condition`, `type` (`swap`/`giveaway`), `wantedItem` (optional) | `201` listing |
| GET | `/requests` | `?userId=demo-user` (required) | `200` requests the user sent or received |
| POST | `/requests` | `listingId`, `requesterId`, `message` | `201` request (`pending`) |
| PATCH | `/requests/:id` | `{"status": "accepted"}` or `"declined"` | `200` request |

Rules the server enforces:

- Requests must point to an existing, available listing that the requester
  doesn't own, and a user can have only one pending request per listing (409
  otherwise).
- Accepting a request marks the listing `completed` and declines the other
  pending requests for it.
- A request can be decided only once (409).

Limits: title 80 characters, description 1000, condition 40, wanted item 120,
message 500.

In the app, call these through `apiClient` from `lib/data/data.dart` instead
of making HTTP requests directly.

## Tests

```bash
cd server
dart test                 # unit + HTTP tests, including restart persistence
bash tool/smoke_test.sh   # starts the real server, restarts it, checks data
```

GitHub Actions runs these, plus formatting and analysis, before building the
APK.
