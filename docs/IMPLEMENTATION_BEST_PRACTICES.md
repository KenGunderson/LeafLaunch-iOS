# Implementation Best Practices

These conventions apply to new work and the relevant parts of code being changed in LeafLaunch, a Swift 6 SwiftUI app using FactoryKit and Rune. Read the matching contracts and closest same-layer implementation through [AGENTS.md](../AGENTS.md) before editing. Existing files can contain legacy deviations; they do not require an unrelated cleanup or override the explicit rules below.

For a concrete ViewModel, screen, and view component using these conventions, see the [SwiftUI feature example](SWIFTUI_FEATURE_EXAMPLE.md). It includes illustrative live/mock/preview and route wiring without changing production code.

## Keep changes simple and follow existing patterns

- Never over-architect. Choose the smallest complete implementation that satisfies the current requirement using established project patterns and best practices.
- Search for an existing model, component, service, helper, permission rule, or lifecycle entry point before creating another. Extend the existing owner when it already has that responsibility.
- Do not introduce speculative layers, coordinators, repositories, protocols, generic frameworks, configuration objects, or one-use pass-through wrappers. Add an abstraction only when a concrete current responsibility or demonstrated reuse justifies it; existing service protocol/live/mock contracts still apply.
- Extract coherent responsibilities when that improves comprehension or reuse. Avoid splitting a straightforward flow into trivial helpers, one-item extensions, or layers that only forward calls.
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
    loadUser()

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
AppHeaderScrollView {
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
- Use `.task { [weak viewModel] in ... }` for initial async loading when the entry point and existing lifecycle support it. Preserve structured cancellation; do not start the same load from both `.task` and first appearance.
- Forward `.onDisappear { [weak viewModel] in ... }` cleanup for active capture, realtime, playback, recording, or similar sessions. Do not add empty lifecycle hooks to screens without that responsibility.
- Root, splash, and startup surfaces have nonstandard lifecycle sequencing. Preserve their documented ownership and timing; do not mechanically apply standard screen wiring to them.

### Readable SwiftUI composition

- Keep `body` declarative and focused on composition, lifecycle hooks, and presentation. Keep side effects out of view construction; use established ViewModel actions and lifecycle entry points.
- Extract sections when they have a coherent name/responsibility, branch independently, repeat, or obscure the top-level flow. Avoid helpers that merely rename a single modifier chain without improving comprehension or reuse.
- Use small named helpers, generally `private func section() -> some View`, with parameters when needed. Add `@ViewBuilder` only for conditional or multiple view-producing statements.
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
- Reuse the current loading alert and error helpers, including `AlertServiceProtocol`, `.simpleLoadingIndicator`, `dismissLoadingIndicator()`, and `Constants.Message.errorMessage(_:)` where applicable. Do not invent a second loading/error presentation mechanism.

## Rune and app-owned UI

- Search [LeafLaunch components](../LeafLaunch/Components/) and the [Rune component catalog](UBIQUITOUS_COMPONENTS_GLOBAL.md) before implementing custom UI. Verify the actual API in the relevant source; a catalog entry is a discovery aid.
- Prefer an existing LeafLaunch wrapper when it covers the use case. For example, [LeafLaunchButton](../LeafLaunch/Components/Base/LeafLaunchButton.swift) owns app-specific button defaults while using Rune's `CommonButton` internally.
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

### Empty states at the screen root

Apply `emptyStateOverlay` to the `AppHeaderScrollView` chain after constructing it, rather than inside `content()`. The overlay must cover the full screen context, including the header, instead of only the scrolling content.

```swift
AppHeaderScrollView {
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

## Feature integration parity

Apply only the integrations affected by the change; do not create unused services, events, routes, or mock infrastructure to satisfy a checklist.

- For a new or changed ViewModel, keep [live factories](../LeafLaunch/DI/Live/ViewModelAssembly.swift), [mock factories](../LeafLaunch/DI/Mock/MockViewModelAssembly.swift), and the [mock resolver](../LeafLaunch/DI/Mock/MockAssembler.swift) in parity. Match actor annotations and constructor signatures.
- For a service dependency, update its protocol and relevant [live](../LeafLaunch/DI/Live/ServiceAssembly.swift) and [mock](../LeafLaunch/DI/Mock/MockServiceAssembly.swift) registrations and direct callers.
- Build previews with `mockResolve(...)`, required chainable route/context setup, existing shared fixtures such as [MockModels](../LeafLaunch/DI/Mock/MockModels.swift), and `.withMockServices()` for service/style environments. Do not duplicate fixture construction or accidentally resolve live services.
- Pair each new [route](../LeafLaunch/Services/Navigation/Models/Routes.swift) with its [navigation destination](../LeafLaunch/Services/Navigation/NavigationService.swift). Resolve the live ViewModel and install route context before the screen can track or load. Preserve route families, tab ownership, sheets, adaptive sheets where used, and full-screen-cover behavior.
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

Adapted from Skillet's [Swift semantic-linter references](https://github.com/SakoHovaguimian/Skillet/tree/main/skills/swift-sako-semantic-linter/references), reviewed at commit `88d780b09a34313c66fadea4a6a343cc12353fb4`. The rules above are local guidance, so applying them does not require fetching the source on every task. LeafLaunch-specific names, placement, lifecycle exceptions, and the simplicity/scope requirements above govern their application. The spacious whitespace convention follows the user's corrected worked example and takes precedence over the upstream advice against spacing inside braces.

- [Core Swift](https://github.com/SakoHovaguimian/Skillet/blob/88d780b09a34313c66fadea4a6a343cc12353fb4/skills/swift-sako-semantic-linter/references/core-swift.md): member access, formatting, naming, ownership, and safety boundaries.
- [Screens and ViewModels](https://github.com/SakoHovaguimian/Skillet/blob/88d780b09a34313c66fadea4a6a343cc12353fb4/skills/swift-sako-semantic-linter/references/screen-viewmodel.md): member order, ownership, lifecycle, composition, and analytics.
- [Async safety](https://github.com/SakoHovaguimian/Skillet/blob/88d780b09a34313c66fadea4a6a343cc12353fb4/skills/swift-sako-semantic-linter/references/async-safety.md): tasks, cancellation, and loading state.
- [Rune UI](https://github.com/SakoHovaguimian/Skillet/blob/88d780b09a34313c66fadea4a6a343cc12353fb4/skills/swift-sako-semantic-linter/references/rune-ui.md): component reuse, style authority, semantic tokens, images, animation, and presentation.
- [Integration parity](https://github.com/SakoHovaguimian/Skillet/blob/88d780b09a34313c66fadea4a6a343cc12353fb4/skills/swift-sako-semantic-linter/references/integration-parity.md): DI, previews, navigation, APIs, fixtures, and permissions.
