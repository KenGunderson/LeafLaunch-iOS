# LeafLaunch customer app

This SwiftUI app serves customers of the business assigned to its Xcode target. Screens use structural wireframes to exercise navigation and state. Preserve those layouts when extending functionality.

Rune owns the active style. Built-in fallback tokens are defined in [LeafLaunchLightTheme](LeafLaunch/Services/DesignSystem/LeafLaunchLightTheme.swift), [LeafLaunchDarkTheme](LeafLaunch/Services/DesignSystem/LeafLaunchDarkTheme.swift), [LeafLaunchThemeTokens](LeafLaunch/Services/DesignSystem/LeafLaunchThemeTokens.swift), and [LeafLaunchFonts](LeafLaunch/Services/DesignSystem/LeafLaunchFonts.swift). Those files remain the canonical token sources.

API `StoreAppBranding` colors and available font families flow through [StoreThemeBuilder](LeafLaunch/Services/DesignSystem/StoreThemeBuilder.swift) into a Rune `Theme`. The Codable cache reconstructs that theme synchronously before root/splash creation. The same canonical branding schema supplies the seven supported Rune radius roles in logical points (0–100). Missing radius roles use LeafLaunchThemeTokens; spacing, shadows, and interaction tokens retain the built-in definitions. Cache schema 2 resolves the complete supported definition, while schema 1 migrates synchronously with existing radius defaults.

Customer screens use the environment style, semantic typography, native controls, `GroupBox` wireframes, and existing app/Rune components. Selection must be readable through text and control state. Avoid decorative motion, new palettes, fixed marketing layouts, and custom component systems. Product gallery media remains functional; placeholder boxes cover unavailable media.

Store Details uses JobLens iOS's `BubbleTabBarView` over a `TabView` with the system tab bar hidden. Preserve its 42pt top corners, secondary background, card shadow, accent/body selection colors, and selection keyframes. LeafLaunch supplies its own Store, Shop, Favorites, and Account titles and icons; badge counts remain zero. Keep the bar mounted in its keyboard-independent overlay and animate visibility through its vertical offset. Scroll content uses the shared `tabFlowContentSpacing()` modifier to stay above the overlay.

Native SwiftUI controls own focus, scrolling, safe-area behavior, accessibility, and dynamic sizing. English is the current application language; dates, currency, and numeric formatting follow Foundation and location currency/timezone metadata. See [UX-CONTRACT](UX-CONTRACT.md) for workflow ownership and recovery.
