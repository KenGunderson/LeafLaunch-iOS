# Customer application architecture

## Target configuration

[BusinessConfig](../LeafLaunch/Helpers/BusinessConfig.swift) reads target-specific constants emitted into Info.plist by [LeafLaunch.xcconfig](../Configurations/LeafLaunch.xcconfig). The existing LeafLaunch target is dedicated to store `ba6266df-513d-5b44-a58b-6e209284ceac`. Its public app key, `2fec1b48-f628-5ad6-8772-e15f432c8d14`, is the matching configuration UUID in `LeafLaunch-api/src/scripts/migrationData.ts`.

An app key identifies a `StoreAppConfiguration`; it is a public configuration identifier, not a Firebase token or secret. The API resolves branding, availability, age policy, minimum versions, and locations from it. Each additional business needs a separate Xcode target and xcconfig with its own IDs, logo asset, bundle identifier, signing, and Firebase plist. Include the shared Swift sources in that target. Do not choose tenants at runtime.

The target retains its provisioned `com.lltemplate` bundle identifier. Its Firebase plist and API StoreAppConfiguration fixture use project `leaflaunch-cfd63` and iOS app `1:198677595159:ios:34290bed90bb041cf94852`. The existing local API service-account project agrees with this registration; credentials remain outside source control. Device registration still requires the configured platform identifier and app key. Deployed Firebase credentials and APNs delivery must be verified in the deployment environment.

Target-specific `LEAFLAUNCH_DEVELOPMENT_API_URL` and `LEAFLAUNCH_PRODUCTION_API_URL` values flow through Info.plist and BusinessConfig. Debug and Development use the supplied `http://localhost:3000/api` backend; Localhost and custom environments remain deliberate development choices. Production requires an absolute HTTPS base URL, rejects loopback hosts, and has no localhost fallback. Its URL remains empty until a confirmed deployment value is supplied. Missing or malformed environment metadata defaults to Production, so it fails closed. The mock target makes no HTTP calls and needs neither URL.

## LeafLaunch Mock target

Select the shared **LeafLaunch Mock** scheme to run the same customer experience without a backend or Firebase account. Its [configuration](../Configurations/LeafLaunch%20Mock.xcconfig) uses bundle ID `com.lltemplate.mock` and defines `LEAFLAUNCH_MOCK` in every build configuration, including Release. The target shares the app sources, assets, and packages; it excludes the Firebase plist, push entitlement, and Crashlytics upload phase. AppDelegate skips Firebase initialization and remote-notification registration for this target.

AppAssembler installs mock API, authentication, Firebase, analytics, and connectivity services into `Container.shared` before resolving ViewModels. Navigation, alerts, persistence, launch, and lifecycle services retain their normal behavior. Backend methods return local values through the existing APIServiceProtocol; no HTTP API requests are needed. Product images use deterministic Picsum URLs and require internet access.

All fixture data is in [MockModels.swift](../LeafLaunch/DI/Mock/MockModels.swift), including preview fixtures. It mirrors the first LeafLaunch-Web owner workspace, **High Standards**, Store `80000000-0000-4000-8000-000000000001`. Names, addresses, category assignments, product prices and availability, marketing copy, schedules, and loyalty entries come from `LeafLaunch-Web/src/services/demo/` and `strings.ts`. Random web record IDs are stable local IDs here, and relative schedules restart with the app. Only customer-visible locations, products, current promotions, and upcoming events are exposed; owner drafts and archived records stay outside the customer experience. The web workspace's unfinished launch readiness is treated as available so the complete customer flow can be exercised.

The app starts signed in as the owner's seeded customer **Alexis Mensah** (`alexis.mensah@example.com`), membership **LEAF2345**, with **1,235 points** and all 30 ledger entries. The Pearl District Shop and Capitol Hill Storefront share that business-wide balance and history. Old Town Shop starts without a location membership and supports joining. The real location picker and age-21 gate remain active. Sign out to exercise guest browsing, local login, signup, and password reset. Mock login accepts the form's valid inputs; signup creates a fresh customer with zero points and joins the selected location. Profile edits, joining, and account deletion mutate the in-memory mock session. Relaunching restores Alexis and the original fixtures. Favorites, selected location, guest approvals, and theme preferences persist in the mock app’s separate defaults. Authenticated mock age acceptances are session-owned and reset on relaunch, so the customer affirms again even when local approval metadata remains.

