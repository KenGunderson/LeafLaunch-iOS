# LeafLaunch

Swift 6 / SwiftUI foundation using FactoryKit and Rune. Open `LeafLaunch.xcodeproj` and use the LeafLaunch, LeafLaunch Dev, or LeafLaunch Localhost scheme. The app bundle identifier is `com.lltemplate` in every configuration.

## Scaffolding

- Launch shows Home through the existing `NavigationService` and `AppRootView` navigation stack. Authentication is disabled in `Constants.Capabilities`. Startup does not wait for authentication or backend health while authentication is disabled.
- Statsig, voice transcription, permission services, StoreKit subscriptions, local notifications, onboarding, and What's New flows have been removed. Remote push notification handling and the App Store review action remain available.
- Tab screens, views, models, and `TabBarNavigationService` remain under their existing directories for a future child flow. Root launch does not create a tab controller.
- `AvailableTheme` contains only Light and Dark. Theme files and shared tokens live in `LeafLaunch/Services/DesignSystem`; colors, spacing, and radii follow `LeafLaunch-Web/src/app/theme.css`. Typography uses native system sans at the web size scale. The supplied default and dark app icons follow the device's icon appearance.
- Firebase uses `LeafLaunch/Resources/GoogleService-Info.plist`. Amplitude uses `Constants.Analytics.amplitudeAPIKey`; remote analytics collection retains the existing production-only behavior.
- API environments currently use `http://localhost:3000/api` as a configuration placeholder. Set provisioned LeafLaunch development and production endpoints in `Constants.URLs` before connecting the backend or shipping. Existing API models and screens are retained for later integration.

Git origin: `git@github.com:KenGunderson/LeafLaunch-iOS.git`.

## Verification

Use SwiftLint, Swift syntax parsing, `plutil -lint`, and `git diff --check` for static verification. Project guidance prohibits Xcode builds unless explicitly requested and prohibits adding tests. A successful build and device/simulator launch must be verified separately when requested.

## Documentation

- [Implementation best practices](docs/IMPLEMENTATION_BEST_PRACTICES.md) — application-layer UI composition, empty states, timelines, logging, and formatting conventions.
- [Ubiquitous components](docs/UBIQUITOUS_COMPONENTS_GLOBAL.md) — generated Rune component catalog.
