# Global UI Conventions

Use these rules with the [implementation guide](../guides/IMPLEMENTATION_BEST_PRACTICES.md), [design contract](../../DESIGN.md), and [loading contract](../examples/VIEW_MODEL_LOADING_AND_ALERTS.md). The active Rune theme and validated store branding remain the runtime authority. Grimoire's component structure does not replace LeafLaunch's colors, font scale, radii, density, or customer navigation.

## Open sections and configurable headers

Use [LLSection](../../LeafLaunch/Components/Base/LLSection.swift) for an open titled content group. It owns heading-to-content and body spacing, an optional leading image, and an optional trailing action. Configure the shared owner instead of assembling another section wrapper.

Keep ordinary sections open. Entity cards, functional controls, existing commerce surfaces, modal cards, and grouped Settings rows retain their established surfaces and geometry. Do not remove a meaningful product surface or add nested cards just to match a template. [CommerceSectionHeader](../../LeafLaunch/Components/Commerce/CommerceSectionHeader.swift) remains the storefront heading/action owner; [SectionView](../../LeafLaunch/Components/Section.swift) supports custom trailing content. Reuse these owners within section composition as appropriate.

## Semantic spacing

[LLSpacing](../../LeafLaunch/Services/DesignSystem/LLSpacing.swift) names layout responsibilities using existing `RNTheme.SpacingKey` values. Resolve keys through `self.style` or pass them directly to Rune-aware padding APIs. It is an alias layer over the existing theme scale, with no second numeric spacing system.

LeafLaunch keeps its established density: `.large` between independent sections, `.medium` for page/form/list spacing, `.small2` between headings and content or cards, `.small` between related controls, and `.extraSmall` for metadata. Use the role matching the current responsibility. Compact metadata/control gaps, hero layouts, and intentionally touching groups use their focused roles. Configurable components can accept a spacing key rather than hardcoding a role.

Every `VStack`, `HStack`, and lazy stack declares explicit style-resolved spacing, including previews. Use `LLSpacing.none` only for intentionally touching layouts. Preserve media dimensions, icon sizes, safe areas, tab-bar clearance, fixed control heights, and deliberate geometry exceptions. Role adoption must not silently normalize different existing gaps to one value.

## Typed design tokens

- Use a matching existing spacing role or design-system token instead of repeating its number at usage sites.
- Match the token family to the property: spacing keys for gaps/padding/insets, radius keys for corner radii, and shadow keys for shadows. Equal numbers do not make unrelated families interchangeable.
- Use the correct family's `.custom(...)` when no token matches, including calculated or negative padding. Do not hide an existing role inside a custom literal.
- Use `runePadding` and `runeCornerRadius` for view padding and corner radii. Resolve through the active style when another API requires a scalar. Drawing shapes retain their shape-specific APIs and style-resolved radius values.
- Keep numeric scale definitions in the owning runtime theme or role. Blur, border widths, media dimensions, animation timing, and other geometry keep their own API semantics.
- Keep custom shadow configurations in `.runeShadow(.custom(...))`; do not substitute a spacing key for a shadow radius.

## Semantic color modifiers

Use `runeForeground`, `runeTextColor`, `runeBackground`, `runeTint`, and `runeFill` for the theme-key families their actual APIs support. Preserve native style modifiers for palette roles, caller-supplied `RNColorSource`, custom background layers, and other inputs without a corresponding Rune overload. Pass `RNColorSource` directly where a `ShapeStyle` is accepted; explicitly resolve against the active style only for a required bridge. See [Rune migration](../setup/RUNE_MIGRATION.md#semantic-modifiers).

## Actions and copy

Use Rune's `runeAsButton` for app-owned actions, through [LeafLaunchButton](../../LeafLaunch/Components/Base/LeafLaunchButton.swift) where its defaults apply. Style the label first, then apply action feedback. Preserve disabled/loading gates, control geometry, and single haptic ownership. Keep native `Button` where system roles or framework integration require it, including destructive menu/dialog actions. Native `Link`, `Picker`, text-field focus, keyboard dismissal, and system-owned controls retain their behavior.

Follow the existing [Title Case rule](../../DESIGN.md#typography) for app-owned prominent labels and actions. Author copy at its source, preserve acronyms, and keep descriptive body copy in sentence case. Preserve fetched and user-entered names, filenames, emails, route identifiers, and analytics values; never enforce display casing with `.capitalized` at render time.

## Segmented content

Use [LLSegmentedControl](../../LeafLaunch/Components/Base/LLSegmentedControl.swift) where the feature has segmented selection. Its binding changes immediately and the control owns selected-fill animation. Apply [llBlurReplace(value:)](../../LeafLaunch/ViewModifiers/LLBlurReplaceModifier.swift) to the smallest content subtree whose result changes.

Keep scroll owners, ViewModels, tasks, subscriptions, focus, and editor values outside replacement identity. A plain form-value picker does not replace its form. Preserve a feature's existing transition geometry and timing when centralizing a repeated treatment; configurable animation is appropriate for a concrete current variation. Do not add an unused selector solely for consistency.

## Initial state and refresh

An unresolved request or permission check differs from unavailable, denied, or successfully empty content. Keep neutral/progress content on the first render, including before `.task` starts. Show resolved outcomes only after their owner completes. Retain content and successful empty results during refresh of the same context, including refresh failure. Preserve query, location, user, and generation guards when the context changes.

ViewModels with `loadData(showHud:)` expose read-only `isFirstLoad`. Lifecycle loads pass `loadData(showHud: self.viewModel.isFirstLoad)`; the default is `false`. A successful uncancelled load clears first-load state. Reappearance still refreshes at the existing time, with no modal HUD after initial success. Initial failure/cancellation leaves recovery available.

Suitable read-only fetch-backed screens pass async `onRefresh:` to [LLAppHeaderScrollView](../../LeafLaunch/Components/Base/LLAppHeaderScrollView.swift). Await the actual ViewModel work with `showHud: false`. Keep Menu's specialized refresh outcome feedback, one vertical scroll owner, and existing task cancellation. Do not refresh editors in a way that overwrites draft fields.