## Launch and navigation

`LeafLaunchApp.init` resolves UserDefaultsService and synchronously restores cached branding before resolving RootViewModel. RootScreen's `.task` starts `RootStartupService`, which waits for optional existing authentication, StoreSession bootstrap, and the splash callback. Guest access never depends on account creation. Bootstrap failures finish the splash gate and expose retry controls.

`StoreSessionService` owns the public configuration, explicit customer-safe `PublicStore`, and selected validated location. Bootstrap resolves the tenant from the public app key and checks the target Store ID. Hours requests carry the same app key and Store ID. The client verifies both returned identities and current availability before selection. Cached invalid, foreign, or unavailable locations return to the picker; one available location selects automatically. Store Info displays the returned business identity, legal name, support contacts, and website alongside actual location information.

The selected location’s server-resolved `EffectiveAgePolicy` controls access before StoreDetails becomes visible. A required policy presents the existing non-dismissible age modal. The approval dictionary retains `[userId: [state]]`, using canonical country/region keys and a conservative missing-scope key. Separate metadata records scope, accepted minimum age, policy version, and approval revision. Unchanged or weaker requirements retain approval; a higher minimum age, changed scope, or explicit approval-revision change requires renewed affirmation. Legacy state-only entries have no policy evidence and deliberately require re-attestation. A stable persisted guest identity owns guest approval; authentication never transfers it to a customer.

Authenticated approval uses the existing AgeGateAcceptance GET/PUT contract with location context. The server re-resolves policy and validates the displayed age/version, while local approval is committed only after a valid response. A policy-conflict response refreshes bootstrap and the selected policy before another affirmation. Guests keep their local flow without registration. Identity, location, refreshed bootstrap, and foreground configuration changes reevaluate the gate. Superseded acceptance/selection work cannot approve another identity or location. Device registration likewise owns a cancellable request and verifies the current customer/Firebase UID; cached Firebase tokens are UID-scoped and stale refresh results cannot survive account changes.

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
| Bootstrap | `GET /v1/public/apps/{appKey}/bootstrap?platform=IOS&version=...&store_id=...` |
| Validate location, hours, and effective age policy | `GET /v1/public/locations/{locationId}/hours?store_id=...` with `x-app-key` |
| Categories | `GET /v1/public/locations/{locationId}/categories` |
| Product feed/details | `GET /v1/public/locations/{locationId}/products` and `.../products/{productId}` |
| Promotions/events | `GET /v1/public/locations/{locationId}/promotions` and `.../events` |
| Authenticated age affirmation | `GET/PUT /v1/customer/age-gate` with `location_id` (query/body) and `x-app-key` |
| Customer profile | `GET/PATCH/DELETE /v1/customer/account` |
| Register profile | `POST /v1/customer/locations/{locationId}/account` |
| Membership | `GET/POST /v1/customer/locations/{locationId}/membership` |
| Points history | `GET /v1/customer/locations/{locationId}/loyalty` |

Public calls explicitly bypass bearer authentication while carrying public tenant context. Customer calls obtain a fresh Firebase bearer token and pass `x-app-key` plus location context where required. Page responses retain server metadata; money uses Decimal, points preserve API strings, and product attribute values support the API’s primitive/array union.

