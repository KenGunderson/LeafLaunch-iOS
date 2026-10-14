# AGENTS.md

LeafLaunch is a SwiftUI iOS app built with Swift 6, FactoryKit, and Rune. This file is a task index: follow the links for the area you are changing instead of reading the whole repository.

## Standing rules

- Do not run Xcode builds unless the user explicitly asks. Do not write tests.
- Never over-architect. Make the smallest complete change using existing patterns and best practices; do not add speculative layers, protocols, generic frameworks, wrappers, or unrelated refactors. Add an abstraction only for a concrete current responsibility or demonstrated reuse.
- Split independent models into separate Swift files whenever possible; place them near the feature or service that owns them.
- Preserve existing architecture, user changes, service contracts, navigation behavior, and async behavior. Search for an existing model, component, service, or helper before creating another.
- Follow the closest same-layer implementation and the applicable [implementation guide](docs/IMPLEMENTATION_BEST_PRACTICES.md) sections, which incorporate the Skillet semantic-linter references. Use LeafLaunch's actual names and contracts; preserve documented lifecycle exceptions. Style cleanup must not change behavior or expand into a repository-wide format pass.
- Follow the [core Swift conventions](docs/IMPLEMENTATION_BEST_PRACTICES.md#core-swift-conventions): `self.` for instance properties (including bindings and callable Factory properties), normally no `self.` for methods, and readable parameter layout. Match the [worked example's spacious Swift formatting](docs/SWIFTUI_FEATURE_EXAMPLE.md): blank lines inside expanded bodies and between logical groups, with short helpers and closures kept compact. This is the default project style, not a legacy exception. Keep logger identifiers in separated `SCREAMING_SNAKE_CASE`.
- Keep screens and view models together by feature. Follow the [screen and ViewModel contract](docs/IMPLEMENTATION_BEST_PRACTICES.md#screens-and-viewmodels): canonical screen member order, one `@StateObject` owner, weak navigation, route context before lifecycle work, first-appearance tracking before idempotent subscriber binding, and no screen subscriptions in `init`.
- Trigger fetch-backed screen loading and reappearance refresh with `.task { [weak viewModel] in viewModel?.loadData(showHud: true) }`; keep initial fetches out of first-appearance callbacks. See the [lifecycle contract](docs/IMPLEMENTATION_BEST_PRACTICES.md#lifecycle-and-analytics).
- Follow the [async ownership rules](docs/IMPLEMENTATION_BEST_PRACTICES.md#async-tasks-loading-and-cancellation): name and cancel owned tasks, snapshot dependencies/context, check cancellation before results or errors, preserve main-actor UI mutation, and keep loading/empty state coherent.
- Reuse LeafLaunch components and Rune before custom UI. Use the active environment style, semantic tokens, and established image/presentation APIs; add a focused app wrapper only for a real product-specific need or repeated treatment. See [Rune and app-owned UI](docs/IMPLEMENTATION_BEST_PRACTICES.md#rune-and-app-owned-ui).
- Present errors in the owning ViewModel through its injected AlertService; never use `.errorHandler`. Follow the focused error helpers and individually owned loading alerts in the [async rules](docs/IMPLEMENTATION_BEST_PRACTICES.md#async-tasks-loading-and-cancellation).
- When adding or changing dependencies or features, keep protocols, live and mock registrations, preview/mock resolver entries, route destinations/context, analytics, and applicable API endpoints/fixtures in [integration parity](docs/IMPLEMENTATION_BEST_PRACTICES.md#feature-integration-parity). Match constructor signatures and actor annotations.
- New Swift files must be added to the appropriate target in [project.pbxproj](LeafLaunch.xcodeproj/project.pbxproj); this project uses explicit file references.

## Find the relevant code

1. Pick the matching row below. Read the linked contract and a nearby implementation, then inspect direct callers before editing.
2. Check [live registrations](LeafLaunch/DI/Live/ServiceAssembly.swift), [view model registrations](LeafLaunch/DI/Live/ViewModelAssembly.swift), and [mock registrations](LeafLaunch/DI/Mock/) when changing dependencies. A file's presence does not mean it is wired into the app.
3. Use `rg --files LeafLaunch` to locate files and `rg -n 'SymbolName' LeafLaunch` to find ownership and call sites. If a link becomes stale, locate its replacement and update this index.

Paths below are relative to the repository root. Directory links are search scopes, not instructions to read every file.

## Task references

| When working on… | Read / inspect |
| --- | --- |
| Swift style, naming, or file ownership | [Core Swift conventions](docs/IMPLEMENTATION_BEST_PRACTICES.md#core-swift-conventions), closest same-layer implementation, [models](LeafLaunch/Models/) |
| App launch and root state | [App entry point](LeafLaunch/App.swift), [app delegate](LeafLaunch/AppDelegate.swift), [root screen](LeafLaunch/Screens/Root/RootScreen.swift), [startup coordinator](LeafLaunch/Services/Startup/RootStartupService.swift) |
| Customer launch, white-label targets, catalog, and loyalty | [Customer architecture](docs/CUSTOMER_ARCHITECTURE.md), [target configuration](LeafLaunch/Helpers/BusinessConfig.swift), [store session](LeafLaunch/Services/StoreSession/StoreSessionService.swift), [customer models](LeafLaunch/Models/Customer/), [store screens](LeafLaunch/Screens/StoreDetails/) |
| A screen or view model | Closest pair in [Screens](LeafLaunch/Screens/), [base view model contract](LeafLaunch/Models/System/ViewModel.swift), [screen and ViewModel conventions](docs/IMPLEMENTATION_BEST_PRACTICES.md#screens-and-viewmodels), [worked example](docs/SWIFTUI_FEATURE_EXAMPLE.md) |
| Tasks, cancellation, or loading state | [Async ownership rules](docs/IMPLEMENTATION_BEST_PRACTICES.md#async-tasks-loading-and-cancellation), task properties and cleanup in the owning screen's ViewModel or service |
| Dependency injection or previews | [Live service assembly](LeafLaunch/DI/Live/ServiceAssembly.swift), [live view model assembly](LeafLaunch/DI/Live/ViewModelAssembly.swift), [mock assembly](LeafLaunch/DI/Mock/MockAssembler.swift), [mock services](LeafLaunch/DI/Mock/MockServiceAssembly.swift) |
| Offline customer demo or LeafLaunch Mock target | [Mock target contract](docs/CUSTOMER_ARCHITECTURE.md#leaflaunch-mock-target), [all mock fixtures](LeafLaunch/DI/Mock/MockModels.swift), [mock configuration](Configurations/LeafLaunch%20Mock.xcconfig) |
| Navigation, sheets, and tab flow | [Route model](LeafLaunch/Services/Navigation/Models/Routes.swift), [navigation service and destinations](LeafLaunch/Services/Navigation/NavigationService.swift), [root navigation wrapper](LeafLaunch/Components/Base/AppRootView.swift), [tab screen](LeafLaunch/Screens/Tab/TabBarScreen.swift) |
| Shared UI, empty states, and alerts | [App components](LeafLaunch/Components/), [empty state modifier](LeafLaunch/ViewModifiers/EmptyStateOverlayModifier.swift), [app button](LeafLaunch/Components/Base/LeafLaunchButton.swift), [UI conventions](docs/IMPLEMENTATION_BEST_PRACTICES.md) |
| Rune components or styling | [Rune component catalog](docs/UBIQUITOUS_COMPONENTS_GLOBAL.md), [theme registry](LeafLaunch/Services/DesignSystem/ThemeRegistry.swift), [Light theme](LeafLaunch/Services/DesignSystem/LeafLaunchLightTheme.swift), [Dark theme](LeafLaunch/Services/DesignSystem/LeafLaunchDarkTheme.swift), [shared tokens](LeafLaunch/Services/DesignSystem/LeafLaunchThemeTokens.swift), [Rune import](LeafLaunch/Helpers/GlobalImports.swift) |
| App models and constants | [Models](LeafLaunch/Models/), [user model](LeafLaunch/Models/GPUser.swift), [constants](LeafLaunch/Helpers/Constants.swift) |
| REST endpoints and networking | [API contract and request handling](<LeafLaunch/Services/API/Rest API/APIServiceProtocol.swift>), [API implementation](<LeafLaunch/Services/API/Rest API/APIService.swift>), [route definitions](<LeafLaunch/Services/API/Rest API/Models/API.swift>), [endpoint example](<LeafLaunch/Services/API/Rest API/Endpoints/APIService+Users.swift>) |
| Sign in and Firebase | [Auth service](LeafLaunch/Services/Auth/AuthService.swift), [Firebase service](LeafLaunch/Services/Firebase/FirebaseService.swift), [auth screens](LeafLaunch/Screens/Auth/) |
| Push notifications and deep links | [App delegate](LeafLaunch/AppDelegate.swift), [push service](LeafLaunch/Services/PushNotification/PushNotificationService.swift), [deep link service](LeafLaunch/Services/Deeplink/DeeplinkService.swift) |
| Analytics and logging | [Analytics service](LeafLaunch/Services/Analytics/AnalyticsService.swift), [event models](LeafLaunch/Services/Analytics/Models/), [logging contract](LeafLaunch/Services/Logger/Loggable.swift) |
| Environment and persistence | [Environment service](LeafLaunch/Services/Environment/EnvironmentService.swift), [user defaults service](LeafLaunch/Services/UserDefaults/UserDefaultsService.swift) |
| Assets, permissions metadata, and project settings | [Assets](LeafLaunch/Resources/Assets.xcassets/), [Info.plist](LeafLaunch/Resources/Info.plist), [privacy manifest](LeafLaunch/Resources/PrivacyInfo.xcprivacy), [project settings](LeafLaunch.xcodeproj/project.pbxproj) |

## Verify and maintain

- For documentation edits, check linked paths and run `git diff --check`.
- For Swift edits, inspect changed call sites and target membership. Report what was not verified when a build would be needed; do not run an Xcode build unless explicitly asked, and do not write tests.
- Keep this index concise. Add a task row for a new area; put detailed rules in a focused document under `docs/` and link it here.
