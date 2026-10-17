# Implementation Best Practices

These conventions apply to new work and the relevant parts of code being changed in LeafLaunch, a Swift 6 SwiftUI app using FactoryKit and Rune. Read the matching contracts and closest same-layer implementation through [AGENTS.md](../AGENTS.md) before editing. Existing files can contain legacy deviations; they do not require an unrelated cleanup or override the explicit rules below.

For a concrete ViewModel, screen, and view component using these conventions, see the [SwiftUI feature example](SWIFTUI_FEATURE_EXAMPLE.md) and the focused [loading and alert contract](VIEW_MODEL_LOADING_AND_ALERTS.md). The feature example includes illustrative live/mock/preview and route wiring without changing production code.

## Keep changes simple and follow existing patterns

- Never over-architect. Choose the smallest complete implementation that satisfies the current requirement using established project patterns and best practices.
- Search for an existing model, component, service, helper, permission rule, or lifecycle entry point before creating another. Extend the existing owner when it already has that responsibility.
- Do not introduce speculative layers, coordinators, repositories, protocols, generic frameworks, configuration objects, or one-use pass-through wrappers. Add an abstraction only when a concrete current responsibility or demonstrated reuse justifies it; existing service protocol/live/mock contracts still apply.
- Extract coherent responsibilities when that improves comprehension or reuse. The small view-builder helpers required below are direct composition, not extra architecture. Avoid one-item extensions and layers that only forward calls.
- Preserve architecture, user changes, API shape, actor isolation, task ownership, state timing, navigation, and async behavior. A lint or formatting change must not alter those contracts. A behavior fix must be deliberate and within the requested scope.
- Apply conventions to the work at hand. Do not run a repository-wide format pass or migrate unrelated screens. When evidence is insufficient for a safe fix, report the precise unresolved finding instead of guessing.
- Local project instructions and actual framework contracts govern adaptations of the upstream references. Keep root/startup and other nonstandard lifecycle exceptions explicit; do not invent a parallel architecture to make them resemble standard screens.

## Core Swift conventions

### Member access

- Use `self.` for instance properties and references through them, including state, environment values, dependencies, closure properties, and bindings such as `self.$viewModel.email`.
- Omit `self.` for method calls unless required for capture, disambiguation, or escaping-closure semantics. For example, call `track()` or `bindSubscribers()`, but retain compiler-required explicit access.
- Distinguish methods from callable properties. FactoryKit registrations such as `self.analyticsService()` are property access through `callAsFunction`; follow the framework and local registration pattern.
- Do not prefix local variables, static members, or global references with instance `self.`.

### Whitespace, parameters, and closures

- Write `var body: some View`, never `var body : some View`. Remove trailing whitespace and malformed member tokens such as `. leading`.
- Use the spacious layout in the [worked example](SWIFTUI_FEATURE_EXAMPLE.md) as the default project style. In expanded function, task, `defer`, `do`/`catch`, conditional, and view-builder bodies, leave a blank line after the opening brace and before the closing brace. Separate the final member from its enclosing type or extension's closing brace with a blank line. These gaps are intentional; do not compress them as generic formatting cleanup.
- Keep short one-statement helpers, simple initializers/accessors, inline guards, and short action/header/lifecycle closures compact, as shown in the example. Do not expand every brace indiscriminately. A dependency-assignment initializer may begin its assignments immediately after the opening brace; keep the assignments together, separate lifecycle logging, and leave a blank line before the closing brace.
- Separate logical groups inside longer bodies without breaking up a connected sequence. For example, keep an awaited fetch next to its cancellation guard, then separate the result mutation with a blank line. Keep a context-unwrapping guard next to the analytics emission it enables. Separate task-state cleanup from presentation dismissal inside `defer`.
- Keep a declaration's first parameter on the declaration line when readable, including `init(firstParameter: ...)`; align subsequent parameters one per line beneath it. Do not introduce a bare `init(` line unless the active local convention explicitly requires it.
- Keep calls on one line when readable, including one-parameter setup calls such as `self.viewModel.setup(navigationService: self.navigationService)`.
- For multiline calls, place arguments one per line and the closing parenthesis on its own line. Do not force the first argument onto the opening line when that harms readability or conflicts with the local formatter.
- Prefer trailing closures when they clarify the primary action. Retain labels when multiple closures would otherwise obscure intent. Use `() -> Void`, not `() -> ()`.

