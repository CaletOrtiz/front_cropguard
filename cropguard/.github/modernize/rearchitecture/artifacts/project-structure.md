# Project Structure

## Project type
This repository is a Flutter mobile application (Dart) with feature-first organization. It is a frontend-centric app that integrates with Supabase and a FastAPI backend for persistence and AI diagnosis.

## Top-level layout
- `lib/` — application code and dependency wiring
- `lib/core/` — shared theme, constants, error handling, network clients, and generic widgets
- `lib/features/` — domain-oriented modules with data, domain, and presentation responsibilities
- `lib/navigation/` — go_router entry points and app shell route composition
- `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/` — platform runners and native configuration
- `assets/` — static app content, including images and the asset manifest

## Layer architecture
The feature modules are organized by business or user flow, not by framework layer. Within each feature, the code follows a practical layered structure:
- `data/` — remote data sources and repository implementations
- `domain/` — entities, repositories, and use cases
- `presentation/` — bloc/cubit state containers, screens, widgets, and UI state logic

The app root in `lib/app.dart` wires providers and the `AuthBloc` into `MaterialApp.router`. The navigation shell in `lib/navigation/app_router.dart` configures the authenticated shell and the full-screen flows.

## Functional areas
- Auth: email/login/signup, Google OAuth, session checks
- Farms: farm CRUD, ownership scoping, crop and plot metadata
- Home: dashboard and summary cards
- Diagnosis: image intake and AI backend assessment
- History: previous diagnosis retrieval and detail viewing
- My Crops: crop and plot details
- Guide: static crop library browsing
- Profile: personal data and account settings

## Entry points
- `lib/main.dart` — initializes Supabase and FastAPI clients, then boots the app
- `lib/app.dart` — application provider registration and router configuration
- `lib/navigation/app_router.dart` — route graph and shell composition
- `lib/navigation/presentation/shell/main_shell.dart` — authenticated shell with bottom navigation

## Observed responsibility boundaries
The source code shows a hybrid architecture: a Flutter UI client, a feature-first organization, state management with Flutter BLoC, and repository-backed network integrations for both Supabase and FastAPI. The app is not organized around a backend monolith but around user-facing flows and data access adapters.
