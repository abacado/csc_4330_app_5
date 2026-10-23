# Listing UI / server handoff

The app now has a create form, one optional gallery photo, a preview, reusable
cards on Home, and a full detail page wired to the existing request sheet.
Editing and deleting are outside this version. No server code was changed.

## Existing server works now

Text-only listings can be posted with the existing POST /listings endpoint.
Fields: ownerId, hobbyId, title (80), description (1000), condition (40),
type (swap/giveaway), wantedItem (120; required by the form for swaps).
On failure the draft stays intact. After posting, use Home's Refresh button.

## Server additions (done)

The server now validates, stores, and returns `area` and `photoDataUrl`, and
the app posts them by default (`LISTING_MEDIA_ENABLED` defaults to `true`;
pass `--dart-define=LISTING_MEDIA_ENABLED=false` only against an older
server). Home also reloads listings by itself after a post and whenever the
Home tab is opened again, so Refresh is no longer required. Tests:
`server/test/listing_media_test.dart` and `test/home_reload_test.dart`.

The original request, for reference:

Optional fields in NewListing / Listing:

- `area`: trimmed city/area string, max 80 characters. Omit when empty.
- `photoDataUrl`: one JPG/PNG/WebP image encoded as a `data:image/...;base64,...`
  string. The decoded photo must be at most 512 KiB. Omit when absent.

Validate, persist, and return both fields from POST /listings, GET /listings,
and GET /listings/:id. Missing fields in old records must default to null.
Validate image signatures, MIME types, decoded size, and area length on the
server too; do not trust client validation. Do not allow arbitrary URL schemes.
Increase the request body limit from the current 64 KiB to 768 KiB (512 KiB
becomes about 683 KiB after base64 encoding). Keep a finite limit.

Before that work was complete, the default form allowed photo/area preview but
blocked posting with either field. It does not silently discard them. Plain
text listings still work. Once implemented and tested, enable with:

```powershell
flutter run --dart-define=LISTING_MEDIA_ENABLED=true
```

Add the same define to APK/web build commands (including CI) only after the
server supports the fields. If an enabled server still omits them in its response,
the app warns that the base listing was posted without them, preventing a false
success message and reminding the team not to retry blindly and create duplicates.

The photo picker is gallery-only. Android/browser selection uses image_picker;
iOS photo-library usage text is configured. Real device testing remains required.
Hobby IDs come from the profile HobbyCatalog so all available hobbies are supported.

## Smoke test after connecting

1. Create a text giveaway and a swap; confirm both appear after refreshing Home.
2. Add a photo/area, preview, then publish with media enabled. Restart server/app
   and check the image and area remain visible on Home and in details.
3. Confirm a different demo user sees the owner's profile and can send a request.
4. Accept the request as owner; completed listings disappear after refreshing Home.
5. Test an unavailable server, oversized/non-image file, canceled photo picker,
   and the narrow phone layout. No duplicate post should occur from repeated taps.
