# Platform setup

## Maps (rider)

Create and restrict a Google Maps Platform key for the Android package `com.rideflow.rider_app` and the iOS bundle ID generated for `rider_app`. Enable Maps SDK for Android and Maps SDK for iOS, then configure the key using Google's platform setup instructions. The dark map styling is applied by `RiderMapPage`; do not commit API keys.

## Payments (driver)

Create consumable products with IDs `3h`, `6h`, `day`, and `week` in App Store Connect and Google Play Console. Set up signing, store agreements, sandbox testers and receipt verification on the backend. The current example activates a timer from the client purchase event; production entitlement must be granted only after trusted server verification.

## Driver location and background execution

Set `RIDE_WS_URL` at build time to the authenticated backend WebSocket endpoint. Implement token renewal and reconnect behavior against the backend contract before release. This starter streams while the app is active. Persistent background tracking needs platform-specific background location capability/permissions, a foreground service on Android, user-visible disclosure and lifecycle testing. Configure only after the service's privacy policy and operational needs are settled.

## Shared API client

`ride_core` exposes a Dio client with bearer access token injection and a refresh-on-401 hook. Supply secure storage callbacks and a refresh endpoint response with `accessToken` / `refreshToken`; call sites should handle expired sessions and surface user-facing errors.