`ProductQuery.sort` sends `featured`, `name`, `price_ascending`, or `price_descending`. The API orders the full filtered result before pagination. StoreShop never downloads the whole catalog to sort it; filter, search, and sort changes cancel old requests and reset paging, and load-more retains the selected order. Price ordering and the row’s “from” amount use the minimum effective price among available variants of a published listing. Individual variant details retain visible prices and availability labels; products without an available price sort last. See the API’s [catalog rules](../../LeafLaunch-API/docs/UBIQUITOUS_BUSINESS_LOGIC.md#shared-product-versus-local-listing) for promotion, missing-price, and tie-breaking semantics.

## Persistence and theme

Customer keys are scoped by business, app key, and bundle. They include the cached theme definition, `last_selected_location_id`, identity-keyed approved states, guest identity, and favorited product IDs. Logout preserves browsing preferences and removes existing sensitive security-pin state.

Rune Theme contains UI types and is not Codable. `CachedStoreTheme` persists the canonical validated branding definition, resolved radius roles, fallback preference, and target/schema metadata; StoreThemeBuilder reconstructs the actual Rune Theme synchronously. Theme preference changes preserve the fetched definition. Cache schema 2 records all seven supported Rune radius roles in logical points, bounded to 0–100. Missing values resolve from LeafLaunchThemeTokens: `extra_small=2`, `small=4`, `small2=6`, `medium=10`, `medium2=14`, `large=20`, and `extra_large=28`; Rune’s `none` remains zero.

App Style now carries eight independent optional base colors: background, content background, title, body, accent, button, button title and icon. These map to Rune's existing background.primary/secondary, textColor.title/body, palette.link/highlight, foreground.primary (CommonButton fill), and foreground.secondary respectively. Button Title Color maps directly to textColor.button (text(.button)); only an omitted button title color uses derived contrasting text. Button fill, button title and accent tint remain independent. Configured base values remain exact; StoreThemeColors and StoreThemeColor derive only supporting shades in OKLCH, including nested surfaces, icon variants, inverted/placeholder/button text and skeleton. The deterministic derivation, gamut mapping and contrast rules are documented in the [API runtime theme contract](../../LeafLaunch-API/docs/UBIQUITOUS_BUSINESS_LOGIC.md#runtime-theme-definition). Derived colors are reconstructed, never cached individually. Web intentionally previews the selected colors only and performs no color derivation. Native derives readable supporting colors where possible, but arbitrary low-contrast configured bases are not silently changed.

Font Family is typed by StoreAppFontFamily: System, Avenir Next, Helvetica Neue, Arial, Georgia, Palatino, Menlo or Courier New. StoreThemeFonts applies the selected family while retaining role sizes and weights; System uses the built-in system fonts, and unavailable families use those same defaults. The Web preview uses local fonts with an explicit generic fallback and never downloads font assets.

Schema 1 color/font/media definitions migrate synchronously with those established radius defaults. Corrupt, invalid, incomplete schema-2, unknown-schema, or foreign-target caches are removed and fall back to the built-in theme. First launch also uses that default. No arbitrary expiration or asynchronous startup theme application is added. Spacing, shadows, and interaction tokens remain owned by the existing app defaults because the API does not configure those roles.

## Public launch contract and domain authority

The API calls the tenant a Store. `store_id` and the customer-safe `store` projection identify that tenant; the app key identifies its StoreAppConfiguration and grants no authentication authority. Bootstrap retains existing launch state, update URL, feature flags, Store-wide gate fields, canonical branding, and available-location summaries, with each location’s effective age policy. The public hours response uses an explicit location projection including address, hours, and schedule exceptions; protected Store/staff/customer/billing relationships and Firebase credentials never enter these public payloads.

Regional configuration, restriction precedence, version allocation, administrative permissions, and accepted policy evidence are owned by the API’s [business rules](../../LeafLaunch-API/docs/UBIQUITOUS_BUSINESS_LOGIC.md#legal-bootstrap-and-hours) and [language](../../LeafLaunch-API/docs/UBIQUITOUS_LANGUAGE.md#store-location-app-legal-and-billing). The supplied business policy requires 18+ approval across all US states. The target fixture expresses it as one US country rule (`country_code=US`, `region=null`, required, minimum age 18); regional configuration currently accepts US scope only and compares region identifiers with the Location’s canonical stored values. Existing stricter Store restrictions remain effective. A confirmed production HTTPS API URL remains an external deployment value.

The customer app reads loyalty balance and redemption/spending history through membership and ledger; it has no checkout, payment, or points-spending flow. Verification follows [AGENTS.md](../AGENTS.md#verify-and-maintain). Source checks do not establish iOS SDK compatibility, push delivery, or device behavior.