An expanded lifecycle method has breathing room inside its braces; a one-statement navigation helper stays compact:

```swift
func handleFirstAppear() {

    track()
    bindSubscribers()

}

func dismiss() {
    self.navigationService?.pop()
}
```

The worked example is the spacing reference for initializers, nested SwiftUI groups, tasks, previews, factories, and switch branches. Follow its whitespace without changing the statements or introducing additional helpers.

### Naming and file ownership

- Use canonical LeafLaunch domain language and nearby model names. Avoid vague abbreviations, generic `data`/`item` names where the domain is known, and type names that obscure lifecycle or ownership.
- Split independent models and independently owned top-level types into focused Swift files whenever possible. Keep feature/service-specific models near their owner; put shared domain models in the established [Models](../LeafLaunch/Models/) area. Do not extract a private implementation detail into a new abstraction merely to create another file.
- Keep screens, their ViewModels, and feature-only views together under [Screens](../LeafLaunch/Screens/). Put genuinely reusable UI in [Components](../LeafLaunch/Components/).
- When renaming a primary type, synchronize its filename, file header, references, and explicit Xcode project membership. Use `// MARK: -` only when it improves navigation.
- Logger names use fully separated `SCREAMING_SNAKE_CASE`, including every lexical word: `PROJECT_CHAT_VIEW_MODEL`, never `PROJECTCHAT_VIEW_MODEL`.

## Screens and ViewModels

### Screen member order

Order populated screen member sections as follows, with at least one blank line between sections. Omit empty sections:

1. `@Environment`
2. `@Binding`
3. `@State` and `@StateObject`
4. `@FocusState`
5. Other stored properties
6. Non-view computed properties
7. Initialization and non-view methods
8. View logic: `body`, the navigation-header helper, content, sections, rows, cards, overlays, and other `some View` builders

Keep `body` and view-producing helpers in the final section. Keep the navigation header as a focused helper, called directly from the header closure. Prefer `navHeader()` in new standard screens; retain an established feature helper name such as `headerView()` when changing an existing screen.

```swift
LLAppHeaderScrollView {
    navHeader()
} scrollViewContent: {
    content()
}
```

### ViewModel contract and ownership

- Standard screen ViewModels are `final class` types conforming to [ViewModel](../LeafLaunch/Models/System/ViewModel.swift) or an existing specialized project ViewModel protocol. Preserve the project's actor-isolation contract; UI mutation belongs on `@MainActor`.
- Treat `loggerName`, `loggerEmoji`, `logInit()`, and `logDeinit()` as one lifecycle contract. Pair initialization logging with deinitialization logging and owned-task cleanup.
- Hold screen-injected navigation services weakly. Do not make navigation state a second ownership root.
- For route-created screens, install every required route/context value with `@discardableResult func setup(...) -> Self` before the screen can track, appear, or load. Follow the existing [LegalViewModel](../LeafLaunch/Screens/Settings/Legal/LegalViewModel.swift) route-setup pattern; this does not require unrelated navigation-only setup methods to become chainable.
- Let the screen own its injected ViewModel with `@StateObject`; when providing an explicit initializer, initialize `_viewModel = StateObject(wrappedValue: viewModel)`. Child views and extracted forms use `@ObservedObject` to observe the same instance. Do not create a second owner or resolve a replacement during view construction.
- Never bind screen publishers in `init`. Temporary navigation-destination construction must not create live subscriptions. Repeated binding must be idempotent: guard existing bindings or intentionally replace the `CancelBag` before rebinding.

### Lifecycle and analytics

