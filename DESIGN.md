---
version: alpha
omitted:
  - section: colors
    reason: Store branding and Rune runtime themes own color values.
  - section: typography
    reason: Rune font roles preserve each store's configured font family.
  - section: spacing
    reason: LeafLaunchThemeTokens and the environment Rune style own spacing.
  - section: rounded
    reason: Validated store radius definitions and Rune own radius values.
  - section: components
    reason: Native SwiftUI and Rune component contracts are documented below.
---

# LeafLaunch customer storefront

## Overview

LeafLaunch is a native SwiftUI commerce app for the business assigned to its target. The design makes products, real prices, saved favorites, and store information easy to browse. Its signature interaction is a horizontal category pill rail with a second subcategory rail that reveals or replaces through a blur transition.

The skin is a construction system, not a fixed brand. Each store owns its appearance through Rune. Preserve the store's configured colors, fonts, radius roles, logo, and existing theme persistence. Product familiarity and clear actions take priority over decorative layouts.

## Colors

Rune is the only runtime styling authority. Production views read `@Environment(\.style)`; semantic Rune color sources and modifiers resolve that same environment. Do not introduce feature palettes, literal colors, gradients, `Style.shared` reads, or a second theme engine. Pass the environment style explicitly when an API such as `source(style:)` or `resolvedColor(style:)` requires color resolution.

The mapping remains:

`StoreAppBranding -> validated cached definition / StoreThemeBuilder -> Rune Theme -> environment style -> shared components`

[LeafLaunchLightTheme](LeafLaunch/Services/DesignSystem/LeafLaunchLightTheme.swift), [LeafLaunchDarkTheme](LeafLaunch/Services/DesignSystem/LeafLaunchDarkTheme.swift), [LeafLaunchThemeTokens](LeafLaunch/Services/DesignSystem/LeafLaunchThemeTokens.swift), and [LeafLaunchFonts](LeafLaunch/Services/DesignSystem/LeafLaunchFonts.swift) remain canonical fallback sources. This document defines composition, without duplicating their values. Cached branding restores synchronously before splash creation; the supported remote radius and font contracts remain intact.

Use background.primary for the canvas, secondary for content surfaces, tertiary/quinary for media placeholders and quiet grouping, and border for outlines. Title/body roles carry content hierarchy. Foreground.primary pairs with text.button for filled selection and primary actions; accent/link, icon, and button roles stay independent. Semantic error and destructive roles retain their meaning. The same construction must work in light, dark, and store-defined themes.

## Typography

Use Rune `appFont(with:)` and the active store's font roles. Section titles use TITLE_6, screen headers use HEADER_3, product names use TITLE_3, and prices use TITLE_5. Supporting copy uses BODY_1/BODY_2 or NOTE_1. Do not set a new font family or fixed custom type scale in a feature.

Let descriptive text wrap naturally. Avoid fixed text heights and shrinking essential labels. Product grids become one column at accessibility Dynamic Type sizes. Native controls, semantic accessibility labels, header traits, and meaningful selection state remain available throughout.

## Layout

Compose screens from short, named view builders and focused feature components. Keep models and ViewModels in their established feature ownership. Use environment spacing tokens: medium for content padding, small/small2 for related content, and large/large2 between sections.

Shop and Favorites share a two-column, image-first product grid. Each card presents category, name, available minimum price, and a separate favorite action. Opening the card shows product details; the heart never opens the product. Do not add cart, checkout, stock claims, or fake discount information that the domain does not supply.

Product details give the gallery primary space, with paging and selectable thumbnails when multiple active images exist. Name, price, availability, variants, description, and attributes follow in small coherent sections. Only higher base prices represent a discount; identify a discounted variant when showing its savings.

Store overview shows the selected location, promotions with actual imagery and linked products, upcoming events with location schedules, and real contacts/hours. Account separates profile, membership balance, and activity. Location selection and age consent use the same surface hierarchy while retaining their existing navigation and consent behavior.

Store Details retains JobLens iOS's `BubbleTabBarView` over the root `TabView`, with one navigation stack per tab, the system bar hidden, 42pt top corners, and its existing keyboard-independent overlay. `tabFlowContentSpacing()` keeps content above that bar. Keep the Store, Shop, Favorites, and Account navigation labels and icons.

## Elevation & Depth

Use Rune `AppCardView` and existing theme shadow roles. `CommerceSurface` supplies the recurring padded surface, theme radius, and border. Image-led cards use unpadded `AppCardView` composition. Do not nest cards just to divide text; prefer spacing or a disclosure within the owning surface.

## Shapes

Surfaces and media use theme large radius, inputs use medium2, and primary actions retain LeafLaunchButton's theme medium radius. Categories and sort controls are capsules because they form scrolling selection rails. The tab bar keeps its documented shape. All other radius choices come from the active Rune theme.

## Components

| Responsibility | Owner |
| --- | --- |
| Primary actions | LeafLaunchButton using Rune CommonButton |
| Padded commerce surfaces | CommerceSurface using Rune AppCardView |
| Section title and optional supporting text | CommerceSectionHeader using SectionView |
| Contextual empty/error content | CommerceEmptyState; screen-wide overlays retain EmptyStateView |
| Catalog category selection | CatalogCategoryFilters and CatalogFilterPill |
| Product grid and cards | ProductGridView and ProductCardView |
| Price, media, and saved state | ProductPriceView, ProductImageView, and ProductFavoriteButton |
| Product gallery and details | ProductGalleryView, ProductDetailsSummaryView, ProductOptionsView, and ProductAttributesView |
| Promotions, events, and store details | Focused views under StoreDetails/Overview/Views |
| Profile, membership, and activity | Focused views under StoreDetails/Account/Views |
| Location selection and age consent | LocationSelectionCard and AgeVerificationConsentView |
| Launch identity | SplashScreenView and SplashBrandMarkView |

Native SwiftUI owns scrolling, focus, menus, pickers, disclosures, and safe areas. Rune `ImageSource` owns media loading and caching; product URLs come from the existing public media endpoint, not raw object keys. Keep loading, unavailable-media, empty, and failure/retry states truthful. Signed thumbnail requests are cancellable and cannot publish into a superseded catalog.

Apply `.animation(.bouncy, value:)` to meaningful selection, favorite feedback, disclosures, and splash entrance. Category changes replace the subcategory group with `.blurReplace`; changing the parent clears its selected child. Respect `accessibilityReduceMotion` by removing transforms and animated transitions. Do not add perpetual decorative animation or delays to the startup callback.

## Do's and Don'ts

- Keep store branding and all visual tokens in Rune; improve hierarchy through construction.
- Use actual model imagery, prices, schedules, availability, balances, and ledger strings.
- Give icon actions accessible names and at least 44pt touch targets.
- Keep search, filtering, server sorting, pagination, local favorites, legal copy, and lifecycle ownership consistent with [UX-CONTRACT](UX-CONTRACT.md).
- Check changed call sites and both app targets. Follow the repository's restriction on Xcode builds and tests.
