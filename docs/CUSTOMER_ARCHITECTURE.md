# Customer application architecture

## Target configuration

[BusinessConfig](../LeafLaunch/Helpers/BusinessConfig.swift) reads target-specific constants emitted into Info.plist by [LeafLaunch.xcconfig](../Configurations/LeafLaunch.xcconfig). The existing LeafLaunch target is dedicated to store `ba6266df-513d-5b44-a58b-6e209284ceac`. Its public app key, `2fec1b48-f628-5ad6-8772-e15f432c8d14`, is the matching configuration UUID in `LeafLaunch-api/src/scripts/migrationData.ts`.

An app key identifies a `StoreAppConfiguration`; it is a public configuration identifier, not a Firebase token or secret. The API resolves branding, availability, age policy, minimum versions, and locations from it. Each additional business needs a separate Xcode target and xcconfig with its own IDs, logo asset, bundle identifier, signing, and Firebase plist. Include the shared Swift sources in that target. Do not choose tenants at runtime.

The initial target retains `com.lltemplate` and its existing Firebase registration. The API seed's iOS bundle identifier is `com.leaflaunch.demo`; device registration checks that field. Provision a matching Firebase app and bundle, or align the API configuration with this target, before validating push registration for that seeded app. Production API URLs also remain deployment-specific in Constants.

## LeafLaunch Mock target

Select the shared **LeafLaunch Mock** scheme to run the same customer experience without a backend or Firebase account. Its [configuration](../Configurations/LeafLaunch%20Mock.xcconfig) uses bundle ID `com.lltemplate.mock` and defines `LEAFLAUNCH_MOCK` in every build configuration, including Release. The target shares the app sources, assets, and packages; it excludes the Firebase plist, push entitlement, and Crashlytics upload phase. AppDelegate skips Firebase initialization and remote-notification registration for this target.

AppAssembler installs mock API, authentication, Firebase, analytics, and connectivity services into `Container.shared` before resolving ViewModels. Navigation, alerts, persistence, launch, and lifecycle services retain their normal behavior. Backend methods return local values through the existing APIServiceProtocol; no HTTP API requests are needed. Product images use deterministic Picsum URLs and require internet access.

All fixture data is in [MockModels.swift](../LeafLaunch/DI/Mock/MockModels.swift), including preview fixtures. It mirrors the first LeafLaunch-Web owner workspace, **High Standards**, Store `80000000-0000-4000-8000-000000000001`. Names, addresses, category assignments, product prices and availability, marketing copy, schedules, and loyalty entries come from `LeafLaunch-Web/src/services/demo/` and `strings.ts`. Random web record IDs are stable local IDs here, and relative schedules restart with the app. Only customer-visible locations, products, current promotions, and upcoming events are exposed; owner drafts and archived records stay outside the customer experience. The web workspace's unfinished launch readiness is treated as available so the complete customer flow can be exercised.

The app starts signed in as the owner's seeded customer **Alexis Mensah** (`alexis.mensah@example.com`), membership **LEAF2345**, with **1,235 points** and all 30 ledger entries. The Pearl District Shop and Capitol Hill Storefront share that business-wide balance and history. Old Town Shop starts without a location membership and supports joining. The real location picker and age-21 gate remain active. Sign out to exercise guest browsing, local login, signup, and password reset. Mock login accepts the form's valid inputs; signup creates a fresh customer with zero points and joins the selected location. Profile edits, joining, and account deletion mutate the in-memory mock session. Relaunching restores Alexis and the original fixtures; favorites, selected location, age approvals, and theme preferences persist in the mock app's separate defaults.

## Launch and navigation

`LeafLaunchApp.init` resolves UserDefaultsService and synchronously restores cached branding before resolving RootViewModel. RootScreen's `.task` starts `RootStartupService`, which waits for optional existing authentication, StoreSession bootstrap, and the splash callback. Guest access never depends on account creation. Bootstrap failures finish the splash gate and expose retry controls.