- Use `.onFirstAppear { [weak viewModel] in ... }` for standard first-appearance wiring. Inject navigation before calling `handleFirstAppear()` or starting work that can navigate.
- Make `handleFirstAppear()` call `track()` exactly once for the first-appearance flow, before applicable subscriber binding. Standard screens that use this entry point must not also call `viewModel.track()` directly.
- Keep `track()` in the final same-type extension in the primary ViewModel file. Track screen views through `self.analyticsService.track(screen:)` there.
- Add the matching [ScreenEvent](../LeafLaunch/Services/Analytics/Models/ScreenEvent.swift) case and preserve its `screen_view` mapping. Include applicable LeafLaunch context, such as a user ID or legal context; compact nil properties before emission. Do not import unrelated domain IDs from another app.
- Keep intent, success, mutation, and error analytics beside the action that causes them rather than in screen `track()`.
- Use `.task { [weak viewModel] in viewModel?.loadData(showHud: true) }` for initial loading and reappearance refresh on every fetch-backed screen. Keep `handleFirstAppear()` focused on tracking and idempotent subscriber binding; it must not start the same fetch. The loader owns its named cancellable tasks and accepts `showHud` when a loading alert applies. When it starts a stored unstructured task, SwiftUI’s `.task` does not automatically cancel that separate task on disappearance; replacement/deinitialization and any required explicit lifecycle cancellation belong to its owner. Root's `.task` starts the startup coordinator while the splash owns launch feedback. Screens with no initial data load do not need empty task hooks.
- Forward `.onDisappear { [weak viewModel] in ... }` cleanup for active capture, realtime, playback, recording, or similar sessions. Do not add empty lifecycle hooks to screens without that responsibility.
- Root, splash, and startup surfaces have nonstandard lifecycle sequencing. Preserve their documented ownership and timing; do not mechanically apply standard screen wiring to them.

### Readable SwiftUI composition

- Keep `body` declarative and focused on composition, lifecycle hooks, and presentation. Keep side effects out of view construction; use established ViewModel actions and lifecycle entry points.
- **Hard rule: compose views with small, named `@ViewBuilder` methods.** Keep `content()` as a short list of section/action calls inside the necessary layout and state branches. Put repeated collections in section helpers and each row/card in its own helper. Split nested layouts further when they obscure the visible responsibility.
- Annotate focused `private func section() -> some View` helpers with `@ViewBuilder`, including helpers with one root container. Use feature names such as `products()`, `productRow(_:)`, or `loadProfile()`, and pass only the values each block needs.
- Keep extraction local: use private methods and existing components. A composition helper does not justify another ViewModel, protocol, wrapper, configuration layer, or file. A separate view needs real reuse or an independently owned responsibility; avoid helpers that only rename a modifier chain without improving readability.
- Preserve stable `ForEach` identity. Use `\.self` only when the values remain stable and unique for the collection's lifetime.
- Respect accessibility, Dynamic Type, localization, and reduced-motion behavior in touched UI.
- Do not manufacture layout with fixed minimum-height spacers such as `.frame(maxWidth: .infinity, minHeight: 360)`. Use the scroll container, safe area, and content to determine available space.
- For activity timelines, calculate whether a trailing connector is visible in the parent sequence and pass that value into the card. The last item must not draw a connector below itself; the card should not infer its position from global state.

## Async tasks, loading, and cancellation

