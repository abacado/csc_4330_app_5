# HobbySwap delivery plan

Deadline: Friday, October 23, 2026, at 5 p.m. America/Chicago.

## First version

Demo: open the app, explore a hobby, create a listing, load it from the server,
request a swap, and view that request. Login stays a clearly labeled placeholder.
Borrowing, teaching, reviews, location matching, and friends are deferred.

The app provides theme, navigation, searchable hobby guides, first-project ideas,
and interactive starter checklists. Checklist progress lasts for the current app
session. Home loads available listings from the shared API and supports refresh,
details, empty results, and retry after errors. Distance filtering is not implemented.
The server and API client are merged, with persistent listings/requests and tests.
Profile and Messages are included from the teammate's branch. Abigail's listing
form, photo preview, listing cards, and detail/request page are implemented locally
on `codex/listings-ui`. Text-only posting uses the existing API. Publishing photos
and city/area awaits the server additions in `LISTING_HANDOFF.md`.

## Four owners

| Owner | Scope | Main files | Done when |
| --- | --- | --- | --- |
| Student 1 (Abigail) | Home, hobby browsing/details, starter checklists, final integration | `lib/features/home/home_page.dart`, `lib/features/hobbies/` | A user can browse hobbies and view a starter checklist; all features work together. |
| Abigail (reassigned) | Listing form, listing cards/details, validation; server teammate handles media persistence | `lib/features/listings/` | Text swaps/giveaways post through the existing API; photo/area publishing follows server handoff. |
| Student 3 | Placeholder account/profile, local hobby selections, exchange requests UI | `lib/features/profile/`, `lib/features/messages/` | A demo user can view a profile and send/view swap requests. Full chat is optional. |
| Student 4 | Server, persistent storage, API client, server tests, automated build check | `server/`, `lib/data/`, `.github/workflows/` | Listings and requests survive a server restart; another device can connect; CI produces an APK. |

Everyone tests their own feature and records a short demo segment. Student 1
assembles the video; Student 2 supplies sample listings; Student 3 checks the task
list; Student 4 confirms the automated build. Rebalance if server work takes longer.

## Agree on these contracts before connecting features

Use string IDs. Use one fixed demo user until authentication is implemented.
The server owns timestamps and IDs. Agree on the demo user ID together.

- Hobby: `id`, `name`, `description`, `starterItems` (list of strings).
- Listing: `id`, `ownerId`, `hobbyId`, `title`, `description`, `condition`,
  `type` (`swap` or `giveaway`), `wantedItem` (optional), `status` (`available` or `completed`).
- Swap request: `id`, `listingId`, `requesterId`, `message`, `status`
  (`pending`, `accepted`, or `declined`).
- `GET /health`: server readiness.
- `GET /listings`: list listings; optionally filter by `hobbyId`.
- `POST /listings`: validate and persist a listing; return the saved listing.
- `GET /requests?userId=...`: requests for the demo user's incoming/outgoing exchanges.
- `POST /requests`: validate the listing and persist a request.
- `PATCH /requests/:id`: accept or decline a request.

Student 4 owns a shared API client; screens should call that client rather than
copying network logic. Configure the server URL outside widgets. A phone cannot
reach a computer server through the phone's own localhost. Document device setup.
Demo identities are not authentication; use sample data only for this version.

## Schedule

- Tuesday: agree on contracts, ownership, and server approach; branch from the shared scaffold.
- Wednesday: each feature works independently; server endpoints and persistence work.
- Thursday: merge and connect features; run the complete demo on a phone; fix failures.
- Friday morning: verify a fresh setup, automated APK build, and persistence; record video.
- Friday by 3 p.m.: freeze features and prepare submission, leaving two hours for fixes.

## Submission checklist

- [x] Git repository exists and local folder is connected.
- [x] Shared sage/peach theme and five-tab navigation.
- [x] Feature folders and navigation smoke test.
- [x] Shared scaffold committed and pushed for teammates.
- [x] Server component implemented with persistent data.
- [x] Searchable hobby guides, beginner projects, and interactive starter checklists implemented locally.
- [x] Home reads available listings from the server with loading, empty, error/retry, and detail states implemented locally.
- [ ] Abigail's latest feature changes committed and pushed.
- [ ] Listings and requests connected to server.
- [ ] Automated build verified on GitHub (workflow already exists).
- [ ] App tested on a phone, including server failure behavior.
- [x] Setup instructions include server launch and device connection (`server/README.md`).
- [ ] Demo video recorded and linked.
- [ ] Final task ownership/completion updated and submission delivered.

## Abigail: remaining integration and demo work

- [ ] Merge Student 2's listing creation and Student 3's profile/request screens when ready.
- [ ] Confirm a listing created in Post appears on Home after tapping Refresh.
- [ ] Run the complete create-listing/request/accept flow on a phone with two demo identities.
- [ ] Confirm server errors are understandable on the phone and data survives a restart.
- [ ] Confirm the final GitHub APK build succeeds.
- [x] Rebuild the Pages preview for Abigail's hobby/Home changes locally; push is still needed.
- [ ] Collect demo clips, assemble the final video, and add the video URL to README.

See `DEMO.md` for the recording outline and pre-recording checks. Automated widget
tests cover hobby searching, checklist navigation, listing errors/retry, and display
of available listings. Those checks do not replace the final phone demonstration.

Verification on October 22: all 14 Flutter tests passed and the release web build
succeeded. Analysis reported only the existing `use_null_aware_elements` info in
`lib/data/api_client.dart`; no analysis errors or warnings. The generated web files
were copied into `docs/`. No physical phone was connected for an end-to-end test.

## Collaboration

Use short feature branches such as `codex/hobbies`, `codex/listings`,
`codex/profile-requests`, and `codex/server`. Merge through pull requests.
Coordinate edits to `app_shell.dart`, `app_theme.dart`, and `pubspec.yaml` with
Student 1. Keep feature changes inside the assigned folders where possible.
