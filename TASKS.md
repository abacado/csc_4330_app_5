# HobbySwap delivery plan

Deadline: Friday, October 23, 2026, at 5 p.m. America/Chicago.

## First version

Demo: open the app, explore a hobby, create a listing, load it from the server,
request a swap, and view that request. Login stays a clearly labeled placeholder.
Borrowing, teaching, reviews, location matching, and friends are deferred.

The current scaffold provides theme, navigation, feature folders, starter hobby
pages, and honest placeholders. It does not save data or include a server yet.

## Four owners

| Owner | Scope | Main files | Done when |
| --- | --- | --- | --- |
| Student 1 (Abigail) | Home, hobby browsing/details, starter checklists, final integration | `lib/features/home/home_page.dart`, `lib/features/hobbies/` | A user can browse hobbies and view a starter checklist; all features work together. |
| Student 2 | Listing form, listing cards/details, validation, connect listing UI to server | `lib/features/listings/` | A valid swap/giveaway can be posted and reloaded from the server; loading and error states are visible. |
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
- [ ] Shared scaffold committed and pushed for teammates.
- [ ] Server component implemented with persistent data.
- [ ] Listings and requests connected to server.
- [ ] Automated build verified on GitHub (workflow already exists).
- [ ] App tested on a phone, including server failure behavior.
- [ ] Setup instructions include server launch and device connection.
- [ ] Demo video recorded and linked.
- [ ] Final task ownership/completion updated and submission delivered.

## Collaboration

Use short feature branches such as `codex/hobbies`, `codex/listings`,
`codex/profile-requests`, and `codex/server`. Merge through pull requests.
Coordinate edits to `app_shell.dart`, `app_theme.dart`, and `pubspec.yaml` with
Student 1. Keep feature changes inside the assigned folders where possible.
