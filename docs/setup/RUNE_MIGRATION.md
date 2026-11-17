# Rune migration

LeafLaunch uses the remote `Rune` package on `main`, pinned to `764ca91fc44abf4b37c1f77c8355d94398ae58af` in [Package.resolved](../../LeafLaunch.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved). That revision includes the naming migration from `d98aa96` and the later corner-treatment APIs. Its manifest requires Swift tools 6.4, Swift 6 language mode, and iOS 26. LeafLaunch retains its existing iOS 26 deployment targets and `@_exported import Rune`.

The package, product, and module stay `Rune`. Rune-owned types use `RN` names and Rune-specific modifiers use `.rune…`; do not add aliases for removed names. The obsolete Kingfisher transitive pin is removed because the current Rune manifest has no external package dependencies.

## Integration owners

- [App.swift](../../LeafLaunch/App.swift) and the [mock preview host](../../LeafLaunch/DI/Mock/MockAssembler.swift) publish `.runeImageCache(.standard)` and `.runeStyle(RNStyle.shared)` outside their presentation chains. Style publication provides the environment style, theme invalidation token, and color scheme.
- [ThemeRegistry](../../LeafLaunch/Services/DesignSystem/ThemeRegistry.swift), the [theme builder](../../LeafLaunch/Services/DesignSystem/StoreThemeBuilder.swift), and [user defaults](../../LeafLaunch/Services/UserDefaults/UserDefaultsService.swift) use `RNTheme`, `RNThemeProtocol`, and `RNStyleProtocol`. Theme identifiers, preference raw values, cached branding, palettes, fonts, spacing, and radii retain their existing values.
- [ServiceAssembly](../../LeafLaunch/DI/Live/ServiceAssembly.swift) and [MockServiceAssembly](../../LeafLaunch/DI/Mock/MockServiceAssembly.swift) register the renamed alert contracts with the same scopes. Presentation owners retain one `RNObservableAlertServiceWrapper` over the intended injected service. Custom window channels keep their existing identifiers.
- [Shared components](../../LeafLaunch/Components) keep LeafLaunch names and product defaults while using `runeAsButton`, `RNCardView`, `RNHeaderScrollView`, `RNImageSource`, and the other renamed Rune APIs internally.

## Semantic modifiers

Views and modifiers read `@Environment(\.style)` for active styling. Use these APIs for the corresponding responsibilities:

| Responsibility | API |
| --- | --- |
| Font | `.runeFont(with: .BODY_1)` |
| Title/body copy | `.runeTextColor(.title)` / `.runeTextColor(.body)` |
| Foreground role | `.runeForeground(.primary)` |
| Background role | `.runeBackground(.secondary)` |
| Control tint from a foreground role | `.runeTint(.primary)` |
| Shape fill | `.runeFill(.background(.secondary))` |
| Padding | `.runePadding(.horizontal, .medium)` |
| Exact scalar or calculated padding | `.runePadding(.bottom, .custom(value))` |
| Radius | `.runeCornerRadius(.medium2)` |
| Border and shadow | `.runeBorder(...)` / `.runeShadow(...)` |
| Custom action | `.runeAsButton(...)` |

`runeForeground` and `runeTint` take foreground keys; `runeBackground` takes a background key. Palette roles, caller-provided sources, conditional sources, custom background views, and inherited native tint can keep native SwiftUI style APIs when Rune has no equivalent overload. For example, `.foregroundStyle(RNColorSource.palette(.link))` and `.tint(RNColorSource.palette(.link))` preserve the independent store accent instead of substituting the button-fill foreground role.

`RNColorSource` conforms to `ShapeStyle` and resolves semantic references against the rendering environment. Pass the source directly where possible. Bridges that need concrete styles or colors explicitly use `source(style: self.style)` or `resolvedColor(style: self.style)`. The `asColor`, `asGradient`, and `asMaterial` accessors only unwrap concrete cases. Do not cache resolved semantic colors across theme changes or introduce semantic cycles in theme definitions.

Use theme roles where they match the responsibility. Preserve scalar drawing/media dimensions, line widths, animation timing, and exact custom layout offsets. Alert card configuration uses `RNCornerRadius.theme(...)` when it should follow the presentation theme. Nested tokens remain under `RNTheme`; app-owned models such as `NavBarButton.Style` keep their names.

## Presentation and behavior

Errors remain in ViewModels using the injected `RNAlertServiceProtocol` and `.runeAlert(...)` factories. Every loading operation creates its own `RNAlert(.simpleLoadingIndicator)` and dismisses that exact instance in `defer`, including cancellation. Preserve task cancellation, generation and identity guards, successful content during refresh, single-flight mutations, and existing screen lifecycle behavior. See the [loading contract](../examples/VIEW_MODEL_LOADING_AND_ALERTS.md).

Images use `RNImageSource.view()` or `RNImageView(source:)`, retaining placeholders, sizing, clipping, ordering, and stable gallery identity. Toasts use `RNToastManager.shared` and `RNToastItem`, with explicit timing where automatic dismissal is intended. Header refresh continues awaiting the existing refresh work and keeps one vertical scroll owner.

LeafLaunch uses small named `@ContentBuilder` helpers and content closures, following the adopted Grimoire composition convention. FactoryKit registrations, navigation, analytics, and observation ownership remain with their existing owners. The current SwiftUI toolchain and pinned Rune source support `ContentBuilder`.

## Verification

Review signatures against the pinned Rune source, inspect live/mock/preview parity, check residual removed symbols and native styling calls, and verify explicit target membership. Swift syntax parsing, plist/JSON validation, documentation-link checks, and `git diff --check` are source checks; they do not establish dependency typechecking or runtime behavior. Do not write tests. Do not run Xcode builds or tests without an explicit user request.

The migration source review passed Swift syntax parsing for all 278 production Swift files, plist/lockfile validation, and explicit source membership for both app targets. No Xcode build, dependency typecheck, tests, or runtime checks were performed. The dependency lock was updated to the verified remote revision without running Xcode’s package update operation.