- Store independently cancellable unstructured work in named task properties. Use the existing task-ownership pattern; do not add a task-management framework. View-scoped structured work can remain owned by `.task`.
- Cancel replaceable work before assigning its replacement. Cancel every stored task during deinitialization; use `isolated deinit` when required by the owning type's isolation.
- Snapshot dependencies, required IDs, and request inputs before entering a task so work cannot race mutable ViewModel setup or retain the ViewModel unnecessarily.
- Capture the ViewModel weakly in long-lived tasks and mutate UI state on `@MainActor`. Avoid holding a strong ViewModel reference across a long suspension merely to read dependencies that could have been captured separately.
- Check cancellation before committing results, marking a load successful, emitting success effects, navigating, or presenting errors. Cancellation must not become a user-facing failure.
- Use `defer` for paired cleanup and loading-state completion. A cancelled operation must still dismiss the presentation it owns, without committing results or marking initial loading successful. A superseded task's cleanup must not clear a newer task's loading state or presentation; preserve existing ownership guards.
- For fetch-backed screens that distinguish initial loading from empty content, keep `isLoading`, `hasCompletedInitialLoad`, `hasContent`, and `shouldShowEmptyState` (or equivalent existing state) coherent. Show empty state only after an initial load has completed, while not loading and without content; do not treat a cancelled/failed initial request as a successful empty response.
- Follow the [loading and alert contract](VIEW_MODEL_LOADING_AND_ALERTS.md) for new standard `loadData(showHud:)` flows: cancel the previous load, set `isLoading`, snapshot dependencies/context, and start `Task { @MainActor [weak self] in ... }`. Check cancellation before side effects and after awaited work. For cancel-before-replace tasks, clear the handle/loading flag in `defer` only when `!Task.isCancelled`; cancelled cleanup must not clear newer work.
- Preserve intentional single-flight gates for pagination, mutations, or coupled request sequences. Keep existing request IDs, authenticated-user checks, and store/query context guards when cancellation alone cannot establish ownership. An explicit cancellation/reset path must reset its own state; do not rely on cancelled-task cleanup to do so.
- Create a unique `RuneAlert(.simpleLoadingIndicator)` inside each task. Show it through the snapshotted AlertService only when `showHud` is true and dismiss that exact instance with `dismissAlert(loadingIndicator)` in `defer`, including cancellation. Broad calls such as `dismissLoadingIndicator()`, `dismiss()`, or `dismissAll()` can remove another operation's loader or its error alert.
- Present screen errors from the owning ViewModel through its injected `AlertServiceProtocol` and a focused `presentError(...)` helper. Never use `.errorHandler` or publish an `Error` solely to trigger an alert. Keep inline error state only for persistent failure/retry UI. Check cancellation/ownership before presentation and retain previous content on refresh failure.
- Keep reusable alert copy in `Constants.Message`. The actual formatter is `errorMessage(context:_:)`, for example `Constants.Message.errorMessage(context: .get, "profile")`; the topic is unlabeled. Choose `.get`, `.create`, `.update`, or `.delete` for the attempted operation. Add focused messages for non-CRUD wording rather than exposing raw transport errors. Constants contain copy, not services, navigation, API calls, or capture ownership.
- Keep success, error, and confirmation presentation in focused ViewModel methods. Present success only after a successful, uncancelled mutation; fetching does not require a success alert. Alert callbacks that reference the ViewModel capture it weakly. Independent actions own independent task properties and deinitialization cancellation. Do not add unused subscriber bags or bind subscriptions in `init`.
- A failed initial load must leave a retry control reachable. Mark initial completion only after required requests succeed; use `try?` only for deliberately optional work with an explicit fallback. Snapshot required IDs/query values, check cancellation before sequential follow-up operations, and use `async let` for independent required requests before committing their results.

## Rune and app-owned UI

- Search [LeafLaunch components](../LeafLaunch/Components/) and the [Rune component catalog](UBIQUITOUS_COMPONENTS_GLOBAL.md) before implementing custom UI. Verify the actual API in the relevant source; a catalog entry is a discovery aid.
- Prefer an existing LeafLaunch wrapper when it covers the use case. For example, [LeafLaunchButton](../LeafLaunch/Components/Base/LeafLaunchButton.swift) owns app-specific button defaults while using Rune's `CommonButton` internally.
- When matching call sites repeatedly override the same Rune defaults, extract that treatment into a focused app component or modifier and migrate those callers. Centralize its padding, typography, colors, border, radius, or shadow; expose only options required by current use cases, not Rune’s full parameter list or speculative variants.
- Add a small app component only when a repeated treatment or concrete product-specific behavior justifies it. Keep Rune details inside that component and expose a focused API expressing product intent, rather than forwarding every Rune parameter. Do not wrap every primitive solely for naming consistency.
- Raw Rune components remain appropriate inside wrappers and when no app wrapper covers the need. Promote repeated app-specific treatments before they spread. Flag custom components/raw visual tokens only when an existing Rune or app primitive clearly covers the same use case; record the concrete gap when a new reusable component is necessary.
- Use `@Environment(\.style)` and `self.style` in production views with environment access. Reserve `Style.shared` for static defaults or contexts without environment access.
- Use semantic typography, spacing, radius, and color tokens when available. Choose typography by semantic role and compare scale with adjacent screens. Use the active environment's container and section spacing rather than isolated hardcoded values.
- Treat `ColorSource` as an `AnyShapeStyle`; pass it directly where supported. Use `.source()` only when required by the called API or established framework usage.
- Use `ImageSource` for Rune-backed system, resource, local, and remote images. Avoid raw `Image(systemName:)`, `AsyncImage`, or a new image cache when an existing image source or app wrapper covers the need. Drawing/canvas and framework-interoperability uses can require native image APIs.
- Prefer an existing remote-image wrapper when it supplies the required cache, thumbnail, content-mode, and placeholder behavior. Do not create one unless the current feature has an uncovered need.
- Gate heavy content on data readiness and keep those conditions beside the affected content.
- Scope animation with `.animation(_:value:)` to the driving state. Use transitions for meaningful inserted/removed groups and targeted content transitions when continuity helps. Add geometry or compositing groups only when complex animated elements need rendering coherence.
- Keep sheet/overlay triggers in the ViewModel and use the project's established presentation styles. Keep preview, navigation, analytics, and first-appearance wiring consistent with the feature and the lifecycle contract above.

