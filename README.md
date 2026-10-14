# LeafLaunch

LeafLaunch is a Swift 6 / SwiftUI customer app using FactoryKit and Rune. Each live target belongs to one Store and its public StoreAppConfiguration key. The app supports guest browsing, location selection, age approval, a paginated product catalog, favorites, customer accounts, and loyalty history.

## Run configurations

Open [LeafLaunch.xcodeproj](LeafLaunch.xcodeproj). The live target uses the existing `com.lltemplate` bundle and Firebase registration; the offline target uses `com.lltemplate.mock`.

| Scheme | Run configuration | Backend |
| --- | --- | --- |
| LeafLaunch | Debug | Target Development API URL |
| LeafLaunch Dev | Development | Target Development API URL |
| LeafLaunch Localhost | Localhost | `http://localhost:3000/api` |
| LeafLaunch Mock | Debug | In-memory fixtures; no backend or Firebase account |

[LeafLaunch.xcconfig](Configurations/LeafLaunch.xcconfig) supplies Store identity, app key, bundle, and environment URLs through Info.plist. Development uses `http://localhost:3000/api`. Live Release builds use Production, which requires a confirmed HTTPS value for `LEAFLAUNCH_PRODUCTION_API_URL`; it is currently unset and cannot fall back to localhost.

The mock scheme uses the High Standards customer fixtures, starts signed in as Alexis Mensah, and retains its existing 21+ gate. Sign out to browse as a guest. See the [mock target contract](docs/CUSTOMER_ARCHITECTURE.md#leaflaunch-mock-target) for fixture behavior and persistence.

## Customer flow

Startup synchronously restores the cached Rune theme, resolves existing authentication when present, and fetches public launch data. StoreSessionService validates the target Store and selected location before opening the Store tabs. A required location policy presents a non-dismissible age modal; guest approvals remain separate from authenticated customer acceptances. The live target fixture requires 18+ approval throughout the US.

Store tabs provide Overview, Shop, Favorites, and Account. Store Info uses public Store/contact and location data. Search, filters, and sorting run through the paginated API; load-more retains server order. Colors, fonts, media references, and radius roles share the canonical branding definition and target-scoped cache. Screens retain structural wireframes and existing Rune/app components.

## Verification

Follow [AGENTS.md](AGENTS.md#verify-and-maintain): inspect changed contracts, call sites, task ownership, configuration, and explicit target membership. Permitted static checks include Swift syntax parsing, focused Foundation model typechecking, `plutil -lint`, and `git diff --check`. Do not run Xcode builds or tests unless explicitly authorized. Static checks do not establish device behavior, push delivery, or live backend integration.

## Documentation

- [Customer architecture](docs/CUSTOMER_ARCHITECTURE.md): targets, launch, endpoint mapping, persistence, and theme reconstruction.
- [Customer workflow](UX-CONTRACT.md): navigation, gating, async state, and recovery ownership.
- [Design contract](DESIGN.md): structural wireframes, native controls, and Rune token ownership.
- [Implementation best practices](docs/IMPLEMENTATION_BEST_PRACTICES.md): Swift conventions, lifecycle, tasks, errors, and integration parity.
- [SwiftUI feature example](docs/SWIFTUI_FEATURE_EXAMPLE.md): worked formatting and feature-wiring reference.
- [Rune component catalog](docs/UBIQUITOUS_COMPONENTS_GLOBAL.md): component discovery; verify signatures against the pinned package source.