`StoreSessionService` owns business configuration and the selected validated location. It prioritizes cached location validation; failed or foreign-business IDs clear the cache and return to selection. Without a cached ID, a single location is selected automatically. The business-wide age gate uses location region for the approval key and a stable persisted guest identity when logged out. StoreDetails opens only after approval. Authentication changes reevaluate identity-specific approval.

Main observes session state and creates a new StoreDetails ViewModel and children for each store entry. Route-created product screens receive their location/product context before lifecycle work. Existing NavigationService and TabBarNavigationService own paths.

`StoreDetails/` has four feature/shared folders:

- `Overview/`: promotions, upcoming events, business summary, actual location, and opening hours.
- `Shop/`: category/subcategory filtering, search, menu sorting, paginated products, nested product details, and favorites.
- `Account/`: guest registration/login actions, customer profile, loyalty balance, and ledger history.
- `Shared/`: product wireframe rows and shared tab content.

Each screen owns one StateObject ViewModel. Child screens have dedicated paired files. Fetch-backed screens use `.task { [weak viewModel] in viewModel?.loadData(showHud: true) }` for initial/reappearance loading. First appearance installs navigation, tracks, and binds subscribers without duplicating the fetch. ViewModels present errors through focused AlertService helpers and dismiss each task's unique loading alert in `defer`; views do not use `.errorHandler`. Shared domain models are split in `Models/Customer/`; feature-specific models live in lower-case `models/` folders.

## Endpoint mapping

| Mobile operation | Existing API |
| --- | --- |
| Bootstrap | `GET /v1/public/apps/{appKey}/bootstrap?platform=IOS&version=...` |
| Validate location and hours | `GET /v1/public/locations/{locationId}/hours` |
| Categories | `GET /v1/public/locations/{locationId}/categories` |
| Product feed/details | `GET /v1/public/locations/{locationId}/products` and `.../products/{productId}` |
| Promotions/events | `GET /v1/public/locations/{locationId}/promotions` and `.../events` |
| Customer profile | `GET/PATCH/DELETE /v1/customer/account` |
| Register profile | `POST /v1/customer/locations/{locationId}/account` |
| Membership | `GET/POST /v1/customer/locations/{locationId}/membership` |
| Points history | `GET /v1/customer/locations/{locationId}/loyalty` |

Public calls explicitly bypass bearer authentication. Customer calls obtain a fresh Firebase bearer token and pass `x-app-key` plus location context where required. API envelopes retain page metadata; money uses Decimal, points preserve API strings, and product attribute values support the API's primitive/array union.

## Persistence and theme

Customer keys are scoped by business, app key, and bundle. They include the cached theme definition, `last_selected_location_id`, identity-keyed approved states, guest identity, and favorited product IDs. Logout preserves browsing preferences and removes existing sensitive security-pin state.

Rune Theme contains UI types and is not Codable. `CachedStoreTheme` therefore persists the validated API branding plus fallback preference and identity/schema metadata, and StoreThemeBuilder reconstructs a real Rune Theme synchronously. Theme preference changes preserve branding. No arbitrary cache expiration is added.

## API limitations

The backend calls a tenant `Store`, so Business uses the same Codable wire contract. No public endpoint returns the complete Store object; bootstrap supplies only its public name, branding, launch state, age policy, flags, and location summaries. The protected owner portal API is intentionally not used by guest mobile clients.

To support the requested full business/store ingestion, per-state age rules, radius payloads, and efficient server sorting, extend the public customer API contract. Until then, the app uses supplied business summaries and colors, Rune fallback radius/spacing tokens, and business-wide gating scoped to location states. Featured products use explicit load-more; selecting a sort loads all matching pages before ordering the menu. Loyalty balance and redemption/spending history are read from membership and ledger; this milestone does not invent a points-spending mutation.

No Xcode build or test run is part of this implementation, per repository instructions. Source parsing cannot prove SDK type compatibility or simulator behavior.
