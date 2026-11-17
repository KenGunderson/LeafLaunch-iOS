# Implementation Best Practices

These conventions apply to new work and the relevant parts of code being changed in LeafLaunch, a Swift 6 SwiftUI app using FactoryKit and Rune. Read the matching contracts and closest same-layer implementation through [AGENTS.md](../../AGENTS.md) before editing. Existing files can contain legacy deviations; they do not require an unrelated cleanup or override the explicit rules below.

Use the [feature implementation workflow](FEATURE_IMPLEMENTATION.md) for discovery and sequencing. For a concrete ViewModel, screen, and view component using these conventions, see the [SwiftUI feature example](../examples/SWIFTUI_FEATURE_EXAMPLE.md) and the focused [loading and alert contract](../examples/VIEW_MODEL_LOADING_AND_ALERTS.md). The feature example includes illustrative live/mock/preview and route wiring without changing production code.

## Keep changes simple and follow existing patterns

- Never over-architect. Choose the smallest complete implementation that satisfies the current requirement using established project patterns and best practices.
- Search for an existing model, component, service, helper, permission rule, or lifecycle entry point before creating another. Extend the existing owner when it already has that responsibility.
- Do not introduce speculative layers, coordinators, repositories, protocols, generic frameworks, configuration objects, or one-use pass-through wrappers. Add an abstraction only when a concrete current responsibility or demonstrated reuse justifies it; existing service protocol/live/mock contracts still apply.
- Extract coherent responsibilities when that improves comprehension or reuse. The small view-builder helpers required below are direct composition, not extra architecture. Avoid one-item extensions and layers that only forward calls.
- Preserve architecture, user changes, API shape, actor isolation, task ownership, state timing, navigation, and async behavior. A lint or formatting change must not alter those contracts. A behavior fix must be deliberate and within the requested scope.
- Apply conventions to the work at hand. Do not run a repository-wide format pass or migrate unrelated screens unless that scope is explicitly requested. When evidence is insufficient for a safe fix, report the precise unresolved finding instead of guessing.
- Local project instructions and actual framework contracts govern adaptations of the upstream references. Keep root/startup and other nonstandard lifecycle exceptions explicit; do not invent a parallel architecture to make them resemble standard screens.

## Core Swift conventions

### Member access

- Use `self.` for instance properties and references through them, including state, environment values, dependencies, closure properties, and bindings such as `self.$viewModel.email`.
- Omit `self.` for method calls unless required for capture, disambiguation, or escaping-closure semantics. For example, call `track()` or `bindSubscribers()`, but retain compiler-required explicit access.
- Distinguish methods from callable properties. FactoryKit registrations such as `self.analyticsService()` are property access through `callAsFunction`; follow the framework and local registration pattern.
- Do not prefix local variables, static members, or global references with instance `self.`.

### Whitespace, parameters, and closures

