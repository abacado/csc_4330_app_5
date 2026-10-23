# HobbySwap

A Flutter phone app for discovering hobbies, sharing supplies through swaps or
giveaways, and sending exchange requests. The app uses a Dart API server that
saves profiles, listings, photos, and requests to a local JSON file.

## Run the complete app locally (recommended for grading and demos)

**Start both the server and the app. Keep their terminals open while testing.**
The GitHub Pages site is an interface preview; it does not run the Dart server.
For the complete working demo, use the local Chrome window opened by Flutter.

### Prerequisites

- Flutter SDK installed and available in your terminal (Dart is included).
- Google Chrome for the simplest local demo.
- Git to download the project; VS Code is optional.
- Internet access for the first dependency download.

Check the Flutter installation:

```powershell
flutter doctor
```

Fix any issues relevant to the platform you are using. Android tools are needed
for an Android demo, but not for the Chrome demo below.

### 1. Open the project

For a new checkout:

```powershell
git clone https://github.com/abacado/csc_4330_app_5.git
cd csc_4330_app_5
```

If you already have the project open in VS Code, open **Terminal > New Terminal**
in the folder containing `pubspec.yaml`, `lib`, and `server`. Your existing folder
may be named `csc_4330_hobby_app`; that is fine.

### 2. Terminal 1: start the server

From the project folder:

```powershell
cd server
dart pub get
dart run bin/server.dart
```

Wait for `HobbySwap server listening on port 8080`. Leave this terminal running.
Open http://localhost:8080/health in your browser. A healthy server returns:

```json
{"status":"ok"}
```

The server saves changes in `server/data/hobbyswap.json`, which is created on
first use. Existing data is loaded when the server restarts. This file is local
to the computer running the server; it is not a shared cloud database.

### 3. Terminal 2: start the app

Open a **second terminal in the project folder**, not inside `server`:

```powershell
flutter pub get
flutter run -d chrome
```

Use the Chrome window that Flutter opens. It connects to the running server at
`http://localhost:8080`. The first run can take a few minutes.

If the second terminal opened inside `server`, run `cd ..` first.

### 4. Try the features

1. Open **Profile** and create a demo profile.
2. Explore a hobby, read its guide, and check off starter supplies.
3. Open **Post**, add an item name, hobby, condition, description, and offer type.
   A swap also needs an exchange preference. One photo and a city/area are optional.
4. Preview and post the listing. Open **Home**; use Refresh if needed.
5. Tap a listing to see its details. A different demo user can send a request.
6. View received/sent requests in **Messages** and accept or decline as the owner.

The server starts without sample listings or profiles. An empty Home is expected
until someone posts. Checklist progress lasts only for the current app session;
profiles, listings, and exchange requests are saved by the server.

### Optional: demonstrate two users

Accounts are demo identities, not real login accounts. The default ID is
`demo-user`, so two default builds act as the same person and cannot request
one another's items.

Keep the server and first app running. In a third terminal at the project root:

```powershell
flutter run -d chrome --dart-define=DEMO_USER_ID=demo-user-2
```

Create a different profile in this second app. Request an item owned by the first
user, then return to the first app's Messages tab and refresh to see the request.

### Stop the demo

Press `q` in each terminal running `flutter run`. Press **Ctrl+C** in the server
terminal. Restart using the same commands to load the saved server data.

## Run on an Android phone or emulator

Start the server as described above. Enable USB debugging on your Android phone,
connect it to the computer, and approve the debugging prompt, or start an emulator.
Find the available device IDs:

```powershell
flutter devices
```

For an Android emulator, replace `YOUR_EMULATOR_ID` with its actual ID:

```powershell
flutter run -d YOUR_EMULATOR_ID
```

The emulator uses `http://10.0.2.2:8080` to reach the computer's server.

For a physical Android phone, put the computer and phone on the same reachable
Wi-Fi network. The server prints a `Phones on the same Wi-Fi` address. Replace
`YOUR_PHONE_ID` and the example IP below with your device ID and that address:

```powershell
flutter run -d YOUR_PHONE_ID --dart-define=API_BASE_URL=http://192.168.1.20:8080
```

First check `http://192.168.1.20:8080/health` in the phone's browser using your
actual computer IP. It must return `{"status":"ok"}`. If it cannot connect,
check Windows Firewall access for Dart/port 8080 and whether the network blocks
communication between devices. A phone hotspot can be used for the demo.

An APK must also be built with the correct server address for a physical phone:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.1.20:8080
```

The APK is at `build/app/outputs/flutter-apk/app-release.apk`. Keep the server
running while using it. GitHub's APK build accepts a repository variable named
`API_BASE_URL`; without an override, its default Android address targets an
emulator, not a physical phone. APK files install on Android, not iPhone.

## Troubleshooting

| Problem | What to check |
| --- | --- |
| `flutter` or `dart` is not recognized | Install Flutter, add its `bin` folder to PATH, and reopen the terminal. |
| Server connection error | Confirm Terminal 1 is still running and `/health` responds. |
| Port 8080 is already in use | An existing server may already be running. Check `/health` and stop an old instance if necessary. |
| `No pubspec.yaml file found` | Run app commands in the project root, or server commands inside `server`. |
| Home is empty | Post a listing first, then refresh. Completed items are not shown as available. |
| Cannot request your own listing | Use the second demo identity described above. |
| Website opens but saving/loading fails | Use the local app/server instructions. GitHub Pages does not host the API. |
| Phone cannot connect | Use the computer's Wi-Fi IP, check `/health` on the phone, and check firewall/network access. |

For a different server port, start it with `dart run bin/server.dart --port 9000`
and run the app with `--dart-define=API_BASE_URL=http://localhost:9000`.

## Tests and automated build

From the project root:

```powershell
flutter analyze --no-fatal-infos
flutter test
```

For the separate server package:

```powershell
cd server
dart pub get
dart test
```

GitHub Actions runs server checks, app checks, and a release Android build.
In the repository's **Actions** tab, open a successful Android build and download
the **release-apk** artifact to get the zipped APK. See `.github/workflows/android-ci.yml`.

## GitHub Pages preview

Preview: https://abacado.github.io/csc_4330_app_5/

Pages publishes the generated files in `docs/` on `main`. It hosts the interface;
it does not start the Dart server. The current web build uses localhost, so this
link is not a complete public multi-user deployment. Use the local instructions
above for a reliable full-feature demo.

After merging app changes into main, rebuild the browser preview:

```powershell
powershell -File tool/update_pages.ps1
```

Review and commit the updated `docs/` files, then push main and wait for the Pages
deployment. Hosting a public server is not required for the local demo. A future
public deployment would need a reachable HTTPS API, persistent server storage,
and a web build configured with that server's `API_BASE_URL`.

## Project notes

- Explore has six beginner guides and starter checklists. Profile hobby selection
  and the listing form use the larger hobby catalog.
- There is no distance filter; city/area is entered as text.
- These are demo accounts; use sample data for the class presentation.
- [Server setup and API reference](server/README.md)
- [Task list and team responsibilities](TASKS.md)
- [Demo recording outline](DEMO.md)
- [Listing UI and server handoff](LISTING_HANDOFF.md)