The current app-owned treatments are:

- [LLAppCardView](../LeafLaunch/Components/Base/LLAppCardView.swift) owns the shared Rune card defaults; [CommerceSurface](../LeafLaunch/Components/Commerce/CommerceSurface.swift) applies the storefront's `.large` radius, and [LeafLaunchCardView](../LeafLaunch/Components/Base/LeafLaunchCardView.swift) adds a title. Reuse the appropriate level instead of recreating its treatment in screens.
- [LLAppHeaderScrollView](../LeafLaunch/Components/Base/LLAppHeaderScrollView.swift) owns Rune header/content composition with `.medium` horizontal content padding. Navigation content retains its own layout. A screen with intentional different padding, such as Home's default `.large`, may keep the Rune primitive.
- [llTextFieldStyle](../LeafLaunch/ViewModifiers/LLTextFieldViewModifier.swift) owns the shared titled, bordered Rune field treatment and semantic `.medium2` input radius. Callers retain focus bindings, keyboard/content types, secure entry, validation, and submission behavior.
- [tabFlowContentSpacing](../LeafLaunch/ViewModifiers/TabFlowContentSpacingModifier.swift) adds 120 points **inside the tab screen's scrolling content** so final actions clear the custom tab bar. Do not apply it to the header or outer scrolling container. Preserve the account authentication-route safe-area inset in [StoreDetailsScreen](../LeafLaunch/Screens/StoreDetails/StoreDetailsScreen.swift): pushed auth screens do not own that tab-root content inset.

### Empty states at the screen root

This overlay contract applies when a feature uses `emptyStateOverlay`. LeafLaunch’s [CommerceEmptyState](../LeafLaunch/Components/Commerce/CommerceEmptyState.swift) is intentionally contextual: catalog filters, sorting, and surrounding actions stay available during empty/retry states. Do not replace it with a full-screen overlay merely to match an upstream list example.

Apply `emptyStateOverlay` to the `LLAppHeaderScrollView` (or intentional Rune `AppHeaderScrollView`) chain after constructing it, rather than inside `content()`. The overlay must cover the full screen context, including the header, instead of only the scrolling content.

```swift
LLAppHeaderScrollView {
    navHeader()
} scrollViewContent: {
    content()
}
.emptyStateOverlay(
    shouldShow: self.viewModel.shouldShowEmptyState,
    config: self.emptyStateConfig
)
.onFirstAppear { [weak viewModel] in
    viewModel?.setup(navigationService: self.navigationService)
    viewModel?.handleFirstAppear()
}
```

Keep `content()` focused on the populated screen tree. If the empty state already offers the primary creation action, do not duplicate a create/invite action in the empty list. Show the standard list-level action once content exists.

### Tabs, themes, and presentations

