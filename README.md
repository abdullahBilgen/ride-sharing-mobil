# RideFlow mobile

Flutter monorepo for the rider and driver clients. Both clients share `packages/ride_core` for the dark premium theme, domain models, Dio API client and reconnecting WebSocket client. Each app keeps its screens and workflows under its own `lib/features/` boundary as the product grows.

## Repository layout

```text
rider_app/                 Rider client (Google Maps booking/search screen)
driver_app/                Driver client (packages, online status and location stream)
packages/ride_core/        Shared theme, models, API and realtime primitives
docs/                      Integration and release notes
```

## Run locally

Requires Flutter and Dart. Run `flutter pub get` from each app directory, then `flutter run`. The rider map requires a Google Maps key configured for Android and iOS; see `docs/platform-setup.md`.

## Integration status

The repository provides the two critical app entry screens and the reusable foundations. They are UI/integration scaffolds: sample driver and fare details are demo data; authentication storage, production API URL, backend event contract, location sharing consent, store product configuration and server-side purchase validation must be connected for a live service. Store products use `3h`, `6h`, `day`, and `week` identifiers in this starter. Background location requires native platform configuration and permission disclosures; foreground location streaming is wired to the driver's WebSocket.

## Architecture direction

Use feature-first folders (`features/<feature>/{data,domain,presentation}`) inside each app. Keep entities/use cases independent from Flutter, place Dio and WebSocket implementations in data/infrastructure layers, and expose feature state via Riverpod providers/notifiers. `ride_core` should contain only concepts and infrastructure genuinely shared by both clients.