- Write `var body: some View`, never `var body : some View`. Remove trailing whitespace and malformed member tokens such as `. leading`.
- Use the spacious layout in the [worked example](../examples/SWIFTUI_FEATURE_EXAMPLE.md) as the default project style. In expanded function, task, `defer`, `do`/`catch`, conditional, and view-builder bodies, leave a blank line after the opening brace and before the closing brace. Switches follow the separate [switch layout rules](#switch-layout). Separate the final member from its enclosing type or extension's closing brace with a blank line. These gaps are intentional; do not compress them as generic formatting cleanup.
- Keep short one-statement helpers, simple initializers/accessors, inline guards, and short action/header/lifecycle closures compact, as shown in the example. Do not expand every brace indiscriminately. A dependency-assignment initializer may begin its assignments immediately after the opening brace; keep the assignments together, separate lifecycle logging, and leave a blank line before the closing brace.
- A guard's `else` block with multiple statements or an expanded multiline expression must have a blank line after `{` and before `}`. When other logic precedes its final `return`, also put a blank line immediately before `return`, even when the block only logs and returns. A simple `else { return }` or `else { return nil }` stays compact; a multiline guard condition alone does not require expanding its exit.
- A `MainActor.run` block with more than one line of logic must have a blank line after the opening brace (or the capture list's `in`) and before the closing brace. Count the body, not the capture list or comments. A one-line action may stay compact. Preserve the actor hop, captures, statement order, and awaited completion.
- Separate logical groups inside longer bodies without breaking up a connected sequence. For example, keep an awaited fetch next to its cancellation guard, then separate the result mutation with a blank line. Keep a context-unwrapping guard next to the analytics emission it enables. Separate task-state cleanup from presentation dismissal inside `defer`.
- Apply parameter layout across the app: views, ViewModels, services, models, protocols, and other Swift code follow the same rules.
- At call sites with two or more arguments inside parentheses, put the first argument on the next line, indent each argument one level, and put `)` on its own line aligned with the call. This includes initializers, modifiers, service calls, and nested calls regardless of line length, except for the explicit compact forms below. Never use declaration-style hanging alignment for a call. Zero- and one-argument calls may remain compact, including `self.viewModel.setup(navigationService: self.navigationService)`. Keep enum-pattern destructuring and calls inside single-line string interpolation inline so their syntax stays intact.
- Keep these call-site exceptions on one line: `ForEach` arguments, simple `min`/`max` operations, every `.padding(...)` and `.runePadding(...)`, and `.frame(...)` modifiers containing `maxWidth:` or `maxHeight:`. Examples: `ForEach(self.viewModel.projects, id: \.self) { project in`, `min(count, self.routes.count)`, `.runePadding(.top, .small)`, and `.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)`. Keep all padding arguments inline, including edge sets and style-resolved values. Keep accompanying frame arguments, such as `alignment:` or `minHeight:`, on that same line. Extract a complicated padding or frame argument into a named local value instead of nesting an expanded call inside the modifier. Frames containing only fixed dimensions continue to follow the general call-site rule.
- For declarations with more than two parameters, keep the first parameter on the declaration line and align each subsequent parameter directly beneath it. Keep the closing `)`, any effects such as `async`/`throws`, any `-> ReturnType`, and the opening body brace on the final parameter line. Never drop a declaration's closing parenthesis or opening brace onto a separate line. This applies to functions, view helpers, methods, protocol requirements, initializers, subscripts, and associated-value definitions. Declarations with up to two parameters may stay on one line; if expanded, use the same alignment. Closure/function types within a parameter remain part of that parameter.
- When expanding a call makes its enclosing body multiline, preserve the blank line inside that body's braces. If the call's closing `)` now sits directly above the enclosing `}`, insert a blank line between them. Separate adjacent closing braces in expanded bodies with a blank line as well; do not add an extra blank line where one already exists. Keep connected call delimiters such as `))` and trailing-closure syntax together.
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

Calls and declarations deliberately have different layouts:

```swift
VStack(
    alignment: .leading,
    spacing: self.style.spacing(LLSpacing.content)
) {

    content()

}

func start(onLaunchStateChanged: @escaping (LaunchScreenService.State) -> Void,
           onAuthError: @escaping (Error) -> Void,
           onNoNetwork: @escaping () -> Void,
           onHealthCheckResult: @escaping (_ requiresForceUpdate: Bool) -> Void)

init(analyticsService: AnalyticsServiceProtocol,
     authService: AuthServiceProtocol,
     viewLifecycleService: ViewLifecycleServiceProtocol,
     environmentService: EnvironmentServiceProtocol,
     localNotificationService: LocalNotificationServiceProtocol) {

    self.analyticsService = analyticsService
    self.authService = authService
    self.viewLifecycleService = viewLifecycleService
    self.environmentService = environmentService
    self.localNotificationService = localNotificationService

}

func llTextFieldStyle(text: String,
                      title: String? = nil,
                      icon: RNImageSource? = nil,
                      isFocused: Bool,
                      backgroundColor: RNColorSource = .background(.secondary)) -> some View {

    modifier(LLTextFieldViewModifier(
        text: text,
        title: title,
        icon: icon,
        isFocused: isFocused,
        backgroundColor: backgroundColor
    ))

}
```

Guard exits and expanded actor blocks use explicit interior spacing:

```swift
guard self.didInitializeSDK else {

    self.isReady = false
    self.shouldUseSDK = false

    return

}

await MainActor.run { [weak self] in

    self?.isReady = true
    self?.refreshState()

}
```

### Readable expressions and conditions

- Give nested calculations and complicated conditions meaningful local names before using their results. Split nested `min`/`max` clamps, mixed `&&`/`||` expressions, and long chains of checks into named steps or related groups. Keep each simple `min`/`max` call inline; do not solve expression complexity by expanding its argument list.
- A long condition includes three or more checks joined by `&&`/`||`. Name the underlying checks or combine them into meaningful groups so the final condition reads in domain terms. Two-part conditions can stay direct when their intent is already clear; name nontrivial calculations, validation thresholds, or chained transformations when they obscure that intent. Do not introduce a helper, model, or wrapper just to name an expression.
- Preserve parentheses, operand order, bounds, and short-circuit behavior. Pure calculations from local or stored values may be named eagerly. Do not eagerly evaluate service calls, computed dependencies, optional-dependent checks, side effects, throwing work, or async work that was previously conditional. Use an early guard or a local computed variable when a later check must remain lazy. Do not cache a live condition across an `await` or move it across state changes.

```swift
let requestedIndex = attempt - 1
let lastDelayIndex = self.rateLimitRetryDelays.count - 1
let cappedIndex = min(requestedIndex, lastDelayIndex)
let delayIndex = max(0, cappedIndex)

let didRecognitionFinish = isFinal || errorMessage != nil
let shouldRestartRecognition = didRecognitionFinish && self.isRecording

if shouldRestartRecognition {

    restartRecognition()

}
```

### Switch layout

- Put the first `case` immediately below `switch ... {`, and the switch's closing `}` immediately below its final case body. Do not insert blank lines at these two boundaries, even when the final body is expanded.
- Keep a single simple value, direct return, or assignment on the case line, such as `case .settings: name = "settings"`, `case .permission: return false`, or `default: return`. This includes straightforward factory/enum construction such as `case .photos: return .systemImage("person.fill")` and `case .routes: return .devSetting(.routes)`, whether the result uses an explicit `return` or an implicit switch expression. A simple inline `min`/`max` result may also stay on the case line. These are value-producing cases with no additional work.
- Put other calls, calculations, nested control flow, and multiple statements below the label, with a blank line after the label and before the next case. Simple factory construction and inline `min`/`max` results follow the compact exception above; do not compact an arbitrary method call or a multiline constructor. Separate a neighboring compact case from an expanded case with a blank line. The final case still touches the switch's closing brace.
- When several patterns share one result, keep the first pattern after `case`, place each remaining pattern on its own line indented two levels beyond the case label, and keep the final colon with the last pattern. Put even a single-value return below this grouped label with a blank line above it and before the following case. In a switch containing grouped patterns, also put a neighboring simple single-pattern result below its label; that short body does not need a blank line after its label.

```swift
var screenName: String {

    var name: String

    switch self {
    case .settings: name = "settings"
    case .components: name = "components"
    case .routes: name = "routes"
    }

    return "dev_settings_\(name)"

}

private func isFeaturePage(_ page: OnboardingPage) -> Bool {

    switch page {
    case .businessSetup,
            .locationControl,
            .photos,
            .beforeAndAfter,
            .documentation:

        return true

    case .permission:
        return false
    }

}
```

### Naming and file ownership

- Use canonical LeafLaunch domain language and nearby model names. Avoid vague abbreviations, generic `data`/`item` names where the domain is known, and type names that obscure lifecycle or ownership.
- Name screens that list a specific kind of data with a singular domain name followed by `ListScreen` and `ListViewModel`, such as `ProductListScreen` and `LocationListViewModel`. Keep meaningful scope qualifiers for filtered lists, such as `FavoriteProductListScreen`. Name screens driven by a single domain item with `DetailsScreen` and `DetailsViewModel`. A navigation or tab container uses a container name rather than taking the details name from its content.
- Split independent models and independently owned top-level types into focused Swift files whenever possible. Keep feature/service-specific models near their owner; put shared domain models in the established [Models](../../LeafLaunch/Models) area. Do not extract a private implementation detail into a new abstraction merely to create another file.
- Keep screens, their ViewModels, and feature-only views together under [Screens](../../LeafLaunch/Screens). Put genuinely reusable UI in [Components](../../LeafLaunch/Components).
- When renaming a primary type, synchronize its filename, file header, references, and explicit Xcode project membership. Use `// MARK: -` only when it improves navigation.
- Logger names use fully separated `SCREAMING_SNAKE_CASE`, including every lexical word: `PROJECT_CHAT_VIEW_MODEL`, never `PROJECTCHAT_VIEW_MODEL`.

## Screens and ViewModels

### View and screen member order

Order populated view and screen member sections as follows, with at least one blank line between sections. Omit empty sections:

1. Locally declared models and nested types, such as `struct`, `enum`, and `typealias`
2. `@Environment` and `@EnvironmentObject`
3. `@Binding`
4. `@State` and `@StateObject`
5. `@FocusState`
6. Other stored properties
7. Non-view computed properties
8. Initialization and non-view methods
9. View logic: `body`, the navigation-header helper, content, sections, rows, cards, overlays, and other `some View` builders

Keep neighboring declarations with the same property wrapper together, with no blank lines between them. This also applies to consecutive `@Published` properties in ViewModels. Use a blank line between member sections and wrapper groups, such as `@Environment` → `@Binding` → `@State`/`@StateObject` → `@FocusState`. Preserve declaration order and initializer timing; this grouping rule does not authorize moving or renaming state.

Local model/type declarations also come first in ViewModels, above logging identifiers, dependencies, navigation, task handles, published state, and all other properties. This ordering does not change model ownership: independent models still belong in separate feature-owned files; keep an existing nested implementation type at the top of its owner.

Keep `body` and view-producing helpers in the final section. Keep the navigation header as a focused helper, called directly from the header closure. Prefer `navHeader()` in new standard screens; retain an established feature helper name such as `headerView()` when changing an existing screen.

```swift
LLAppHeaderScrollView {
    navHeader()
} scrollViewContent: {
    content()
}
```

### ViewModel contract and ownership

- Standard screen ViewModels are `final class` types conforming to [ViewModel](../../LeafLaunch/Models/System/ViewModel.swift) or an existing specialized project ViewModel protocol. Preserve the project's actor-isolation contract; UI mutation belongs on `@MainActor`.
- Treat `loggerName`, `loggerEmoji`, `logInit()`, and `logDeinit()` as one lifecycle contract. Pair initialization logging with deinitialization logging and owned-task cleanup.
- Hold screen-injected navigation services weakly. Do not make navigation state a second ownership root.
- For route-created screens, install every required route/context value with `@discardableResult func setup(...) -> Self` before the screen can track, appear, or load. Follow the existing [LegalDetailsViewModel](../../LeafLaunch/Screens/Settings/Legal/LegalDetailsViewModel.swift) route-setup pattern; this does not require unrelated navigation-only setup methods to become chainable.
- Let the screen own its injected ViewModel with `@StateObject`; when providing an explicit initializer, initialize `_viewModel = StateObject(wrappedValue: viewModel)`. Child views and extracted forms use `@ObservedObject` to observe the same instance. Do not create a second owner or resolve a replacement during view construction.
- Never bind screen publishers in `init`. Temporary navigation-destination construction must not create live subscriptions. Repeated binding must be idempotent: guard existing bindings or intentionally replace the `CancelBag` before rebinding.

### Lifecycle and analytics

- Use `.onFirstAppear { [weak viewModel] in ... }` for standard first-appearance wiring. Inject navigation before calling `handleFirstAppear()` or starting work that can navigate.
- Make `handleFirstAppear()` call `track()` exactly once for the first-appearance flow, before applicable subscriber binding. Standard screens that use this entry point must not also call `viewModel.track()` directly.
- Keep `track()` in the final same-type extension in the primary ViewModel file. Track screen views through `self.analyticsService.track(screen:)` there.
- Add the matching [ScreenEvent](../../LeafLaunch/Services/Analytics/Models/ScreenEvent.swift) case and preserve its `screen_view` mapping. Include applicable LeafLaunch context, such as a user ID or legal context; compact nil properties before emission. Do not import unrelated domain IDs from another app.
- Keep intent, success, mutation, and error analytics beside the action that causes them rather than in screen `track()`.
- Use `.task { [weak viewModel] in viewModel?.loadData(showHud: self.viewModel.isFirstLoad) }` for initial loading and reappearance refresh on fetch-backed screens with `loadData(showHud:)`. Expose read-only `isFirstLoad`, derive it from existing successful-load state when possible, and default `showHud` to `false`. Only a successful uncancelled load clears first-load state; failed initial loads retain HUD/retry recovery. Keep reload timing and never reset this state on reappearance. Explicit screen actions opt into `showHud: true` only when modal feedback is needed. Keep `handleFirstAppear()` focused on tracking and idempotent subscriber binding; it must not start the same fetch. The loader owns its named cancellable tasks and accepts `showHud` when a loading alert applies. When it starts a stored unstructured task, SwiftUI’s `.task` does not automatically cancel that separate task on disappearance; replacement/deinitialization and any required explicit lifecycle cancellation belong to its owner. Root's `.task` starts the startup coordinator while the splash owns launch feedback. Screens with no initial data load do not need empty task hooks.
- Forward `.onDisappear { [weak viewModel] in ... }` cleanup for active capture, realtime, playback, recording, or similar sessions. Do not add empty lifecycle hooks to screens without that responsibility.
- Root, splash, and startup surfaces have nonstandard lifecycle sequencing. Preserve their documented ownership and timing; do not mechanically apply standard screen wiring to them.

### Readable SwiftUI composition

- Keep `body` declarative and focused on composition, lifecycle hooks, and presentation. Keep side effects out of view construction; use established ViewModel actions and lifecycle entry points.
- **Hard rule: compose views with small, named `@ContentBuilder` methods.** Keep `content()` as a short list of section/action calls inside the necessary layout and state branches. Put repeated collections in section helpers and each row/card in its own helper. Split nested layouts further when they obscure the visible responsibility.
- Annotate focused `private func section() -> some View` helpers with `@ContentBuilder`, including helpers with one root container. Use feature names such as `products()`, `productRow(_:)`, or `loadProfile()`, and pass only the values each block needs.
- Keep extraction local: use private methods and existing components. A composition helper does not justify another ViewModel, protocol, wrapper, configuration layer, or file. A separate view needs real reuse or an independently owned responsibility; avoid helpers that only rename a modifier chain without improving readability.
- Preserve stable `ForEach` identity. Use `\.self` only when the values remain stable and unique for the collection's lifetime.
- Respect accessibility, Dynamic Type, localization, and reduced-motion behavior in touched UI.
- Every `VStack`, `HStack`, and lazy stack declares explicit spacing through the active style and [LLSpacing](../../LeafLaunch/Services/DesignSystem/LLSpacing.swift), including previews. Configurable components resolve their caller-provided `RNTheme.SpacingKey`. Use `LLSpacing.none` only for intentionally touching layouts.
- Follow the [typed design-token rules](../reference/GLOBAL_UI_CONVENTIONS.md#typed-design-tokens): use a matching semantic spacing role or token from the correct property family. Keep LeafLaunch's existing geometry and theme scales; unmatched values use that family's `.custom(...)`.
- Do not manufacture layout with fixed minimum-height spacers such as `.frame(maxWidth: .infinity, minHeight: 360)`. Use the scroll container, safe area, and content to determine available space.
- Use `.frame(maxWidth: .infinity, alignment:)` or `.frame(maxHeight: .infinity, alignment:)` on the content that owns the available space instead of `Spacer()`. Preserve intentional minimum gaps through stack spacing or semantic padding.
- For activity timelines, calculate whether a trailing connector is visible in the parent sequence and pass that value into the card. The last item must not draw a connector below itself; the card should not infer its position from global state.

## Async tasks, loading, and cancellation

- Store independently cancellable unstructured work in named task properties. Use the existing task-ownership pattern; do not add a task-management framework. View-scoped structured work can remain owned by `.task`.
- Cancel replaceable work before assigning its replacement. Cancel every stored task during deinitialization; use `isolated deinit` when required by the owning type's isolation.
- Snapshot dependencies, required IDs, and request inputs before entering a task so work cannot race mutable ViewModel setup or retain the ViewModel unnecessarily.
- Capture the ViewModel weakly in long-lived tasks and mutate UI state on `@MainActor`. Avoid holding a strong ViewModel reference across a long suspension merely to read dependencies that could have been captured separately.
- Check cancellation before committing results, marking a load successful, emitting success effects, navigating, or presenting errors. Cancellation must not become a user-facing failure.
- In async catch blocks, check `Task.isCancelled` before logging, wrapping, retrying, publishing, presenting an error, or running failure rollback. Use one cancellation guard: `guard !Task.isCancelled else { throw APIError.cancelled }` in `throws(APIError)` methods, `guard !Task.isCancelled else { throw CancellationError() }` in other throwing methods, or `guard !Task.isCancelled else { return }` in nonthrowing task owners. Do not add a second error-type check. Keep required cleanup and task-owned alert dismissal intact. This policy checks cancellation of the current task; an error from a dependency alone does not mark that task cancelled. Firebase authentication also preserves explicit propagation of its existing user-identity invalidation `CancellationError` even if the current task flag is false; this is a context guard, not duplicate task-cancellation detection. A cancelled or superseded bootstrap must not publish completion from `defer`; real failures retain their existing recovery and launch-gate behavior.
- Qualify API cancellation throws as `APIError.cancelled`. A nested `do`/`catch` can infer `any Error` for its thrown values even inside a `throws(APIError)` method, so shorthand `.cancelled` may not resolve.
- Give these catch blocks a blank line after the opening brace and before the closing brace. Put the remaining error handling immediately below the cancellation guard, with no blank line between them:

```swift
catch {

    guard !Task.isCancelled else { throw APIError.cancelled }
    throw APIError.unknownError

}
```

- Use `defer` for paired cleanup and loading-state completion. A cancelled operation must still dismiss the presentation it owns, without committing results or marking initial loading successful. A superseded task's cleanup must not clear a newer task's loading state or presentation; preserve existing ownership guards.
- For fetch-backed screens that distinguish initial loading from empty content, keep `isLoading`, `hasCompletedInitialLoad`, `hasContent`, and `shouldShowEmptyState` (or equivalent existing state) coherent. Show empty state only after an initial load succeeds and without content. Retain the resolved empty result during refresh of the same context, including refresh failure; loading flags must not hide and reinsert it. Initial unresolved requests or permission checks must remain neutral/progress content, including the render before `.task` begins; do not treat a cancelled/failed initial request as a successful empty response.
- Follow the [loading and alert contract](../examples/VIEW_MODEL_LOADING_AND_ALERTS.md) for new standard `loadData(showHud:)` flows: cancel the previous load, set `isLoading`, snapshot dependencies/context, and start `Task { @MainActor [weak self] in ... }`. Check cancellation before side effects and after awaited work. For cancel-before-replace tasks, clear the handle/loading flag in `defer` only when `!Task.isCancelled`; cancelled cleanup must not clear newer work.
- Preserve intentional single-flight gates for pagination, mutations, or coupled request sequences. Keep existing request IDs, authenticated-user checks, and store/query context guards when cancellation alone cannot establish ownership. An explicit cancellation/reset path must reset its own state; do not rely on cancelled-task cleanup to do so.
- Create a unique `RNAlert(.simpleLoadingIndicator)` inside each task. Show it through the snapshotted RNAlertService only when `showHud` is true and dismiss that exact instance with `dismissAlert(loadingIndicator)` in `defer`, including cancellation. Broad calls such as `dismissLoadingIndicator()`, `dismiss()`, or `dismissAll()` can remove another operation's loader or its error alert.
- Present screen errors from the owning ViewModel through its injected `RNAlertServiceProtocol` and a focused `presentError(...)` helper. Never use `.runeErrorHandler` or publish an `Error` solely to trigger an alert. Keep inline error state only for persistent failure/retry UI. Check cancellation/ownership before presentation and retain previous content on refresh failure.
- Keep reusable alert copy in `Constants.Message`. The actual formatter is `errorMessage(context:_:)`, for example `Constants.Message.errorMessage(context: .get, "profile")`; the topic is unlabeled. Choose `.get`, `.create`, `.update`, or `.delete` for the attempted operation. Add focused messages for non-CRUD wording rather than exposing raw transport errors. Constants contain copy, not services, navigation, API calls, or capture ownership.
- Keep success, error, and confirmation presentation in focused ViewModel methods. Present success only after a successful, uncancelled mutation; fetching does not require a success alert. Alert callbacks that reference the ViewModel capture it weakly. Independent actions own independent task properties and deinitialization cancellation. Do not add unused subscriber bags or bind subscriptions in `init`.
- A failed initial load must leave a retry control reachable. Mark initial completion only after required requests succeed; use `try?` only for deliberately optional work with an explicit fallback. Snapshot required IDs/query values, check cancellation before sequential follow-up operations, and use `async let` for independent required requests before committing their results.

## Rune and app-owned UI

- Search [LeafLaunch components](../../LeafLaunch/Components) and the [Rune component catalog](../reference/UBIQUITOUS_COMPONENTS_GLOBAL.md) before implementing custom UI. Verify the actual API in the relevant source; a catalog entry is a discovery aid.
- Prefer an existing LeafLaunch wrapper when it covers the use case. For example, [LeafLaunchButton](../../LeafLaunch/Components/Base/LeafLaunchButton.swift) owns app-specific button defaults and uses Rune's `runeAsButton` for action feedback.
- When matching call sites repeatedly override the same Rune defaults, extract that treatment into a focused app component or modifier and migrate those callers. Centralize its padding, typography, colors, border, radius, or shadow; expose only options required by current use cases, not Rune’s full parameter list or speculative variants.
- Add a small app component only when a repeated treatment or concrete product-specific behavior justifies it. Keep Rune details inside that component and expose a focused API expressing product intent, rather than forwarding every Rune parameter. Do not wrap every primitive solely for naming consistency.
- Raw Rune components remain appropriate inside wrappers and when no app wrapper covers the need. Promote repeated app-specific treatments before they spread. Flag custom components/raw visual tokens only when an existing Rune or app primitive clearly covers the same use case; record the concrete gap when a new reusable component is necessary.
- Publish `.runeStyle(RNStyle.shared)` and `.runeImageCache(.standard)` at the app and preview roots. `.runeStyle` provides environment style, theme invalidation, and color scheme; a bare `.environment(\.style, ...)` does not supply that complete contract. Use `@Environment(\.style)` and `self.style` in production views with environment access. Reserve `RNStyle.shared` for static defaults or contexts without environment access.
- Use semantic typography, spacing, radius, and color tokens when available. Choose typography by semantic role and compare scale with adjacent screens. Use the active environment's container and section spacing rather than isolated hardcoded values.
- Treat `RNColorSource` as a dynamic `ShapeStyle`; pass it directly where supported. Prefer `.runeTextColor`, `.runeForeground`, `.runeBackground`, `.runeTint`, and `.runeFill` for their supported roles, and `.runePadding`, `.runeCornerRadius`, `.runeFont`, and `.runeShadow` for theme tokens. Palette roles and caller-provided sources can use native style modifiers when Rune has no matching overload. Use `.source(style: self.style)` or `.resolvedColor(style: self.style)` only when an API needs an explicit bridge; `.asColor` only unwraps a concrete color.
- Use `RNImageSource` for Rune-backed system, resource, local, and remote images. Avoid raw `Image(systemName:)`, `AsyncImage`, or a new image cache when an existing image source or app wrapper covers the need. Drawing/canvas and framework-interoperability uses can require native image APIs.
- Prefer an existing remote-image wrapper when it supplies the required cache, thumbnail, content-mode, and placeholder behavior. Do not create one unless the current feature has an uncovered need.
- Gate heavy content on data readiness and keep those conditions beside the affected content.
- Scope animation with `.animation(_:value:)` to the driving state. Use transitions for meaningful inserted/removed groups and targeted content transitions when continuity helps. Add geometry or compositing groups only when complex animated elements need rendering coherence.
- Keep sheet/overlay triggers in the ViewModel and use the project's established presentation styles. Keep preview, navigation, analytics, and first-appearance wiring consistent with the feature and the lifecycle contract above.

Follow [global UI conventions](../reference/GLOBAL_UI_CONVENTIONS.md) for open sections, semantic spacing, app-owned actions, and segmented-content replacement. Use `runeAsButton` for app actions while preserving native destructive/system roles, focus gestures, geometry, disabled/loading state, and single haptic ownership. Keep scroll/task/focus/editor ownership outside replacement identity.

The current app-owned treatments are:

- [LLAppCardView](../../LeafLaunch/Components/Base/LLAppCardView.swift) owns the shared Rune card defaults; [CommerceSurface](../../LeafLaunch/Components/Commerce/CommerceSurface.swift) applies the storefront's `.large` radius, and [LeafLaunchCardView](../../LeafLaunch/Components/Base/LeafLaunchCardView.swift) adds a title. Reuse the appropriate level instead of recreating its treatment in screens.
- [LLDivider](../../LeafLaunch/Components/Base/LLDivider.swift) owns horizontal separators with the active style's `background(.quaternary)` and a 1.25-point height. Use it instead of SwiftUI `Divider()` or repeated horizontal separator rectangles. `LLAppCardView` owns the shared 0.8-point Rune card border.
- [LLAppHeaderScrollView](../../LeafLaunch/Components/Base/LLAppHeaderScrollView.swift) owns Rune header/content composition with `LLSpacing.pageInset` horizontal content padding. Suitable read-only fetch-backed screens pass async `onRefresh:` and await the actual ViewModel task; routine refresh suppresses HUDs. Preserve the catalog's specialized result feedback and editor field timing. Navigation content retains its own layout. A screen with intentional different padding, such as Home's default `.large`, may keep the Rune primitive.
- [llTextFieldStyle](../../LeafLaunch/ViewModifiers/LLTextFieldViewModifier.swift) owns a separate title and the local [LLCommonTextFieldStyle](../../LeafLaunch/Components/Base/LLCommonTextFieldStyle.swift). This focused adaptation of Rune’s field style keeps the 48-point height, required leading icon, no shadow, and `.medium2` radius while owning an inset 0.8-point outline that uses `background.border` when unfocused and the active accent when focused. Placeholder text and unfocused icons use `text.placeholder`; focus accents the border, icon, and cursor. Keep native focus bindings on the input before this wrapper; callers retain example prompts, keyboard/content types, secure entry, validation, and submission behavior. Focus styling must not change the input height or title gap.
- [tabFlowContentSpacing](../../LeafLaunch/ViewModifiers/TabFlowContentSpacingModifier.swift) adds 120 points **inside the tab screen's scrolling content** so final actions clear the custom tab bar. Do not apply it to the header or outer scrolling container. Preserve the account authentication-route safe-area inset in [StoreContainerScreen](../../LeafLaunch/Screens/StoreDetails/StoreContainerScreen.swift): pushed auth screens do not own that tab-root content inset.

### Empty states at the screen root

This overlay contract applies when a feature uses `emptyStateOverlay`. LeafLaunch’s [CommerceEmptyState](../../LeafLaunch/Components/Commerce/CommerceEmptyState.swift) is intentionally contextual: catalog filters, sorting, and surrounding actions stay available during empty/retry states. Do not replace it with a full-screen overlay merely to match an upstream list example.

Apply `emptyStateOverlay` to the `LLAppHeaderScrollView` (or intentional Rune `RNHeaderScrollView`) chain after constructing it, rather than inside `content()`. The overlay must cover the full screen context, including the header, instead of only the scrolling content.

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

- Preserve [StoreContainerScreen](../../LeafLaunch/Screens/StoreDetails/StoreContainerScreen.swift) as owner of the three customer tabs (Store, Menu, Account) and their independent navigation roots. Its custom bar hides the native tab bar and native tab-bar background. Keep per-tab context, selection, route stacks, and keyboard behavior intact; do not replace the customer experience with upstream showcase tabs.
- Use [NavBarButton](../../LeafLaunch/Components/Nav/NavBarButton.swift), [NavHeader](../../LeafLaunch/Components/Nav/NavHeader.swift), and [TabItemView](../../LeafLaunch/Screens/Tab/TabViews/TabItemView.swift) for shared navigation treatments. Every app navigation header uses `NavHeader`, including Settings, authentication, legal, and developer screens; do not substitute Rune `RNNavBarView` or a custom header. Navigation actions use the shared 32-point outlined circle with at least a 44-point touch target. Navigation and section titles use `LeafLaunchThemeTokens.headingFont` (`HEADER_3`, as defined by the runtime theme). Keep these sizes in the shared owners without per-screen overrides. Keep the independently maintained `NavBarButton.Style` model in its own file. Use `RNImageSource` and Rune `runeBadge` where appropriate; positive badges cap visible text at `99+` and do not affect layout. Preserve accessible action names and selection semantics.
- Let long content grow through actual rows, stable identity, and the existing vertical scroll owner. Use lazy stacks where appropriate. Manual scrolling checks should reach a final row/action; do not fake overflow with spacer heights or introduce nested vertical scrolling without a concrete presentation need.
- Select appearance through [AvailableTheme](../../LeafLaunch/Services/DesignSystem/ThemeRegistry.swift) and the existing `UserDefaultsServiceProtocol.set(theme:)`. Keep live/mock behavior, theme publishers, mock previews, and the active Rune style consistent. Preserve the synchronous target-scoped store-theme cache and runtime branding rules in the [customer contract](../reference/CUSTOMER_ARCHITECTURE.md#persistence-and-theme).
- Runtime LeafLaunch theme definitions remain canonical; [DESIGN.md](../../DESIGN.md) documents their intent. Use semantic roles for colors, fonts, radii, shadows, and interaction; an upstream palette, font family, asset, radius scale, spring, or screenshot does not authorize a global redesign. A deliberate local modal/capsule radius may differ from ordinary card roles without redefining the shared scale.
- Present app modal cards through the injected RNAlertService and focused `RNAlertCardConfig` factories in [Components/Alerts](../../LeafLaunch/Components/Alerts), such as [invitationAlert](../../LeafLaunch/Components/Alerts/InvitationAlert.swift) and its [InvitationAlertView](../../LeafLaunch/Components/Alerts/InvitationAlertView.swift). Keep configuration separate from its view, dismiss the card before invoking its completion action when that is the contract, and keep callbacks weak when they capture a ViewModel. Use Rune’s `RNToastManager.shared` for toast presentation when the feature needs a toast; do not add another feedback service.
- Modal content must retain readable wrapping, a reachable dismissal action, and accessibility semantics. For content that can exceed the modal height, follow a fitting layout with an appropriate scrolling fallback instead of clipping details or shrinking text into fixed bounds. Decorative grabbers/icons should not compete with actionable labels.

## Feature integration parity

Apply only the integrations affected by the change; do not create unused services, events, routes, or mock infrastructure to satisfy a checklist.

- For a new or changed ViewModel, keep [live factories](../../LeafLaunch/DI/Live/ViewModelAssembly.swift), [mock factories](../../LeafLaunch/DI/Mock/MockViewModelAssembly.swift), and the [mock resolver](../../LeafLaunch/DI/Mock/MockAssembler.swift) in parity. Match actor annotations and constructor signatures.
- For a service dependency, update its protocol and relevant [live](../../LeafLaunch/DI/Live/ServiceAssembly.swift) and [mock](../../LeafLaunch/DI/Mock/MockServiceAssembly.swift) registrations and direct callers.
- Put `#Preview` blocks at the bottom of each new view file, using the project's spacious Swift formatting. Use `mockResolve(...)`, required chainable route/context setup, existing shared fixtures such as [MockModels](../../LeafLaunch/DI/Mock/MockModels.swift), and `.withMockPreviews()` for the Rune canvas and mock service/style environments. Do not duplicate fixture construction or accidentally resolve live services.
- Pair each new [route](../../LeafLaunch/Services/Navigation/Models/Routes.swift) with its [navigation destination](../../LeafLaunch/Services/Navigation/NavigationService.swift). Resolve the live ViewModel and install route context before the screen can track or load. Preserve route families, tab ownership, sheets, adaptive sheets where used, and full-screen-cover behavior.
- Public customer models decode explicit public projections; never ingest protected Store relationships into launch data. The app key resolves StoreAppConfiguration and must agree with the target Store ID. Effective age-policy and server-sort contracts belong to the existing API domain owners; retain them in live/mock/preview parity.
- Restore the validated target-scoped theme definition synchronously before Root/splash creation. Cache serializable branding plus resolved supported radius roles and reconstruct Rune RNTheme; do not serialize Rune UI types or add asynchronous startup application/expiration.
- For API work, update [APIServiceProtocol](<../../LeafLaunch/Services/API/Rest API/APIServiceProtocol.swift>) first, then the applicable live endpoint, mock endpoint, and fixtures. Preserve signatures, isolation, request/response contracts, and expected errors.
- Find the actual mock endpoint authority instead of assuming it lives in DI. LeafLaunch's `MockAPIService` is currently defined in [MockServiceAssembly.swift](../../LeafLaunch/DI/Mock/MockServiceAssembly.swift); inspect it and the [live endpoint extensions](<../../LeafLaunch/Services/API/Rest API/Endpoints>) for the affected call.
- Reuse shared request encoding, response decoding, query conversion, and existing configurable mock error/value helpers where available. Make fixtures realistic enough for the filtering or pagination behavior the UI uses; do not build unused mock configuration layers.
- Reuse centralized domain permission helpers when applicable. Do not duplicate role, membership, mutation, or visibility decisions in screens or ViewModels, or invent a new permission architecture for a feature that does not need it.
- Add new Swift files to the appropriate target in [project.pbxproj](../../LeafLaunch.xcodeproj/project.pbxproj); LeafLaunch uses explicit file references.

## Verification and scope

- Do not run Xcode builds unless the user explicitly asks. Do not write tests. Do not run tests without an explicit request.
- For documentation-only work, verify local links and section anchors, run `git diff --check`, and confirm the diff contains only the requested documentation.
- For Swift work, inspect changed call sites, ownership/cancellation paths, affected live/mock/preview registrations, navigation and analytics wiring, and target membership as applicable. Report what needs build/runtime verification without running an unauthorized build.
- Keep validation proportional to the change. These rules do not authorize unrelated refactoring or code changes during a documentation-only task.

## Source references

The [Grimoire practice review](../reference/GRIMOIRE_PRACTICES_REVIEW.md) records the 2026-10-17 baseline and the selected 2026-11-16 adoption, including superseded details and LeafLaunch-specific adaptations. It supplements the references below.

Adapted from Skillet's [Swift semantic-linter references](https://github.com/SakoHovaguimian/Skillet/tree/main/skills/swift-sako-semantic-linter/references), reviewed at commit `88d780b09a34313c66fadea4a6a343cc12353fb4`. The rules above are local guidance, so applying them does not require fetching the source on every task. LeafLaunch-specific names, placement, lifecycle exceptions, and the simplicity/scope requirements above govern their application. The spacious whitespace convention follows the user's corrected worked example and takes precedence over the upstream advice against spacing inside braces.

- [Core Swift](https://github.com/SakoHovaguimian/Skillet/blob/88d780b09a34313c66fadea4a6a343cc12353fb4/skills/swift-sako-semantic-linter/references/core-swift.md): member access, formatting, naming, ownership, and safety boundaries.
- [Screens and ViewModels](https://github.com/SakoHovaguimian/Skillet/blob/88d780b09a34313c66fadea4a6a343cc12353fb4/skills/swift-sako-semantic-linter/references/screen-viewmodel.md): member order, ownership, lifecycle, composition, and analytics.
- [Async safety](https://github.com/SakoHovaguimian/Skillet/blob/88d780b09a34313c66fadea4a6a343cc12353fb4/skills/swift-sako-semantic-linter/references/async-safety.md): tasks, cancellation, and loading state.
- [Rune UI](https://github.com/SakoHovaguimian/Skillet/blob/88d780b09a34313c66fadea4a6a343cc12353fb4/skills/swift-sako-semantic-linter/references/rune-ui.md): component reuse, style authority, semantic tokens, images, animation, and presentation.
- [Integration parity](https://github.com/SakoHovaguimian/Skillet/blob/88d780b09a34313c66fadea4a6a343cc12353fb4/skills/swift-sako-semantic-linter/references/integration-parity.md): DI, previews, navigation, APIs, fixtures, and permissions.