- Preserve [StoreDetailsScreen](../LeafLaunch/Screens/StoreDetails/StoreDetailsScreen.swift) as owner of the four customer tabs and their independent navigation roots. Its custom bar hides the native tab bar and native tab-bar background. Keep per-tab context, selection, route stacks, and keyboard behavior intact; do not replace the customer experience with upstream showcase tabs.
- Use [NavBarButton](../LeafLaunch/Components/Nav/NavBarButton.swift), [NavHeader](../LeafLaunch/Components/Nav/NavHeader.swift), and [TabItemView](../LeafLaunch/Screens/Tab/TabViews/TabItemView.swift) for shared navigation treatments. Keep the independently maintained `NavBarButton.Style` model in its own file. Use `ImageSource` and Rune `commonBadge` where appropriate; positive badges cap visible text at `99+` and do not affect layout. Preserve accessible action names and selection semantics.
- Let long content grow through actual rows, stable identity, and the existing vertical scroll owner. Use lazy stacks where appropriate. Manual scrolling checks should reach a final row/action; do not fake overflow with spacer heights or introduce nested vertical scrolling without a concrete presentation need.
- Select appearance through [AvailableTheme](../LeafLaunch/Services/DesignSystem/ThemeRegistry.swift) and the existing `UserDefaultsServiceProtocol.set(theme:)`. Keep live/mock behavior, theme publishers, mock previews, and the active Rune style consistent. Preserve the synchronous target-scoped store-theme cache and runtime branding rules in the [customer contract](CUSTOMER_ARCHITECTURE.md#persistence-and-theme).
- Runtime LeafLaunch theme definitions remain canonical; [DESIGN.md](../DESIGN.md) documents their intent. Use semantic roles for colors, fonts, radii, shadows, and interaction; an upstream palette, font family, asset, radius scale, spring, or screenshot does not authorize a global redesign. A deliberate local modal/capsule radius may differ from ordinary card roles without redefining the shared scale.
- Present app modal cards through the injected AlertService and focused `AppCardConfig` factories in [Components/Alerts](../LeafLaunch/Components/Alerts/), such as [invitationAlert](../LeafLaunch/Components/Alerts/InvitationAlert.swift) and its [InvitationAlertView](../LeafLaunch/Components/Alerts/InvitationAlertView.swift). Keep configuration separate from its view, dismiss the card before invoking its completion action when that is the contract, and keep callbacks weak when they capture a ViewModel. Use Rune’s `ToastManager.shared` for toast presentation when the feature needs a toast; do not add another feedback service.
- Modal content must retain readable wrapping, a reachable dismissal action, and accessibility semantics. For content that can exceed the modal height, follow a fitting layout with an appropriate scrolling fallback instead of clipping details or shrinking text into fixed bounds. Decorative grabbers/icons should not compete with actionable labels.

## Feature integration parity

Apply only the integrations affected by the change; do not create unused services, events, routes, or mock infrastructure to satisfy a checklist.

- For a new or changed ViewModel, keep [live factories](../LeafLaunch/DI/Live/ViewModelAssembly.swift), [mock factories](../LeafLaunch/DI/Mock/MockViewModelAssembly.swift), and the [mock resolver](../LeafLaunch/DI/Mock/MockAssembler.swift) in parity. Match actor annotations and constructor signatures.
- For a service dependency, update its protocol and relevant [live](../LeafLaunch/DI/Live/ServiceAssembly.swift) and [mock](../LeafLaunch/DI/Mock/MockServiceAssembly.swift) registrations and direct callers.
- Put `#Preview` blocks at the bottom of each new view file, using the project's spacious Swift formatting. Use `mockResolve(...)`, required chainable route/context setup, existing shared fixtures such as [MockModels](../LeafLaunch/DI/Mock/MockModels.swift), and `.withMockPreviews()` for the Rune canvas and mock service/style environments. Do not duplicate fixture construction or accidentally resolve live services.
- Pair each new [route](../LeafLaunch/Services/Navigation/Models/Routes.swift) with its [navigation destination](../LeafLaunch/Services/Navigation/NavigationService.swift). Resolve the live ViewModel and install route context before the screen can track or load. Preserve route families, tab ownership, sheets, adaptive sheets where used, and full-screen-cover behavior.
- Public customer models decode explicit public projections; never ingest protected Store relationships into launch data. The app key resolves StoreAppConfiguration and must agree with the target Store ID. Effective age-policy and server-sort contracts belong to the existing API domain owners; retain them in live/mock/preview parity.
- Restore the validated target-scoped theme definition synchronously before Root/splash creation. Cache serializable branding plus resolved supported radius roles and reconstruct Rune Theme; do not serialize Rune UI types or add asynchronous startup application/expiration.
- For API work, update [APIServiceProtocol](<../LeafLaunch/Services/API/Rest API/APIServiceProtocol.swift>) first, then the applicable live endpoint, mock endpoint, and fixtures. Preserve signatures, isolation, request/response contracts, and expected errors.
- Find the actual mock endpoint authority instead of assuming it lives in DI. LeafLaunch's `MockAPIService` is currently defined in [MockServiceAssembly.swift](../LeafLaunch/DI/Mock/MockServiceAssembly.swift); inspect it and the [live endpoint extensions](<../LeafLaunch/Services/API/Rest API/Endpoints/>) for the affected call.
- Reuse shared request encoding, response decoding, query conversion, and existing configurable mock error/value helpers where available. Make fixtures realistic enough for the filtering or pagination behavior the UI uses; do not build unused mock configuration layers.
- Reuse centralized domain permission helpers when applicable. Do not duplicate role, membership, mutation, or visibility decisions in screens or ViewModels, or invent a new permission architecture for a feature that does not need it.
- Add new Swift files to the appropriate target in [project.pbxproj](../LeafLaunch.xcodeproj/project.pbxproj); LeafLaunch uses explicit file references.

## Verification and scope

- Do not run Xcode builds unless the user explicitly asks. Do not write tests. Do not run tests without an explicit request.
- For documentation-only work, verify local links and section anchors, run `git diff --check`, and confirm the diff contains only the requested documentation.
- For Swift work, inspect changed call sites, ownership/cancellation paths, affected live/mock/preview registrations, navigation and analytics wiring, and target membership as applicable. Report what needs build/runtime verification without running an unauthorized build.
- Keep validation proportional to the change. These rules do not authorize unrelated refactoring or code changes during a documentation-only task.

## Source references

The [2026-10-17 Grimoire review](GRIMOIRE_PRACTICES_REVIEW.md) records the seven reviewed commits, their cumulative rules, superseded details, and LeafLaunch-specific adaptations. It supplements the references below.

Adapted from Skillet's [Swift semantic-linter references](https://github.com/SakoHovaguimian/Skillet/tree/main/skills/swift-sako-semantic-linter/references), reviewed at commit `88d780b09a34313c66fadea4a6a343cc12353fb4`. The rules above are local guidance, so applying them does not require fetching the source on every task. LeafLaunch-specific names, placement, lifecycle exceptions, and the simplicity/scope requirements above govern their application. The spacious whitespace convention follows the user's corrected worked example and takes precedence over the upstream advice against spacing inside braces.

- [Core Swift](https://github.com/SakoHovaguimian/Skillet/blob/88d780b09a34313c66fadea4a6a343cc12353fb4/skills/swift-sako-semantic-linter/references/core-swift.md): member access, formatting, naming, ownership, and safety boundaries.
- [Screens and ViewModels](https://github.com/SakoHovaguimian/Skillet/blob/88d780b09a34313c66fadea4a6a343cc12353fb4/skills/swift-sako-semantic-linter/references/screen-viewmodel.md): member order, ownership, lifecycle, composition, and analytics.
- [Async safety](https://github.com/SakoHovaguimian/Skillet/blob/88d780b09a34313c66fadea4a6a343cc12353fb4/skills/swift-sako-semantic-linter/references/async-safety.md): tasks, cancellation, and loading state.
- [Rune UI](https://github.com/SakoHovaguimian/Skillet/blob/88d780b09a34313c66fadea4a6a343cc12353fb4/skills/swift-sako-semantic-linter/references/rune-ui.md): component reuse, style authority, semantic tokens, images, animation, and presentation.
- [Integration parity](https://github.com/SakoHovaguimian/Skillet/blob/88d780b09a34313c66fadea4a6a343cc12353fb4/skills/swift-sako-semantic-linter/references/integration-parity.md): DI, previews, navigation, APIs, fixtures, and permissions.
