# Implementation Best Practices

These conventions keep an app’s UI coherent while allowing Rune to remain a reusable foundation. Apply them to new work and use them when touching an existing screen.

## Prefer app-owned UI components

Screens should compose app-prefixed components rather than raw Rune `Common*` components whenever an app component exists or the screen needs app-specific visual behavior.

For example, a `JLButton` may define JobLens’s capsule shape, sizing, typography, and interaction defaults while using Rune’s `CommonButton` internally. The screen uses `JLButton`; the wrapper owns the Rune details.

- Keep Rune primitives inside the implementation of the app component.
- Create a small app-prefixed wrapper when a visual treatment is repeated or is part of the product design language.
- Give wrappers a focused API that expresses product intent instead of exposing every underlying Rune parameter.
- Raw Rune components are appropriate inside wrappers, or temporarily when no app-level abstraction exists. Promote repeated raw usage to an app component before it spreads through screens.

This keeps future design changes local and prevents `Common*` APIs from becoming the screen-level design system.

## Keep empty states at the screen root

Apply `emptyStateOverlay` to the `AppHeaderScrollView` chain, after the scroll view is constructed. Do not apply it inside the scrolling `content()` helper. The overlay must cover the full screen context, including the header, rather than only the scrollable region.

```swift
AppHeaderScrollView(
    navBarContent: {
        navigationBar()
    },
    scrollViewContent: {
        content()
    }
)
.emptyStateOverlay(
    shouldShow: self.viewModel.shouldShowEmptyState,
    config: self.emptyStateConfig
)
.onFirstAppear {
    self.viewModel?.setup(navigationService: self.navigationService)
}
```

Keep `content()` focused on the populated screen tree. It should not decide where an empty-state overlay is mounted.

When an empty state offers the primary creation action, do not also show a redundant create or invite button in the empty list. Show the standard list-level action only after the list has content.

```swift
if self.viewModel.hasContent {

    JLButton(style: .primary, title: "Create Project") {

        navigateToProjectEditor()

    }

}
```

## Model activity timelines explicitly

The activity card should receive whether it draws a trailing connector. Calculate that in the parent sequence so the last item never renders a line below itself.

```swift
ForEach(Array(self.viewModel.activities.enumerated()), id: \.element.id) { index, activity in

    JLProjectActivityCard(
        activity: activity,
        showsTimelineConnector: index < self.viewModel.activities.count - 1
    )

}
```

This keeps the card reusable and makes the sequence rule visible where the list is composed.

## Name logger identifiers consistently

Logger names use fully separated `SCREAMING_SNAKE_CASE`. Separate every lexical word, including compound type names.

```swift
internal let loggerName: String = "PROJECT_CHAT_VIEW_MODEL"
```

Avoid compressed names such as `PROJECTCHAT_VIEW_MODEL`; they make log filtering and ownership harder to read.

## Compose readable SwiftUI trees

- Break screen view trees into small, named subviews or helpers as soon as a section has its own responsibility.
- Preserve the project’s spacious formatting: use blank lines to separate meaningful view-building phases, closures, and control-flow bodies.
- Keep one-parameter setup calls on one line:

  ```swift
  self.viewModel?.setup(navigationService: self.navigationService)
  ```

- Do not use fixed minimum-height spacers such as `.frame(maxWidth: .infinity, minHeight: 360)` to manufacture layout. Let the screen’s scroll container, safe area, and content determine the available space.

These rules make screen structure easier to inspect, preserve product-level visual consistency, and keep design-system changes inexpensive.
