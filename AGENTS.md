# AGENTS.md

Grimoire is a SwiftUI iOS app built with Swift 6, FactoryKit, and Rune. This file is a task index: follow the links for the area you are changing instead of reading the whole repository.

## Standing rules

- Do not run Xcode builds unless the user explicitly asks. Do not write tests.
- Split independent models into separate Swift files whenever possible; place them near the feature or service that owns them.
- Preserve existing architecture, user changes, service contracts, navigation behavior, and async behavior. Search for an existing model, component, service, or helper before creating another.
- Follow the closest same-layer implementation and the applicable parts of the [implementation guide](docs/IMPLEMENTATION_BEST_PRACTICES.md). Its `JL*` snippets illustrate patterns from another app; use Grimoire's actual components and names.
- Keep screens and view models together by feature. For reusable UI, prefer an existing Grimoire component or a focused app component over repeating raw Rune components in screens. Keep logger identifiers in separated `SCREAMING_SNAKE_CASE`.
- When adding or changing a service dependency, update its protocol and the relevant live and mock registrations, including SwiftUI previews that resolve it.
- New Swift files must be added to the appropriate target in [project.pbxproj](Grimoire.xcodeproj/project.pbxproj); this project uses explicit file references.

## Find the relevant code

1. Pick the matching row below. Read the linked contract and a nearby implementation, then inspect direct callers before editing.
2. Check [live registrations](Grimoire/DI/Live/ServiceAssembly.swift), [view model registrations](Grimoire/DI/Live/ViewModelAssembly.swift), and [mock registrations](Grimoire/DI/Mock/) when changing dependencies. A file's presence does not mean it is wired into the app.
3. Use `rg --files Grimoire` to locate files and `rg -n 'SymbolName' Grimoire` to find ownership and call sites. If a link becomes stale, locate its replacement and update this index.

Paths below are relative to the repository root. Directory links are search scopes, not instructions to read every file.

## Task references

| When working on… | Read / inspect |
| --- | --- |
| App launch and root state | [App entry point](Grimoire/App.swift), [app delegate](Grimoire/AppDelegate.swift), [root screen](Grimoire/Screens/Root/RootScreen.swift), [startup coordinator](Grimoire/Services/Startup/RootStartupService.swift) |
| A screen or view model | Closest pair in [Screens](Grimoire/Screens/), [base view model contract](Grimoire/Models/System/ViewModel.swift), [UI conventions](docs/IMPLEMENTATION_BEST_PRACTICES.md) |
| Dependency injection or previews | [Live service assembly](Grimoire/DI/Live/ServiceAssembly.swift), [live view model assembly](Grimoire/DI/Live/ViewModelAssembly.swift), [mock assembly](Grimoire/DI/Mock/MockAssembler.swift), [mock services](Grimoire/DI/Mock/MockServiceAssembly.swift) |
| Navigation, sheets, and tab flow | [Route model](Grimoire/Services/Navigation/Models/Routes.swift), [navigation service and destinations](Grimoire/Services/Navigation/NavigationService.swift), [root navigation wrapper](Grimoire/Components/Base/AppRootView.swift), [tab screen](Grimoire/Screens/Tab/TabBarScreen.swift) |
| Shared UI, empty states, and alerts | [App components](Grimoire/Components/), [empty state modifier](Grimoire/ViewModifiers/EmptyStateOverlayModifier.swift), [app button](Grimoire/Components/Base/GrimoireButton.swift), [UI conventions](docs/IMPLEMENTATION_BEST_PRACTICES.md) |
| Rune components or styling | [Rune component catalog](docs/UBIQUITOUS_COMPONENTS_GLOBAL.md), [theme registry](Grimoire/Services/DesignSystem/ThemeRegistry.swift), [themes](Grimoire/Services/DesignSystem/GPTheme.swift), [Rune import](Grimoire/Helpers/GlobalImports.swift) |
| App models and constants | [Models](Grimoire/Models/), [user model](Grimoire/Models/GPUser.swift), [constants](Grimoire/Helpers/Constants.swift) |
| REST endpoints and networking | [API contract and request handling](<Grimoire/Services/API/Rest API/APIServiceProtocol.swift>), [API implementation](<Grimoire/Services/API/Rest API/APIService.swift>), [route definitions](<Grimoire/Services/API/Rest API/Models/API.swift>), [endpoint example](<Grimoire/Services/API/Rest API/Endpoints/APIService+Users.swift>) |
| Sign in and Firebase | [Auth service](Grimoire/Services/Auth/AuthService.swift), [Firebase service](Grimoire/Services/Firebase/FirebaseService.swift), [auth screens](Grimoire/Screens/Auth/) |
| Push notifications and deep links | [App delegate](Grimoire/AppDelegate.swift), [push service](Grimoire/Services/PushNotification/PushNotificationService.swift), [payload router](Grimoire/Services/PushNotification/NotificationPayloadRouter.swift), [deep link service](Grimoire/Services/Deeplink/DeeplinkService.swift) |
| Local notifications and permissions | [Local notification contract](Grimoire/Services/LocalNotification/LocalNotificationServiceProtocol.swift), [recurrence calculator](Grimoire/Services/LocalNotification/LocalNotificationRecurrenceCalculator.swift), [notification models](Grimoire/Models/Service%20Models/LocalNotifications/), [permission services](Grimoire/Services/Permissions/) |
| Analytics, logging, and feature flags | [Analytics service](Grimoire/Services/Analytics/AnalyticsService.swift), [event models](Grimoire/Services/Analytics/Models/), [logging contract](Grimoire/Services/Logger/Loggable.swift), [Statsig service](Grimoire/Services/Statsig/StatsigService.swift) |
| Environment, persistence, and subscriptions | [Environment service](Grimoire/Services/Environment/EnvironmentService.swift), [user defaults service](Grimoire/Services/UserDefaults/UserDefaultsService.swift), [StoreKit service](Grimoire/Services/StoreKit/AppStoreSubscriptionService.swift) |
| Assets, permissions metadata, and project settings | [Assets](Grimoire/Resources/Assets.xcassets/), [Info.plist](Grimoire/Resources/Info.plist), [privacy manifest](Grimoire/Resources/PrivacyInfo.xcprivacy), [project settings](Grimoire.xcodeproj/project.pbxproj) |

## Verify and maintain

- For documentation edits, check linked paths and run `git diff --check`.
- For Swift edits, inspect changed call sites and target membership. Report what was not verified when a build would be needed; do not run an Xcode build unless explicitly asked, and do not write tests.
- Keep this index concise. Add a task row for a new area; put detailed rules in a focused document under `docs/` and link it here.
