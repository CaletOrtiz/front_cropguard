# Tech Stack

## Runtime and language
- Flutter SDK (`pubspec.yaml`) with Dart language support
- SDK constraint: `^3.12.2` in `pubspec.yaml`
- Application name: `kroppi`

## Framework and libraries
- `flutter_bloc` 9.1.1 — state management for auth and diagnosis flows
- `go_router` 17.2.0 — route configuration and navigation
- `supabase_flutter` 2.18.0 — auth, session state, and database queries
- `dio` 5.11.1 — HTTP client used for FastAPI backend calls
- `image_picker` 1.2.3 — camera and gallery selection
- `google_sign_in` 7.2.0 — Google OAuth for the auth flow
- `google_fonts` 8.2.1 — typography styling
- `equatable` 3.0.0 — state value comparison
- `fpdart` 1.2.0 — functional error handling utilities
- `http_parser` 4.1.2 — content-type parsing for image file metadata

## Native and platform runtime
- Android, iOS, Linux, macOS, Windows, and web platform runners are present in the repository
- App-level runtime is managed by Flutter and the platform runners under the respective folders

## External integrations
- Supabase auth and database queries are used for farm ownership, profiles, and session-based access control
- A FastAPI backend is consumed via a configured Dio client for crop diagnosis endpoints
- Google OAuth client IDs are read from environment variables and defaults in the auth service

## Existing stack only
This file is intentionally limited to the stack present in the repository and does not prescribe a target migration or replacement architecture.
